import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GetRewardsPage extends StatelessWidget {
  const GetRewardsPage({super.key});

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
          "Get Rewards & Gifts",
          style: GoogleFonts.merriweather(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w400,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Divider line below AppBar (static)
          const Divider(color: Colors.white24, thickness: 1),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Gift icon
                    CircleAvatar(
                      radius: 70,
                      backgroundColor: const Color(0xFF012C25),
                      child: Icon(
                        Icons.card_giftcard,
                        color: const Color(0xFF1ABC9C),
                        size: 70,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Congratulations text
                    Text(
                      "Congratulations!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.merriweather(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Subheading
                    Text(
                      "You’re a Top Insight Contributor!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.merriweather(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Description paragraph
                    Text(
                      "Your recent feedback report has received the *highest number of upvotes* this cycle, signaling a critical issue that our client will prioritize immediately. As a thank you for providing the community's voice, you've earned a special reward.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.merriweather(
                        color: Colors.white70,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Incentive container
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1C),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Incentive: ₹500 Cashback / Coupon",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.merriweather(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Check your registered email for details on redeeming your prize.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.merriweather(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // View Details Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1ABC9C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          // Handle button press
                        },
                        child: Text(
                          "VIEW DETAILS",
                          style: GoogleFonts.merriweather(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
