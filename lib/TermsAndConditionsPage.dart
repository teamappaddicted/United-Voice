import 'package:Xolve/HelpCenterPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsAndConditionsPage extends StatefulWidget {
  const TermsAndConditionsPage({Key? key}) : super(key: key);

  @override
  State<TermsAndConditionsPage> createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
  final ScrollController _scrollController = ScrollController();

  
  static const Color backgroundColor = Colors.black;
  static const Color textColor = Colors.white;
  static const Color accentColor = Color(0xFF1BBD97);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // The Terms text (you provided this content)
  final String _termsText = '''
Acceptance of Terms
Your access to and use of the Service is conditioned upon your acceptance of and compliance with these Terms. These Terms apply to all visitors, users, and others who access or use the Service ("Users").
By using this Service, you agree to comply with and be bound by these Terms and Conditions. If you do not agree to these terms, please do not use this Service.

Use of the Service
The Xolve app is designed solely to facilitate the submission, tracking, and upvoting of constructive, real-time feedback, reports, and suggestions to product companies ("Clients"). You agree to use this Service only for lawful purposes and in a way that does not infringe upon the rights of others or restrict or inhibit anyone else's use and enjoyment of the Service.

User Account
To use certain features of the Service, you will need to create a user account. You are solely responsible for maintaining the confidentiality of your account information and for all activities that occur under it. During registration, you agree to provide accurate, complete, and current details. Furthermore, you must notify us immediately if you suspect any breach or unauthorized use of your account, as we are not liable for any losses or damages resulting from your failure to protect your credentials or comply with this security obligation.

Privacy Policy
The Xolve app is designed solely to facilitate the submission, tracking, and upvoting of constructive, real-time feedback, reports, and suggestions to product companies ("Clients"). You agree to use this Service only for lawful purposes and in a way that does not infringe upon the rights of others or restrict or inhibit anyone else's use and enjoyment of the Service.
''';

  @override
  Widget build(BuildContext context) {
    // Responsiveness helpers
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final screenHeight = media.size.height;
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'User';

    // Card dimensions - adapt to screen size
    final bool isWide = screenWidth > 600;
    final double cardWidth = isWide ? screenWidth * 0.6 : screenWidth * 0.92;
    final double cardHeight = isWide ? screenHeight * 0.7 : screenHeight * 0.60;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 24.0 : 16.0,
            vertical: isWide ? 20.0 : 12.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row with back, title, Help
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back arrow
                  InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.arrow_back,
                        color: textColor,
                        size: isWide ? 28 : 24,
                      ),
                    ),
                  ),

                  // Right side Help link
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HelpCenterPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Help',
                      style: GoogleFonts.inter(
                        color: accentColor,
                        fontSize: isWide ? 16 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Greeting and instruction
              Text(
                'Hello, $userName',
                style: GoogleFonts.inter(
                  color: textColor,
                  fontSize: isWide ? 28 : 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Before you create an account, please read and accept our Terms and Conditions.',
                style: GoogleFonts.inter(
                  color: textColor.withOpacity(0.75),
                  fontSize: isWide ? 16 : 14,
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 18),

              // Center card (Terms box)
              Center(
                child: Container(
                  width: cardWidth,
                  height: cardHeight,
                  decoration: BoxDecoration(
                    color: Colors.grey[900], // slight difference to card vs bg
                    borderRadius: BorderRadius.circular(14.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(0.04),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Card header
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 14.0),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Terms and Conditions',
                                      style: GoogleFonts.inter(
                                        color: textColor,
                                        fontSize: isWide ? 18 : 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Last Updated: October 24, 2025',
                                      style: GoogleFonts.inter(
                                        color: textColor.withOpacity(0.6),
                                        fontSize: isWide ? 13 : 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // small red dot as in the image (decorative)
                              Container(
                                width: 10,
                                height: 10,
                                margin: const EdgeInsets.only(left: 8.0),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Divider
                        Container(
                          height: 1,
                          color: Colors.white.withOpacity(0.04),
                        ),

                        // Scrollable content area with custom scrollbar
                        Expanded(
                          child: RawScrollbar(
                            controller: _scrollController,
                            thumbColor: accentColor,
                            radius: const Radius.circular(8),
                            thickness: 8,
                            crossAxisMargin: 4,
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 14.0),
                              child: SelectableText(
                                _termsText,
                                style: GoogleFonts.inter(
                                  color: textColor,
                                  fontSize: isWide ? 15 : 14,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // NOTE: Buttons removed as per requirement.
                        // The bottom area can be used for spacing or extra small note.
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),

              // Small spacer at bottom for devices with tall screens
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
