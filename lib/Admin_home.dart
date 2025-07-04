import 'package:flutter/material.dart';
import 'approval_requests_page.dart';
import 'user_list_page.dart';
import 'post_notice_page.dart';
import 'login.dart';
import 'profile_page.dart';
import 'notice_page.dart';
import 'report_page.dart';

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
      const UserListPage(),
      ProfilePage(email: widget.email),
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
                _logoutTile(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsPage() {
    return const Center(child: Text('Alerts page'));
  }

  void _onItemTapped(int index) {
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProfilePage(email: widget.email)),
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

  static Widget _menuTile(
      BuildContext context,
      IconData icon,
      String title,
      Color color,
      Widget? destinationPage,
      ) {
    return InkWell(
      onTap: destinationPage != null
          ? () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => destinationPage),
        );
      }
          : null,
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

  static Widget _logoutTile(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text("Logout"),
              content: const Text("Are you sure you want to logout?"),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.pop(dialogContext),
                ),
                TextButton(
                  child: const Text("Logout"),
                  onPressed: () {
                    Navigator.pop(dialogContext); // Close dialog
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                          (Route<dynamic> route) => false,
                    );
                  },
                ),
              ],
            );
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: ListTile(
            leading: Icon(Icons.logout, color: Colors.white, size: 30),
            title: Text(
              "Logout",
              style: TextStyle(
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
