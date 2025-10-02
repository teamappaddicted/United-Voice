import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unitedvoice/CustomerIssuePage.dart';

// Problem Model
class Problem {
  final String id;
  final String fullName;
  final String issueDetails;
  final String category;
  final String companyName;
  final String userAvatar; // avatar of the reporter
  final int votes;

  Problem({
    required this.id,
    required this.fullName,
    required this.issueDetails,
    required this.category,
    required this.companyName,
    required this.userAvatar,
    required this.votes,
  });

  factory Problem.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Problem(
      id: doc.id,
      fullName: data['fullName'] ?? '',
      issueDetails: data['issueDetails'] ?? '',
      category: data['category'] ?? '',
      companyName: data['companyName'] ?? '',
      userAvatar: data['userAvatar'] ??
          'https://ui-avatars.com/api/?name=${data['fullName'] ?? 'User'}',
      votes: data['votes'] ?? 0,
    );
  }
}

class UnitedVoiceApp extends StatelessWidget {
  const UnitedVoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'United Voice',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0B0D),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B0B0D),
          elevation: 0,
        ),
        tabBarTheme: TabBarThemeData(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(color: Colors.white, width: 2.0),
            insets: EdgeInsets.symmetric(horizontal: 16.0),
          ),
        ),
        textTheme: TextTheme(
          titleLarge: GoogleFonts.playfairDisplay(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          bodyMedium: GoogleFonts.playfairDisplay(
              fontSize: 15, color: Colors.white70, height: 1.5),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Top Bar
  Widget _buildTopBar() {
    final user = FirebaseAuth.instance.currentUser;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: user?.photoURL != null
                ? NetworkImage(user!.photoURL!)
                : const AssetImage('assets/avatar1.jpg') as ImageProvider,
            backgroundColor: Colors.white10,
          ),
          Expanded(
            child: Center(
              child: Text(
                'United Voice',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          IconButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout, color: Colors.white70, size: 24),
          ),
        ],
      ),
    );
  }

  // Problem List Item with dynamic vertical line
  Widget _buildListItem(Problem problem) {
    final List<String> reactionAvatars = [
      'assets/avatar1.jpg',
      'assets/avatar2.jpg',
      'assets/avatar3.jpg',
      'assets/avatar4.jpg',
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 18.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column (avatar + vertical line + vote row)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundImage: problem.userAvatar.isNotEmpty
                        ? NetworkImage(problem.userAvatar)
                        : const AssetImage('assets/avatar1.jpg')
                            as ImageProvider,
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: Colors.white12,
                    ),
                  ),
                  // Vote row at the bottom of the line
                  
                ],
              ),
            ),
          ),

          // Right column (content) remains unchanged
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(problem.fullName,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontSize: 17)),
                const SizedBox(height: 4),
                Text('${problem.companyName} • ${problem.category}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),
                Text(problem.issueDetails,
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F0F0F),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.white30, width: 1.2),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      child: const Text(
                        'Vote',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    SizedBox(
                      width: 75,
                      height: 20,
                      child: Stack(
                        children: List.generate(4, (i) {
                          return Positioned(
                            left: i * 15.0,
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.white,
                              backgroundImage:
                                  AssetImage(reactionAvatars[i % 4]),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+${problem.votes} votes',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Bottom NavBar
  Widget _buildBottomNavBar() {
    final bottomNavIcons = [
      Icons.home_filled,
      Icons.search,
      Icons.people_outline,
      Icons.bar_chart_sharp,
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
              color: _selectedIndex == i ? Colors.white : Colors.white54,
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            const Divider(color: Colors.white12, height: 1),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Problem'),
                Tab(text: 'Reviews'),
                Tab(text: 'Pitching'),
              ],
            ),
            const Divider(color: Colors.white12, height: 1),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Problem Tab - Firestore Stream
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('customer_issues')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                            child: CircularProgressIndicator(
                                color: Colors.white));
                      }
                      final problems = snapshot.data!.docs
                          .map((doc) => Problem.fromDoc(doc))
                          .toList();
                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 10),
                        itemCount: problems.length,
                        itemBuilder: (context, index) {
                          return _buildListItem(problems[index]);
                        },
                      );
                    },
                  ),
                  const Center(
                      child: Text('Reviews Content',
                          style: TextStyle(color: Colors.white70))),
                  const Center(
                      child: Text('Pitching Content',
                          style: TextStyle(color: Colors.white70))),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF1BBD97),
        foregroundColor: Colors.black,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CustomerIssuePage()),
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
}
