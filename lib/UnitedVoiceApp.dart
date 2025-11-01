// --- Imports ---
import 'dart:convert';
import 'package:Xolve/Aboutuspage.dart';
import 'package:Xolve/AnalyticsPage.dart';
import 'package:Xolve/CustomerIssuePage.dart';
import 'package:Xolve/Getsrewardspage.dart';
import 'package:Xolve/HelpCenterPage.dart';
import 'package:Xolve/IdeaPitchingPage.dart';
import 'package:Xolve/NotificationPage.dart';
import 'package:Xolve/ProfilePage.dart';
import 'package:Xolve/TermsAndConditionsPage.dart';
import 'package:Xolve/searchpage.dart';
import 'package:Xolve/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cached_network_image/cached_network_image.dart';

// --- Problem Model UPDATED ---
class Problem {
  final String id;
  final String fullName;
  final String issueDetails;
  final String category;
  final String companyName;
  final String userAvatar;
  final String? photoURL;
  final int votes;
  final String uid;

  final List<Map<String, dynamic>> votedUsers;

  Problem({
    required this.id,
    required this.fullName,
    required this.issueDetails,
    required this.category,
    required this.companyName,
    required this.userAvatar,
    required this.votes,
    required this.photoURL,
    required this.uid,
    required this.votedUsers,
  });

  factory Problem.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Problem(
      id: doc.id,
      uid: data['uid'] ?? '',
      photoURL: data['photoURL'],
      fullName: data['fullName'] ?? '',
      issueDetails: data['issueDetails'] ?? '',
      category: data['category'] ?? '',
      companyName: data['companyName'] ?? '',
      userAvatar: data['userAvatar'] ??
          'https://ui-avatars.com/api/?name=${data['fullName'] ?? 'User'}',
      votes: data['votesCount'] ?? 0,
      votedUsers: (data['votedUsers'] as List<dynamic>?)
              ?.map((user) => Map<String, dynamic>.from(user))
              .toList() ??
          [],
    );
  }
}



// --- Main App ---
class UnitedVoiceApp extends StatelessWidget {
  const UnitedVoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xolve',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0B0D),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B0B0D),
          elevation: 0,
        ),
        // TabBar theming removed from ThemeData to avoid TabBarTheme/TabBarThemeData mismatch;
        // Individual TabBar widgets are themed directly where needed.
        textTheme: TextTheme(
          titleLarge: GoogleFonts.inriaSerif(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          bodyMedium: GoogleFonts.inriaSerif(
              fontSize: 15, color: Colors.white70, height: 1.5),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      
    );
  }
}

