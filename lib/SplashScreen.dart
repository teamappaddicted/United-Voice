import 'dart:async';
import 'package:Xolve/UnitedVoiceApp.dart';
import 'package:Xolve/main_Login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';



class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3)); // splash delay
    User? user = FirebaseAuth.instance.currentUser;

    if (mounted) {
      if (user != null) {
        // User already logged in → go to home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UnitedVoiceApp()),
        );
      } else {
        // No user → go to login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const main_Login()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 20),
            Text(
              "Loading Xolve...",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
