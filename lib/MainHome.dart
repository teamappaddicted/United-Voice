import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:unitedvoice/CustomerIssuePage.dart';
import 'package:unitedvoice/HomeFeedPage.dart';
import 'package:unitedvoice/ProfilePage.dart';

class MainHome extends StatefulWidget {
  final int selectedIndex; // 👈 allow passing initial tab index

  const MainHome({super.key, this.selectedIndex = 0});

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex; // 👈 use passed index
  }

  // Different pages
  final List<Widget> _pages = [
    const HomeFeedPage(),
    const Center(
        child: Text("Search Issues / Brands",
            style: TextStyle(color: Colors.white, fontSize: 20))),
    const Center(
        child: Text("Report an Issue",
            style: TextStyle(color: Colors.white, fontSize: 20))),
    const Center(
        child: Text("Analytics & Insights",
            style: TextStyle(color: Colors.white, fontSize: 20))),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          FirebaseAuth.instance.currentUser?.displayName ?? "User",
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await GoogleSignIn().signOut();
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: _pages[_selectedIndex],

      // Floating Action Button (Report Issue)
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CustomerIssuePage()),
          );
        },
        child: const Icon(Icons.add, color: Colors.black, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Bottom Navigation Bar
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home,
                  color: _selectedIndex == 0 ? Colors.white : Colors.grey),
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              icon: Icon(Icons.search,
                  color: _selectedIndex == 1 ? Colors.white : Colors.grey),
              onPressed: () => _onItemTapped(1),
            ),
            const SizedBox(width: 40), // space for FAB notch
            IconButton(
              icon: Icon(Icons.bar_chart,
                  color: _selectedIndex == 3 ? Colors.white : Colors.grey),
              onPressed: () => _onItemTapped(3),
            ),
            IconButton(
              icon: Icon(Icons.person,
                  color: _selectedIndex == 4 ? Colors.white : Colors.grey),
              onPressed: () => _onItemTapped(4),
            ),
          ],
        ),
      ),
    );
  }
}
