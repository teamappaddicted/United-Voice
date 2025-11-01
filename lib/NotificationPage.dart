import 'package:Xolve/Aboutuspage.dart';
import 'package:Xolve/Getsrewardspage.dart';
import 'package:Xolve/HelpCenterPage.dart';
import 'package:Xolve/ProfilePage.dart';
import 'package:Xolve/TermsAndConditionsPage.dart';
import 'package:Xolve/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';


class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _notificationsPlugin.initialize(initSettings,
        onDidReceiveNotificationResponse: (response) async {
      if (response.payload == 'open_notifications') {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const NotificationPage()),
          );
        }
      }
    });
  }

  String _getFirstLetter(String? name) {
    if (name == null || name.isEmpty) return "?";
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final String firstLetter = _getFirstLetter(currentUser?.displayName);

    return Scaffold(
      backgroundColor: Colors.black,
      drawer: _buildDrawer(context), // ✅ Reuse same drawer as unitedvoiceapp.dart
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Builder(
                  builder: (context) => GestureDetector(
                    onTap: () => Scaffold.of(context).openDrawer(),
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUser!.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white10,
                          );
                        }

                        final data =
                            snapshot.data!.data() as Map<String, dynamic>?;
                        final photoUrl = data?['photoURL'] ?? '';
                        return CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white10,
                          backgroundImage: (photoUrl.isNotEmpty)
                              ? NetworkImage(
                                  "$photoUrl?cache=${DateTime.now().millisecondsSinceEpoch}")
                              : null,
                          child: (photoUrl.isEmpty)
                              ? Text(
                                  firstLetter,
                                  style: GoogleFonts.inriaSerif(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                )
                              : null,
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "Notifications",
                      style: GoogleFonts.lora(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.settings,
                      color: Colors.white, size: 24),
                ),
              ],
            ),
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('receiverId', isEqualTo: currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.white));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Something went wrong!",
                  style: GoogleFonts.poppins(color: Colors.redAccent)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No notifications yet!",
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          var notifications = snapshot.data!.docs;
          notifications.sort((a, b) {
            var aTime =
                (a['timestamp'] as Timestamp?)?.toDate() ?? DateTime(2000);
            var bTime =
                (b['timestamp'] as Timestamp?)?.toDate() ?? DateTime(2000);
            return bTime.compareTo(aTime);
          });

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const Divider(
              color: Colors.white24,
              thickness: 0.6,
              height: 28,
            ),
            itemBuilder: (context, index) {
              var data = notifications[index].data() as Map<String, dynamic>;

              String senderName = data['senderName'] ?? 'Unknown';
              String senderPhoto = data['senderPhoto'] ?? '';
              String message = data['message'] ?? '';
              String postType = data['postType'] ?? '';
              Timestamp? timestamp = data['timestamp'];

              String displayMessage = message;
              if (data['type'] == 'vote' && postType.isNotEmpty) {
                displayMessage = 'Voted your $postType';
              }

              final senderImage = senderPhoto.isNotEmpty
                  ? '$senderPhoto?cache=${DateTime.now().millisecondsSinceEpoch}'
                  : '';

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage: senderImage.isNotEmpty
                          ? NetworkImage(senderImage)
                          : const AssetImage('assets/default_profile.png')
                              as ImageProvider,
                      radius: 20,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(
                              text: "@$senderName ",
                              style:
                                  const TextStyle(color: Colors.tealAccent),
                            ),
                            TextSpan(text: displayMessage),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _timeAgo(timestamp),
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ✅ Copied directly from your unitedvoiceapp.dart drawer definition
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF111113),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.white));
              }

              final data = snapshot.data?.data() as Map<String, dynamic>?;
              final displayName =
                  data?['name'] ?? currentUser!.displayName ?? 'User';
              final photoUrl =
                  data?['photoURL'] ?? currentUser!.photoURL ?? '';
              final email = data?['email'] ?? currentUser!.email ?? '';
              final firstLetter = displayName.isNotEmpty
                  ? displayName[0].toUpperCase()
                  : 'U';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.black26,
                        backgroundImage: (photoUrl.isNotEmpty)
                            ? NetworkImage(
                                "$photoUrl?timestamp=${DateTime.now().millisecondsSinceEpoch}")
                            : null,
                        child: (photoUrl.isEmpty)
                            ? Text(
                                firstLetter,
                                style: GoogleFonts.inriaSerif(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              )
                            : null,
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_circle_left_outlined,
                            color: Colors.white, size: 35),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(displayName,
                      style: GoogleFonts.inriaSerif(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(email,
                      style: GoogleFonts.inriaSerif(
                          color: Colors.white54, fontSize: 14)),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(Icons.person_outline,
                        color: Colors.white),
                    title: Text('Profile',
                        style: GoogleFonts.inriaSerif(color: Colors.white)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProfilePage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded,
                        color: Colors.white),
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('About ',
                            style: GoogleFonts.inriaSerif(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16)),
                        SizedBox(
                          height: 14,
                          child: Image.asset('assets/Xolve logo .png',
                              fit: BoxFit.contain),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AboutUsPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.card_giftcard_outlined,
                        color: Colors.white),
                    title: Text('Get Rewards & Gifts',
                        style: GoogleFonts.inriaSerif(color: Colors.white)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const GetRewardsPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.description_outlined,
                        color: Colors.white),
                    title: Text('Terms & Conditions',
                        style: GoogleFonts.inriaSerif(color: Colors.white)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const TermsAndConditionsPage()),
                      );
                    },
                  ),
                  const Spacer(),
                  const Divider(color: Colors.white24, height: 1),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined,
                        color: Colors.white70),
                    title: Text('Settings & Privacy',
                        style: GoogleFonts.inriaSerif(color: Colors.white)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SettingsPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.help_outline,
                        color: Colors.white70),
                    title: Text('Help Center',
                        style: GoogleFonts.inriaSerif(color: Colors.white)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HelpCenterPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _timeAgo(Timestamp? timestamp) {
    if (timestamp == null) return "";
    final now = DateTime.now();
    final diff = now.difference(timestamp.toDate());
    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m";
    if (diff.inHours < 24) return "${diff.inHours}h";
    if (diff.inDays < 7) return "${diff.inDays}d";
    return "${diff.inDays ~/ 7}w";
  }
}
