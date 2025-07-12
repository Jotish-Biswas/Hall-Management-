import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserListPage extends StatefulWidget {
  final String userRole;
  final String hallname; // Hall of the logged-in user

  const UserListPage({super.key, required this.userRole, required this.hallname});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;
  String currentRole = "";
  String searchQuery = "";
  bool showSearch = false;
  late TextEditingController searchController;
  late List<String> roles;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();

    // Set roles based on logged-in user's role
    if (widget.userRole.toLowerCase() == "admin") {
      roles = ["Student", "Teacher", "Shopkeeper"];
    } else if (widget.userRole.toLowerCase() == "teacher") {
      roles = ["Student", "Shopkeeper"];
    } else {
      roles = ["Student"]; // Default fallback
    }

    currentRole = roles[0];
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
      // Filter by hallname for both admin and teacher
      final uri = Uri.parse(
        'http://127.0.0.1:8000/users/users_by_hall?role=$currentRole&hall_name=${Uri.encodeComponent(widget.hallname)}&search=${Uri.encodeComponent(searchQuery)}',
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          users = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch users");
      }
    } catch (e) {
      print("Fetch error: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteUser(String email) async {
    try {
      final endpoint = widget.userRole.toLowerCase() == "teacher"
          ? 'http://127.0.0.1:8000/users/teacher/users/delete'
          : 'http://127.0.0.1:8000/users/delete';

      final response = await http.delete(
        Uri.parse(endpoint),
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
          SnackBar(content: Text("Failed to delete $email")),
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
        return Colors.lightGreenAccent;
      case 2:
        return Colors.cyan;
      default:
        return Colors.white;
    }
  }

  Widget buildUserDetails(Map<String, dynamic> user) {
    // Display hall_name in user details
    switch (currentRole) {
      case "Student":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Department: ${user['department'] ?? 'N/A'}"),
            Text("Session: ${user['session'] ?? 'N/A'}"),
            Text("Hall: ${user['hall_name'] ?? 'N/A'}"),
            Text("Email: ${user['email']}"),
          ],
        );
      case "Teacher":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Department: ${user['department'] ?? 'N/A'}"),
            Text("Hall: ${user['hall_name'] ?? 'N/A'}"),
            Text("Email: ${user['email']}"),
          ],
        );
      case "Shopkeeper":
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hall: ${user['hall_name'] ?? 'N/A'}"),
            Text("Email: ${user['email']}"),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: roles.length,
      child: Scaffold(
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
              : const Text("User List"),
          actions: [
            IconButton(
              icon: Icon(showSearch ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  showSearch = !showSearch;
                  searchQuery = "";
                  searchController.clear();
                  fetchUsers();
                });
              },
            ),
          ],
          backgroundColor: Colors.blueGrey,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            tabs: List.generate(roles.length, (index) {
              return Tab(
                child: Text(
                  roles[index],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _tabController.index == index ? getTabColor(index) : Colors.white70,
                  ),
                ),
              );
            }),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                "Total $currentRole${users.length == 1 ? '' : 's'}: ${users.length}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: users.isEmpty
                  ? Center(child: Text("No $currentRole users found."))
                  : ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      title: Text(user['full_name'] ?? 'No Name'),
                      subtitle: buildUserDetails(user),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.black),
                        onPressed: () => deleteUser(user['email']),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
