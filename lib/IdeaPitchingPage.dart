import 'dart:typed_data';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class IdeaPitchingPage extends StatefulWidget {
  const IdeaPitchingPage({Key? key}) : super(key: key);

  @override
  State<IdeaPitchingPage> createState() => _IdeaPitchingPageState();
}

class _IdeaPitchingPageState extends State<IdeaPitchingPage> {
  final _formKey = GlobalKey<FormState>();
  final _ideaTitleCtrl = TextEditingController();
  final _ideaDescriptionCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _ideaTitleCtrl.dispose();
    _ideaDescriptionCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  // 🧩 Generate a fallback avatar (white background, black letter)
  Future<String> _generateInitialAvatar(String name) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()..color = Colors.white;
    final textPainter = TextPainter(
      text: TextSpan(
        text: name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 64,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    // Draw background
    canvas.drawRect(const Rect.fromLTWH(0, 0, 120, 120), paint);
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (120 - textPainter.width) / 2,
        (120 - textPainter.height) / 2,
      ),
    );

    final picture = pictureRecorder.endRecording();
    final img = await picture.toImage(120, 120);

    
    final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return "data:image/png;base64,${base64Encode(pngBytes!.buffer.asUint8List())}";
  }

  // 🧩 Fetch profile image priority-wise
  Future<String?> _getProfileImage(String email, String name) async {
    try {
      // Step 1: Try to fetch custom profile photo from users collection (if it exists)
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .get();

      if (userDoc.exists && userDoc.data()!.containsKey('photoURL')) {
        final photoUrl = userDoc['photoURL'];
        if (photoUrl != null && photoUrl.toString().isNotEmpty) {
          return photoUrl;
        }
      }

      // Step 2: Use Google auth image if available
      final googleImage = FirebaseAuth.instance.currentUser?.photoURL;
      if (googleImage != null && googleImage.isNotEmpty) return googleImage;

      // Step 3: Generate avatar if no image found
      return await _generateInitialAvatar(name);
    } catch (e) {
      debugPrint("Error fetching profile image: $e");
      return await _generateInitialAvatar(name);
    }
  }

  Future<void> _submitIdea() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final userName = currentUser?.displayName ?? 'Anonymous User';
      final userEmail = currentUser?.email ?? 'Unknown Email';

      // 🧩 Get profile image with priority
      final profileImage = await _getProfileImage(userEmail, userName);

      // 🧩 Step 1: Prepare idea data
      final ideaData = {
        'uid': FirebaseAuth.instance.currentUser!.uid,
        'title': _ideaTitleCtrl.text.trim(),
        'description': _ideaDescriptionCtrl.text.trim(),
        'contact': _contactCtrl.text.trim(),
        'userName': userName,
        'userEmail': userEmail,
        'photoURL': profileImage ?? '', // Added field
        'timestamp': FieldValue.serverTimestamp(),
        
        'votesCount': 0,
        'votedUsers': [],
      };

      // 🧩 Step 2: Add to Firestore
      final docRef =
          await FirebaseFirestore.instance.collection('idea_pitched').add(ideaData);

      // ✅ Step 3: Ensure vote fields exist
      await docRef.update({
        'votesCount': FieldValue.increment(0),
        'votedUsers': FieldValue.arrayUnion([]),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Idea submitted successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed to submit idea: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Pitch Your Idea", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 1,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: screenWidth * 0.5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/IdeaBanner.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 24),
                _SectionCard(
                  title: "Idea Information",
                  child: Column(
                    children: [
                      _darkTextField(
                        controller: _ideaTitleCtrl,
                        label: "Idea Title",
                        icon: Icons.lightbulb,
                        hint: "Give your idea a short and catchy title",
                      ),
                      const SizedBox(height: 14),
                      _darkTextField(
                        controller: _ideaDescriptionCtrl,
                        label: "Idea Description",
                        icon: Icons.description,
                        hint:
                            "Describe your idea clearly — how it works, what problem it solves, and why it’s unique.",
                        maxLines: 5,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _SectionCard(
                  title: "Contact Information",
                  child: _darkTextField(
                    controller: _contactCtrl,
                    label: "Contact Info",
                    icon: Icons.contact_mail,
                    hint: "Enter your email or phone number",
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: _submitting ? null : _submitIdea,
                    icon: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.arrow_upward),
                    label: Text(
                      _submitting ? "Submitting..." : "Submit Idea",
                      style: TextStyle(
                        fontSize: 16,
                        color: _submitting ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _darkTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        labelStyle: const TextStyle(color: Colors.white),
        prefixIcon: Icon(icon, color: Colors.white),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white54),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF1BBD97)),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      validator: (v) =>
          v == null || v.trim().isEmpty ? "$label is required" : null,
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
