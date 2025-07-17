import 'package:flutter/material.dart';
import 'student_home.dart';
import 'teacher_home.dart';
import 'shopkeeper_home.dart';
import 'Admin_home.dart';
import 'waiting_approval_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'forgot_password_page.dart';
import 'ServerLink.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = 'Student';
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Blue-White Theme Colors
  final Color _primaryBlue = const Color(0xFF1976D2);      // Primary blue
  final Color _darkBlue = const Color(0xFF0D47A1);         // Dark blue
  final Color _lightBlue = const Color(0xFFBBDEFB);        // Light blue
  final Color _white = Colors.white;                      // White
  final Color _darkGrey = const Color(0xFF424242);        // Text color
  final Color _lightGrey = const Color(0xFFEEEEEE);       // Background

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightGrey,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 80),
              
              // Logo & Title
              Column(
                children: [
                  Icon(Icons.account_circle, size: 80, color: _primaryBlue),
                  const SizedBox(height: 16),
                  Text(
                    'HALL MANAGEMENT',
                    style: TextStyle(
                      color: _darkBlue,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Welcome back! Please login to continue',
                    style: TextStyle(
                      color: _darkGrey,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // Login Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: _white,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Role Selector - Fixed to prevent overflow
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _lightBlue.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: ['Student', 'Teacher', 'Shopkeeper', 'Admin'].map((role) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedRole = role),
                                  child: Container(
                                    constraints: BoxConstraints(minWidth: 70),
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                    decoration: BoxDecoration(
                                      color: _selectedRole == role ? _primaryBlue : Colors.transparent,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      role,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: _selectedRole == role ? _white : _darkGrey,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Email Field
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email or Username',
                          labelStyle: TextStyle(color: _darkGrey.withOpacity(0.6)),
                          prefixIcon: Icon(Icons.email, color: _primaryBlue),
                          filled: true,
                          fillColor: _lightGrey,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(color: _darkGrey),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Password Field
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: _darkGrey.withOpacity(0.6)),
                          prefixIcon: Icon(Icons.lock, color: _primaryBlue),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: _primaryBlue,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          filled: true,
                          fillColor: _lightGrey,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(color: _darkGrey),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                          ),
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(color: _primaryBlue),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'LOGIN',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Sign Up Prompt
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(color: _darkGrey),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/signup'),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: _primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Create Hall Button
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/create_hall'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _primaryBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'CREATE NEW HALL',
                  style: TextStyle(color: _primaryBlue),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // About Us
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/about'),
                child: Text(
                  'About Us',
                  style: TextStyle(color: _primaryBlue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
          "role": _selectedRole,
        }),
      ).timeout(const Duration(seconds: 10));

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        await _handleSuccess(response.body, email);
      } else if (response.statusCode == 403) {
        _handlePendingApproval(response.body);
      } else {
        _showSnackBar('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error: ${e.toString()}');
    }
  }

  Future<void> _handleSuccess(String response, String email) async {
    final data = jsonDecode(response);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('role', _selectedRole);
    await prefs.setString('name', data['name']);
    await prefs.setString('hall_name', data['hall_name'] ?? 'Unknown Hall');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => _getHomePage(data['name'], email, data['hall_name']),
      ),
    );
  }

  Widget _getHomePage(String name, String email, String hallName) {
    switch (_selectedRole) {
      case 'Student':
        return StudentHomePage(name: name, email: email, hallname: hallName);
      case 'Teacher':
        return TeacherHomepage(name: name, email: email, hallname: hallName);
      case 'Shopkeeper':
        return ShopkeeperHomePage(name: name, email: email, hallname: hallName);
      case 'Admin':
        return AdminHomePage(name: name, email: email, hallname: hallName);
      default:
        return const Scaffold(body: Center(child: Text('Invalid role')));
    }
  }

  void _handlePendingApproval(String response) {
    final data = jsonDecode(response);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => WaitingApprovalPage(name: data['name'] ?? 'User'),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _primaryBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}