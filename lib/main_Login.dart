import 'package:Xolve/UnitedVoiceApp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';


class main_Login extends StatelessWidget {
  const main_Login({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Login(),
      ),
    );
  }
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  final FlutterAppAuth _appAuth = FlutterAppAuth();
  late AnimationController _animationController;
  bool _isOverlayVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  Future<void> SignInwithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Force refresh of Google account info (to get updated DP/name)
      await googleSignIn.disconnect().catchError((_) {});
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return; // user cancelled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) return;

      // Generate cache-busting photo URL to ensure refresh
      String? photoUrl = user.photoURL;
      if (photoUrl != null && photoUrl.isNotEmpty) {
        photoUrl = "$photoUrl?time=${DateTime.now().millisecondsSinceEpoch}";
      }

      final firestore = FirebaseFirestore.instance;
      final userDocRef = firestore.collection('users').doc(user.uid);
      final userDoc = await userDocRef.get();

      if (!userDoc.exists) {
        // Create new user document
        await userDocRef.set({
          'uid': user.uid,
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'photoURL': photoUrl ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
        print("✅ New user created in Firestore: ${user.displayName}");
      } else {
        // Update existing user info
        await userDocRef.update({
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'photoURL': photoUrl ?? '',
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
        print("🔁 User data updated in Firestore.");
      }

      // ✅ Sync updated photoURL across related collections
      final userId = user.uid;
      final newPhotoURL = photoUrl ?? '';

      // Update in customer_issues
      final issuesSnap = await firestore
          .collection('customer_issues')
          .where('uid', isEqualTo: userId)
          .get();
      for (var doc in issuesSnap.docs) {
        await doc.reference.update({'photoURL': newPhotoURL});
      }

      // Update in idea_pitched
      final ideaSnap = await firestore
          .collection('idea_pitched')
          .where('uid', isEqualTo: userId)
          .get();
      for (var doc in ideaSnap.docs) {
        await doc.reference.update({'photoURL': newPhotoURL});
      }

      print("🔄 Synced updated photoURL across customer_issues & idea_pitched.");

      // Navigate to app
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UnitedVoiceApp()),
        );
      }
    } catch (e) {
      print("❌ Error signing in with Google: $e");
    }
  }

  void _toggleOverlayVisibility() {
    setState(() {
      _isOverlayVisible = !_isOverlayVisible;
      _isOverlayVisible
          ? _animationController.forward()
          : _animationController.reverse();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: _toggleOverlayVisibility,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Center(
              child: Image(
                image: const AssetImage("assets/Xolve logo .png"),
                height: screenHeight * 0.32,
                width: screenWidth * 0.32,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: _isOverlayVisible ? 0 : -200,
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromARGB(255, 66, 66, 66),
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.transparent,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(
                            color: const Color.fromARGB(255, 66, 66, 66),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: SignInwithGoogle,
                          style: ButtonStyle(
                            shape:
                                MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.transparent),
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.transparent),
                            shadowColor:
                                MaterialStateProperty.all<Color>(Colors.transparent),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const FaIcon(
                                FontAwesomeIcons.google,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "Continue with Google",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
