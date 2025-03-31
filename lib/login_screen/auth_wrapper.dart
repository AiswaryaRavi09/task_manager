import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/screens/homescreen_view.dart';
import 'package:task_manager_app/login_screen/view/login_screen_view.dart';

import 'auth_providers.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthNotifier>();

    // Show loading indicator while checking auth state
    if (authState.loading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Debug info
    print('AuthWrapper build: isAuthenticated = ${authState.isAuthenticated}');
    print('Current user: ${authState.user?.email}');

    // Redirect based on auth state
    if (authState.isAuthenticated) {
      return HomeScreen();
    } else {
      return LoginScreen();
    }
  }
}