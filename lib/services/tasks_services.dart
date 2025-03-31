import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_manager_app/screens/task_list_screen.dart';
import 'package:uuid/uuid.dart';
import '../models/tasks.dart';
import 'package:http/http.dart' as http;

import '../screens/task_list_screen.dart';

class TaskService {
  final supabase = Supabase.instance.client;

  Future<void> createTask(String title, String description,String dueDate,String priority, String status) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      print("❌ User not authenticated");
      throw Exception("User not authenticated");
    }

    final task = {
      'id': const Uuid().v4(),
      'user_id': user.id,
      'title': title,
      'description': description,
      'due_date': dueDate,
      'priority': priority,
      'status': status,
      'created_at': DateTime.now().toIso8601String(),
    };

    print("📤 Sending Task Data: $task");

    final response = await Supabase.instance.client.from('tasks').insert(task).select();

    print("🟢 Full Response: $response");

    if (response == null) {
      print("🔥 Error: Response is null");
      throw Exception("Failed to create task: No response from Supabase");
    }

    if (response.isEmpty) {
      print("🔥 Error: Insert failed, response is empty.");
      throw Exception("Failed to create task: Empty response.");
    } else {
      print("✅ Task created successfully: $response");

    }

  }

  Future<List<Task>> fetchCompletedTasks() async {
    final response = await Supabase.instance.client
        .from('tasks')
        .select()
        .eq('status', 'Completed');  // ✅ Ensure filtering works

    print("🔍 Supabase response: $response"); // ✅ Debugging: Check fetched tasks
    return response.map((task) => Task.fromJson(task)).toList();
  }

  Future<List<Task>> fetchTasks(int page, int limit) async {
    try {
      final List<Map<String, dynamic>> response = await supabase
          .from('tasks')
          .select('*')
          .order('due_date', ascending: true)
          .range(page * limit, (page + 1) * limit - 1);

      return response.map((task) => Task.fromJson(task)).toList();
    } catch (e) {
      throw Exception("Failed to fetch tasks: $e");
    }
  }

  Future<void> updateTask(
      String taskId,
      String title,
      String description,
      String dueDate,
      String priority,
      String status,
      ) async {
    try {
      print("🔍 Updating Task ID: $taskId");

      final response = await Supabase.instance.client
          .from('tasks')
          .update({
        'title': title,
        'description': description,
        'due_date': dueDate,
        'priority': priority,
        'status': status,
      })
          .eq('id', taskId)
          .select(); // ✅ Ensure response is returned

      print("✅ Update response: $response");

      if (response == null || response.isEmpty) {
        throw Exception("Failed to update task: No response from Supabase");
      }
    } catch (e) {
      print("🔥 Error updating task: $e");
      throw e;
    }
  }




  final SupabaseClient _client = Supabase.instance.client;

  Future<void> deleteTask(String taskId) async {
    try {
      print("🛑 Checking if Task ID: $taskId exists...");

      // Step 1: Check if the task exists
      final existingTask = await _client
          .from('tasks')
          .select()
          .eq('id', taskId)
          .maybeSingle(); // ✅ Returns `null` if task doesn't exist

      if (existingTask == null) {
        throw Exception("Task not found or already deleted");
      }

      print("🟢 Task found: $existingTask");

      // Step 2: Attempt to delete (Without `.select()`)
      final response = await _client
          .from('tasks')
          .delete()
          .eq('id', taskId); // ✅ Remove `.select()`

      print("🟡 Supabase Delete Response: $response");

      print("✅ Task deleted successfully");
    } catch (e) {
      print("🔥 Supabase Delete Error: $e");
      throw Exception("Failed to delete task");
    }
  }
}
