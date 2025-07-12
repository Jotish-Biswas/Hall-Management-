import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'notice_detail_page.dart';

class Notice {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final String hallName; // Added hall name

  Notice({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.hallName, // Added
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      hallName: json['hall_name'] ?? 'JN_Hall', // Default value
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class NoticePage extends StatefulWidget {
  final String hallname;
  const NoticePage({super.key, required this.hallname});

  @override
  State<NoticePage> createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
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
      // Pass hallname as query parameter
      final url = Uri.parse('http://127.0.0.1:8000/notices?hall_name=${Uri.encodeComponent(widget.hallname)}');

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _allNotices = data.map((json) => Notice.fromJson(json)).toList();
          _filteredNotices = List.from(_allNotices);
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

  Future<void> deleteNotice(String noticeId) async {
    final url = Uri.parse('http://127.0.0.1:8000/notices/$noticeId');
    final response = await http.delete(url);
    if (response.statusCode == 200) {
      setState(() {
        _allNotices.removeWhere((notice) => notice.id == noticeId);
        _filteredNotices.removeWhere((notice) => notice.id == noticeId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notice deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete notice: ${response.body}')),
      );
    }
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
      return Text('Notice Board - ${widget.hallname}'); // Show hall name
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
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage))
          : _filteredNotices.isEmpty
          ? const Center(child: Text("No notices found"))
          : ListView.builder(
        itemCount: _filteredNotices.length,
        itemBuilder: (context, index) {
          final notice = _filteredNotices[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(notice.title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Posted: ${notice.timestamp.toLocal().toString().split(' ')[0]}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    "Hall: ${notice.hallName}",
                    style: const TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirm Delete'),
                          content: const Text('Are you sure you want to delete this notice?'),
                          actions: [
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () => Navigator.pop(context, false),
                            ),
                            TextButton(
                              child: const Text('Delete'),
                              onPressed: () => Navigator.pop(context, true),
                            ),
                          ],
                        ),
                      );

                      if (confirmed ?? false) {
                        await deleteNotice(notice.id);
                      }
                    },
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NoticeDetailPage(notice: notice),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}