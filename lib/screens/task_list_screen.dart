import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_manager_app/screens/view_task_screen.dart';
import '../login_screen/view/login_screen_view.dart';
import '../models/tasks.dart';
import '../services/tasks_services.dart';
import 'edit_task_screen.dart';

class TaskListScreen extends StatefulWidget {
  static const routeName = "/task-list";

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TaskService _taskService = TaskService();
  final SupabaseClient _client = Supabase.instance.client;

  List<Task> _tasks = [];
  List<Task> _filteredTasks = []; // Tasks filtered by search query
  int _page = 0;
  final int _limit = 10;
  bool _isLoading = false;
  bool _hasMoreData = true;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedFilter;
  String? _selectedPriority;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
    _searchController.addListener(_filterTasks);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 🚀 Fetch paginated tasks from Supabase
  Future<void> _fetchTasks({bool isRefresh = false}) async {
    if (_isLoading || (!_hasMoreData && !isRefresh)) return;

    setState(() {
      _isLoading = true;
      if (isRefresh) {
        _tasks.clear();
        _page = 0;
        _hasMoreData = true;
      }
    });

    try {
      List<Task> tasks = await _taskService.fetchTasks(_page, _limit);
      setState(() {
        if (tasks.length < _limit) _hasMoreData = false;
        _tasks.addAll(tasks);
        _applyFilters();
        _isLoading = false;
        _page++;
      });
    } catch (e) {
      print("🔥 Error fetching tasks: $e");
      setState(() => _isLoading = false);
    }
  }

  /// Filters tasks based on the search query
  void _filterTasks() {
    _applyFilters();
  }

  /// Apply search and filter conditions together
  void _applyFilters() {
    setState(() {
      _filteredTasks = _tasks.where((task) {
        bool matchesSearch = task.title.toLowerCase().contains(_searchController.text.toLowerCase());
        bool matchesStatus = _selectedFilter == null || task.status == _selectedFilter;
        bool matchesPriority = _selectedPriority == null || task.priority == _selectedPriority;
        return matchesSearch && matchesStatus && matchesPriority;
      }).toList();
    });
  }


  List<Task> _applySearchFilter(List<Task> tasks, String query) {
    if (query.isEmpty) {
      return tasks;
    } else {
      return tasks
          .where((task) =>
          task.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  Future<void> _logout() async {
    try {
      await _client.auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()), // Redirect to login
      );
    } catch (e) {
      print("🔥 Error logging out: $e");
    }
  }

  /// 🗑 Delete Task Function
  Future<void> _deleteTask(String taskId) async {
    try {
      await _taskService.deleteTask(taskId);
      setState(() {
        _tasks.removeWhere((task) => task.id == taskId);
        _filteredTasks = _applySearchFilter(_tasks, _searchController.text);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Task deleted")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("🔥 Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Task Lists", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _tasks.clear();
            _page = 0;
            _hasMoreData = true;
          });
          await _fetchTasks();
        },
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search by title...",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.filter_list, color: Colors.black),
                    onSelected: (String? value) {
                      setState(() {
                        _selectedFilter = value == "" ? null : value; // Reset to show all if "All" is selected
                        _applyFilters();
                      });
                    },

                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(value: "", child: Text("All")),
                      PopupMenuItem(value: "Pending", child: Text("Pending")),
                      PopupMenuItem(value: "Completed", child: Text("Completed")),
                    ],
                  ),
                  SizedBox(width: 10),

                  // Priority Filter
                  PopupMenuButton<String>(
                    icon: Icon(Icons.filter_list, color: Colors.black),
                    onSelected: (String? value) {
                      setState(() {
                        _selectedPriority = value == "" ? null : value;
                        _applyFilters();
                      });
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(value: "", child: Text("All Priorities")),
                      PopupMenuItem(value: "High", child: Text("High Priority")),
                      PopupMenuItem(value: "Medium", child: Text("Medium Priority")),
                      PopupMenuItem(value: "Low", child: Text("Low Priority")),
                    ],
                  ),
                ],
              ),
            ),

            // Expanded list view
            Expanded(
              child: ListView.builder(
                itemCount: _filteredTasks.length + 1,
                itemBuilder: (context, index) {
                  if (index < _filteredTasks.length) {
                    final task = _filteredTasks[index];
                    return Card(
                      elevation: 10,
                      shadowColor: Colors.indigo,
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(task.title, style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(task.status),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove_red_eye, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ViewTaskScreen(task: task)),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(IconlyBold.edit, color: Colors.black),
                              onPressed: () async {
                                bool? result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditTaskScreen(
                                      task: task,
                                      onTaskUpdated: _fetchTasks,
                                    ),
                                  ),
                                );
                                if (result == true) _fetchTasks();
                              },
                            ),
                            IconButton(
                              icon: Icon(IconlyLight.delete, color: Colors.red),
                              onPressed: () => _deleteTask(task.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (_isLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (_hasMoreData) {
                    return Center(
                      child: ElevatedButton(
                        onPressed: _fetchTasks,
                        child: Text("Load More"),
                      ),
                    );
                  } else {
                    return SizedBox(); // No more data
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
