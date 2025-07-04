import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;
  String currentRole = "Student";
  String searchQuery = "";
  bool showSearch = false;
  late TextEditingController searchController;
  final List<String> roles = ["Student", "Teacher", "Shopkeeper"];
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
      final uri = Uri.parse(
        'http://127.0.0.1:8000/users?role=$currentRole&search=$searchQuery',
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
      final response = await http.delete(
        Uri.parse('http://127.0.0.1:8000/users/delete'),
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
    switch (currentRole) {
      case "Student":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Department: ${user['department'] ?? 'N/A'}"),
            Text("Session: ${user['session'] ?? 'N/A'}"),
            Text("Email: ${user['email']}"),
          ],
        );
      case "Teacher":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Department: ${user['department'] ?? 'N/A'}"),
            Text("Email: ${user['email']}"),
          ],
        );
      case "Shopkeeper":
      default:
        return Text("Email: ${user['email']}");
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
            tabs: [
              Tab(
                child: Text(
                  "Student",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _tabController.index == 0 ? getTabColor(0) : Colors.white70,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "Teacher",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _tabController.index == 1 ? getTabColor(1) : Colors.white70,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "Shopkeeper",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _tabController.index == 2 ? getTabColor(2) : Colors.white70,
                  ),
                ),
              ),
            ],
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
                      title: Text(user['full_name']),
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
