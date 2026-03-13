import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ref_qeueu/widgets/safe_scaffold.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ref_qeueu/services/auth_service.dart';
import 'package:ref_qeueu/services/database_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ref_qeueu/widgets/glass_widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RefugeeHomeScreenNew extends StatefulWidget {
  const RefugeeHomeScreenNew({super.key});

  @override
  State<RefugeeHomeScreenNew> createState() => _RefugeeHomeScreenNewState();
}

class _RefugeeHomeScreenNewState extends State<RefugeeHomeScreenNew> {
  bool _subScreenActive = false;
  String? _activeSubScreen;
  String? _userName;
  String? _activeTicketId;
  String? _hospitalId;
  String? _profileImageUrl;
  bool _showProfileOverlay = false;

  @override
  void initState() {
    super.initState();
    _loadLocalProfile();
    // Ensure local family members are available immediately when the
    // refugee home screen is shown so Join Queue can list/select them.
    _loadFamilyMembers();
  }

  Future<void> _loadLocalProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('user_name');
      final tid = prefs.getString('active_ticket_id');
      final hid = prefs.getString('active_hospital_id') ?? 'fac_001';
      if (mounted) {
        setState(() {
          _userName = name;
          _activeTicketId = tid;
          _hospitalId = hid;
          _profileImageUrl = prefs.getString('profile_image_url');
        });
      }
    } catch (_) {}
  }

  List<Map<String, String>> _familyMembers = [];

  Future<void> _loadFamilyMembers() async {
    try {
      final auth = AuthService();
      final list = await auth.getFamilyMembers();
      if (mounted) setState(() => _familyMembers = list);
    } catch (_) {}
  }

  Widget _buildProfileOverlay() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: Colors.black.withOpacity(0.6),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      _buildGlassIconButton(
                        Icons.close_rounded,
                        () => setState(() => _showProfileOverlay = false),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        'Profile Settings',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      _buildGlassIconButton(
                        Icons.logout_rounded,
                        () => _handleLogout(),
                        iconColor: Colors.redAccent,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        // Avatar Section with Glow
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueAccent.withOpacity(0.2),
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
                                    color: Colors.white.withOpacity(0.1),
                                    width: 1.5),
                              ),
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.1),
                                ),
                                child: const Icon(Icons.person_rounded,
                                    color: Colors.white, size: 60),
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
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color:
                                    const Color(0xFF10B981).withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified_user_rounded,
                                  color: Color(0xFF10B981), size: 14),
                              const SizedBox(width: 6),
                              Text(
                                'UNHCR VERIFIED',
                                style: GoogleFonts.dmSans(
                                  color: const Color(0xFF10B981),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48),

                        // User Info Card
                        GlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _buildInfoRow(Icons.qr_code_rounded, 'Refugee ID',
                                  'REF-987-420-X'),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Divider(color: Colors.white10),
                              ),
                              _buildInfoRow(Icons.phone_rounded, 'Contact No',
                                  '+254 712 345 678'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Stats Row (Horizontal Scrollable)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              _buildProfileStat(
                                  'Family Size',
                                  '${_familyMembers.length + 1}',
                                  Icons.groups_rounded,
                                  Colors.blueAccent),
                              const SizedBox(width: 12),
                              _buildProfileStat('Medical Visits', '12',
                                  Icons.history_rounded, Colors.purpleAccent),
                              const SizedBox(width: 12),
                              _buildProfileStat('Priority Status', 'Regular',
                                  Icons.star_rounded, Colors.amberAccent),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Settings Groups
                        _buildSettingsSection(
                          'Account & Security',
                          [
                            _buildSettingsItem(
                                Icons.badge_rounded,
                                'Digital Identity',
                                'Manage certificates',
                                () {}),
                            _buildSettingsItem(
                                Icons.lock_rounded,
                                'Change Access PIN',
                                'Secure your account',
                                () {}),
                            _buildSettingsItem(
                                Icons.notifications_active_rounded,
                                'Notification Prefs',
                                'SMS & Push alerts',
                                () {}),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildSettingsSection(
                          'Support',
                          [
                            _buildSettingsItem(Icons.help_center_rounded,
                                'Help Center', 'FAQs & Knowledge Base', () {}),
                            _buildSettingsItem(
                                Icons.chat_bubble_rounded,
                                'Emergency Support',
                                'Talk to a coordinator',
                                () {}),
                            _buildSettingsItem(
                                Icons.info_rounded,
                                'About Application',
                                'Version 2.4.0-Premium',
                                () {}),
                          ],
                        ),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(duration: 400.ms).scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          curve: Curves.easeOutCubic),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 20),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.dmSans(
                    color: Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(value,
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileStat(
      String label, String value, IconData icon, Color color) {
    return SizedBox(
      width: 120,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 12),
            Text(value,
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.dmSans(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
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

  Widget _buildSettingsItem(
      IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
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

  Widget _buildGlassIconButton(IconData icon, VoidCallback onTap,
      {Color iconColor = Colors.white}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  Future<void> _handleLogout() async {
    await AuthService().logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
          context, '/role_selection', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeScaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E3A8A), // Deep Blue
              Color(0xFF312E81), // Indigo
              Color(0xFF4C1D95), // Deep Purple
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
                children: [
                  // HEADER
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(
                                context, '/role_selection');
                          },
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.25),
                                        Colors.white.withOpacity(0.08),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white.withOpacity(0.3))),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/illustrations/app_logo.png',
                                    width: 32,
                                    height: 32,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Text('MyQueue',
                                  style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // BODY
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          GlassCard(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.pushNamed(
                                        context, '/profile'),
                                    behavior: HitTestBehavior.opaque,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Welcome back,',
                                                style: GoogleFonts.dmSans(
                                                  color: Colors.white70,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                _userName ?? 'Refugee',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Hero(
                                          tag: 'profile_avatar',
                                          child: Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.white.withOpacity(0.3),
                                                  Colors.white.withOpacity(0.1),
                                                ],
                                              ),
                                              border: Border.all(
                                                  color: Colors.white
                                                      .withOpacity(0.2)),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 10,
                                                  offset: Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: ClipOval(
                                              child: _profileImageUrl != null
                                                  ? Image.network(
                                                      _profileImageUrl!,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (_, __,
                                                              ___) =>
                                                          const Icon(
                                                              Icons
                                                                  .person_rounded,
                                                              color:
                                                                  Colors.white),
                                                    )
                                                  : const Icon(
                                                      Icons.person_rounded,
                                                      color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  _buildQueueStatus(),
                                ]),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Services',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.95,
                            children: [
                              _DashboardCard(
                                  title: 'Join Queue',
                                  subtitle: 'Find hospital',
                                  icon: Icons.people_alt_rounded,
                                  gradientColors: const [
                                    Color(0xFFF59E0B),
                                    Color(0xFFD97706)
                                  ], // Amber
                                  onTap: () => Navigator.pushNamed(
                                      context, '/refugee/join_queue')),
                              _DashboardCard(
                                  title: 'Create ID',
                                  subtitle: 'Register family',
                                  icon: Icons.badge_rounded,
                                  gradientColors: const [
                                    Color(0xFF8B5CF6),
                                    Color(0xFF6D28D9)
                                  ], // Purple
                                  onTap: () => Navigator.pushNamed(
                                      context, '/refugee/family_registration')),
                              _DashboardCard(
                                  title: 'Ambulance',
                                  subtitle: 'Emergency',
                                  icon: Icons.emergency_rounded,
                                  gradientColors: const [
                                    Color(0xFFEF4444),
                                    Color(0xFFB91C1C)
                                  ], // Red
                                  onTap: () => Navigator.pushNamed(
                                      context, '/refugee_ambulance_request')),
                              _DashboardCard(
                                  title: 'Med. History',
                                  subtitle: 'Past records',
                                  icon: Icons.medical_information_rounded,
                                  gradientColors: const [
                                    Color(0xFF10B981),
                                    Color(0xFF047857)
                                  ], // Emerald
                                  onTap: () => _openSubScreen('history')),
                            ],
                          ),
                          const SizedBox(height: 32),
                          // Extra Actions
                          GlassCard(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextButton.icon(
                                    onPressed: () => Navigator.pushNamed(
                                        context,
                                        '/refugee/family_registration'),
                                    icon: const Icon(Icons.add_circle_outline,
                                        color: Colors.white),
                                    label: const Text('Add Member',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                                Container(
                                    width: 1,
                                    height: 24,
                                    color: Colors.white24),
                                Expanded(
                                  child: TextButton.icon(
                                    onPressed: _loadFamilyMembers,
                                    icon: const Icon(Icons.refresh_rounded,
                                        color: Colors.white),
                                    label: const Text('Sync Data',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildFamilySection(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Overlay if active
              if (_subScreenActive)
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(30))),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 12.0),
                          child: Row(children: [
                            IconButton(
                                icon: const Icon(Icons.arrow_back,
                                    color: Color(0xFF386BB8)),
                                onPressed: () => setState(() {
                                      _subScreenActive = false;
                                      _activeSubScreen = null;
                                    })),
                            const SizedBox(width: 8),
                            Text(
                                _activeSubScreen == 'id_card'
                                    ? 'My ID Card'
                                    : (_activeSubScreen == 'history'
                                        ? 'History'
                                        : (_activeSubScreen ?? 'Details')),
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold))
                          ]),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: _buildSubScreenContent(),
                        ),
                      ],
                    ),
                  ),
                ),

              // Profile Overlay
              if (_showProfileOverlay) _buildProfileOverlay(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E3A8A).withOpacity(0.9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_rounded, 'Home', true, () {}),
                _buildNavItem(Icons.person_outline_rounded, 'Profile', false,
                    () => Navigator.pushNamed(context, '/profile')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.dmSans(
                color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueStatus() {
    if (_activeTicketId == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded,
                color: Colors.white70, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No active queue ticket at the moment.',
                style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<int>(
      stream: DatabaseService.instance
          .getQueuePositionStream(_hospitalId ?? 'fac_001', _activeTicketId!),
      builder: (context, snapshot) {
        final pos = snapshot.data;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator(
              color: Colors.white, backgroundColor: Colors.white10);
        }
        if (pos == null || pos <= 0) {
          return Text('Calculating position...',
              style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 13));
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1))),
          child: Row(
            children: [
              const Icon(Icons.confirmation_num_rounded,
                  color: Colors.white, size: 24),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Queue Position',
                      style: GoogleFonts.dmSans(
                          color: Colors.white70, fontSize: 12)),
                  Text('$pos',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24)),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('LIVE',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> _resolveActorKey() async {
    // Prefer FirebaseAuth uid, otherwise fall back to stored phone or id
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.uid.isNotEmpty) return user.uid;
    } catch (_) {}

    try {
      final prefs = await SharedPreferences.getInstance();
      final phone = prefs.getString('user_phone');
      if (phone != null && phone.isNotEmpty) {
        return phone.replaceAll('+', '').replaceAll(RegExp(r'[^0-9]'), '');
      }
      final id = prefs.getString('user_id');
      if (id != null && id.isNotEmpty) return id;
    } catch (_) {}

    return null;
  }

  void _openSubScreen(String id) => setState(() {
        _activeSubScreen = id;
        _subScreenActive = true;
      });

  Widget _buildSubScreenContent() {
    if (_activeSubScreen == 'id_card') {
      return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: const [
        Icon(Icons.badge_outlined, size: 64, color: Colors.teal),
        SizedBox(height: 12),
        Text('My ID Card details will appear here',
            style: TextStyle(fontSize: 16))
      ]));
    }

    if (_activeSubScreen == 'history') {
      return FutureBuilder<String?>(
        future: _resolveActorKey(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final actorKey = snap.data;
          if (actorKey == null || actorKey.isEmpty) {
            return const Center(
                child:
                    Text('No user identifier found. Sign in to view history.'));
          }

          final ref = FirebaseDatabase.instance
              .ref('userActivity')
              .child(actorKey)
              .child('sessions');
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 12),
              const Text('Visit History',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: StreamBuilder<DatabaseEvent>(
                  stream: ref.onValue,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final data = snapshot.data?.snapshot.value;
                    if (data == null) {
                      return Center(
                          child: Text('No visits found.',
                              style: TextStyle(color: Colors.grey.shade600)));
                    }

                    // Data is Map of sessionId: {loginAt, logoutAt, method, ...}
                    final Map sessionsMap = data as Map;
                    final List<MapEntry> sessions =
                        sessionsMap.entries.toList();
                    sessions.sort((a, b) {
                      final aTs = (a.value['loginAt'] ?? 0) as int;
                      final bTs = (b.value['loginAt'] ?? 0) as int;
                      return bTs.compareTo(aTs);
                    });

                    return ListView.separated(
                      itemCount: sessions.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final entry = sessions[index];
                        final session =
                            Map<String, dynamic>.from(entry.value as Map);
                        final loginAt = session['loginAt'] is int
                            ? DateTime.fromMillisecondsSinceEpoch(
                                session['loginAt'] as int)
                            : null;
                        final logoutAt = session['logoutAt'] is int
                            ? DateTime.fromMillisecondsSinceEpoch(
                                session['logoutAt'] as int)
                            : null;
                        final method =
                            session['method']?.toString() ?? 'unknown';
                        return ListTile(
                          leading: const Icon(Icons.event_note_outlined,
                              color: Color(0xFF386BB8)),
                          title: Text(loginAt != null
                              ? loginAt
                                  .toLocal()
                                  .toIso8601String()
                                  .split('T')
                                  .first
                              : 'Unknown date'),
                          subtitle: Text(
                              'Method: $method${logoutAt != null ? ' • Left: ${logoutAt.toLocal().toIso8601String().split('T').first}' : ''}'),
                        );
                      },
                    );
                  },
                ),
              ),
            ]),
          );
        },
      );
    }

    return Center(
        child: Text('Sub-screen: ${_activeSubScreen ?? "Unknown"}',
            style: const TextStyle(fontSize: 16)));
  }

  Widget _buildFamilySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Family Account',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                // Add dependency logic
                Navigator.pushNamed(context, '/refugee/family_registration');
              },
              icon: const Icon(Icons.add_circle_outline_rounded,
                  color: Colors.white70, size: 18),
              label: Text(
                'Add Member',
                style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              // Primary Account Holder (Self)
              _buildFamilyMemberTile(
                name: _userName ?? 'Account Holder',
                relationship: 'Self (Primary)',
                isPrimary: true,
              ),
              if (_familyMembers.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(color: Colors.white10),
                ),
              // Dependencies
              ..._familyMembers.map((member) => _buildFamilyMemberTile(
                    name: member['name'] ?? 'Unknown',
                    relationship: member['relationship'] ?? 'Dependent',
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFamilyMemberTile({
    required String name,
    required String relationship,
    bool isPrimary = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isPrimary
              ? const Color(0xFF6366F1).withOpacity(0.1)
              : Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isPrimary ? Icons.stars_rounded : Icons.person_outline_rounded,
          color: isPrimary ? const Color(0xFF818CF8) : Colors.white70,
          size: 20,
        ),
      ),
      title: Text(
        name,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 15,
          fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      subtitle: Text(
        relationship,
        style: GoogleFonts.dmSans(
          color: Colors.white38,
          fontSize: 12,
        ),
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white10, size: 12),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      gradientColors[0].withOpacity(0.8),
                      gradientColors[1].withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[0].withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const Spacer(),
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.dmSans(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
