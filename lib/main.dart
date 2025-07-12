import 'package:flutter/material.dart';
import 'signup_page.dart';
import 'about_page.dart';
import 'login.dart';
import 'create_new_hall.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hall Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(), // Use LoginPage from login.dart
        '/about': (context) => const AboutUsPage(),
        '/create_hall': (_) => const CreateHallPage(),
        '/signup': (context) => const SignUpPage(),

      },
    );

  }
}
