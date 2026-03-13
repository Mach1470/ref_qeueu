import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ref_qeueu/widgets/glass_widgets.dart';
import 'package:ref_qeueu/widgets/safe_scaffold.dart';
import 'package:ref_qeueu/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'digital_identity_screen.dart';
import 'access_pin_screen.dart';
import 'push_alerts_screen.dart';
import 'support_screens.dart';
import '../../services/storage_service.dart';
import '../../services/security_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _userName;
  List<Map<String, String>> _familyMembers = [];
  String? _profileImageUrl; // Added for profile image
  final AuthService _authService = AuthService();
  bool _biometricsEnabled = false;
  bool _pinEnabled = false;
  bool _hasBiometrics = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _checkSecurityStatus();
  }

  Future<void> _checkSecurityStatus() async {
    final security = SecurityService.instance;
    final bioEnabled = await security.isBiometricsEnabled();
    final pinEnabled = await security.isPinEnabled();
    final hasBio = await security.canCheckBiometrics();
    
    if (mounted) {
      setState(() {
        _biometricsEnabled = bioEnabled;
        _pinEnabled = pinEnabled;
        _hasBiometrics = hasBio;
      });
    }
  }

  void _toggleBiometrics(bool value) async {
    if (value) {
      final success = await SecurityService.instance.authenticate();
      if (success) {
        await SecurityService.instance.setBiometricsEnabled(true);
        setState(() => _biometricsEnabled = true);
      }
    } else {
      await SecurityService.instance.setBiometricsEnabled(false);
      setState(() => _biometricsEnabled = false);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Optimize for mobile
    );

    if (image != null) {
      final uid = await _authService.getUserId();
      if (uid == null) return;

      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uploading profile picture...')),
        );
      }

      try {
        // Upload to Firebase Storage
        final imageUrl = await StorageService.instance.uploadProfilePhoto(
          userId: uid,
          photoFile: File(image.path),
        );

        if (imageUrl != null) {
          setState(() => _profileImageUrl = imageUrl);
          await _authService.setProfilePicture(uid, imageUrl);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile picture updated!')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: $e')),
          );
        }
      }
    }
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final auth = AuthService();
    final name = prefs.getString('user_name');
    final members = await auth.getFamilyMembers();

    if (mounted) {
      setState(() {
        _userName = name;
        _familyMembers = members;
        _profileImageUrl = prefs.getString('profile_image_url');
      });
    }
  }

  // Removed _handleLogout as requested

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
              Color(0xFF0F172A), // Slate 900
              Color(0xFF1E1B4B), // Indigo 950
              Color(0xFF312E81), // Indigo 900
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background Orbs
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
                // Custom AppBar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 60, 16, 20),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Profile Settings',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      // Removed _buildLogoutButton()
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Avatar Section
                        _buildHeroProfile(),
                        const SizedBox(height: 40),

                        // Verification Row
                        _buildVerificationBadge(),
                        const SizedBox(height: 48),

                        // Stats Grid
                        _buildStatsGrid(),
                        const SizedBox(height: 32),

                        // User Info Card
                        _buildUserInfoCard(),
                        const SizedBox(height: 32),

                        // Settings Sections
                        _buildSettingsGroup(
                          'Security & Privacy',
                          [
                            _buildSettingsTile(
                                Icons.switch_account_rounded,
                                'Manage Accounts',
                                'Switch between existing profiles',
                                () => Navigator.pushNamed(context, '/account_selector')),
                             _buildSettingsTile(
                                Icons.badge_rounded,
                                'Digital Identity',
                                'Manage UNHCR certificates',
                                () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const DigitalIdentityScreen()))),
                            _buildSecurityToggleTile(
                                Icons.fingerprint_rounded,
                                'Biometric Lock',
                                'Fingerprint or Face ID',
                                _biometricsEnabled,
                                _hasBiometrics ? _toggleBiometrics : null),
                            _buildSettingsTile(
                                Icons.lock_outline_rounded,
                                'Access PIN',
                                _pinEnabled ? 'PIN Protected' : 'Secure your account',
                                () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const AccessPinScreen())).then((_) => _checkSecurityStatus())),
                            _buildSettingsTile(
                                Icons.notifications_none_rounded,
                                'Push Alerts',
                                'Proximity & safety notifications',
                                () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const PushAlertsScreen()))),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Replaced _buildSettingsGroup for 'Support' with direct Text and tiles
                        Text(
                          'Support & Info',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // Assuming textMain is white
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSettingsTile(
                            Icons.help_outline_rounded,
                            'Community Help',
                            'FAQs and usage guides',
                            () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const CommunityHelpScreen()))),
                        _buildSettingsTile(
                            Icons.contact_support_outlined,
                            'Direct Support',
                            'Contact humanitarian aid',
                            () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const DirectSupportScreen()))),
                        _buildSettingsTile(
                            Icons.info_outline_rounded,
                            'About MyQueue',
                            'Version, terms and mission',
                            () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const AboutAppScreen()))),
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

  // Removed _buildLogoutButton widget

  Widget _buildHeroProfile() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.2),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.05)
                  ],
                ),
                border: Border.all(
                    color: Colors.white.withOpacity(0.1), width: 1.5),
              ),
              child: Container(
                width: 130,
                height: 130,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: _profileImageUrl != null
                      ? (_profileImageUrl!.startsWith('http')
                          ? Image.network(_profileImageUrl!, fit: BoxFit.cover)
                          : Image.file(File(_profileImageUrl!),
                              fit: BoxFit.cover))
                      : const Icon(Icons.person_rounded,
                          color: Colors.white, size: 64),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          _userName ?? 'Refugee User',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildVerificationBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_user_rounded,
              color: Color(0xFF10B981), size: 16),
          const SizedBox(width: 8),
          Text(
            'UNHCR VERIFIED STATUS',
            style: GoogleFonts.dmSans(
              color: const Color(0xFF10B981),
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
            child: _buildStatItem('Circle Size', '${_familyMembers.length + 1}',
                Icons.groups_rounded, Colors.blueAccent)),
        const SizedBox(width: 12),
        Expanded(
            child: _buildStatItem(
                'Records', '14', Icons.history_rounded, Colors.purpleAccent)),
        const SizedBox(width: 12),
        Expanded(
            child: _buildStatItem(
                'Status', 'Primary', Icons.star_rounded, Colors.amberAccent)),
      ],
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value,
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style: GoogleFonts.dmSans(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildInfoRow(
              Icons.qr_code_rounded, 'D-IDENTITY ID', 'REF-987-420-GOLD'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.white10),
          ),
          _buildInfoRow(Icons.phone_rounded, 'SECURE LINE', '+254 ••• •• 678'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white54, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.dmSans(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
            Text(value,
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsGroup(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.dmSans(
              color: const Color(0xFF818CF8),
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildSecurityToggleTile(
      IconData icon, String title, String subtitle, bool value, Function(bool)? onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: GoogleFonts.dmSans(
                        color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF6366F1),
            activeTrackColor: const Color(0xFF6366F1).withOpacity(0.3),
            inactiveThumbColor: Colors.white24,
            inactiveTrackColor: Colors.white10,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
      IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, color: Colors.white70, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    Text(subtitle,
                        style: GoogleFonts.dmSans(
                            color: Colors.white38, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white24, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
