import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../tasks/domain/models/task_model.dart';
import '../../../tasks/presentation/providers/tasks_provider.dart';

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void update(String query) => state = query;
}
final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(() => SearchQueryNotifier());

final searchResultsProvider = Provider<List<TaskItem>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  final tasksAsync = ref.watch(tasksProvider);
  
  if (query.isEmpty) return [];
  
  final tasks = tasksAsync.value ?? [];
  return tasks.where((t) {
    final matchesTitle       = t.title.toLowerCase().contains(query);
    final matchesDescription = t.description != null && t.description!.toLowerCase().contains(query);
    final matchesCategory    = t.category != null && t.category!.name.toLowerCase().contains(query);
    final matchesPriority    = t.priority.name.toLowerCase().contains(query);
    return matchesTitle || matchesDescription || matchesCategory || matchesPriority;
  }).toList();
});

class RecentSearchesNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];

  void addSearch(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    final updated = [q, ...state.where((s) => s != q)].take(8).toList();
    state = updated;
  }

  void remove(String query) {
    state = state.where((s) => s != query).toList();
  }

  void clear() => state = [];
}
final recentSearchesProvider = NotifierProvider<RecentSearchesNotifier, List<String>>(() => RecentSearchesNotifier());
