
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_manager_app/screens/task_list_screen.dart';
import 'package:task_manager_app/services/tasks_services.dart';

class CreateTaskScreen extends StatefulWidget {
  @override
  _CreateTaskScreenState createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final TaskService _taskService = TaskService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _duedateController = TextEditingController();
  String _selectedPriority = "Medium";
  String _selectedStatus = "Pending";
  List<Color> _gradientColors = [Colors.indigo, Colors.indigo.shade400];
  int _gradientIndex = 0;
  Timer? _gradientTimer;

  @override
  void initState() {
    super.initState();
    _duedateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _startButtonAnimation();

  }
  void _startButtonAnimation() {
    _gradientTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      setState(() {
        // Alternate gradient colors for animation effect
        if (_gradientIndex == 0) {
          _gradientColors = [Colors.indigo, Colors.indigo.shade400];
        } else {
          _gradientColors = [Colors.indigo.shade400, Colors.indigo];
        }
        _gradientIndex = (_gradientIndex + 1) % 2;
      });
    });
  }

  @override
  void dispose() {
    _gradientTimer?.cancel();
    _titleController.dispose();
    _descController.dispose();
    _duedateController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _duedateController.text = DateFormat('yyyy-MM-dd').format(pickedDate); // ✅ Update UI
      });
    }
  }

  Future<void> _saveTask() async {
    if (_titleController.text.isEmpty || _descController.text.isEmpty || _duedateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Please enter all fields")),
      );
      return;
    }

    try {
      await _taskService.createTask(
        _titleController.text,
        _descController.text,
        _duedateController.text,
        _selectedPriority,
        _selectedStatus,
      );
      Navigator.of(context).pushReplacementNamed(TaskListScreen.routeName);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("🔥 Error: ${e.toString()}")),
      );
      print("🔥 Error: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Task",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Title",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _descController,
              decoration: InputDecoration(labelText: "Description",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.black),
            ),
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _duedateController,
              decoration: InputDecoration(
                labelText: "Due Date",
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDueDate(context), // ✅ Open Date Picker
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
            SizedBox(height: 20),
            // Priority Dropdown
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              items: ["Low", "Medium", "High"].map((String priority) {
                return DropdownMenuItem<String>(
                  value: priority,
                  child: Text(priority),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedPriority = newValue!;
                });
              },
              decoration: InputDecoration(labelText: "Priority",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.black),
                ),              ),
            ),
            SizedBox(height: 20),

            // Status Dropdown
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              items: ["Pending", "In Progress", "Completed"].map((String status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedStatus = newValue!;
                });
              },
              decoration: InputDecoration(labelText: "Status",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),),
            SizedBox(height: 50),
            AnimatedContainer(
              duration: Duration(seconds: 2),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent, // Transparent so gradient shows
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text("Save Task", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
