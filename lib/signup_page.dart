import 'package:flutter/material.dart';
import 'welcome_page.dart';
import 'student_home.dart';
import 'teacher_home.dart';
import 'shopkeeper_home.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'waiting_approval_page.dart';
import 'ServerLink.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String selectedRole = 'Student';
  bool termsAccepted = false;
  List<String> hallNames = [];
  String? selectedHall;
  bool isLoadingHalls = true;


  final TextEditingController field1Controller = TextEditingController();
  final TextEditingController field2Controller = TextEditingController();
  final TextEditingController field3Controller = TextEditingController();
  final TextEditingController field4Controller = TextEditingController();
  final TextEditingController field5Controller = TextEditingController();
  final TextEditingController field6Controller = TextEditingController();
  final TextEditingController field7Controller = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController hallNameController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _fetchHallNames();
  }
  Future<void> _fetchHallNames() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/signup/all-halls'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          hallNames = List<String>.from(data['halls']);
          isLoadingHalls = false;
        });
      } else {
        throw Exception('Failed to load hall names');
      }
    } catch (e) {
      setState(() {
        isLoadingHalls = false;
      });
      _showMessage('Error fetching halls: $e');
    }
  }



  // Define your gradient colors
  final List<Color> gradientColors = [
    const Color(0xFF0F2027),
    const Color(0xFF203A43),
    const Color(0xFF2C5364),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
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
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back, color: Colors.blueAccent, size: 26),
            ),
          ),
        ),
        title: const Text(
          "Hall Registration",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFf5f7fa), Color(0xFFc3cfe2)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2d3748),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Join our community today',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF718096),
                  ),
                ),
                const SizedBox(height: 30),

                // Role Selector
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
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
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF4a6fa5) : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              role,
                              style: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF4a5568),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 30),

                // Form Fields
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        isLoadingHalls
                            ? const CircularProgressIndicator()
                            : DropdownButtonFormField<String>(
                          value: selectedHall,
                          decoration: const InputDecoration(
                            labelText: 'Select Hall Name',
                            border: UnderlineInputBorder(),
                            labelStyle: TextStyle(color: Color(0xFF4a5568)),
                          ),
                          items: hallNames.map((hall) {
                            return DropdownMenuItem<String>(
                              value: hall,
                              child: Text(hall),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedHall = value;
                            });
                          },
                        ),

                        const SizedBox(height: 15),
                        ..._buildFieldsForRole(),
                        const SizedBox(height: 15),
                        _buildPasswordField('Password', passwordController),
                        const SizedBox(height: 15),
                        _buildPasswordField('Confirm Password', confirmPasswordController),
                        const SizedBox(height: 15),
                        
                        // Terms Checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: termsAccepted,
                              onChanged: (value) => setState(() => termsAccepted = value!),
                              activeColor: const Color(0xFF4a6fa5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const Text(
                              'I agree to the terms & conditions',
                              style: TextStyle(
                                color: Color(0xFF4a5568),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Register Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: termsAccepted ? _register : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4a6fa5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 3,
                            ),
                            child: const Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        
                        // About Us Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: _showAboutUs,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF4a6fa5)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'About Us',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF4a6fa5),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ALL YOUR EXISTING METHODS REMAIN EXACTLY THE SAME
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
              labelStyle: const TextStyle(color: Color(0xFF4a5568)),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF4a6fa5)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF4a5568)),
          border: const UnderlineInputBorder(),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF4a6fa5)),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    bool isPassword = label == 'Password';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : _obscureConfirmPassword,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF4a5568)),
          border: const UnderlineInputBorder(),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF4a6fa5)),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              (isPassword ? _obscurePassword : _obscureConfirmPassword)
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: const Color(0xFF4a5568),
            ),
            onPressed: () {
              setState(() {
                if (isPassword) {
                  _obscurePassword = !_obscurePassword;
                } else {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                }
              });
            },
          ),
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
    final uri = Uri.parse('$baseUrl/signup/');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  Future<void> _register() async {
    final email = field7Controller.text.trim();
    final password = passwordController.text;
    final confirm = confirmPasswordController.text;
    final fullName = field1Controller.text.trim();
    final hallName = selectedHall ?? '';


    if (!email.contains('@') || !email.contains('.')) {
      return _showMessage('Enter a valid email.');
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

    bool verified = await _verifyEmailOTP(email, hallName);
    if (!verified) return;

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

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      await sendSignUp(payload);
      Navigator.of(context).pop();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => WaitingApprovalPage(name: fullName),
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<bool> _verifyEmailOTP(String email, String hallName) async {
    try {
      final sendOtpResponse = await http.post(
        Uri.parse('$baseUrl/utils/send-verification-code?hall_name=$hallName'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (sendOtpResponse.statusCode != 200) {
        _showMessage('Failed to send OTP: ${sendOtpResponse.body}');
        return false;
      }

      String? enteredCode = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          TextEditingController otpController = TextEditingController();
          return AlertDialog(
            title: const Text('Verify Your Email'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Enter the 6-digit code sent to your email.'),
                const SizedBox(height: 10),
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Enter Code',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(otpController.text.trim());
                },
                child: const Text('Verify'),
              ),
            ],
          );
        },
      );

      if (enteredCode == null || enteredCode.isEmpty) return false;

      final verifyResponse = await http.post(
        Uri.parse('$baseUrl/utils/verify-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': enteredCode}),
      );

      if (verifyResponse.statusCode == 200) {
        return true;
      } else {
        _showMessage('Incorrect or expired code.');
        return false;
      }
    } catch (e) {
      _showMessage('OTP Verification failed: $e');
      return false;
    }
  }
}