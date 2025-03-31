import 'package:flutter/material.dart';
import '../models/tasks.dart';
import '../services/tasks_services.dart';

class CompletedTaskScreen extends StatefulWidget {
  @override
  _CompletedTaskScreenState createState() => _CompletedTaskScreenState();
}

class _CompletedTaskScreenState extends State<CompletedTaskScreen> {
  final TaskService _taskService = TaskService();
  List<Task> _completedTasks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCompletedTasks();
  }

  Future<void> _fetchCompletedTasks() async {
    setState(() => _isLoading = true);
    try {
      List<Task> tasks = await _taskService.fetchCompletedTasks();
      setState(() {
        _completedTasks = tasks;
      });
    } catch (e) {
      print("🔥 Error fetching completed tasks: $e");
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Completed Tasks",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),)),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _completedTasks.isEmpty
          ? Center(child: Text("No completed tasks yet!"))
          : RefreshIndicator(
        onRefresh: _fetchCompletedTasks,
        child: ListView.builder(
          itemCount: _completedTasks.length,
          itemBuilder: (context, index) {
            final task = _completedTasks[index];
            return Card(
              elevation: 10,
              shadowColor: Colors.indigo,
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: ListTile(
                title: Text(task.title, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Status: ${task.status}"),
              ),
            );
          },
        ),
      ),
    );
  }
}
