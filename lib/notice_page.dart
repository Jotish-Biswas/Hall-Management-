import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'notice_detail_page.dart';

class Notice {
  final String title;
  final String message;
  final DateTime timestamp;

  Notice({
    required this.title,
    required this.message,
    required this.timestamp,
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      title: json['title'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class NoticePage extends StatefulWidget {
  const NoticePage({super.key});

  @override
  State<NoticePage> createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  late Future<List<Notice>> _futureNotices;

  @override
  void initState() {
    super.initState();
    _futureNotices = fetchNotices();
  }

  Future<List<Notice>> fetchNotices() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/notices'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Notice.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load notices");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notice Board"), backgroundColor: Colors.blueGrey),
      body: FutureBuilder<List<Notice>>(
        future: _futureNotices,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No notices available."));
          }

          final notices = snapshot.data!;
          return ListView.builder(
            itemCount: notices.length,
            itemBuilder: (context, index) {
              final notice = notices[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(notice.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    "Posted: ${notice.timestamp.toLocal().toString().split(' ')[0]}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
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
          );
        },
      ),
    );
  }
}
