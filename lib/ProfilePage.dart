import 'dart:convert';
import 'package:Xolve/EditCustomerProfile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  User? _currentUser;
  String? _photoCacheBuster;
  String? _cachedPhotoURL;
  String? _cachedDisplayName;
  String? _cachedDescription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentUser = FirebaseAuth.instance.currentUser;
    _photoCacheBuster = DateTime.now().millisecondsSinceEpoch.toString();

    if (_currentUser != null) {
      _cachedPhotoURL = _currentUser!.photoURL;
      _cachedDisplayName =
          _currentUser!.displayName ?? _currentUser!.email ?? 'User';
    }

    _listenToProfileUpdates();
  }

  void _listenToProfileUpdates() {
    final user = _currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) return;
      final data = snapshot.data()!;
      final newPhoto = data['photoURL'];
      final newName = data['name'] ?? _cachedDisplayName;
      final newBio = data['bio'] ?? 'No description available';

      if (mounted &&
          (newPhoto != _cachedPhotoURL ||
              newName != _cachedDisplayName ||
              newBio != _cachedDescription)) {
        setState(() {
          _cachedPhotoURL = newPhoto;
          _cachedDisplayName = newName;
          _cachedDescription = newBio;
          _photoCacheBuster = DateTime.now().millisecondsSinceEpoch.toString();
        });
      }
    });
  }

  void _refreshPhotoCache() {
    setState(() {
      _photoCacheBuster = DateTime.now().millisecondsSinceEpoch.toString();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child:
              Text('No user logged in', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.zero,
              minimumSize: const Size(40, 40),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () async {
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfilePage(),
                  ),
                );
                if (updated == true) {
                  _refreshPhotoCache();
                }
              },
              child: const Text('Edit Profile',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.zero,
                minimumSize: const Size(40, 40),
              ),
              onPressed: () {},
              child: const Icon(Icons.more_horiz, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 50),
              CircleAvatar(
                radius: 60,
                backgroundImage: (_cachedPhotoURL != null &&
                        _cachedPhotoURL!.isNotEmpty)
                    ? NetworkImage("${_cachedPhotoURL!}?v=$_photoCacheBuster")
                    : null,
                child: (_cachedPhotoURL == null || _cachedPhotoURL!.isEmpty)
                    ? Text(
                        (_cachedDisplayName != null &&
                                _cachedDisplayName!.isNotEmpty)
                            ? _cachedDisplayName![0].toUpperCase()
                            : 'U',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 40),
                      )
                    : null,
              ),
              const SizedBox(height: 12),
              Text(
                _cachedDisplayName ?? 'User',
                style: GoogleFonts.inriaSerif(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                'Customer',
                style:
                    GoogleFonts.inriaSerif(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 12),
              Text(
                _cachedDescription ?? 'No description available',
                textAlign: TextAlign.center,
                style: GoogleFonts.inriaSerif(
                    fontSize: 14, color: Colors.white70, height: 1.5),
              ),
              const SizedBox(height: 20),
              TabBar(
                controller: _tabController,
                labelColor: Colors.greenAccent,
                unselectedLabelColor: Colors.white,
                indicatorColor: Colors.greenAccent,
                tabs: const [
                  Tab(text: 'Problem'),
                  Tab(text: 'Reviews'),
                  Tab(text: 'Pitching'),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 500,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProblemTab(),
                    _buildReviewsTab(),
                    _buildPitchingTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProblemTab() {
    final uid = _currentUser!.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('customer_issues')
          .where('uid', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.white));
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(
              child: Text('No problems posted yet',
                  style: TextStyle(color: Colors.white70)));
        }

        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (_, __) =>
              const Divider(color: Colors.white24, thickness: 0.4),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return _buildPostRow(
              profileImage: data['photoURL'],
              userName: data['fullName'] ?? 'User',
              title: data['fullName'] ?? 'Other',
              subtitle: data['companyName'] ?? 'Category',
              description: data['issueDetails'] ?? 'No details provided',
            );
          },
        );
      },
    );
  }

  Widget _buildPitchingTab() {
    final uid = _currentUser!.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('idea_pitched')
          .where('uid', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.white));
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(
              child: Text('No ideas pitched yet',
                  style: TextStyle(color: Colors.white70)));
        }

        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (_, __) =>
              const Divider(color: Colors.white24, thickness: 0.4),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return _buildPostRow(
              profileImage: data['photoURL'],
              userName: data['userName'] ?? 'User',
              title: data['userName'] ?? 'Untitled Idea',
              subtitle: data['title'] ?? 'No contact info',
              description: data['description'] ?? 'No details provided',
            );
          },
        );
      },
    );
  }

  Widget _buildReviewsTab() {
    final uid = _currentUser!.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('reviews').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.white));
        }
        final docs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final votedUsers =
              List<Map<String, dynamic>>.from(data['votedUsers'] ?? []);
          return votedUsers.any((user) => user['uid'] == uid);
        }).toList();

        if (docs.isEmpty) {
          return const Center(
              child: Text('No voted reviews yet',
                  style: TextStyle(color: Colors.white70)));
        }

        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (_, __) =>
              const Divider(color: Colors.white24, thickness: 0.4),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return Container(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReviewAvatar(data),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['productName'] ?? 'Unnamed Product',
                            style: GoogleFonts.inriaSerif(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(data['companyName'] ?? 'Other',
                            style: GoogleFonts.inriaSerif(
                                color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 8),
                        Text(
                            data['reviewDescription'] ??
                                'No description available',
                            style: GoogleFonts.inriaSerif(
                                color: const Color.fromARGB(255, 240, 240, 240),
                                fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPostRow({
    required dynamic profileImage,
    required String userName,
    required String title,
    required String subtitle,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(profileImage, userName),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.inriaSerif(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: GoogleFonts.inriaSerif(
                        color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
                Text(description,
                    style: GoogleFonts.inriaSerif(
                        color: const Color.fromARGB(255, 240, 240, 240),
                        fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(dynamic profileImage, String userName) {
    if (profileImage != null && profileImage.toString().isNotEmpty) {
      if (profileImage.toString().startsWith('data:image')) {
        final base64Str = profileImage.split(',').last;
        return CircleAvatar(
          radius: 22,
          backgroundColor: Colors.white,
          backgroundImage: MemoryImage(base64Decode(base64Str)),
        );
      } else {
        final freshUrl = "${profileImage.toString()}?v=$_photoCacheBuster";
        return CircleAvatar(
          radius: 22,
          backgroundImage: NetworkImage(freshUrl),
        );
      }
    } else {
      return CircleAvatar(
        radius: 22,
        backgroundColor: Colors.white,
        child: Text(
          userName.isNotEmpty ? userName[0].toUpperCase() : '?',
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      );
    }
  }

  Widget _buildReviewAvatar(Map<String, dynamic> data) {
    final productImageUrl = data['productImageUrl'];
    if (productImageUrl != null && productImageUrl.toString().isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          productImageUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.business, color: Colors.white, size: 26),
            );
          },
        ),
      );
    } else {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: const Icon(Icons.business, color: Colors.white70, size: 26),
      );
    }
  }
}
