import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_manager_app/login_screen/auth_providers.dart';
import 'package:task_manager_app/login_screen/view/login_screen_view.dart';
import 'package:task_manager_app/screens/homescreen_view.dart';
import 'package:task_manager_app/screens/task_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://lyxpflunyvqossuhrezm.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx5eHBmbHVueXZxb3NzdWhyZXptIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDMxNzUxNzUsImV4cCI6MjA1ODc1MTE3NX0.zAUg0W_S-i5qHHdGMpi205qXURDvEGmUUesg66W8qnk',
  );

  print("🟢 Supabase Initialized Successfully");

  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  ChangeNotifierProvider(
      create: (_) => AuthNotifier(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        initialRoute: '/',
        routes: {
          '/': (context) => AuthWrapper(),
          '/home': (context) => HomeScreen(),
          TaskListScreen.routeName: (context) => TaskListScreen(),

        },
      ),
    );
  }
}
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return user == null ? LoginScreen() : HomeScreen();
  }
}
