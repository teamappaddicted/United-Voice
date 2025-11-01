import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

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
        title: Text(
          'Help Center',
          style: GoogleFonts.merriweather(
            fontSize: 22,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Divider(color: Colors.white24, thickness: 1),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                // 🌟 Top Header Section
                Center(
                  child: Column(
                    children: [
                      Text(
                        "We are here to help",
                        style: GoogleFonts.merriweather(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.transparent),
                          
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          "Need assistance or have any questions? Our team is here to ensure you get the help you need. "
                          "Explore the FAQs below or reach out to us directly for more support.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.merriweather(
                            color: Colors.white70,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 🌟 FAQ Section
                const FAQTile(
                  question:
                      'Q1. What is the core problem Xolve solves for companies?',
                  answer:
                      'We transform the overwhelming volume of raw customer feedback and problems into clear, structured, and actionable insights. This eliminates time wasted on duplicate reports, allowing product teams to focus only on unique, validated issues.',
                ),
                const FAQTile(
                  question:
                      'Q2. How does the platform handle duplicate or similar reports?',
                  answer:
                      'Xolve uses proprietary AI systems to analyze all User-Generated Content (UGC) in real-time. The AI automatically categorizes and performs deduplication against existing reports, ensuring companies receive only one structured report per unique problem.',
                ),
                const FAQTile(
                  question:
                      'Q3. As a user, how do I know my feedback will be prioritized?',
                  answer:
                      'The platform utilizes a transparent upvoting feature. While all unique feedback is captured, reports with a high number of upvotes signal high demand, which helps product teams prioritize and act on the most critical user issues first.',
                ),
                const FAQTile(
                  question:
                      'Q4. What rights does Xolve and its clients have over my submitted feedback?',
                  answer:
                      'By submitting a report, you grant us and the client company a worldwide, royalty-free, perpetual license to use and analyze that feedback (UGC) exclusively for product improvement, development, and the operation of the Service.',
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FAQTile extends StatefulWidget {
  final String question;
  final String answer;
  const FAQTile({super.key, required this.question, required this.answer});

  @override
  State<FAQTile> createState() => _FAQTileState();
}

class _FAQTileState extends State<FAQTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.transparent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: GoogleFonts.merriweather(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white70,
                  size: 24,
                ),
              ],
            ),
            if (_isExpanded) ...[
              const SizedBox(height: 12),
              Text(
                widget.answer,
                style: GoogleFonts.merriweather(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
