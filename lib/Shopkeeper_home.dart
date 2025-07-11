import 'package:flutter/material.dart';
import 'shopkeeper_profile.dart';
import 'user_notice_page.dart';
import 'inventory_page.dart';
import 'post_report_page.dart';

class ShopkeeperHomePage extends StatefulWidget {
  final String name;
  final String email;
  final String hallname;

  const ShopkeeperHomePage({super.key, required this.name, required this.email, required this.hallname});

  @override
  State<ShopkeeperHomePage> createState() => _ShopkeeperHomePageState();
}

class _ShopkeeperHomePageState extends State<ShopkeeperHomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Back to Login
          },
        ),
        title: const Text(
          "Shopkeeper Dashboard",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.orange[50],
      body: SafeArea(child: _buildMainPage()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShopkeeperProfilePage(email: widget.email, hallname : widget.hallname),
              ),
            );
          }
          setState(() {
            _selectedIndex = 0; // always stay on Home visually
          });
        },
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return _buildMainPage();
      case 1:
        return User_NoticePage(hallname: widget.hallname);
      case 2:
        return const Center(child: Text("Chat Page Coming Soon..."));
      default:
        return _buildMainPage();
    }
  }

  Widget _buildMainPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Colors.orange,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Welcome back,", style: TextStyle(color: Colors.white)),
              Text(
                widget.name,
                style: const TextStyle(
                    color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Vendor Announcements", style: TextStyle(color: Colors.white70)),
                  Icon(Icons.notifications, color: Colors.white),
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
                    "Market inspection this Friday!",
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
              menuTile(
                  Icons.store,
                  "Products",
                  Colors.teal,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InventoryPage(email: widget.email),
                      ),
                    );
                  },
                ),
             menuTile(
                  Icons.notifications,
                  "Notice",
                  Colors.deepOrange,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => User_NoticePage(hallname : widget.hallname),
                      ),
                    );
                  },
                ),
             menuTile(
                  Icons.report,
                  "Report Post",
                  Colors.redAccent,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostReportPage(email: widget.email, hallname : widget.hallname),
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

  static Widget menuTile(IconData icon, String title, Color color, VoidCallback onTap) {
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
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }
}
