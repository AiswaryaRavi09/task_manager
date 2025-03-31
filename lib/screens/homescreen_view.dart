import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import '../login_screen/view/login_screen_view.dart';
import 'completed_task_screen.dart';
import 'create_tasks_screen.dart';
import 'task_list_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // List of screens for each tab
  final List<Widget> _screens = [
    TaskListScreen(),
    CreateTaskScreen(),
    CompletedTaskScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  void _checkUser() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        }
      });
    }
  }

  // Logout function example (if needed)
  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      // Using CurvedNavigationBar for a curved bottom nav bar with animations.
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: Colors.indigo, // Bar color
        buttonBackgroundColor: Colors.indigo.shade700, // Color for selected button background
        height: 60,
        index: _selectedIndex,
        items: <Widget>[
          Icon(Icons.list, size: 30, color: Colors.white),
          Icon(Icons.add, size: 30, color: Colors.white),
          Icon(Icons.check_box, size: 30, color: Colors.white),
        ],
        animationDuration: Duration(milliseconds: 300),
        animationCurve: Curves.easeInOut,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
