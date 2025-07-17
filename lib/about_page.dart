import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamMembers = [
      {
        'name': 'Dipta Bhattacharjee',
        'role': 'Developer',
        'email': 'diptabhattacharjee117@gmail.com',
        'imageUrl': 'https://scontent.fdac31-2.fna.fbcdn.net/v/t39.30808-6/504060671_689736527552414_1882365572320882137_n.jpg?_nc_cat=107&ccb=1-7&_nc_sid=6ee11a&_nc_eui2=AeHWz9YOFvhMFQwmA_N96E0o1-xKYgPe6wXX7EpiA97rBXISi0LXlyu9C7QnRFJjsPCrAuMUOuHJeUKQhcxJwJ_v&_nc_ohc=7yheXnjJsYEQ7kNvwF0_7rN&_nc_oc=AdkRNgUPfeeqCenOodWwJD0u4GDwcWwTTbv8oMy5kbqAumKSHYfdkEHvdsHajDJ8Rlw&_nc_zt=23&_nc_ht=scontent.fdac31-2.fna&_nc_gid=nuu8t_NVqgbOfku-gyerfg&oh=00_AfRfXqZO0rAddqPiNu4fscod0hNPb-CPYrjkvpN4NaYl3w&oe=687C3E29',
        'social': {'linkedin': '#', 'github': '#'}
      },
      {
        'name': 'Nadim Mahmud',
        'role': 'Developer',
        'email': 'nadimc119@gmail.com',
        'imageUrl': 'https://scontent.fdac31-1.fna.fbcdn.net/v/t39.30808-6/503361527_1226212258975107_5929252310696936115_n.jpg?_nc_cat=110&ccb=1-7&_nc_sid=6ee11a&_nc_eui2=AeGTZBtOV-A0hQPikniBmNhFxDJbif9Vol_EMluJ_1WiX6PCdAyqNmo6V7BhOLxsvdYoGr5-uN1OPZ2zuzbsBCHD&_nc_ohc=rMEoH9VMVxEQ7kNvwHQB443&_nc_oc=AdnKLxGlz_FSHpaK3AKoxu_TmomFAWEB9pY9TGvTeVX83-818g3qOraa0nvtpIG8UHc&_nc_zt=23&_nc_ht=scontent.fdac31-1.fna&_nc_gid=dFyEf0ysHX6z7I65ZVqZiQ&oh=00_AfReBmEw5XzvtUXeQMynrafI5ASu-kWHoa5oyDauNoypeA&oe=687C240D',
        'social': {'linkedin': '#', 'github': '#'}
      },
      {
        'name': 'Tamal Kanti',
        'role': 'Developer',
        'email': 'tamalkanti223@gmail.com',
        'imageUrl': 'https://scontent.fdac31-1.fna.fbcdn.net/v/t39.30808-6/475984362_1164573048566231_5267686621254393992_n.jpg?_nc_cat=102&ccb=1-7&_nc_sid=cc71e4&_nc_eui2=AeFmWtcou5Fj2IAcFKOw995_TfEU6J3WOvpN8RTondY6-rdFprZbexKjvrh_a8_GuJ3AlaQlsZq97Y1uSqg10KIB&_nc_ohc=YbnoxRB7QOUQ7kNvwE-HPKX&_nc_oc=AdkxxmiBjeAhF0sonU_abjoHDyJX4NkrW2wD9FmRg6Wxfx6iMfwM_YQRUVL7cXkidfg&_nc_zt=23&_nc_ht=scontent.fdac31-1.fna&_nc_gid=VBZcXEP8L3uN4Qu9esVigg&oh=00_AfQt9E9TzE7O9PDS9D3d9ZZ_D6A6CwS0ZnsHBi4beJTMFw&oe=687C3844',
        'social': {'linkedin': '#', 'github': '#'}
      },
      {
        'name': 'Jotish Biswas',
        'role': 'Developer',
        'email': '1rjbiswas@gmail.com',
        'imageUrl': 'https://scontent.fdac31-2.fna.fbcdn.net/v/t39.30808-6/482225901_642037672097256_3730515934046412776_n.jpg?_nc_cat=104&ccb=1-7&_nc_sid=6ee11a&_nc_eui2=AeGKvODjjI6Jm6zWJaWujcvaYp3E8q7qXZJincTyrupdkttA_jL1RRmDByqUHmb9HR-Qt8TL9Et1vKZLzy-NBG_L&_nc_ohc=RJ6JFHOBVtsQ7kNvwHMsKjr&_nc_oc=Admnz1UozAn2ZLhWNCCohUHY8_1axHmgcPl4Gpvd_omwKraRvkP54x-QKT8WZlOgs4I&_nc_zt=23&_nc_ht=scontent.fdac31-2.fna&_nc_gid=jepeOO8HED4rL8Be4DG96Q&oh=00_AfSq00Q6RumJBKCGM6aak6Zg3jLPlwEB-3dQX_1Jpwvt6g&oe=687C20C3',
        'social': {'linkedin': '#', 'github': '#'}
      },
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('About Us', 
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: Colors.black45,
                      offset: Offset(1, 1),
                    )
                  ],
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.people_alt, size: 60, color: Colors.white),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  Text(
                    'OUR TEAM',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: const Color(0xFF2C5364),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Meet the talented individuals behind our success',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final member = teamMembers[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: _TeamMemberCard(
                    name: member['name'] as String,
                    role: member['role'] as String,
                    email: member['email'] as String,
                    imageUrl: member['imageUrl'] as String,
                    social: member['social'] as Map<String, String>,
                    onEmailTap: _launchEmail,

                  ),
                );
              },
              childCount: teamMembers.length,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('BACK TO HOME'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C5364),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  canLaunchUrl(Uri emailUri) async => true;
  launchUrl(Uri emailUri) async => true;
}

class _TeamMemberCard extends StatelessWidget {
  final String name;
  final String role;
  final String email;
  final String imageUrl;
  final Map<String, String> social;
  final Function(String) onEmailTap;

  const _TeamMemberCard({
    required this.name,
    required this.role,
    required this.email,
    required this.imageUrl,
    required this.social,
    required this.onEmailTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Avatar with fallback icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) => const Icon(Icons.person),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        role,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Email with icon
                      InkWell(
                        onTap: () => onEmailTap(email),
                        child: Row(
                          children: [
                            Icon(Icons.email_outlined, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                email,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 14,
                                ),
                                softWrap: true,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ],
                        ),

                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Social media links with icons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.link),
                  onPressed: () => launchUrl(Uri.parse(social['linkedin']!)),
                  tooltip: 'LinkedIn',
                ),
                IconButton(
                  icon: const Icon(Icons.code),
                  onPressed: () => launchUrl(Uri.parse(social['github']!)),
                  tooltip: 'GitHub',
                ),
                IconButton(
                  icon: const Icon(Icons.public),
                  onPressed: () => launchUrl(Uri.parse('#')),
                  tooltip: 'Website',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}