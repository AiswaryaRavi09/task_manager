import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/tasks.dart';
import '../services/tasks_services.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;
  final VoidCallback? onTaskUpdated;


  EditTaskScreen({required this.task, this.onTaskUpdated});

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final TaskService _taskService = TaskService();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _duedateController;
  String _priority = "Medium";
  String _status = "Pending";

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(text: widget.task.description);
    _duedateController = TextEditingController(text: widget.task.dueDate?.toString() ?? "");
    _priority = widget.task.priority;
    _status = widget.task.status;
  }

  Future<void> _selectDueDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(widget.task.dueDate as String),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _duedateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _updateTask() async {
    String formattedDate = DateTime.parse(_duedateController.text).toIso8601String();
    print("📝 Updating task..."); // Debugging statement
    try {
      await _taskService.updateTask(
        widget.task.id,
        _titleController.text,
        _descController.text,
        formattedDate, // ✅ Correct format
        _priority,
        _status,
      );


      print("✅ Task updated successfully!"); // Debugging statement
      widget.onTaskUpdated?.call();
      Navigator.pop(context, true);
    } catch (e) {
      print("🔥 Error updating task: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Task",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Title",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.black),
                ),),
            ),
            SizedBox(height: 10,),
            TextField(
              controller: _descController,
              decoration: InputDecoration(labelText: "Description",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.black),
                ),),
            ),
            SizedBox(height: 10,),

            TextField(
              controller: _duedateController,
              decoration: InputDecoration(
                labelText: "Due Date",
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDueDate(context),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              readOnly: true,
            ),
            SizedBox(height: 20,),

            DropdownButtonFormField<String>(
              value: _priority,
              onChanged: (value) => setState(() => _priority = value!),
              items: ["Low", "Medium", "High"]
                  .map((priority) => DropdownMenuItem(value: priority, child: Text(priority)))
                  .toList(),
              decoration: InputDecoration(labelText: "Priority", border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.black),
              ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.black),
                ),),
            ),
            SizedBox(height: 20,),

            DropdownButtonFormField<String>(
              value: _status,
              onChanged: (value) => setState(() => _status = value!),
              items: ["Pending", "In Progress", "Completed"]
                  .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                  .toList(),
              decoration: InputDecoration(labelText: "Status", border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.black),
              ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.black),
                ),),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateTask,
              child: Text("Update Task"),
            ),
          ],
        ),
      ),
    );
  }
}
