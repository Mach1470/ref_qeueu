import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import 'digital_identity_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'visit_history_screen.dart';
import 'support_screens.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _name;
  String? _email;
  String? _phone;
  String? _photoUrl;
  int _familyCount = 0;

  final _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (mounted) {
      setState(() {
        _name = firebaseUser?.displayName ?? prefs.getString('user_name');
        _email = firebaseUser?.email ?? prefs.getString('user_email');
        _phone = prefs.getString('user_phone');
        _photoUrl = firebaseUser?.photoURL ?? prefs.getString('profile_image_url');
      });
    }

    try {
      if (firebaseUser != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .get();
        if (doc.exists && mounted) {
          final d = doc.data()!;
          setState(() {
            _name = d['name']?.toString() ?? _name;
          });
        }
      }
    } catch (_) {}

    final members = await _auth.getFamilyMembers();
    if (mounted) setState(() => _familyCount = members.length);
  }

  Future<void> _pickImage() async {
    final img = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (img == null) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final url = await StorageService.instance
          .uploadProfilePhoto(userId: uid, photoFile: File(img.path));
      if (url != null && mounted) {
        setState(() => _photoUrl = url);
        await _auth.setProfilePicture(uid, url);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _name ?? 'Registered User';
    final displaySub = _email ?? _phone ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE0EAF0)),
            ),
            child: const Icon(Icons.chevron_left_rounded,
                color: Color(0xFF001F47), size: 24),
          ),
        ),
        title: Text('Profile',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: const Color(0xFF001F47))),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: photo + name + email ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFE8F1F8),
                            border: Border.all(
                                color: const Color(0xFFD0E4F4), width: 2),
                          ),
                          child: ClipOval(
                            child: _photoUrl != null
                                ? (_photoUrl!.startsWith('http')
                                    ? Image.network(_photoUrl!,
                                        fit: BoxFit.cover)
                                    : Image.file(File(_photoUrl!),
                                        fit: BoxFit.cover))
                                : const Icon(Icons.person_rounded,
                                    color: Color(0xFF82C4E8), size: 36),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0072BC),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white, width: 1.5),
                            ),
                            child: const Icon(Icons.camera_alt_rounded,
                                color: Colors.white, size: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF001F47),
                          ),
                        ),
                        if (displaySub.isNotEmpty)
                          Text(
                            displaySub,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: const Color(0xFF5A7A8A),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Edit Profile | Settings action row ──
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F8FB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE0EAF0)),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionTab(
                        icon: Icons.person_outline_rounded,
                        label: 'Edit Profile',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => EditProfileScreen(
                                    name: _name,
                                    email: _email,
                                    phone: _phone,
                                    onSaved: _load,
                                  )),
                        ),
                      ),
                    ),
                    VerticalDivider(
                        color: const Color(0xFFE0EAF0),
                        width: 1,
                        thickness: 1),
                    Expanded(
                      child: _ActionTab(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SettingsScreen()),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Healthcare ──
            _SectionHeader('Healthcare'),
            _ListTile(
              icon: Icons.history_rounded,
              iconColor: const Color(0xFF0072BC),
              label: 'Visit History',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const VisitHistoryScreen())),
            ),
            _Divider(),
            _ListTile(
              icon: Icons.groups_rounded,
              iconColor: const Color(0xFF10B981),
              label: 'Family Members',
              trailing: _familyCount > 0
                  ? Text('$_familyCount',
                      style: GoogleFonts.dmSans(
                          color: const Color(0xFF5A7A8A), fontSize: 13))
                  : null,
              onTap: () => Navigator.pushNamed(
                      context, '/refugee/family_registration')
                  .then((_) => _load()),
            ),
            _Divider(),
            _ListTile(
              icon: Icons.credit_card_rounded,
              iconColor: const Color(0xFFFCBE11),
              label: 'Digital Identity',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const DigitalIdentityScreen())),
            ),

            const SizedBox(height: 28),

            // ── Support ──
            _SectionHeader('Contact Us'),
            _ListTile(
              icon: Icons.support_agent_rounded,
              iconColor: const Color(0xFF0072BC),
              label: 'Contact Support',
              isBlue: true,
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const DirectSupportScreen())),
            ),
            _Divider(),
            _ListTile(
              icon: Icons.help_outline_rounded,
              iconColor: const Color(0xFF5A7A8A),
              label: 'Community Help',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const CommunityHelpScreen())),
            ),
            _Divider(),
            _ListTile(
              icon: Icons.info_outline_rounded,
              iconColor: const Color(0xFF5A7A8A),
              label: 'About MyQueue',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AboutAppScreen())),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ── Shared widgets ──

class _ActionTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionTab(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF0072BC), size: 22),
            const SizedBox(height: 6),
            Text(label,
                style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: const Color(0xFF001F47))),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      child: Text(text,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: const Color(0xFF001F47))),
    );
  }
}

class _ListTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool isBlue;
  final Widget? trailing;
  final VoidCallback onTap;

  const _ListTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.isBlue = false,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isBlue
                      ? const Color(0xFF0072BC)
                      : const Color(0xFF1E293B),
                ),
              ),
            ),
            trailing ?? const Icon(Icons.chevron_right_rounded,
                color: Color(0xFFADBCC8), size: 20),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, indent: 20, endIndent: 20, color: Color(0xFFEEF2F6));
}
