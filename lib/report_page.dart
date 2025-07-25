import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'report_detail_page.dart';
import 'ServerLink.dart';

class Report {
  final String id;
  final String email;
  final String title;
  final String message;
  final DateTime timestamp;
  final String hallName; // Added hallName field

  Report({
    required this.email,
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.hallName, // Added to constructor
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      email: json['email'],
      id: json['id'],
      title: json['title'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      hallName: json['hall_name'] ?? 'Unknown Hall', // Added hallName
    );
  }
}

class ReportPage extends StatefulWidget {
  final String hallName; // Add hallName parameter

  const ReportPage({super.key, required this.hallName});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  List<Report> _allReports = [];
  List<Report> _filteredReports= [];
  bool _isLoading = true;
  String _errorMessage = '';

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchReports();
    _searchController.addListener(_filterReports);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchReports() async {
    try {
      // Add hall_name parameter to API call
      final url = Uri.parse('$baseUrl/reports?hall_name=${widget.hallName}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _allReports = data.map((json) => Report.fromJson(json)).toList();
        _filteredReports = List.from(_allReports);
      } else {
        _errorMessage = 'Failed to load reports: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _filterReports() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredReports = List.from(_allReports);
      } else {
        _filteredReports = _allReports.where((report) {
          final titleLower = report.title.toLowerCase();
          final messageLower = report.message.toLowerCase();
          return titleLower.contains(query) || messageLower.contains(query);
        }).toList();
      }
    });
  }

  Future<void> deleteReport(String reportId) async {
    // Add hall_name parameter to delete request
    final url = Uri.parse('$baseUrl/reports/$reportId?hall_name=${widget.hallName}');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      setState(() {
        _allReports.removeWhere((report) => report.id == reportId);
        _filteredReports.removeWhere((report) => report.id == reportId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete report: ${response.body}')),
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
      _filteredReports = List.from(_allReports);
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
            hintText: 'Search Reports...',
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
      return Text('Reports - ${widget.hallName}'); // Show hall name in title
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
          : _filteredReports.isEmpty
          ? const Center(child: Text("No reports found for this hall"))
          : ListView.builder(
        itemCount: _filteredReports.length,
        itemBuilder: (context, index) {
          final report = _filteredReports[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(
                report.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Posted by: ${report.email}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    "Hall: ${report.hallName}", // Show hall name in list
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    "Posted on: ${report.timestamp.toLocal().toString().split(' ')[0]}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                          content: const Text('Are you sure you want to delete this report?'),
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
                        await deleteReport(report.id);
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
                    builder: (_) => ReportDetailPage(report: report),
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