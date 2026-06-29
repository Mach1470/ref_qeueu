import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ref_qeueu/widgets/glass_widgets.dart';
import 'package:ref_qeueu/widgets/safe_scaffold.dart';
import '../../services/security_service.dart';
import 'access_pin_screen.dart';
import 'push_alerts_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _biometricsEnabled = false;
  bool _pinEnabled = false;
  bool _hasBiometrics = false;

  @override
  void initState() {
    super.initState();
    _loadSecurity();
  }

  Future<void> _loadSecurity() async {
    final s = SecurityService.instance;
    final bio = await s.isBiometricsEnabled();
    final pin = await s.isPinEnabled();
    final has = await s.canCheckBiometrics();
    if (mounted) setState(() {
      _biometricsEnabled = bio;
      _pinEnabled = pin;
      _hasBiometrics = has;
    });
  }

  void _toggleBiometrics(bool value) async {
    if (value) {
      final ok = await SecurityService.instance.authenticate();
      if (ok) {
        await SecurityService.instance.setBiometricsEnabled(true);
        if (mounted) setState(() => _biometricsEnabled = true);
      }
    } else {
      await SecurityService.instance.setBiometricsEnabled(false);
      if (mounted) setState(() => _biometricsEnabled = false);
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
            colors: [Color(0xFF001530), Color(0xFF002147), Color(0xFF003D7A)],
          ),
        ),
        child: Column(
          children: [
            // App bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white70, size: 16),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text('Settings',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700)),
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

                    // ── Security ──
                    _sectionLabel('SECURITY & PRIVACY'),
                    const SizedBox(height: 12),
                    GlassCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _toggleTile(
                            icon: Icons.fingerprint_rounded,
                            title: 'Biometric Lock',
                            subtitle: _hasBiometrics
                                ? 'Use fingerprint or face ID to unlock the app'
                                : 'Biometrics not available on this device',
                            value: _biometricsEnabled,
                            onChanged: _hasBiometrics ? _toggleBiometrics : null,
                            color: const Color(0xFF82C4E8),
                          ),
                          _div(),
                          _navTile(
                            icon: Icons.lock_outline_rounded,
                            title: 'Access PIN',
                            subtitle: _pinEnabled
                                ? 'A 4-digit PIN is set — tap to change or remove'
                                : 'Set a 4-digit PIN as a backup to biometrics',
                            color: const Color(0xFF60A5FA),
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const AccessPinScreen()))
                                .then((_) => _loadSecurity()),
                          ),
                          _div(),
                          _navTile(
                            icon: Icons.switch_account_rounded,
                            title: 'Manage Accounts',
                            subtitle: 'Switch between saved profiles on this device',
                            color: const Color(0xFFA78BFA),
                            onTap: () => Navigator.pushNamed(context, '/account_selector'),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: 28),

                    // ── Notifications ──
                    _sectionLabel('NOTIFICATIONS'),
                    const SizedBox(height: 12),
                    GlassCard(
                      padding: EdgeInsets.zero,
                      child: _navTile(
                        icon: Icons.notifications_none_rounded,
                        title: 'Alert Preferences',
                        subtitle:
                            'Manage queue updates, proximity alerts, and safety notices',
                        color: const Color(0xFFFBBF24),
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const PushAlertsScreen())),
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 28),

                    // ── Data & Connectivity ──
                    _sectionLabel('DATA & CONNECTIVITY'),
                    const SizedBox(height: 12),
                    GlassCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _infoTile(
                            icon: Icons.wifi_off_rounded,
                            title: 'Offline Mode',
                            subtitle:
                                'Queue requests and updates are saved locally and synced automatically when you reconnect',
                            color: const Color(0xFF34D399),
                            badge: 'Active',
                          ),
                          _div(),
                          _infoTile(
                            icon: Icons.lock_person_outlined,
                            title: 'Encrypted Local Storage',
                            subtitle:
                                'Your health data, family information, and ID are stored securely on this device using AES-256 encryption',
                            color: const Color(0xFF60A5FA),
                            badge: 'On',
                          ),
                          _div(),
                          _navTile(
                            icon: Icons.sync_rounded,
                            title: 'Sync Data Now',
                            subtitle:
                                'Manually push any pending offline queue requests to the server',
                            color: const Color(0xFF82C4E8),
                            onTap: () async {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Syncing data…'),
                                    duration: Duration(seconds: 2)));
                            },
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: 28),

                    // ── App Preferences ──
                    _sectionLabel('APP PREFERENCES'),
                    const SizedBox(height: 12),
                    GlassCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _infoTile(
                            icon: Icons.language_rounded,
                            title: 'Language',
                            subtitle: 'English (more languages coming soon)',
                            color: const Color(0xFFFBBF24),
                            badge: 'EN',
                          ),
                          _div(),
                          _infoTile(
                            icon: Icons.accessibility_new_rounded,
                            title: 'Accessibility',
                            subtitle: 'High-contrast mode and larger text support',
                            color: const Color(0xFFA78BFA),
                            badge: 'Auto',
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms),

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

  Widget _sectionLabel(String text) => Text(
        text,
        style: GoogleFonts.dmSans(
            color: const Color(0xFF82C4E8),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8),
      );

  Widget _div() =>
      const Divider(color: Colors.white10, height: 1, indent: 20, endIndent: 20);

  Widget _toggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool)? onChanged,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          _iconBox(icon, color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: GoogleFonts.dmSans(
                      color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 11, height: 1.4)),
            ]),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFFCBE11),
            activeTrackColor: const Color(0xFFFCBE11).withOpacity(0.3),
            inactiveThumbColor: Colors.white24,
            inactiveTrackColor: Colors.white10,
          ),
        ],
      ),
    );
  }

  Widget _navTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              _iconBox(icon, color),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title,
                      style: GoogleFonts.dmSans(
                          color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style:
                          GoogleFonts.dmSans(color: Colors.white38, fontSize: 11, height: 1.4)),
                ]),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 13),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String badge,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _iconBox(icon, color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: GoogleFonts.dmSans(
                      color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style:
                      GoogleFonts.dmSans(color: Colors.white38, fontSize: 11, height: 1.4)),
            ]),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(badge,
                style: GoogleFonts.dmSans(
                    color: color, fontSize: 10, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }
}