// --- Home Screen with Voting Functionality ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  String? _cachedPhotoUrl; // to store the profile image once
  String? _displayName;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _cachedPhotoUrl = user?.photoURL;
    _displayName = user?.displayName ?? user?.email ?? 'User';

    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        final updatedPhotoUrl = data['photoURL'];
        final updatedName = data['name'] ?? _displayName;

        // Update only if something changes
        if (mounted &&
            (updatedPhotoUrl != _cachedPhotoUrl ||
                updatedName != _displayName)) {
          setState(() {
            _cachedPhotoUrl = updatedPhotoUrl;
            _displayName = updatedName;
          });
        }
      }
    });

    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- Voting Logic ---
  Future<void> _toggleVote(Problem problem) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userData = {
      'uid': currentUser.uid,
      'name': currentUser.displayName ?? currentUser.email ?? 'User',
      'photoURL': currentUser.photoURL ?? '',
      'email': currentUser.email ?? '',
    };

    try {
      await VoteService.toggleVoteForDoc(
        collectionName: 'customer_issues',
        docId: problem.id,
        authorId: problem.uid, // use Problem.uid as author id
        userData: userData,
        postType: 'problem', // 👈 added postType for problem posts
      );
    } catch (e) {
      debugPrint('Error toggling vote (problem): $e');
      // Optionally: show a SnackBar or toast here
    }
  }

  // --- Top Bar ---
  Widget _buildTopBar() {
    final firstLetter =
        _displayName!.isNotEmpty ? _displayName![0].toUpperCase() : 'U';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Row(
        children: [
          Builder(
            builder: (context) => GestureDetector(
              onTap: () {
                Scaffold.of(context).openDrawer();
              },
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white10,
                backgroundImage:
                    (_cachedPhotoUrl != null && _cachedPhotoUrl!.isNotEmpty)
                        ? CachedNetworkImageProvider(_cachedPhotoUrl!)
                        : null,
                child: (_cachedPhotoUrl == null || _cachedPhotoUrl!.isEmpty)
                    ? Text(
                        firstLetter,
                        style: GoogleFonts.inriaSerif(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: SizedBox(
                height: 16,
                child: Image.asset(
                  'assets/Xolve logo .png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            icon: const Icon(Icons.settings, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  // --- List Item w/ Voting UI ---
  Widget _buildListItem(Problem problem) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final votedUsers = problem.votedUsers;
    final hasVoted = votedUsers.any((user) => user['uid'] == currentUser?.uid);

    // Prepare up to four avatars
    List<Widget> avatars = [];
    int maxDisplayAvatars = 4;
    for (var i = 0; i < votedUsers.length && i < maxDisplayAvatars; ++i) {
      final user = votedUsers[i];
      final photoURL = user['photoURL'] ?? '';
      final cacheBustedUrl = photoURL.isNotEmpty
          ? '$photoURL?t=${DateTime.now().millisecondsSinceEpoch}'
          : '';

      avatars.add(
        Padding(
          key: ValueKey(user['uid']),
          padding: EdgeInsets.only(left: i == 0 ? 0 : 12),
          child: CircleAvatar(
            radius: 10,
            backgroundColor: Colors.white,
            backgroundImage: cacheBustedUrl.isNotEmpty
                ? NetworkImage(cacheBustedUrl)
                : const AssetImage('assets/avatar1.jpg') as ImageProvider,
          ),
        ),
      );
    }

    // Voters section
    Widget votedSection;
    if (votedUsers.isEmpty) {
      votedSection = const Text("No votes",
          style: TextStyle(color: Colors.grey, fontSize: 12));
    } else {
      votedSection = GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => VotersListPage(voters: problem.votedUsers)),
          );
        },
        child: Row(
          children: [
            Stack(children: avatars.reversed.toList()),
            if (votedUsers.length > maxDisplayAvatars)
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  '+${votedUsers.length - maxDisplayAvatars}',
                  style: GoogleFonts.inriaSerif(
                      color: Colors.white70, fontSize: 14),
                ),
              ),
          ],
        ),
      );
    }

    final voteButton = GestureDetector(
      onTap: () => _toggleVote(problem),
      child: Container(
        decoration: BoxDecoration(
          color: hasVoted ? const Color(0xFF1BBD97) : const Color(0xFF0F0F0F),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white30, width: 1.2),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Text(
          hasVoted ? 'Voted' : 'Vote',
          style: GoogleFonts.inriaSerif(
            color: hasVoted ? Colors.black : Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );

    final voteCountWidget = GestureDetector(
      onTap: () {
        if (problem.votedUsers.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => VotersListPage(voters: problem.votedUsers)),
          );
        }
      },
      child: Text(
        '+${problem.votes} votes',
        style: GoogleFonts.inriaSerif(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  Builder(
                    builder: (context) {
                      Widget buildAvatar() {
                        final profileImage = problem.photoURL ?? '';
                        final userName = problem.fullName.isNotEmpty
                            ? problem.fullName
                            : 'User';
                        final cacheBustedProfileUrl = profileImage.isNotEmpty &&
                                !profileImage.startsWith('data:image')
                            ? '$profileImage?t=${DateTime.now().millisecondsSinceEpoch}'
                            : profileImage;

                        if (profileImage.isNotEmpty) {
                          if (profileImage.startsWith('data:image')) {
                            // Case 1: Base64 image
                            final base64Str = profileImage.split(',').last;
                            return CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.white,
                              backgroundImage:
                                  MemoryImage(base64Decode(base64Str)),
                            );
                          } else {
                            // Case 2: Network image with cache bust
                            return CircleAvatar(
                              radius: 22,
                              backgroundImage:
                                  NetworkImage(cacheBustedProfileUrl),
                            );
                          }
                        } else {
                          // Case 3: Default avatar
                          return CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.white,
                            child: Text(
                              userName[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          );
                        }
                      }

                      return buildAvatar();
                    },
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: Colors.white12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double maxWidth = constraints.maxWidth;
                return ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(problem.fullName,
                          style: GoogleFonts.inriaSerif(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('${problem.companyName} • ${problem.category}',
                          style: GoogleFonts.inriaSerif(
                              color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 8),
                      Text(problem.issueDetails,
                          style: GoogleFonts.inriaSerif(
                              color: Color.fromARGB(255, 240, 240, 240),
                              fontSize: 15,
                              height: 1.5)),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          voteButton,
                          const SizedBox(width: 15),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  votedSection,
                                  const SizedBox(width: 8),
                                  voteCountWidget,
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Bottom Bar ---
  Widget _buildBottomNavBar() {
    final bottomNavIcons = [
      Icons.home_filled,
      Icons.search,
      Icons.notifications,
      Icons.bar_chart_rounded,
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF0B0B0D),
        border: Border(top: BorderSide(color: Colors.white12, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(bottomNavIcons.length, (i) {
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = i),
            child: Icon(
              bottomNavIcons[i],
              size: 30,
              color: _selectedIndex == i
                  ? Colors.white
                  : const Color.fromARGB(255, 209, 209, 209),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      drawer: Drawer(
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
                            height: 14, // adjust height for logo alignment
                            child: Image.asset(
                              'assets/Xolve logo .png', // your actual logo path
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
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            Column(
              children: [
                _buildTopBar(),
                TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFF1BBD97),
                  unselectedLabelColor:
                      const Color.fromARGB(255, 240, 240, 240),
                  labelStyle: GoogleFonts.inriaSerif(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: GoogleFonts.inriaSerif(fontSize: 16),
                  indicatorColor: const Color(0xFF1BBD97),
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  tabs: const [
                    Tab(text: 'Problem'),
                    Tab(text: 'Reviews'),
                    Tab(text: 'Pitch'),
                  ],
                ),
                const Divider(color: Colors.white12, height: 1),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      const ProblemTab(),
                      const ReviewsTab(),
                      const PitchTab(),
                    ],
                  ),
                ),
              ],
            ),
            const SearchPage(), // 🔍 Search Page added here
            const NotificationPage(),
            const AnalyticsPage(),
          ],
        ),
      ),
      floatingActionButton: _selectedIndex == 0
          ? Stack(
              alignment: Alignment.bottomRight,
              children: [
                Offstage(
                  offstage: _tabController.index != 0,
                  child: FloatingActionButton(
                    heroTag: 'reportProblem',
                    backgroundColor: Color.fromARGB(255, 240, 240, 240),
                    foregroundColor: Colors.black,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CustomerIssuePage()),
                      );
                    },
                    child: const Icon(Icons.add),
                    tooltip: 'Report Problem',
                  ),
                ),
                Offstage(
                  offstage: _tabController.index != 2,
                  child: FloatingActionButton(
                    heroTag: 'pitchIdea',
                    backgroundColor: Color.fromARGB(255, 240, 240, 240),
                    foregroundColor: Colors.black,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const IdeaPitchingPage()),
                      );
                    },
                    child: const Icon(Icons.lightbulb_outline),
                    tooltip: 'Pitch Idea',
                  ),
                ),
              ],
            )
          : null,
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
}

class ProblemTab extends StatefulWidget {
  const ProblemTab({Key? key}) : super(key: key);

  @override
  State<ProblemTab> createState() => _ProblemTabState();
}

class _ProblemTabState extends State<ProblemTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Important when using AutomaticKeepAliveClientMixin
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('customer_issues')
          .orderBy('votesCount', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong!',
                style: TextStyle(color: Colors.white)),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No data available',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          );
        }
        final problems =
            snapshot.data!.docs.map((doc) => Problem.fromDoc(doc)).toList();
        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 10),
          itemCount: problems.length,
          itemBuilder: (context, index) {
            // Call _buildListItem from HomeScreen by making it public
            // or move this method here if needed
            return (context
                    .findAncestorStateOfType<_HomeScreenState>()
                    ?._buildListItem(problems[index])) ??
                Container();
          },
          separatorBuilder: (context, index) => const Divider(
            color: Color.fromARGB(255, 49, 56, 52),
            thickness: 0.3,
            height: 20,
          ),
        );
      },
    );
  }
}

