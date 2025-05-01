import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Ensure you have the 'url_launcher' package added

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        throw 'Could not launch email';
      }
    } catch (e) {
      debugPrint('Error launching email: $e');
      // Optional: Show error to user
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Could not launch email app')),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.teal[700],
        title: const Text('About Us'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Our Team',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
              ),
            ),
            const SizedBox(height: 20),
            _buildTeamCard(
              context,
              name: 'Dipta',
              role: 'Team Lead',
              email: 'dipta@gmail.com',
              imageUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
              roleColor: Colors.deepOrange,
            ),
            const SizedBox(height: 16),
            _buildTeamCard(
              context,
              name: 'Nadim Mahmud',
              role: 'Developer',
              email: 'nadim@gmail.com',
              imageUrl: 'https://randomuser.me/api/portraits/women/1.jpg',
              roleColor: Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildTeamCard(
              context,
              name: 'Tamal',
              role: 'Developer',
              email: 'tamal@gmail.com',
              imageUrl: 'https://randomuser.me/api/portraits/men/2.jpg',
              roleColor: Colors.green,
            ),
            const SizedBox(height: 16),
            _buildTeamCard(
              context,
              name: 'Jotish',
              role: 'Developer',
              email: 'jotish@gmail.com',
              imageUrl: 'https://randomuser.me/api/portraits/men/2.jpg',
              roleColor: Colors.purple,
            ),
            const SizedBox(height: 30),
            Center(
              child: _buildBackButton(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamCard(
      BuildContext context, {
        required String name,
        required String role,
        required String email,
        required String imageUrl,
        required Color roleColor,
      }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(imageUrl),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: roleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role,
                    style: TextStyle(
                      color: roleColor.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _launchEmail(email),
                    child: Text(
                      email,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.pop(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        elevation: 5,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      child: const Text(
        'Back to Home',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
