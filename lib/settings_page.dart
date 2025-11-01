import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'your_account_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  TextStyle get titleStyle => GoogleFonts.merriweather(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        color: Colors.white,
      );

  TextStyle get subtitleStyle => GoogleFonts.merriweather(
        fontSize: 14,
        color: Colors.white70,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Settings', style: titleStyle.copyWith(fontSize: 22)),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _tile(
            context,
            Icons.person_outline,
            'Your Account',
            'View profile, payment methods, and deactivation options.',
            const YourAccountPage(),
          ),
        
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, String subtitle, Widget page) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 28),
      title: Text(title, style: titleStyle),
      subtitle: Text(subtitle, style: subtitleStyle),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
    );
  }
}
