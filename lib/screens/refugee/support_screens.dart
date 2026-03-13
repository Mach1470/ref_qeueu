import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ref_qeueu/widgets/glass_widgets.dart';
import 'package:ref_qeueu/widgets/safe_scaffold.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CommunityHelpScreen extends StatelessWidget {
  const CommunityHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildSupportScaffold(
      context,
      'Community Help',
      'Knowledge Base',
      [
        _buildStepTile('Queue Basics', 'How to join and track your status.', Icons.format_list_numbered_rounded),
        _buildStepTile('Security PIN', 'Managing your digital passkey.', Icons.lock_outline_rounded),
        _buildStepTile('Emergency Access', 'Prioritizing critical healthcare.', Icons.emergency_rounded),
        _buildStepTile('Digital ID', 'Using your UNHCR verification.', Icons.badge_outlined),
      ],
    );
  }
}

class DirectSupportScreen extends StatelessWidget {
  const DirectSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildSupportScaffold(
      context,
      'Direct Support',
      'Contact Center',
      [
        _buildSupportOption('Call Hotlline', 'Toll-free emergency support', Icons.phone_callback_rounded, Colors.greenAccent),
        _buildSupportOption('Live Chat', 'Connect with a coordinator', Icons.chat_bubble_outline_rounded, Colors.blueAccent),
        _buildSupportOption('Report Issue', 'Submit a technical ticket', Icons.bug_report_outlined, Colors.redAccent),
      ],
    );
  }
}

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeScaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF1E1B4B)],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 60, 16, 0),
              child: Row(
                children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white10,
              child: Icon(Icons.layers_rounded, color: Color(0xFF6366F1), size: 60),
            ).animate().shimmer(duration: 2.seconds),
            const SizedBox(height: 24),
            Text('MyQueue Premium', style: GoogleFonts.poppins(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            Text('Version 2.5.0 Gold Edition', style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 14)),
            const Spacer(),
            GlassCard(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              child: Text(
                'MyQueue is a state-of-the-art platform designed to streamline humanitarian logistics and healthcare access for displaced populations. Built for scale, security, and resilience.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 13, height: 1.6),
              ),
            ),
            const SizedBox(height: 60),
            Text('© 2026 MyQueue Global Systems', style: GoogleFonts.dmSans(color: Colors.white24, fontSize: 11)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

Widget _buildSupportScaffold(BuildContext context, String title, String subtitle, List<Widget> children) {
  return SafeScaffold(
    extendBodyBehindAppBar: true,
    body: Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF312E81)],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 20),
            child: Row(
              children: [
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subtitle, style: GoogleFonts.dmSans(color: const Color(0xFF818CF8), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              children: children,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildStepTile(String title, String subtitle, IconData icon) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF818CF8), size: 24),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                Text(subtitle, style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildSupportOption(String title, String subtitle, IconData icon, Color color) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: GlassCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 28)),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(subtitle, style: GoogleFonts.dmSans(color: Colors.white54, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white12, size: 16),
        ],
      ),
    ),
  );
}
