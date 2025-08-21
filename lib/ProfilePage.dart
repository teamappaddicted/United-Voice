import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user1 = FirebaseAuth.instance.currentUser!;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? user;
  String? name;
  String? email;
  String? photoUrl;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (user != null) {
      name = user!.displayName ?? "";
      email = user!.email ?? "";
      photoUrl = user!.photoURL;

      // ensure user is stored in Firestore
      final docRef = _firestore.collection("users").doc(user!.uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        await docRef.set({
          "name": name,
          "email": email,
          "profileImage": photoUrl,
          "createdAt": DateTime.now().toIso8601String(),
        });
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("No user signed in")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 60,
              backgroundImage: photoUrl != null
                  ? NetworkImage(photoUrl!)
                  : const AssetImage("assets/default_avatar.png") as ImageProvider,
            ),
            const SizedBox(height: 15),
            Text(
              name ?? "No Name",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 5),
            Text(
              email ?? "",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1),
            const SizedBox(height: 10),
            const Text(
              "My Reported Issues",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600 , color: Colors.grey),
            ),
            const SizedBox(height: 10),

            // 🔥 List of Issues Reported by this User
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                 .collection('customer_issues') // ⚠️ Make sure collection name is correct
                  .where('email', isEqualTo: user1.email) // ⚠️ Check Firestore field name
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("No issues reported yet.",style: TextStyle(color: Colors.grey),),
                  );
                }

                final issues = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: issues.length,
                  itemBuilder: (context, index) {
                    final data = issues[index].data() as Map<String, dynamic>;
                    return Card(color: Colors.transparent,

                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey)
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.report_problem, color: Colors.red),
                        title: Text(data["issueDetails"] ?? "No details",style: TextStyle(color: Colors.white),),
                        subtitle: Text("Category: ${data["category"] ?? "N/A"}",style: TextStyle(color: Colors.grey),),
                        trailing: Text(
                          data["productId"] ?? "",
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
