import 'package:flutter/material.dart';
import 'approval_requests_page.dart';
import 'user_list_page.dart';
import 'post_notice_page.dart';
import 'login.dart';
import 'profile_page.dart';
import 'notice_page.dart';
import 'report_page.dart';
import 'admin_create_event_page.dart';
import 'event_participationList_page.dart';
import 'teacher_approval.dart'; // Added import for ApprovalPage

class AdminHomePage extends StatefulWidget {
  final String name;
  final String email;

  const AdminHomePage({super.key, required this.name, required this.email});

  @override
  State<AdminHomePage> createState() => AdminHomePageState();
}

class AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _buildDashboardPage(),
      const NoticePage(),
      const UserListPage(userRole: "admin"),
      ProvostProfilePage(),
    ];
  }

  Widget _buildDashboardPage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.blueGrey,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Welcome Admin,", style: TextStyle(color: Colors.white)),
                Text(
                  widget.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Admin Dashboard", style: TextStyle(color: Colors.white70)),
                    Icon(Icons.admin_panel_settings, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.deepPurple,
                  ),
                  child: const Center(
                    child: Text(
                      "Review and Approve Users",
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
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _menuTile(
                  context,
                  Icons.verified_user,
                  "User Approvals",
                  Colors.blue,
                  const ApprovalRequestsPage(),
                ),
                _menuTile(
                  context,
                  Icons.report,
                  "See Report List",
                  Colors.orange,
                  const ReportPage(),
                ),
                _menuTile(
                  context,
                  Icons.settings,
                  "Post Notice",
                  Colors.green,
                  const PostNoticePage(),
                ),
                _menuTile(
                  context,
                  Icons.event,
                  "Create Event",
                  Colors.deepPurple,
                  const AdminCreateEventPage(),
                ),
                _menuTile(
                  context,
                  Icons.event,
                  "Event Participation",
                  Colors.blue,
                  const AdminEventParticipationPage(),
                ),
                // Added seat approval tile here
                _menuTile(
                  context,
                  Icons.event_seat,
                  "Seat Approvals",
                  Colors.purple,
                  ApprovalPage(teacherEmail: widget.email), // Pass admin email
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProvostProfilePage()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueGrey,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notice"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Users"),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: "Profile"),
        ],
      ),
    );
  }

  Widget _menuTile(
      BuildContext context,
      IconData icon,
      String title,
      Color color,
      Widget destinationPage,
      ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => destinationPage),
        );
      },
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
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}