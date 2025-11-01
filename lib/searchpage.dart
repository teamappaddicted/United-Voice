import 'package:Xolve/Aboutuspage.dart';
import 'package:Xolve/Getsrewardspage.dart';
import 'package:Xolve/HelpCenterPage.dart';
import 'package:Xolve/ProfilePage.dart';
import 'package:Xolve/TermsAndConditionsPage.dart';
import 'package:Xolve/settings_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';


class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _searchQuery = '';
  String? _photoUrl;
  late final User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _photoUrl = _user?.photoURL;
    _refreshProfilePhoto();
  }

  Future<void> _refreshProfilePhoto() async {
    if (_user == null) return;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .get();

    if (userDoc.exists) {
      final newPhotoUrl = userDoc.data()?['photoURL'];
      if (mounted && newPhotoUrl != null) {
        final freshUrl =
            '$newPhotoUrl?cache=${DateTime.now().millisecondsSinceEpoch}';
        if (freshUrl != _photoUrl) {
          setState(() => _photoUrl = freshUrl);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0D),

      // ✅ Drawer now covers full screen height
      drawer: Drawer(
        backgroundColor: const Color(0xFF111113),
        child: SizedBox.expand(
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

                final displayName = (() {
                  final name = data?['name']?.toString().trim();
                  if (name != null && name.isNotEmpty) return name;
                  return currentUser.displayName ?? 'User';
                })();

                final photoUrl = (() {
                  final p = data?['photoURL']?.toString().trim();
                  return (p != null && p.isNotEmpty) ? p : currentUser.photoURL;
                })();

                final email = (() {
                  final e = data?['email']?.toString().trim();
                  if (e != null && e.isNotEmpty) return e;
                  return currentUser.email ?? '';
                })();

                final firstLetter =
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.black26,
                          backgroundImage: (photoUrl != null &&
                                  photoUrl.isNotEmpty)
                              ? NetworkImage(
                                  "$photoUrl?timestamp=${DateTime.now().millisecondsSinceEpoch}")
                              : null,
                          child: (photoUrl == null || photoUrl.isEmpty)
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
                      leading:
                          const Icon(Icons.person_outline, color: Colors.white),
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
                          Text(
                            'About ',
                            style: GoogleFonts.inriaSerif(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            height: 14,
                            child: Image.asset(
                              'assets/Xolve logo .png',
                              fit: BoxFit.contain,
                            ),
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
                      leading:
                          const Icon(Icons.help_outline, color: Colors.white70),
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
      ),

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              child: Row(
                children: [
                  Builder(
                    builder: (context) => GestureDetector(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white12,
                        backgroundImage: _photoUrl != null
                            ? NetworkImage(_photoUrl!)
                            : null,
                        child: _photoUrl == null
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatefulBuilder(
                      builder: (context, setInnerState) {
                        return Container(
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextField(
                            onChanged: (value) {
                              setInnerState(() => _searchQuery = value.trim());
                              setState(() {});
                            },
                            style: GoogleFonts.inriaSerif(
                                color: Colors.white, fontSize: 16),
                            decoration: InputDecoration(
                              hintText: 'Search',
                              hintStyle: GoogleFonts.inriaSerif(
                                  color: Colors.white54),
                              border: InputBorder.none,
                              prefixIcon: const Icon(Icons.search,
                                  color: Colors.white54, size: 22),
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SettingsPage()),
                      ).then((_) => _refreshProfilePhoto());
                    },
                    icon: const Icon(Icons.settings,
                        color: Colors.white, size: 24),
                  ),
                ],
              ),
            ),
            Container(
              height: 1,
              color: Colors.white12,
              margin: const EdgeInsets.only(bottom: 6),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('companies')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(color: Colors.white));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                        child: Text('No companies found.',
                            style: GoogleFonts.inriaSerif(
                                color: Colors.white70, fontSize: 16)));
                  }

                  final filteredCompanies = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['name'] ?? '').toString().toLowerCase();
                    final category =
                        (data['category'] ?? '').toString().toLowerCase();
                    return name.contains(_searchQuery.toLowerCase()) ||
                        category.contains(_searchQuery.toLowerCase());
                  }).toList();

                  if (filteredCompanies.isEmpty) {
                    return Center(
                      child: Text('No results for "$_searchQuery"',
                          style: GoogleFonts.inriaSerif(
                              color: Colors.white54)),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 10.0),
                    itemCount: filteredCompanies.length,
                    separatorBuilder: (_, __) =>
                        const Divider(color: Colors.white12, height: 22),
                    itemBuilder: (context, index) {
                      final data = filteredCompanies[index].data()
                          as Map<String, dynamic>;
                      final companyName = data['name'] ?? 'Unnamed';
                      final logoUrl = data['logoURL'] ?? '';
                      final description =
                          (data['description']?.toString().trim().isNotEmpty ??
                                  false)
                              ? data['description']
                              : 'No description available for this company.';
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: logoUrl.isNotEmpty
                                ? Image.network(
                                    '$logoUrl?ts=${DateTime.now().millisecondsSinceEpoch}',
                                    width: 55,
                                    height: 55,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 55,
                                    height: 55,
                                    color: const Color(0xFF1E1E1E),
                                    child: const Icon(Icons.business,
                                        color: Colors.white, size: 26),
                                  ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(companyName,
                                    style: GoogleFonts.inriaSerif(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                    )),
                                const SizedBox(height: 6),
                                Text(description,
                                    style: GoogleFonts.inriaSerif(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      height: 1.4,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
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
