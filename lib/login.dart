import 'package:flutter/material.dart';
import 'student_home.dart';
import 'teacher_home.dart';
import 'shopkeeper_home.dart';
import 'Admin_home.dart';
import 'waiting_approval_page.dart'; // Page for unapproved teachers
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String selectedRole = 'Student';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hall Management',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.blue),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Role Selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8FFE8),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['Student', 'Teacher', 'Shopkeeper', 'Admin'].map((role) {
                  bool isSelected = role == selectedRole;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selectedRole = role),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          role,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Email & Password Fields
            _buildTextField('Email or Username', emailController),
            _buildTextField('Password', passwordController, obscureText: true),
            const SizedBox(height: 20),

            // Login Button
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text('Login', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),

            const SizedBox(height: 20),

            // Sign Up & Forgot Password
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  child: const Text('Sign Up', style: TextStyle(color: Colors.blue)),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                  ),
                  child: const Text('Forgot Password?', style: TextStyle(color: Colors.blue)),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/about'),
                  child: const Text('About Us', style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          border: const UnderlineInputBorder(),
        ),
      ),
    );
  }

  void _login() async {
    String email = emailController.text.trim();
    String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please fill in both fields.');
      return;
    }

    final url = Uri.parse("http://127.0.0.1:8000/login");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
          "role": selectedRole,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String name = data["name"];

        // Handle role-based redirection
        if (selectedRole == 'Student') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => StudentHomePage(name: name, email: email)));
        } else if (selectedRole == 'Teacher') {
          if (data.containsKey("approved") && data["approved"] == false) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => WaitingApprovalPage(name: name)));
          } else {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => TeacherHompepage(name: name, email: email)));
          }
        } else if (selectedRole == 'Shopkeeper') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => ShopkeeperHomePage(name: name, email: email)));
        } else if (selectedRole == 'Admin') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => AdminHomePage(name: name, email: email)));
        }
      } else {
        final error = jsonDecode(response.body);
        _showMessage("Login failed: ${error['detail']}");
      }
    } catch (e) {
      _showMessage("Error: $e");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
