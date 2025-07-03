import 'package:flutter/material.dart';
import 'notice_page.dart'; // if Notice model is there

class NoticeDetailPage extends StatelessWidget {
  final Notice notice;

  const NoticeDetailPage({super.key, required this.notice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notice Details"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notice.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Posted on: ${notice.timestamp.toLocal().toString().split(' ')[0]}",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const Divider(height: 20),
            Text(
              notice.message,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
