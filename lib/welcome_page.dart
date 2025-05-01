import 'package:flutter/material.dart';

class UserDetails {
  final String role;
  final String name;
  final String email;

  UserDetails({
    required this.role,
    required this.name,
    required this.email,
  });
}

class WelcomePage extends StatelessWidget {
  final UserDetails userDetails;

  const WelcomePage({super.key, required this.userDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF26B0AE),
      appBar: AppBar(
        backgroundColor: Colors.teal[800],
        title: const Text('Welcome'),
        centerTitle: true,
        elevation: 10,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.teal.shade400,
                Colors.cyan.shade300,
                Colors.green.shade300,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 15,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(seconds: 1),
                child: const Icon(Icons.check_circle, size: 100, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text(
                'Welcome, ${userDetails.name}!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(2, 2),
                      blurRadius: 3,
                      color: Colors.black54,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Role: ${userDetails.role}',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              Text(
                'Email: ${userDetails.email}',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Sign Up'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade800,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 5,
                  shadowColor: Colors.black45,
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
