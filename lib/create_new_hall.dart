import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'waiting_approval_page.dart';
import 'Admin_home.dart';

class CreateHallPage extends StatefulWidget {
  const CreateHallPage({super.key});

  @override
  State<CreateHallPage> createState() => _CreateHallPageState();
}

class _CreateHallPageState extends State<CreateHallPage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController hallNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _createHall() async {
    String fullName = fullNameController.text.trim();
    String email = emailController.text.trim();
    String hallName = hallNameController.text.trim();
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;

    // Basic validation
    if (fullName.isEmpty || email.isEmpty || hallName.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showMessage("Please fill in all fields.");
      return;
    }

    if (password != confirmPassword) {
      _showMessage("Passwords do not match.");
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      _showMessage("Please enter a valid email address.");
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // Send request to backend
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/signup/create-hall'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'full_name': fullName,
          'email': email,
          'password': password,
          'hall_name': hallName,
        }),
      );

      // Remove loading indicator
      Navigator.of(context).pop();

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Success - navigate to admin home with all needed data
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AdminHomePage(
              name: fullName,
              email: email,
              hallname: hallName, // Now passing hallName
            ),
          ),
        );

        // Optional: Show success message
        _showMessage("Hall created successfully! Admin email: ${responseData['admin_email']}");
      } else {
        // Handle specific error messages from backend
        String errorMessage = responseData['detail'] ?? 'Failed to create hall';
        if (errorMessage.contains('already exists')) {
          errorMessage = "This hall name is already taken. Please choose another.";
        }
        _showMessage(errorMessage);
      }
    } on http.ClientException catch (e) {
      Navigator.of(context).pop();
      _showMessage("Network error: ${e.message}");
    } on FormatException catch (e) {
      Navigator.of(context).pop();
      _showMessage("Data format error: ${e.message}");
    } catch (e) {
      Navigator.of(context).pop();
      _showMessage("Unexpected error: ${e.toString()}");
    }
  }
  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Hall'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField("Full Name", fullNameController),
              _buildTextField("Email", emailController),
              _buildTextField("Hall Name", hallNameController),
              _buildTextField("Password", passwordController, isPassword: true),
              _buildTextField("Confirm Password", confirmPasswordController, isPassword: true),
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

  Widget _buildTextField(String label, TextEditingController controller, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: isPassword
            ? (controller == passwordController ? _obscurePassword : _obscureConfirmPassword)
            : false,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(controller == passwordController
                ? (_obscurePassword ? Icons.visibility_off : Icons.visibility)
                : (_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility)),
            onPressed: () {
              setState(() {
                if (controller == passwordController) {
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
