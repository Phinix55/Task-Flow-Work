import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/task_model.dart';
import '../../data/task_repository.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/services/notification_service.dart';
import 'filter_provider.dart';

// ──────────────────────────────────────────────────────────────────────────────
// INFRASTRUCTURE
// ──────────────────────────────────────────────────────────────────────────────

final taskRepositoryProvider = Provider<TaskRepository>((ref) => TaskRepository());

// Categories stream — rarely changes, just stream as before
final taskCategoriesProvider = StreamProvider<List<TaskCategory>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(taskRepositoryProvider).getCategoriesStream(user.id);
});

// ──────────────────────────────────────────────────────────────────────────────
// OPTIMISTIC IN-MEMORY CACHE NOTIFIER
// ──────────────────────────────────────────────────────────────────────────────
//
// Architecture (MNC-Level):
//   1. On first load: populate from Supabase realtime stream → seed local cache.
//   2. Every write (add/update/delete/toggle) → mutate local cache first (instant UI),
//      then fire the DB call in the background.
//   3. Supabase realtime pushes silently reconcile the local cache without jitter.
//   4. On network failure: rollback to previous state + show error.
//
// Result: Zero perceived latency for every user-initiated action.
// ──────────────────────────────────────────────────────────────────────────────

class TaskCacheNotifier extends AsyncNotifier<List<TaskItem>> {
  final _uuid = const Uuid();
  StreamSubscription<List<TaskItem>>? _subscription;

  @override
  Future<List<TaskItem>> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return [];

    ref.onDispose(() => _subscription?.cancel());

    final categories = ref.watch(taskCategoriesProvider).value ?? [];
    final repository = ref.watch(taskRepositoryProvider);

    // Seed from remote on first build
    final initial = await repository.fetchTasks(user.id);
    final seeded = _attachCategories(initial, categories);

    // Subscribe to realtime changes and silently reconcile
    _subscription?.cancel();
    _subscription = repository.getTasksStream(user.id).listen((remoteTasks) {
      final cats = ref.read(taskCategoriesProvider).value ?? [];
      final reconciled = _attachCategories(remoteTasks, cats);
      // Only update state if it actually changed content (prevents jitter)
      final current = state.value;
      if (current == null || !_listsIdentical(current, reconciled)) {
        state = AsyncData(reconciled);
      }
    });

    return seeded;
  }

  // ── Private Helpers ─────────────────────────────────────────────────────────

  List<TaskItem> _attachCategories(List<TaskItem> tasks, List<TaskCategory> categories) {
    return tasks.map((task) {
      if (task.categoryId != null) {
        final cat = categories.where((c) => c.id == task.categoryId).firstOrNull;
        return task.copyWith(category: cat);
      }
      return task;
    }).toList();
  }

  bool _listsIdentical(List<TaskItem> a, List<TaskItem> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id || a[i].isCompleted != b[i].isCompleted || a[i].updatedAt != b[i].updatedAt) {
        return false;
      }
    }
    return true;
  }

  List<TaskItem> get _current => state.value ?? [];

  // ── Optimistic Mutations ────────────────────────────────────────────────────

  /// ADD — instantly shows the new task, persists in background.
  Future<void> addTask(TaskItem task) async {
    final optimisticId = task.id.isEmpty ? _uuid.v4() : task.id;
    final newTask = task.copyWith(id: optimisticId);

    // 1. Instant UI
    state = AsyncData([newTask, ..._current]);

    // 2. Background persist + notification
    try {
      await ref.read(taskRepositoryProvider).addTask(newTask);
      // Schedule reminder if task has a due date
      unawaited(NotificationService().scheduleTaskReminder(newTask));
    } catch (e) {
      // 3. Rollback
      state = AsyncData(_current.where((t) => t.id != optimisticId).toList());
      rethrow;
    }
  }

  /// UPDATE — instantly reflects edits, persists in background.
  Future<void> updateTask(TaskItem task) async {
    final previous = _current;
    
    // 1. Instant UI
    state = AsyncData(_current.map((t) => t.id == task.id ? task : t).toList());

    // 2. Background persist + reschedule notification
    try {
      await ref.read(taskRepositoryProvider).updateTask(task);
      // Re-schedule reminder with updated due date
      unawaited(NotificationService().cancelTaskReminder(task.id));
      unawaited(NotificationService().scheduleTaskReminder(task));
    } catch (e) {
      // 3. Rollback
      state = AsyncData(previous);
      rethrow;
    }
  }

  /// TOGGLE COMPLETE — the hottest path, must feel instant.
  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    final previous = _current;

    // 1. Instant UI
    state = AsyncData(_current.map((t) {
      if (t.id != taskId) return t;
      return t.copyWith(
        isCompleted: isCompleted,
        completedAt: isCompleted ? DateTime.now() : null,
      );
    }).toList());

    // 2. Background persist + cancel reminder when completed
    try {
      await ref.read(taskRepositoryProvider).toggleTaskCompletion(taskId, isCompleted);
      if (isCompleted) unawaited(NotificationService().cancelTaskReminder(taskId));
    } catch (e) {
      // 3. Rollback
      state = AsyncData(previous);
      rethrow;
    }
  }

  /// DELETE — instantly removes from list, persists in background.
  Future<void> deleteTask(String taskId) async {
    final previous = _current;

    // 1. Instant UI
    state = AsyncData(_current.where((t) => t.id != taskId).toList());

    // 2. Background persist + cancel any scheduled reminder
    try {
      await ref.read(taskRepositoryProvider).deleteTask(taskId);
      unawaited(NotificationService().cancelTaskReminder(taskId));
    } catch (e) {
      // 3. Rollback
      state = AsyncData(previous);
      rethrow;
    }
  }
}

