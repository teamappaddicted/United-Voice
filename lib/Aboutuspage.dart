import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Text(
      'About ',
      style: GoogleFonts.merriweather(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
    ),
    SizedBox(
      height: 16, // adjust to match text height visually
      child: Image.asset(
        'assets/Xolve logo .png', // replace with your actual logo path
        fit: BoxFit.contain,
      ),
    ),
  ],
),
centerTitle: true,

      ),
      body: Column(
        children: [
          // Fixed Divider below AppBar (like GetRewardsPage)
          const Divider(color: Colors.white24, thickness: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _sectionTitle('About Xolve'),
                  _sectionBody(
                    'Welcome to Xolve- your platform for making voice heard fostering genuine change.',
                  ),

                  const SizedBox(height: 20),
                  _sectionTitle('Our Vision'),
                  _sectionBody(
                    'We believe the power of collective voices. United bridges the gap between raw feedback and actionable insights. We’ve dedicated ourselves to improving products, fostering transparency, and empowering users.',
                  ),

                  const SizedBox(height: 20),
                  _sectionTitle('What We Do'),
                  _sectionBody(
                    'Xolve is designing customer feedback:',
                  ),
                  const SizedBox(height: 10),
                  _iconText(Icons.question_mark_rounded, 'Real-time problem capture'),
                  const SizedBox(height: 8),
                  _iconText(Icons.manage_search_rounded, 'AI-driven duplicate detection'),
                  const SizedBox(height: 8),
                  _iconText(Icons.bar_chart_rounded, 'Structured, prioritized insights for companies'),

                  const SizedBox(height: 25),
                  _sectionTitle('Key Features'),
                  const SizedBox(height: 10),
                  _featureCard(
                    Icons.mic_rounded,
                    'Submit your issues effortlessly. Your experts, and we make it simple to share.',
                  ),
                  const SizedBox(height: 12),
                  _featureCard(
                    Icons.check_circle_outline_rounded,
                    'No more duplicate complaints. Companies get clarity with upvotes & verified reports.',
                  ),

                  const SizedBox(height: 25),
                  _sectionTitle('Our Goal'),
                  _sectionBody(
                    'Empowering users, improving products, fostering transparency. Empowering users, improving products, fostering transparency. Empowering users, improving products, fostering transparency. Empowering users, improving products, fostering transparency.',
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.merriweather(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _sectionBody(String text) {
    return Text(
      text,
      style: GoogleFonts.merriweather(
        color: Colors.white70,
        fontSize: 16,
        height: 1.5,
      ),
    );
  }

  Widget _iconText(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.tealAccent, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.merriweather(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _featureCard(IconData icon, String text) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.tealAccent, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.merriweather(
                color: Colors.white70,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
