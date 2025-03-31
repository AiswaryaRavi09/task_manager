import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/tasks.dart';

class ViewTaskScreen extends StatelessWidget {
  final Task task;

  ViewTaskScreen({required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("View Task")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📌 Title:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(task.title, style: TextStyle(fontSize: 18)),

            SizedBox(height: 10),
            Text("📝 Description:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(task.description),

            SizedBox(height: 10),
            Text("📅 Due Date:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(DateFormat('yyyy-MM-dd').format(task.dueDate as DateTime)),

            SizedBox(height: 10),
            Text("⚡ Priority:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(task.priority),

            SizedBox(height: 10),
            Text("📌 Status:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(task.status),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Back"),
            ),
          ],
        ),
      ),
    );
  }
}
