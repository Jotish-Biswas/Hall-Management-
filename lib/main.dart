import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'student_home.dart';
import 'teacher_home.dart';
import 'shopkeeper_home.dart';
import 'Admin_home.dart';
import 'create_new_hall.dart';
import 'signup_page.dart';
import 'about_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _defaultHome = const LoginPage();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final role = prefs.getString('role');
    final name = prefs.getString('name');
    final hallName = prefs.getString('hall_name');

    if (email != null && role != null && name != null && hallName != null) {
      switch (role) {
        case 'Student':
          _defaultHome = StudentHomePage(name: name, email: email, hallname: hallName);
          break;
        case 'Teacher':
          _defaultHome = TeacherHomepage(name: name, email: email, hallname: hallName);
          break;
        case 'Shopkeeper':
          _defaultHome = ShopkeeperHomePage(name: name, email: email, hallname: hallName);
          break;
        case 'Admin':
          _defaultHome = AdminHomePage(name: name, email: email, hallname: hallName);
          break;
      }
    }

    setState(() {}); // Rebuild with updated default page
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hall Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: _defaultHome,
      routes: {
        '/signup': (_) => const SignUpPage(),
        '/create_hall': (_) => const CreateHallPage(),
        '/about': (_) => const AboutUsPage(),
      },
    );
  }
}