/// The single source of truth for all task data in the app.
final tasksProvider = AsyncNotifierProvider<TaskCacheNotifier, List<TaskItem>>(
  TaskCacheNotifier.new,
);

// ──────────────────────────────────────────────────────────────────────────────
// CONVENIENCE ACTION WRAPPER (replaces old taskActionsProvider)
// ──────────────────────────────────────────────────────────────────────────────
//
// Screens call `ref.read(taskActionsProvider).addTask(...)` — identical API,
// but now it routes through the cache notifier for instant updates.
//

final taskActionsProvider = Provider<_TaskActions>((ref) => _TaskActions(ref));

class _TaskActions {
  final Ref _ref;
  _TaskActions(this._ref);

  Future<void> addTask(TaskItem task) => _ref.read(tasksProvider.notifier).addTask(task);
  Future<void> updateTask(TaskItem task) => _ref.read(tasksProvider.notifier).updateTask(task);
  Future<void> deleteTask(String id) => _ref.read(tasksProvider.notifier).deleteTask(id);
  Future<void> toggleTaskCompletion(String id, bool isCompleted) =>
      _ref.read(tasksProvider.notifier).toggleTaskCompletion(id, isCompleted);
}

// ──────────────────────────────────────────────────────────────────────────────
// DERIVED STATE PROVIDERS
// ──────────────────────────────────────────────────────────────────────────────

final selectedDateProvider = NotifierProvider<SelectedDateNotifier, DateTime>(
  SelectedDateNotifier.new,
);

class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
  void setDate(DateTime date) => state = date;
}

/// Filters the cached task list for the selected day + active filters.
final dailyTasksProvider = Provider<List<TaskItem>>((ref) {
  final tasksAsync = ref.watch(tasksProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  final filters = ref.watch(filterProvider);

  final tasks = tasksAsync.value ?? [];

  return tasks.where((task) {
    // Scheduling filter
    if (task.dueDate == null) {
      // Anytime tasks → only show on Today's view
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      if (!selectedDate.isAtSameMomentAs(today)) {
        return false;
      }
    } else {
      final due = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
      if (!due.isAtSameMomentAs(selectedDate)) return false;
    }

    // Status filter
    if (filters.status == 'pending' && task.isCompleted) return false;
    if (filters.status == 'completed' && !task.isCompleted) return false;
    if (filters.status == 'overdue') {
      if (task.isCompleted || task.dueDate == null || !task.dueDate!.isBefore(DateTime.now())) return false;
    }

    // Priority filter
    if (filters.priorities.isNotEmpty && !filters.priorities.contains(task.priority)) return false;

    // Category filter
    if (filters.categoryIds.isNotEmpty &&
        (task.category == null || !filters.categoryIds.contains(task.category!.name))) return false;

    return true;
  }).toList();
});

/// Daily progress percentage.
final dailyProgressProvider = Provider<double>((ref) {
  final tasks = ref.watch(dailyTasksProvider);
  if (tasks.isEmpty) return 0.0;
  return tasks.where((t) => t.isCompleted).length / tasks.length;
});
