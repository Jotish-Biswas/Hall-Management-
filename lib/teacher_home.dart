import 'package:flutter/material.dart';
import 'teacher_profile.dart';  // Import করা হয়েছে

class TeacherHomePage extends StatefulWidget {
  final String name;
  final String email;

  const TeacherHomePage({super.key, required this.name, required this.email});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      _buildMainPage(),
      const Center(child: Text("Alerts Page Coming Soon...")),
      const Center(child: Text("Chat Page Coming Soon...")),
      TeacherProfilePage(email: widget.email),
    ];

    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
              backgroundColor: Colors.teal,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context); // Login page-এ ফিরে যাও
                },
              ),
              title: const Text(
                "Teacher Dashboard",
                style: TextStyle(color: Colors.white),
              ),
              centerTitle: true,
            )
          : null,
      backgroundColor: Colors.teal[50],
      body: SafeArea(child: pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Alerts"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildMainPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Colors.teal,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Teacher Notices", style: TextStyle(color: Colors.white70)),
                  Icon(Icons.notifications, color: Colors.white),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.deepOrange,
                ),
                child: const Center(
                  child: Text(
                    "Don't miss the Faculty Workshop!",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Main Menu", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text("See All", style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        Expanded(
          child: GridView.count(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            children: [
              menuTile(Icons.schedule, "Approval", Colors.indigo),
              menuTile(Icons.book, "Course Materials", Colors.green),
              menuTile(Icons.feedback, "Student Feedback", Colors.orange),
              menuTile(Icons.grade, "Upload Grades", Colors.purple),
            ],
          ),
        ),
      ],
    );
  }

  static Widget menuTile(IconData icon, String title, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: ListTile(
          leading: Icon(icon, color: Colors.white, size: 30),
          title: Text(title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ),
    );
  }
}
