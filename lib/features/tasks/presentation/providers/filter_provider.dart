import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/task_model.dart';

class TaskFilters {
  final List<TaskPriority> priorities;
  final List<String> categoryIds;
  final String status; // 'all', 'pending', 'completed', 'overdue'

  TaskFilters({
    this.priorities = const [],
    this.categoryIds = const [],
    this.status = 'all',
  });

  TaskFilters copyWith({
    List<TaskPriority>? priorities,
    List<String>? categoryIds,
    String? status,
  }) {
    return TaskFilters(
      priorities: priorities ?? this.priorities,
      categoryIds: categoryIds ?? this.categoryIds,
      status: status ?? this.status,
    );
  }

  bool get isEmpty => priorities.isEmpty && categoryIds.isEmpty && status == 'all';
}

class FilterNotifier extends Notifier<TaskFilters> {
  @override
  TaskFilters build() => TaskFilters();

  void togglePriority(TaskPriority p) {
    if (state.priorities.contains(p)) {
      state = state.copyWith(priorities: state.priorities.where((e) => e != p).toList());
    } else {
      state = state.copyWith(priorities: [...state.priorities, p]);
    }
  }

  void toggleCategory(String catId) {
    if (state.categoryIds.contains(catId)) {
      state = state.copyWith(categoryIds: state.categoryIds.where((e) => e != catId).toList());
    } else {
      state = state.copyWith(categoryIds: [...state.categoryIds, catId]);
    }
  }

  void setStatus(String s) {
    state = state.copyWith(status: s);
  }

  void clearAll() {
    state = TaskFilters();
  }
}

final filterProvider = NotifierProvider<FilterNotifier, TaskFilters>(() => FilterNotifier());
