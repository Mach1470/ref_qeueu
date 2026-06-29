import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ref_qeueu/widgets/glass_widgets.dart';
import 'package:ref_qeueu/widgets/safe_scaffold.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import 'digital_identity_screen.dart';
import 'settings_screen.dart';
import 'support_screens.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _userName;
  String? _userPhone;
  String? _refugeeId;
  String? _campName;
  String? _registrationDate;
  String? _profileImageUrl;
  List<Map<String, String>> _familyMembers = [];
  int _medicalVisits = 0;

  final _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userName = prefs.getString('user_name') ?? prefs.getString('user_phone');
        _userPhone = prefs.getString('user_phone');
        _profileImageUrl = prefs.getString('profile_image_url');
        _campName = prefs.getString('user_facility_name');
      });
    }

    final members = await _auth.getFamilyMembers();
    if (mounted) setState(() => _familyMembers = members);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && mounted) {
        final d = doc.data()!;
        setState(() {
          _userName = d['name']?.toString() ?? _userName;
          _refugeeId = d['refugeeId']?.toString() ?? d['caseNumber']?.toString();
          _campName = d['facilityName']?.toString() ?? _campName;
          final ts = d['createdAt'];
          if (ts is Timestamp) {
            final dt = ts.toDate();
            _registrationDate = '${dt.day}/${dt.month}/${dt.year}';
          }
        });
      }

      final snap = await FirebaseDatabase.instance.ref('userActivity/${user.uid}/sessions').get();
      if (mounted) setState(() => _medicalVisits = snap.children.length);
    } catch (_) {}
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image == null) return;
    final uid = await _auth.getUserId();
    if (uid == null) return;

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Uploading photo…')));
    }
    try {
      final url = await StorageService.instance
          .uploadProfilePhoto(userId: uid, photoFile: File(image.path));
      if (url != null) {
        setState(() => _profileImageUrl = url);
        await _auth.setProfilePicture(uid, url);
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Photo updated')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    }
  }

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF002147),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sign Out',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('You will need to log in again to use MyQueue.',
            style: GoogleFonts.dmSans(color: Colors.white70, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.dmSans(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _auth.logout();
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('is_logged_in', false);
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/role_selection', (_) => false);
              }
            },
            child: Text('Sign Out',
                style: GoogleFonts.dmSans(
                    color: const Color(0xFFEF4444), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  //  BUILD
  // ──────────────────────────────────────────

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
            colors: [Color(0xFF001530), Color(0xFF002147), Color(0xFF003D7A)],
          ),
        ),
        child: Column(
          children: [
            // ── App Bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 12),
              child: Row(
                children: [
                  _CircleBtn(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 14),
                  Text('My Profile',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700)),
                  const Spacer(),
                  _CircleBtn(
                    icon: Icons.settings_outlined,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen())),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildHero(),
                    const SizedBox(height: 20),
                    Center(child: _buildStatusBadge()),
                    const SizedBox(height: 28),
                    _buildStats(),
                    const SizedBox(height: 32),

                    _label('CASE DETAILS'),
                    const SizedBox(height: 12),
                    _buildCaseCard(),
                    const SizedBox(height: 28),

                    _label('REGISTERED HOUSEHOLD'),
                    const SizedBox(height: 12),
                    _buildHouseholdCard(),
                    const SizedBox(height: 28),

                    _label('DIGITAL IDENTITY'),
                    const SizedBox(height: 12),
                    _buildDigitalIdTile(),
                    const SizedBox(height: 32),

                    _label('SUPPORT & INFO'),
                    const SizedBox(height: 12),
                    _buildSupportCard(),
                    const SizedBox(height: 32),

                    _buildSignOutBtn(),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  //  SECTIONS
  // ──────────────────────────────────────────

  Widget _buildHero() {
    return Center(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.04),
                  ]),
                  border: Border.all(color: Colors.white.withOpacity(0.18), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFCBE11).withOpacity(0.35),
                      blurRadius: 40,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _profileImageUrl != null
                      ? (_profileImageUrl!.startsWith('http')
                          ? Image.network(_profileImageUrl!, fit: BoxFit.cover)
                          : Image.file(File(_profileImageUrl!), fit: BoxFit.cover))
                      : const Icon(Icons.person_rounded, color: Colors.white60, size: 48),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCBE11),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF002147), width: 2.5),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _userName ?? 'Registered User',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
          ),
          if (_userPhone != null) ...[
            const SizedBox(height: 4),
            Text(_userPhone!,
                style: GoogleFonts.dmSans(color: Colors.white54, fontSize: 13)),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.15, end: 0);
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 14),
          const SizedBox(width: 7),
          Text('UNHCR REGISTERED',
              style: GoogleFonts.dmSans(
                  color: const Color(0xFF10B981),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4)),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildStats() {
    return Row(
      children: [
        _stat('${_familyMembers.length + 1}', 'Household', Icons.groups_rounded,
            const Color(0xFF82C4E8)),
        const SizedBox(width: 12),
        _stat('$_medicalVisits', 'Visits', Icons.local_hospital_outlined,
            const Color(0xFF34D399)),
        const SizedBox(width: 12),
        _stat('Primary', 'Account', Icons.account_circle_outlined,
            const Color(0xFFFBBF24)),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _stat(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(value,
                style: GoogleFonts.poppins(
                    color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                    color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildCaseCard() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _infoRow(
            Icons.badge_outlined,
            'Refugee / Case ID',
            _refugeeId ?? 'Pending — complete registration',
            copyable: _refugeeId != null,
          ),
          _divider(),
          _infoRow(
            Icons.location_city_outlined,
            'Camp Assignment',
            _campName ?? 'Not yet assigned',
          ),
          if (_registrationDate != null) ...[
            _divider(),
            _infoRow(
              Icons.calendar_today_outlined,
              'Registered Since',
              _registrationDate!,
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _infoRow(IconData icon, String label, String value, {bool copyable = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white54, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.dmSans(
                      color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
              Text(value,
                  style: GoogleFonts.dmSans(
                      color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        if (copyable)
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('ID copied to clipboard'),
                    duration: Duration(seconds: 1)));
            },
            child: const Icon(Icons.copy_rounded, color: Colors.white30, size: 16),
          ),
      ],
    );
  }

  Widget _divider() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 14),
        child: Divider(color: Colors.white10, height: 1),
      );

  Widget _buildHouseholdCard() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${_familyMembers.length + 1} member${_familyMembers.length == 0 ? '' : 's'} registered',
                style: GoogleFonts.dmSans(color: Colors.white54, fontSize: 13),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/refugee/family_registration')
                    .then((_) => _load()),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCBE11).withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFCBE11).withOpacity(0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_rounded, color: Color(0xFF82C4E8), size: 14),
                      const SizedBox(width: 4),
                      Text('Add Member',
                          style: GoogleFonts.dmSans(
                              color: const Color(0xFF82C4E8),
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Primary holder
          _memberRow(_userName ?? 'You', 'Account Holder', primary: true),

          // Registered dependents
          ..._familyMembers.map((m) => Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: Colors.white10, height: 1),
                  ),
                  _memberRow(
                    m['name'] ?? 'Member',
                    m['relationship'] ?? 'Family Member',
                  ),
                ],
              )),

          if (_familyMembers.isEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'No dependents added yet. Tap "Add Member" to register your spouse, children, or other household members under your case.',
              style: GoogleFonts.dmSans(
                  color: Colors.white30, fontSize: 12, height: 1.6),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 450.ms);
  }

  Widget _memberRow(String name, String role, {bool primary = false}) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primary
                ? const Color(0xFFFCBE11).withOpacity(0.18)
                : Colors.white.withOpacity(0.06),
          ),
          child: Icon(
            primary ? Icons.person_rounded : Icons.person_outline_rounded,
            color: primary ? const Color(0xFF82C4E8) : Colors.white54,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(name,
              style: GoogleFonts.dmSans(
                  color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: primary
                ? const Color(0xFFFCBE11).withOpacity(0.14)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(role,
              style: GoogleFonts.dmSans(
                  color: primary ? const Color(0xFF82C4E8) : Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildDigitalIdTile() {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const DigitalIdentityScreen())),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFCBE11).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.credit_card_rounded, color: Color(0xFF82C4E8), size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('UNHCR Digital Certificate',
                      style: GoogleFonts.dmSans(
                          color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  Text('View and share your verified identity document',
                      style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 13),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildSupportCard() {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _navRow(
            Icons.help_outline_rounded,
            'Community Help',
            'FAQs, how-to guides, and usage tips',
            const Color(0xFF60A5FA),
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CommunityHelpScreen())),
          ),
          const Divider(color: Colors.white10, height: 1, indent: 20, endIndent: 20),
          _navRow(
            Icons.support_agent_rounded,
            'Direct Support',
            'Contact UNHCR and humanitarian staff',
            const Color(0xFF34D399),
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const DirectSupportScreen())),
          ),
          const Divider(color: Colors.white10, height: 1, indent: 20, endIndent: 20),
          _navRow(
            Icons.info_outline_rounded,
            'About MyQueue',
            'Version, mission, privacy and legal',
            const Color(0xFFA78BFA),
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AboutAppScreen())),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 550.ms);
  }

  Widget _navRow(IconData icon, String title, String sub, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    Text(sub,
                        style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 13),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignOutBtn() {
    return GestureDetector(
      onTap: _confirmSignOut,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444).withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.22)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 17),
            const SizedBox(width: 10),
            Text('Sign Out',
                style: GoogleFonts.dmSans(
                    color: const Color(0xFFEF4444),
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.dmSans(
            color: const Color(0xFF82C4E8),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8),
      );
}

// ──────────────────────────────────────────
//  Small shared widgets
// ──────────────────────────────────────────

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(icon, color: Colors.white70, size: 16),
      ),
    );
  }
}
