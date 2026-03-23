import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/task_model.dart';

class TaskRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // Real-time stream of User's Categories
  Stream<List<TaskCategory>> getCategoriesStream(String userId) {
    return _client
        .from('task_categories')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at')
        .map((data) => data.map((e) => TaskCategory.fromJson(e)).toList());
  }

  // Real-time stream of User's Tasks with their Category attached
  Stream<List<TaskItem>> getTasksStream(String userId) {
    // Supabase streams don't support foreign key joins (.select) natively yet in the same way,
    // so we stream tasks, but when we consume in the provider we can parse them.
    // Wait, Supabase Flutter .stream() DOES NOT support joining directly. 
    // We will handle the join in the Riverpod provider by combining the two streams.
    return _client
        .from('tasks')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('sort_order', ascending: true)
        .order('created_at', ascending: false)
        .map((data) => data.map((e) => TaskItem.fromJson(e)).toList());
  }

  /// One-shot fetch used to seed the in-memory cache on first build.
  Future<List<TaskItem>> fetchTasks(String userId) async {
    final data = await _client
        .from('tasks')
        .select()
        .eq('user_id', userId)
        .order('sort_order', ascending: true)
        .order('created_at', ascending: false);
    return (data as List).map((e) => TaskItem.fromJson(e)).toList();
  }

  Future<void> addTask(TaskItem task) async {
    await _client.from('tasks').insert(task.toJson());
  }

  Future<void> updateTask(TaskItem task) async {
    await _client.from('tasks').update(task.toJson()).eq('id', task.id);
  }

  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    await _client.from('tasks').update({
      'is_completed': isCompleted,
      // completed_at is handled automatically by the Supabase SQL trigger we set up!
    }).eq('id', taskId);
  }

  Future<void> deleteTask(String taskId) async {
    await _client.from('tasks').delete().eq('id', taskId);
  }

  Future<void> updateSortOrder(List<TaskItem> tasks) async {
    // Batch update sort orders
    // We can use an RPC or upsert to patch multiple rows.
    for (var t in tasks) {
       await _client.from('tasks').update({'sort_order': t.sortOrder}).eq('id', t.id);
    }
  }
}
