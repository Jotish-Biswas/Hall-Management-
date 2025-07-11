import 'package:flutter/material.dart';
import 'student_profile.dart';
import 'login.dart';
import 'user_notice_page.dart';
import 'post_report_page.dart';
import 'show_event_page.dart';
import 'shop_list_page.dart';

class StudentHomePage extends StatefulWidget {
  final String name;
  final String email;

  const StudentHomePage({super.key, required this.name, required this.email});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      _buildMainPage(),
      User_NoticePage(),
      const Center(child: Text("Chat Page Coming Soon...")),
      StudentProfilePage(
        email: widget.email,
        onBack: () => setState(() => _selectedIndex = 0),
      ),
    ];

    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
              backgroundColor: Colors.lightBlue,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context); // Exit to login or previous page
                },
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
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const Placeholder(), // Replace with actual page
                  ));
                },
              ),
              MenuTile(
                icon: Icons.store,
                title: "Shop",
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ShopListPage()),
                  );
                },
              ),
              MenuTile(
                icon: Icons.grade,
                title: "Post Reports",
                color: Colors.green,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => PostReportPage(email: widget.email),
                  ));
                },
              ),
              MenuTile(
                icon: Icons.library_books,
                title: "Emergency Service",
                color: Colors.pinkAccent,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const Placeholder(), // Replace with actual page
                  ));
                },
              ),
              MenuTile(
                icon: Icons.event_available,
                title: "Events",
                color: Colors.deepPurple,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => StudentEventPage(
                      studentName: widget.name,
                      studentEmail: widget.email,
                    ),
                  ));
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
