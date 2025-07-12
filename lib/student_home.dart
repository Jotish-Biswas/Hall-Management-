import 'package:flutter/material.dart';
import 'student_profile.dart';
import 'login.dart';
import 'user_notice_page.dart';
import 'post_report_page.dart';
import 'show_event_page.dart';
import 'shop_list_page.dart';
import 'chat.dart';
import 'seat_application.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StudentHomePage extends StatefulWidget {
  final String name;
  final String email;
  final String hallname;

  const StudentHomePage({super.key, required this.name, required this.email, required this.hallname});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  int _selectedIndex = 0;

  Future<bool> _checkIfApproved() async {
    try {
      final url = Uri.parse('http://127.0.0.1:8000/api/seat/check-approval')
          .replace(queryParameters: {
        'email': widget.email,
        'hall_name': widget.hallname,
      });

      print('Checking approval URL: ${url.toString()}');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['approved'] ?? false;
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to check approval status');
      }
    } catch (e) {
      print('Error checking approval status: $e');
      throw Exception('Connection error');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      _buildMainPage(),
      User_NoticePage(hallname: widget.hallname),
      ChatPage(studentEmail: widget.email, hallName: widget.hallname),
      StudentProfilePage(
        email: widget.email,
        hallname: widget.hallname,
        onBack: () => setState(() => _selectedIndex = 0),
      ),
    ];

    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
        backgroundColor: Colors.lightBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Student Dashboard",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      )
          : null,
      backgroundColor: Colors.lightBlue[50],
      body: SafeArea(child: pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (int index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notice"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildMainPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Colors.lightBlue,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Welcome back,", style: TextStyle(color: Colors.white)),
              Text(
                widget.name,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text("Campus News", style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 10),
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.orangeAccent,
                ),
                child: const Center(
                  child: Text(
                    "Dhaka University Hall",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Text("Main Menu", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        Expanded(
          child: GridView.count(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            children: [
              MenuTile(
                icon: Icons.schedule,
                title: "Room Application",
                color: Colors.blueAccent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SeatApplication(studentEmail: widget.email, hallname: widget.hallname),
                    ),
                  );
                },
              ),
              MenuTile(
                icon: Icons.store,
                title: "Shop",
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ShopListPage(hallname: widget.hallname)),
                  );
                },
              ),
              MenuTile(
                icon: Icons.grade,
                title: "Post Reports",
                color: Colors.green,
                onTap: () async {
                  final navigator = Navigator.of(context);
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    final isApproved = await _checkIfApproved();

                    navigator.pop();

                    if (isApproved) {
                      navigator.push(
                        MaterialPageRoute(
                          builder: (_) => PostReportPage(email: widget.email, hallname: widget.hallname),
                        ),
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Access Denied"),
                          content: const Text("Only resident students can post reports."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      );
                    }
                  } catch (e) {
                    navigator.pop();

                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Connection Error"),
                        content: const Text("Could not verify your status. Please try again."),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("OK"),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
              // Emergency Service removed here

              MenuTile(
                icon: Icons.event_available,
                title: "Events",
                color: Colors.deepPurple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StudentEventPage(
                        studentName: widget.name,
                        studentEmail: widget.email,
                        hallName: widget.hallname,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const MenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: ListTile(
            leading: Icon(icon, color: Colors.white, size: 30),
            title: Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }
}
