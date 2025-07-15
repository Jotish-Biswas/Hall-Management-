import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'notice_detail_page.dart';
import 'notice_page.dart';
import 'ServerLink.dart';


class User_NoticePage extends StatefulWidget {
  final String hallname;
  const User_NoticePage({super.key, required this.hallname});

  @override
  State<User_NoticePage> createState() => _User_NoticePageState();
}

class _User_NoticePageState extends State<User_NoticePage> {
  List<Notice> _allNotices = [];
  List<Notice> _filteredNotices = [];
  bool _isLoading = true;
  String _errorMessage = '';

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchNotices();
    _searchController.addListener(_filterNotices);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchNotices() async {
    try {
      final url = Uri.parse('$baseUrl/notices?hall_name=${Uri.encodeComponent(widget.hallname)}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _allNotices = data.map((json) => Notice.fromJson(json)).toList();
          _filteredNotices = List.from(_allNotices);
          _isLoading = false;
        });
      } else if (response.statusCode == 400) {
        setState(() {
          _errorMessage = 'No hall specified';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load notices: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  void _filterNotices() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredNotices = List.from(_allNotices);
      } else {
        _filteredNotices = _allNotices.where((notice) {
          final titleLower = notice.title.toLowerCase();
          final messageLower = notice.message.toLowerCase();
          return titleLower.contains(query) || messageLower.contains(query);
        }).toList();
      }
    });
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _filteredNotices = List.from(_allNotices);
    });
  }

  Widget _buildAppBarTitle() {
    if (_isSearching) {
      final screenWidth = MediaQuery.of(context).size.width;
      return SizedBox(
        width: screenWidth * 0.6,
        height: 36,
        child: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
            hintText: 'Search Notices...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            fillColor: Colors.white24,
            filled: true,
            isDense: true,
          ),
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
        ),
      );
    } else {
      return Text('Notices - ${widget.hallname}');
    }
  }

  List<Widget> _buildAppBarActions() {
    if (_isSearching) {
      return [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: _stopSearch,
        ),
      ];
    } else {
      return [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: _startSearch,
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildAppBarTitle(),
        backgroundColor: Colors.blueGrey,
        actions: _buildAppBarActions(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage))
          : (_filteredNotices.isEmpty
          ? const Center(
        child: Text("No notices found in your hall"),
      )
          : ListView.builder(
        itemCount: _filteredNotices.length,
        itemBuilder: (context, index) {
          final notice = _filteredNotices[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(notice.title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                "Posted: ${notice.timestamp.toLocal().toString().split(' ')[0]}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NoticeDetailPage(notice: notice), // FIXED HERE
                  ),
                );
              },
            ),
          );
        },
      ))),
    );
  }
}
