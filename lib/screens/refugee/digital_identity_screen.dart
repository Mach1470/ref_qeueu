import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ref_qeueu/widgets/glass_widgets.dart';
import 'package:ref_qeueu/widgets/safe_scaffold.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ref_qeueu/services/auth_service.dart';

class DigitalIdentityScreen extends StatefulWidget {
  const DigitalIdentityScreen({super.key});

  @override
  State<DigitalIdentityScreen> createState() => _DigitalIdentityScreenState();
}

class _DigitalIdentityScreenState extends State<DigitalIdentityScreen> {
  final AuthService _auth = AuthService();
  String _userName = 'Loading...';
  String _userId = 'Loading...';
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final name = (await _auth.getUserId()) ?? 'REF-000-GOLD';
    final id = (await _auth.getUserId()) ?? 'REF-000-000-GOLD';
    final profileImg = await _auth.getProfilePicture(id);
    if (mounted) {
      setState(() {
        _userName = name;
        _userId = id;
        _profileImageUrl = profileImg;
      });
    }
  }

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
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E1B4B),
              Color(0xFF312E81),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6366F1).withOpacity(0.12),
                ),
              ).animate().fadeIn(duration: 1.seconds).scale(),
            ),
            Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildIdentityCard(),
                        const SizedBox(height: 40),
                        _buildSectionHeader('Verification Details'),
                        const SizedBox(height: 16),
                        _buildDetailTile(Icons.verified_user_rounded, 'Status', 'UNHCR Certified', Colors.greenAccent),
                        _buildDetailTile(Icons.calendar_today_rounded, 'Issued Date', 'Jan 12, 2026', Colors.blueAccent),
                        _buildDetailTile(Icons.history_rounded, 'Last Sync', 'Active (Real-time)', Colors.purpleAccent),
                        const SizedBox(height: 40),
                        _buildSectionHeader('Legal Authority'),
                        const SizedBox(height: 16),
                        GlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Text(
                                'This digital identity is recognized by humanitarian agencies and local authorities for prioritized healthcare access and logistics support.',
                                style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 13, height: 1.5),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  const Icon(Icons.info_outline, color: Colors.blueAccent, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Encrypted with 256-bit AES',
                                    style: GoogleFonts.dmSans(color: Colors.blueAccent, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 20),
      child: Row(
        children: [
          _buildCircleButton(Icons.arrow_back_ios_new_rounded, () => Navigator.pop(context)),
          const SizedBox(width: 16),
          Text(
            'Digital Identity',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          _buildCircleButton(Icons.share_rounded, () {}),
        ],
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildIdentityCard() {
    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5), Color(0xFF312E81)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage('https://www.transparenttextures.com/patterns/carbon-fibre.png'),
                    repeat: ImageRepeat.repeat,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('UNHCR CERTIFICATE',
                            style: GoogleFonts.dmSans(
                                color: Colors.white60,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text('GOLD STATUS',
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            const Icon(Icons.verified_rounded,
                                color: Colors.greenAccent, size: 16),
                          ],
                        ),
                      ],
                    ),
                    if (_profileImageUrl != null)
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 2),
                        ),
                        child: ClipOval(
                          child: _profileImageUrl!.startsWith('http')
                              ? Image.network(_profileImageUrl!,
                                  fit: BoxFit.cover)
                              : Image.file(File(_profileImageUrl!),
                                  fit: BoxFit.cover),
                        ),
                      )
                    else
                      const Icon(Icons.qr_code_2_rounded,
                          color: Colors.white, size: 40),
                  ],
                ),
                const Spacer(),
                Text(_userName.toUpperCase(), style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                Text(_userId, style: GoogleFonts.dmSans(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 3)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).scale();
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.dmSans(color: const Color(0xFF818CF8), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5),
    );
  }

  Widget _buildDetailTile(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 18)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
                Text(value, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
