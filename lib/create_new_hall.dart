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
  final emailController = TextEditingController();
  final hallNameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<bool> _verifyNewHallOTP(String email, String hallName) async {
    final resp1 = await http.post(
      Uri.parse('$baseUrl/utils/send-verification-code-new-hall?hall_name=$hallName'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (resp1.statusCode != 200) {
      final err = jsonDecode(resp1.body)['detail'] ?? 'Failed to send OTP';
      _showMessage(err);
      return false;
    }

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
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: const Text('OK')),
          ],
        );
      },
    );
    if (code == null || code.isEmpty) return false;

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
    final email = emailController.text.trim();
    final hallName = hallNameController.text.trim();
    final password = passwordController.text;
    final confirm = confirmController.text;

    if (fullName.isEmpty || email.isEmpty || hallName.isEmpty || password.isEmpty || confirm.isEmpty) {
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

    bool ok = await _verifyNewHallOTP(email, hallName);
    if (!ok) return;

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
          builder: (_) => AdminHomePage(name: fullName, email: email, hallname: hallName),
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
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 154, 151, 151),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.arrow_back, color: Colors.lightBlue, size: 24),
            ),
          ),
        ),
        title: const Text("Create New Hall", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildCardField(
                label: "Full Name",
                controller: fullNameController,
                icon: Icons.person,
              ),
              _buildCardField(
                label: "Email",
                controller: emailController,
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildCardField(
                label: "Hall Name",
                controller: hallNameController,
                icon: Icons.apartment,
              ),
              _buildCardField(
                label: "Password",
                controller: passwordController,
                icon: Icons.lock,
                isPassword: true,
                obscureText: _obscurePassword,
                toggleObscure: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              _buildCardField(
                label: "Confirm Password",
                controller: confirmController,
                icon: Icons.lock_outline,
                isPassword: true,
                obscureText: _obscureConfirmPassword,
                toggleObscure: () {
                  setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _createHall,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFF203A43),
                    elevation: 5,
                    shadowColor: Colors.blueAccent,
                  ),
                  child: const Text(
                    "Create Hall as Admin",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? toggleObscure,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: const Color(0xFFE3F2FD), // light blue shade
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword ? obscureText : false,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: label,
            labelStyle: const TextStyle(color: Color(0xFF0D47A1)),
            icon: Icon(icon, color: const Color(0xFF0D47A1)),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFF0D47A1),
                    ),
                    onPressed: toggleObscure,
                  )
                : null,
          ),
          style: const TextStyle(color: Color(0xFF0D47A1)),
        ),
      ),
    );
  }
}
