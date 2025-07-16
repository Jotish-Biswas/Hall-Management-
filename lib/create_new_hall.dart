import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Admin_home.dart';
import 'ServerLink.dart';

class CreateHallPage extends StatefulWidget {
  const CreateHallPage({super.key});
  @override
  State<CreateHallPage> createState() => _CreateHallPageState();
}

class _CreateHallPageState extends State<CreateHallPage> {
  final fullNameController = TextEditingController();
  final emailController    = TextEditingController();
  final hallNameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController  = TextEditingController();

  bool _obscurePassword       = true;
  bool _obscureConfirmPassword = true;

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<bool> _verifyNewHallOTP(String email, String hallName) async {
    // 1) Request OTP
    final resp1 = await http.post(
      Uri.parse(
          '$baseUrl/utils/send-verification-code-new-hall?hall_name=$hallName'
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (resp1.statusCode != 200) {
      final err = jsonDecode(resp1.body)['detail'] ?? 'Failed to send OTP';
      _showMessage(err);
      return false;
    }

    // 2) Prompt for code
    String? code = await showDialog<String>(
      context: context,
      builder: (_) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text('Enter Verification Code'),
          content: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: '6-digit code'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, ctrl.text.trim()),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    if (code == null || code.isEmpty) return false;

    // 3) Verify code
    final resp2 = await http.post(
      Uri.parse('$baseUrl/utils/verify-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code}),
    );
    if (resp2.statusCode != 200) {
      _showMessage('Invalid or expired code');
      return false;
    }
    return true;
  }

  void _createHall() async {
    final fullName = fullNameController.text.trim();
    final email    = emailController.text.trim();
    final hallName = hallNameController.text.trim();
    final password = passwordController.text;
    final confirm  = confirmController.text;

    if (fullName.isEmpty ||
        email.isEmpty ||
        hallName.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty) {
      _showMessage("Please fill all fields.");
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      _showMessage("Enter a valid email.");
      return;
    }
    if (password != confirm) {
      _showMessage("Passwords do not match.");
      return;
    }

    // OTP step
    bool ok = await _verifyNewHallOTP(email, hallName);
    if (!ok) return;

    // Create hall API
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final resp = await http.post(
      Uri.parse('$baseUrl/signup/create-hall'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'full_name': fullName,
        'email': email,
        'password': password,
        'hall_name': hallName,
      }),
    );
    Navigator.pop(context); // remove loader

    if (resp.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AdminHomePage(
            name: fullName,
            email: email,
            hallname: hallName,
          ),
        ),
      );
    } else {
      final msg = jsonDecode(resp.body)['detail'] ?? 'Create hall failed';
      _showMessage(msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Hall')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildField("Full Name", fullNameController),
              _buildField("Email", emailController),
              _buildField("Hall Name", hallNameController),
              _buildField("Password", passwordController, isPassword: true),
              _buildField("Confirm Password", confirmController, isPassword: true),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createHall,
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                child: const Text("Create Hall as Admin"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: ctrl,
        obscureText: isPassword
            ? (ctrl == passwordController ? _obscurePassword : _obscureConfirmPassword)
            : false,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(ctrl == passwordController
                ? (_obscurePassword ? Icons.visibility_off : Icons.visibility)
                : (_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility)),
            onPressed: () {
              setState(() {
                if (ctrl == passwordController) {
                  _obscurePassword = !_obscurePassword;
                } else {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                }
              });
            },
          )
              : null,
        ),
      ),
    );
  }
}
