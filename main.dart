import 'package:flutter/material.dart';
import 'signup_page.dart';
import 'about_page.dart';
import 'welcome_page.dart';
import 'login.dart'; // Import the login page

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
        '/signup': (context) => const SignUpPage(),
      },
      // Handle routes that need arguments
      onGenerateRoute: (settings) {
        if (settings.name == '/welcome') {
          final args = settings.arguments as UserDetails;
          return MaterialPageRoute(
            builder: (context) => WelcomePage(userDetails: args),
          );
        }
        return null; // Unknown route
      },
    );
  }
}
