import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_model.dart';

class TaskRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Task>> fetchTasks() async {
    final response = await _client
        .from('tasks')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => Task.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addTask(Task task) async {
    await _client.from('tasks').insert(task.toJson());
  }

  Future<void> updateTask(int id, Map<String, dynamic> data) async {
    await _client.from('tasks').update(data).eq('id', id);
  }

  Future<void> deleteTask(int id) async {
    await _client.from('tasks').delete().eq('id', id);
  }
}