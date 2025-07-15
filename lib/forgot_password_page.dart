import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ServerLink.dart';

import 'reset_password_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  bool isCodeSent = false;
  bool isLoading = false;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> sendVerificationCode() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      _showMessage('Please enter your email.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse("$baseUrl/forgot-password");
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}));

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      setState(() {
        isCodeSent = true;
      });
      _showMessage('Verification code sent to $email');
    } else {
      final error = jsonDecode(response.body);
      _showMessage(error['detail'] ?? 'Failed to send code');
    }
  }

  Future<bool> verifyCode() async {
    final email = emailController.text.trim();
    final code = codeController.text.trim();
    if (code.isEmpty) {
      _showMessage('Please enter the verification code.');
      return false;
    }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse("$baseUrl/verify-code");
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}));

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      return true;
    } else {
      final error = jsonDecode(response.body);
      _showMessage(error['detail'] ?? 'Invalid code');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Forgot Password', style: TextStyle(color: Colors.blue)),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.blue),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Enter your email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            if (!isCodeSent)
              ElevatedButton(
                onPressed: isLoading ? null : sendVerificationCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Send Verification Code', style: TextStyle(color: Colors.white)),
              ),

            if (isCodeSent) ...[
              TextField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: 'Enter verification code',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                  bool verified = await verifyCode();
                  if (verified) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResetPasswordPage(email: emailController.text.trim()),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Verify & Continue', style: TextStyle(color: Colors.white)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


