// lib/MainHome.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeFeedPage extends StatelessWidget {
  const HomeFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('customer_issues')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No issues yet 🚀"));
          }

          final issues = snapshot.data!.docs;

          return ListView.builder(
            itemCount: issues.length,
            itemBuilder: (context, index) {
              final issue = issues[index].data() as Map<String, dynamic>;
              final docId = issues[index].id;

              // ✅ FIX timestamp handling
              DateTime? timestamp;
              if (issue['createdAt'] is Timestamp) {
                timestamp = (issue['createdAt'] as Timestamp).toDate();
              } else if (issue['createdAt'] is String) {
                timestamp = DateTime.tryParse(issue['createdAt']);
              }

              final formattedTime = timestamp != null
                  ? DateFormat('MMM d, h:mm a').format(timestamp)
                  : "Unknown time";

              return _TweetCard(
                docId: docId,
                fullName: issue['fullName'] ?? "Anonymous",
                issueDetails: issue['issueDetails'] ?? "",
                category: issue['category'] ?? "",
                time: formattedTime,
                votes: issue['votes'] ?? 0,
                photoUrl: currentUser?.photoURL, // ✅ pass Google profile photo
              );
            },
          );
        },
      ),
    );
  }
}

class _TweetCard extends StatelessWidget {
  final String docId;
  final String fullName;
  final String issueDetails;
  final String category;
  final String time;
  final int votes;
  final String? photoUrl; // ✅ added

  const _TweetCard({
    required this.docId,
    required this.fullName,
    required this.issueDetails,
    required this.category,
    required this.time,
    required this.votes,
    this.photoUrl, // ✅ added
  });

  Future<void> _vote() async {
    final ref =
        FirebaseFirestore.instance.collection('customer_issues').doc(docId);
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      final currentVotes = (snap['votes'] ?? 0) as int;
      tx.update(ref, {'votes': currentVotes + 1});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade800, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row: Avatar + Name + Time
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                backgroundImage:
                    photoUrl != null ? NetworkImage(photoUrl!) : null,
                child: photoUrl == null
                    ? const Icon(Icons.person, color: Colors.black)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          fullName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.white),
                        ),
                        Text(
                          time,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      issueDetails,
                      style: const TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Category Chip
          Chip(
            label: Text(category,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            backgroundColor: Colors.black,
            side: const BorderSide(color: Colors.grey),
          ),

          const SizedBox(height: 8),

          // ✅ Only Vote button
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.how_to_vote,
                    color: Colors.grey, size: 20),
                onPressed: _vote,
              ),
              Text(
                "$votes votes",
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
