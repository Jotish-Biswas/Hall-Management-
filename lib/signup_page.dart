import 'package:flutter/material.dart';
import 'welcome_page.dart';
import 'student_home.dart';
import 'teacher_home.dart';
import 'shopkeeper_home.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'waiting_approval_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String selectedRole = 'Student';
  bool termsAccepted = false;

  final TextEditingController field1Controller = TextEditingController(); // Full Name
  final TextEditingController field2Controller = TextEditingController();
  final TextEditingController field3Controller = TextEditingController();
  final TextEditingController field4Controller = TextEditingController();
  final TextEditingController field5Controller = TextEditingController();
  final TextEditingController field6Controller = TextEditingController();
  final TextEditingController field7Controller = TextEditingController(); // Email
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController hallNameController = TextEditingController(); // Hall Name

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('User Registration'), centerTitle: true),
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
                children: ['Student', 'Teacher', 'Shopkeeper'].map((role) {
                  bool isSelected = role == selectedRole;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        selectedRole = role;
                        _clearFields();
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.green : Colors.transparent,
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

            // Input Fields
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTextField('Hall Name', hallNameController),
                    const SizedBox(height: 10),
                    ..._buildFieldsForRole(),
                    _buildTextField('Password', passwordController, obscureText: true),
                    _buildTextField('Confirm Password', confirmPasswordController, obscureText: true),
                    CheckboxListTile(
                      value: termsAccepted,
                      onChanged: (value) => setState(() => termsAccepted = value!),
                      title: const Text('I agree to the terms & conditions'),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: termsAccepted ? _register : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text('Register', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _showAboutUs,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text('About Us', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutUs() {
    Navigator.pushNamed(context, '/about');
  }

  List<Widget> _buildFieldsForRole() {
    switch (selectedRole) {
      case 'Student':
        return [
          _buildTextField('Full Name', field1Controller),
          _buildTextField('Roll No', field3Controller),
          _buildTextField('Department Name', field2Controller),
          _buildTextField('Email', field7Controller, keyboardType: TextInputType.emailAddress),
          _buildTextField('Session', field5Controller),
          _buildTextField('Registration No', field4Controller),
          _buildDatePickerField('Date of Birth', field6Controller),
        ];
      case 'Teacher':
        return [
          _buildTextField('Full Name', field1Controller),
          _buildTextField('Teacher Reg.No', field2Controller),
          _buildTextField('Department', field3Controller),
          _buildTextField('Email', field7Controller, keyboardType: TextInputType.emailAddress),
          _buildTextField('Phone Number', field4Controller, keyboardType: TextInputType.phone),
          _buildTextField('Address', field5Controller),
        ];
      case 'Shopkeeper':
        return [
          _buildTextField('Full Name', field1Controller),
          _buildTextField('Type of Shop', field2Controller),
          _buildTextField('Phone Number', field3Controller, keyboardType: TextInputType.phone),
          _buildTextField('Email', field7Controller, keyboardType: TextInputType.emailAddress),
        ];
      default:
        return [];
    }
  }

  Widget _buildDatePickerField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime(2005, 1, 1),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );

          if (pickedDate != null) {
            setState(() {
              controller.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
            });
          }
        },
        child: AbsorbPointer(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: const UnderlineInputBorder(),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
          ),
        ),
      ),
    );
  }

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    bool isPasswordField = label == 'Password';
    bool isConfirmField = label == 'Confirm Password';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        obscureText: obscureText
            ? (isPasswordField ? _obscurePassword : _obscureConfirmPassword)
            : false,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const UnderlineInputBorder(),
          suffixIcon: obscureText
              ? IconButton(
            icon: Icon(
              (isPasswordField
                  ? _obscurePassword
                  : _obscureConfirmPassword)
                  ? Icons.visibility_off
                  : Icons.visibility,
            ),
            onPressed: () {
              setState(() {
                if (isPasswordField) {
                  _obscurePassword = !_obscurePassword;
                } else if (isConfirmField) {
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

  void _clearFields() {
    field1Controller.clear();
    field2Controller.clear();
    field3Controller.clear();
    field4Controller.clear();
    field5Controller.clear();
    field6Controller.clear();
    field7Controller.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    hallNameController.clear();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> sendSignUp(Map<String, dynamic> payload) async {
    final uri = Uri.parse('http://127.0.0.1:8000/signup');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  void _register() async {
    final email = field7Controller.text.trim();
    final password = passwordController.text;
    final confirm = confirmPasswordController.text;
    final fullName = field1Controller.text.trim();
    final hallName = hallNameController.text.trim();

    // Simple client-side checks
    if (!email.contains('@') || !email.contains('.')) {
      return _showMessage('Please enter a valid email.');
    }
    if (password.length < 6) {
      return _showMessage('Password must be at least 6 characters.');
    }
    if (password != confirm) {
      return _showMessage('Passwords do not match.');
    }
    if (fullName.isEmpty) {
      return _showMessage('Full Name is required.');
    }
    if (!termsAccepted) {
      return _showMessage('You must accept terms & conditions.');
    }

    // Build the payload
    final payload = {
      'full_name': fullName,
      'email': email,
      'password': password,
      'hall_name': hallName,
      'role': selectedRole,
      'extra': {
        if (selectedRole == 'Student') ...{
          'roll_no': field3Controller.text.trim(),
          'department': field2Controller.text.trim(),
          'session': field5Controller.text.trim(),
          'registration_no': field4Controller.text.trim(),
          'dob': field6Controller.text.trim(),
        } else if (selectedRole == 'Teacher') ...{
          'teacher_reg_no': field2Controller.text.trim(),
          'department': field3Controller.text.trim(),
          'phone': field4Controller.text.trim(),
          'address': field5Controller.text.trim(),
        } else if (selectedRole == 'Shopkeeper') ...{
          'shop_type': field2Controller.text.trim(),
          'phone': field3Controller.text.trim(),
        }
      }
    };

    // Call API
    try {
      // show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      await sendSignUp(payload);
      Navigator.of(context).pop(); // remove loading

      // On success, navigate by role
      Widget nextPage;
      if (selectedRole == 'Student') {
        nextPage = WaitingApprovalPage(name: fullName);
      } else if (selectedRole == 'Teacher') {
        nextPage = WaitingApprovalPage(name: fullName);
      } else {
        nextPage = WaitingApprovalPage(name: fullName);
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => nextPage),
      );
    } catch (e) {
      Navigator.of(context).pop(); // remove loading
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}