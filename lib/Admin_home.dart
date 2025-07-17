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
import 'teacher_seat_approval.dart';

class AdminHomePage extends StatefulWidget {
  final String name;
  final String email;
  final String hallname;

  const AdminHomePage({super.key, required this.name, required this.email, required this.hallname});

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
      NoticePage(hallname: widget.hallname),
      UserListPage(userRole: "Admin", hallname: widget.hallname),
      ProvostProfilePage(email: widget.email, hallName: widget.hallname),
    ];
  }

  Widget _buildDashboardPage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Welcome Admin,", style: TextStyle(color: Colors.white)),
                Text(
                  widget.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
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
                const SizedBox(height: 20),
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.deepPurple.withOpacity(0.8),
                  ),
                  child: Center(
                    child: Text(
                      "Welcome to ${widget.hallname}",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Text(
              "Main Menu",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                _menuTile(context, Icons.verified_user, "User Approvals", Colors.blue, ApprovalRequestsPage(hallname: widget.hallname)),
                _menuTile(context, Icons.report, "See Report List", Colors.orange, ReportPage(hallName: widget.hallname)),
                _menuTile(context, Icons.settings, "Post Notice", Colors.green, PostNoticePage(hallname: widget.hallname)),
                _menuTile(context, Icons.event, "Create Event", Colors.deepPurple, AdminCreateEventPage(hallName: widget.hallname)),
                _menuTile(context, Icons.event, "Event Participation", Colors.blue, AdminEventParticipationPage(hallName: widget.hallname)),
                _menuTile(context, Icons.event_seat, "Seat Approvals", Colors.purple, ApprovalPage(teacherEmail: widget.email, hallname: widget.hallname)),
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
        MaterialPageRoute(builder: (_) => ProvostProfilePage(email: widget.email, hallName: widget.hallname)),
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
        title: const Text("Admin Dashboard", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.grey[100],
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.indigo,
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

  Widget _menuTile(BuildContext context, IconData icon, String title, Color color, Widget destinationPage) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => destinationPage));
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
