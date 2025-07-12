import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TeacherUserListPage extends StatefulWidget {
  final String hallname;  // <-- Add hallname here

  const TeacherUserListPage({super.key, required this.hallname});

  @override
  State<TeacherUserListPage> createState() => _TeacherUserListPageState();
}

class _TeacherUserListPageState extends State<TeacherUserListPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;
  String currentRole = "Student";
  String searchQuery = "";
  bool showSearch = false;
  late TextEditingController searchController;
  final List<String> roles = ["Student", "Shopkeeper"];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    _tabController = TabController(length: roles.length, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {
        currentRole = roles[_tabController.index];
        searchQuery = "";
        searchController.clear();
        fetchUsers();
      });
    });

    fetchUsers();
  }

  @override
  void dispose() {
    searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchUsers() async {
    setState(() => isLoading = true);
    try {
      // Include hall_name in query params
      final uri = Uri.parse(
        'http://127.0.0.1:8000/users/teacher/users?role=$currentRole&hall_name=${Uri.encodeComponent(widget.hallname)}&search=${Uri.encodeComponent(searchQuery)}',
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          users = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch users: ${response.body}");
      }
    } catch (e) {
      print("Fetch error: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteUser(String email) async {
    try {
      final response = await http.delete(
        Uri.parse('http://127.0.0.1:8000/users/teacher/users/delete'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Deleted $email")),
        );
        fetchUsers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Delete failed: ${response.body}")),
        );
      }
    } catch (e) {
      print("Delete error: $e");
    }
  }

  Color getTabColor(int index) {
    switch (index) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.cyan;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: showSearch
            ? Container(
          height: 40,
          margin: const EdgeInsets.only(right: 8),
          child: TextField(
            controller: searchController,
            autofocus: true,
            onChanged: (value) {
              setState(() => searchQuery = value);
              fetchUsers();
            },
            decoration: InputDecoration(
              hintText: "Search $currentRole...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
        )
            : const Text("Manage Students/Shopkeepers"),
        actions: [
          IconButton(
            icon: Icon(showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                showSearch = !showSearch;
                if (!showSearch) {
                  searchQuery = "";
                  searchController.clear();
                  fetchUsers();
                }
              });
            },
          ),
        ],
        backgroundColor: Colors.blueGrey,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              child: Text(
                "Students",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _tabController.index == 0 ? getTabColor(0) : Colors.white70,
                ),
              ),
            ),
            Tab(
              child: Text(
                "Shopkeepers",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _tabController.index == 1 ? getTabColor(1) : Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
          ? Center(child: Text("No $currentRole users found"))
          : ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: user['image_url'] != null
                    ? NetworkImage(user['image_url'])
                    : null,
                child: user['image_url'] == null ? const Icon(Icons.person) : null,
              ),
              title: Text(user['full_name']),
              subtitle: Text(user['email']),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => deleteUser(user['email']),
              ),
            ),
          );
        },
      ),
    );
  }
}