class ReviewsTab extends StatefulWidget {
  const ReviewsTab({Key? key}) : super(key: key);

  @override
  State<ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends State<ReviewsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Future<void> _toggleVote(DocumentSnapshot reviewDoc) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userData = {
      'uid': currentUser.uid,
      'name': currentUser.displayName ?? currentUser.email ?? 'User',
      'photoURL': currentUser.photoURL ?? '',
      'email': currentUser.email ?? '',
    };

    final data = reviewDoc.data() as Map<String, dynamic>;
    final authorId = data['authorId'] ?? '';

    try {
      await VoteService.toggleVoteForDoc(
        collectionName: 'reviews',
        docId: reviewDoc.id,
        authorId: authorId.toString(),
        userData: userData,
        postType: 'review',
      );
    } catch (e) {
      debugPrint('Error toggling vote (review): $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.white));
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Something went wrong!',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No reviews available yet!',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          );
        }

        final reviews = snapshot.data!.docs;

        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 10),
          itemCount: reviews.length,
          separatorBuilder: (context, index) => const Divider(
            color: Color.fromARGB(255, 49, 56, 52),
            thickness: 0.3,
            height: 20,
          ),
          itemBuilder: (context, index) {
            final reviewDoc = reviews[index];
            final data = reviewDoc.data() as Map<String, dynamic>;

            final currentUser = FirebaseAuth.instance.currentUser;

            final List<dynamic> votedUsersRaw = data['votedUsers'] ?? [];
            final List<Map<String, dynamic>> votedUsers = votedUsersRaw
                .map((e) {
                  if (e is Map<String, dynamic>) {
                    return e;
                  } else if (e is String) {
                    return {'uid': e};
                  } else {
                    return <String, dynamic>{};
                  }
                })
                .where((u) => u.containsKey('uid'))
                .toList();

            final hasVoted =
                votedUsers.any((u) => u['uid'] == currentUser?.uid);

            Widget buildAvatar() {
              final productImageUrl = data['productImageUrl'];
              if (productImageUrl != null &&
                  productImageUrl.toString().isNotEmpty) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl:
                        '$productImageUrl?refresh=${DateTime.now().millisecondsSinceEpoch}',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorWidget: (context, error, stackTrace) => Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.business,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
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
                  child: const Icon(
                    Icons.business,
                    color: Colors.white70,
                    size: 26,
                  ),
                );
              }
            }

            Widget buildVoteSection() {
              List<Widget> avatars = [];
              const int maxDisplayAvatars = 4;

              for (int i = 0;
                  i < votedUsers.length && i < maxDisplayAvatars;
                  i++) {
                final user = votedUsers[i];
                final photoURL = user['photoURL'] ?? '';

                avatars.add(
                  Padding(
                    key: ValueKey(user['uid']),
                    padding: EdgeInsets.only(left: i == 0 ? 0 : 12),
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.white,
                      backgroundImage: photoURL.isNotEmpty
                          ? CachedNetworkImageProvider(
                              '$photoURL?refresh=${DateTime.now().millisecondsSinceEpoch}')
                          : const AssetImage('assets/avatar1.jpg')
                              as ImageProvider,
                    ),
                  ),
                );
              }

              final votersWidget = votedUsers.isEmpty
                  ? const Text(
                      "No votes",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    )
                  : GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ReviewVotersListPage(voters: votedUsers),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Stack(children: avatars.reversed.toList()),
                          if (votedUsers.length > maxDisplayAvatars)
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                '+${votedUsers.length - maxDisplayAvatars}',
                                style: GoogleFonts.inriaSerif(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _toggleVote(reviewDoc),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: hasVoted
                            ? const Color(0xFF1BBD97)
                            : const Color(0xFF0F0F0F),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white30, width: 1.2),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      child: Text(
                        hasVoted ? 'Voted' : 'Vote',
                        style: GoogleFonts.inriaSerif(
                          color: hasVoted ? Colors.black : Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          votersWidget,
                          const SizedBox(width: 8),
                          Text(
                            '+${data['votesCount'] ?? votedUsers.length} votes',
                            style: GoogleFonts.inriaSerif(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 12.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildAvatar(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['authorName'] ?? 'Unknown Company',
                          style: GoogleFonts.inriaSerif(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data['productName'] ?? 'Untitled Product',
                          style: GoogleFonts.inriaSerif(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data['reviewDescription'] ?? '',
                          style: GoogleFonts.inriaSerif(
                            color: Color.fromARGB(255, 240, 240, 240),
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        buildVoteSection(),
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
}

class PitchTab extends StatefulWidget {
  const PitchTab({Key? key}) : super(key: key);

  @override
  State<PitchTab> createState() => _PitchTabState();
}

class _PitchTabState extends State<PitchTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Future<void> _toggleVote(DocumentSnapshot ideaDoc) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userData = {
      'uid': currentUser.uid,
      'name': currentUser.displayName ?? currentUser.email ?? 'User',
      'photoURL': currentUser.photoURL ?? '',
      'email': currentUser.email ?? '',
    };

    final data = ideaDoc.data() as Map<String, dynamic>;

    final authorId = (data['uid'] ??
            data['userId'] ??
            data['authorId'] ??
            data['createdBy'] ??
            '')
        .toString();

    try {
      await VoteService.toggleVoteForDoc(
        collectionName: 'idea_pitched',
        docId: ideaDoc.id,
        authorId: authorId,
        userData: userData,
        postType: 'idea',
      );
    } catch (e) {
      debugPrint('Error toggling vote (idea): $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('idea_pitched')
          .orderBy('votesCount', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.white));
        }
        if (snapshot.hasError) {
          return const Center(
              child: Text('Something went wrong!',
                  style: TextStyle(color: Colors.white)));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
              child: Text('No ideas pitched yet!',
                  style: TextStyle(color: Colors.white, fontSize: 16)));
        }

        final ideas = snapshot.data!.docs;

        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 10),
          itemCount: ideas.length,
          separatorBuilder: (context, index) => const Divider(
            color: Color.fromARGB(255, 49, 56, 52),
            thickness: 0.3,
            height: 20,
          ),
          itemBuilder: (context, index) {
            final ideaDoc = ideas[index];
            final data = ideaDoc.data() as Map<String, dynamic>;

            final currentUser = FirebaseAuth.instance.currentUser;
            final votedUsers = List<Map<String, dynamic>>.from(
                (data['votedUsers'] ?? [])
                    .map((v) => Map<String, dynamic>.from(v)));
            final hasVoted =
                votedUsers.any((user) => user['uid'] == currentUser?.uid);

            final profileImage = data['photoURL']; // ✅ fixed field name
            final userName = data['userName'] ?? 'User';

            // --- Avatar Builder (for idea owner) ---
            Widget buildAvatar() {
              if (profileImage != null && profileImage.toString().isNotEmpty) {
                if (profileImage.toString().startsWith('data:image')) {
                  final base64Str = profileImage.split(',').last;
                  return CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    backgroundImage: MemoryImage(base64Decode(base64Str)),
                  );
                } else {
                  return CircleAvatar(
                    radius: 22,
                    backgroundImage: CachedNetworkImageProvider(
                      '$profileImage?refresh=${DateTime.now().millisecondsSinceEpoch}',
                    ),
                  );
                }
              } else {
                return CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                );
              }
            }

            // --- Vote Section (for voters) ---
            Widget buildVoteSection() {
              List<Widget> avatars = [];
              int maxDisplayAvatars = 4;
              for (var i = 0;
                  i < votedUsers.length && i < maxDisplayAvatars;
                  ++i) {
                final user = votedUsers[i];
                final photoURL = user['photoURL'] ?? '';

                avatars.add(
                  Padding(
                    key: ValueKey(user['uid']),
                    padding: EdgeInsets.only(left: i == 0 ? 0 : 12),
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.white,
                      backgroundImage: photoURL.isNotEmpty
                          ? CachedNetworkImageProvider(
                              '$photoURL?refresh=${DateTime.now().millisecondsSinceEpoch}')
                          : const AssetImage('assets/avatar1.jpg')
                              as ImageProvider,
                    ),
                  ),
                );
              }

              final votedSection = votedUsers.isEmpty
                  ? const Text("No votes",
                      style: TextStyle(color: Colors.grey, fontSize: 12))
                  : GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  PitchVotersListPage(voters: votedUsers)),
                        );
                      },
                      child: Row(
                        children: [
                          Stack(children: avatars.reversed.toList()),
                          if (votedUsers.length > maxDisplayAvatars)
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                '+${votedUsers.length - maxDisplayAvatars}',
                                style: GoogleFonts.inriaSerif(
                                    color: Colors.white70, fontSize: 14),
                              ),
                            ),
                        ],
                      ),
                    );

              final voteCountWidget = GestureDetector(
                onTap: () {
                  if (votedUsers.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              PitchVotersListPage(voters: votedUsers)),
                    );
                  }
                },
                child: Text(
                  '+${data['votesCount'] ?? votedUsers.length} votes',
                  style: GoogleFonts.inriaSerif(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _toggleVote(ideaDoc),
                    child: Container(
                      decoration: BoxDecoration(
                        color: hasVoted
                            ? const Color(0xFF1BBD97)
                            : const Color(0xFF0F0F0F),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white30, width: 1.2),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      child: Text(
                        hasVoted ? 'Voted' : 'Vote',
                        style: GoogleFonts.inriaSerif(
                          color: hasVoted ? Colors.black : Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          votedSection,
                          const SizedBox(width: 8),
                          voteCountWidget,
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            // --- Final UI for Each Idea ---
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildAvatar(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['userName'] ?? 'Unknown User',
                          style: GoogleFonts.inriaSerif(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data['title'] ?? 'Untitled Idea',
                          style: GoogleFonts.inriaSerif(
                              color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data['description'] ?? '',
                          style: GoogleFonts.inriaSerif(
                              color: Color.fromARGB(255, 240, 240, 240),
                              fontSize: 15,
                              height: 1.5),
                        ),
                        const SizedBox(height: 16),
                        buildVoteSection(),
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
}

class VotersListPage extends StatelessWidget {
  final List<Map<String, dynamic>> voters;
  const VotersListPage({super.key, required this.voters});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0D),
      appBar: AppBar(
        title:
            Text('Voters', style: GoogleFonts.inriaSerif(color: Colors.white)),
        backgroundColor: const Color(0xFF0B0B0D),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: voters.length,
        itemBuilder: (context, idx) {
          final voter = voters[idx];
          final photoURL = voter['photoURL'] ?? '';
          return ListTile(
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white10,
              backgroundImage: (photoURL.isNotEmpty)
                  ? CachedNetworkImageProvider(
                      '$photoURL?refresh=${DateTime.now().millisecondsSinceEpoch}')
                  : const AssetImage('assets/avatar1.jpg') as ImageProvider,
              child: (photoURL.isEmpty)
                  ? Text(
                      voter['name']?.isNotEmpty == true
                          ? voter['name'][0].toUpperCase()
                          : 'U',
                      style: GoogleFonts.inriaSerif(color: Colors.white),
                    )
                  : null,
            ),
            title: Text(
              voter['name'] ?? 'User',
              style: GoogleFonts.inriaSerif(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              voter['email'] ?? 'email not available',
              style: GoogleFonts.inriaSerif(color: Colors.grey, fontSize: 12),
            ),
          );
        },
      ),
    );
  }
}

class PitchVotersListPage extends StatelessWidget {
  final List<Map<String, dynamic>> voters;
  const PitchVotersListPage({super.key, required this.voters});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0D),
      appBar: AppBar(
        title: Text('Idea Voters',
            style: GoogleFonts.inriaSerif(color: Colors.white)),
        backgroundColor: const Color(0xFF0B0B0D),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: voters.isEmpty
          ? Center(
              child: Text('No votes yet!',
                  style: GoogleFonts.inriaSerif(color: Colors.white70)))
          : ListView.builder(
              itemCount: voters.length,
              itemBuilder: (context, idx) {
                final voter = voters[idx];
                final photoURL = voter['photoURL'] ?? '';
                return ListTile(
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white10,
                    backgroundImage: (photoURL.isNotEmpty)
                        ? CachedNetworkImageProvider(
                            '$photoURL?refresh=${DateTime.now().millisecondsSinceEpoch}')
                        : const AssetImage('assets/avatar1.jpg')
                            as ImageProvider,
                    child: (photoURL.isEmpty)
                        ? Text(
                            voter['name']?.isNotEmpty == true
                                ? voter['name'][0].toUpperCase()
                                : 'U',
                            style: GoogleFonts.inriaSerif(color: Colors.white),
                          )
                        : null,
                  ),
                  title: Text(
                    voter['name'] ?? 'User',
                    style: GoogleFonts.inriaSerif(
                        color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    voter['email'] ?? 'email not available',
                    style: GoogleFonts.inriaSerif(
                        color: Colors.grey, fontSize: 12),
                  ),
                );
              },
            ),
    );
  }
}

class ReviewVotersListPage extends StatelessWidget {
  final List<Map<String, dynamic>> voters;
  const ReviewVotersListPage({super.key, required this.voters});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0D),
      appBar: AppBar(
        title: Text('Product Voters',
            style: GoogleFonts.inriaSerif(color: Colors.white)),
        backgroundColor: const Color(0xFF0B0B0D),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: voters.isEmpty
          ? Center(
              child: Text('No votes yet!',
                  style: GoogleFonts.inriaSerif(color: Colors.white70)))
          : ListView.builder(
              itemCount: voters.length,
              itemBuilder: (context, idx) {
                final voter = voters[idx];
                final photoURL = voter['photoURL'] ?? '';
                return ListTile(
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white10,
                    backgroundImage: (photoURL.isNotEmpty)
                        ? CachedNetworkImageProvider(
                            '$photoURL?refresh=${DateTime.now().millisecondsSinceEpoch}')
                        : const AssetImage('assets/avatar1.jpg')
                            as ImageProvider,
                    child: (photoURL.isEmpty)
                        ? Text(
                            voter['name']?.isNotEmpty == true
                                ? voter['name'][0].toUpperCase()
                                : 'U',
                            style: GoogleFonts.inriaSerif(color: Colors.white),
                          )
                        : null,
                  ),
                  title: Text(
                    voter['name'] ?? 'User',
                    style: GoogleFonts.inriaSerif(
                        color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    voter['email'] ?? 'email not available',
                    style: GoogleFonts.inriaSerif(
                        color: Colors.grey, fontSize: 12),
                  ),
                );
              },
            ),
    );
  }
}

