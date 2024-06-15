import 'package:flutter/material.dart';
import 'package:taskflow/screen/developer_home_screen.dart';
import 'package:taskflow/screen/developer_task_screen.dart';
import 'package:taskflow/screen/login_screen.dart';
import 'package:taskflow/screen/manager_detail_screen.dart';
import 'package:taskflow/screen/manager_home_screen.dart';
import 'package:taskflow/screen/manager_task_screen.dart';
import 'package:taskflow/screen/register_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register':(context) => const RegisterPage(),
        '/dev-home':(context) => const DeveloperHomeScreen(),
        '/manager-home':(context) => const ManagerHomeScreen(),
        '/dev-task':(context) => const DeveloperTaskScreen(),
        '/manager-task':(context) => const ManagerTaskScreen(),
        '/manager-detail': (context) => const ManagerDetailScreen(),
      },
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF42a77e)),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}