class VoteService {
  /// Toggle vote for a document inside [collectionName] with id [docId].
  /// [authorId] is the owner/author's uid of the doc (so we can create notification).
  /// [userData] is the map representing current user: { uid, name, photoURL, email }.
  /// [postType] is an optional string indicating the type of post (e.g. 'problem' or 'idea')
  /// which will be included in the notification payload when a new vote is created.
  static Future<void> toggleVoteForDoc({
    required String collectionName,
    required String docId,
    required String authorId,
    required Map<String, dynamic> userData,
    String? postType,
  }) async {
    final docRef =
        FirebaseFirestore.instance.collection(collectionName).doc(docId);
    final currentUid = userData['uid'] as String;
    bool didVote = false;

    // Transaction ensures atomic read-modify-write
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snapshot = await tx.get(docRef);
      if (!snapshot.exists) {
        throw Exception('Document does not exist');
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final List<dynamic> votedUsersRaw =
          List<dynamic>.from(data['votedUsers'] ?? []);
      final List<Map<String, dynamic>> votedUsers = votedUsersRaw
          .map((v) =>
              v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{})
          .toList();

      final alreadyVoted = votedUsers.any((v) => v['uid'] == currentUid);

      if (!alreadyVoted) {
        votedUsers.insert(0, userData);
        didVote = true;
      } else {
        votedUsers.removeWhere((v) => v['uid'] == currentUid);
        didVote = false;
      }

      tx.update(docRef, {
        'votedUsers': votedUsers,
        'votesCount': votedUsers.length,
      });
    });

    // ✅ Create notification if user newly voted
    try {
      if (didVote && authorId.isNotEmpty && authorId != currentUid) {
        final now = FieldValue.serverTimestamp();

        // 🔹 Dynamic message based on post type
        String message = 'Voted your post';
        if (postType != null && postType.isNotEmpty) {
          if (postType.toLowerCase() == 'problem') {
            message = 'Voted your problem';
          } else if (postType.toLowerCase() == 'idea') {
            message = 'Voted your idea';
          }
        }

        final notification = {
          'receiverId': authorId,
          'senderId': currentUid,
          'senderName': userData['name'] ?? '',
          'senderPhoto': userData['photoURL'] ?? '',
          'message': message,
          'type': 'vote',
          'relatedDocId': docId,
          'timestamp': now,
          'isRead': false,
        };

        if (postType != null && postType.isNotEmpty) {
          notification['postType'] = postType;
        }

        await FirebaseFirestore.instance
            .collection('notifications')
            .add(notification);
      }
    } catch (e) {
      debugPrint('Failed to create notification: $e');
    }
  }
}
