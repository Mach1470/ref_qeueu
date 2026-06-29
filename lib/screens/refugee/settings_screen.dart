import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/auth_service.dart';
import '../../services/security_service.dart';
import 'access_pin_screen.dart';
import 'push_alerts_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
      });
    }
  }

  Future<void> _toggleBiometric(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    if (val) {
      final ok = await SecurityService.instance.authenticate();
      if (!ok) return;
    }
    await prefs.setBool('biometric_enabled', val);
    if (mounted) setState(() => _biometricEnabled = val);
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sign out',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700, color: const Color(0xFF001F47))),
        content: Text('Are you sure you want to sign out?',
            style: GoogleFonts.dmSans(color: const Color(0xFF5A7A8A))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.dmSans()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Sign out',
                style: GoogleFonts.dmSans(
                    color: Colors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await AuthService().logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
          context, '/role_selection', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text('Settings',
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
            const SizedBox(height: 8),

            // ── Account ──
            _SectionHeader('Account'),
            _SettingsTile(
              icon: Icons.language_rounded,
              label: 'Change Language',
              onTap: () => _showComingSoon('Language settings'),
            ),
            _Divider(),
            _SettingsTile(
              icon: Icons.lock_outline_rounded,
              label: 'Change Password',
              onTap: () => _showComingSoon('Change password'),
            ),
            _Divider(),
            _SettingsTile(
              icon: Icons.email_outlined,
              label: 'Change Email',
              onTap: () => _showComingSoon('Change email'),
            ),

            const SizedBox(height: 24),

            // ── Security ──
            _SectionHeader('Security & Privacy'),
            _SwitchTile(
              icon: Icons.fingerprint_rounded,
              label: 'Biometric Lock',
              subtitle: 'Use fingerprint or face to lock the app',
              value: _biometricEnabled,
              onChanged: _toggleBiometric,
            ),
            _Divider(),
            _SettingsTile(
              icon: Icons.pin_outlined,
              label: 'Access PIN',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AccessPinScreen())),
            ),

            const SizedBox(height: 24),

            // ── Notifications ──
            _SectionHeader('Notifications'),
            _SettingsTile(
              icon: Icons.notifications_none_rounded,
              label: 'Alert Preferences',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const PushAlertsScreen())),
            ),

            const SizedBox(height: 24),

            // ── Legal ──
            _SectionHeader('Legal'),
            _SettingsTile(
              icon: Icons.privacy_tip_outlined,
              label: 'Privacy Policy',
              onTap: () => _showComingSoon('Privacy Policy'),
            ),
            _Divider(),
            _SettingsTile(
              icon: Icons.description_outlined,
              label: 'Terms and Conditions',
              onTap: () => _showComingSoon('Terms and Conditions'),
            ),

            const SizedBox(height: 24),

            // ── Account Actions ──
            _SectionHeader('Account Actions'),
            _SettingsTile(
              icon: Icons.logout_rounded,
              label: 'Sign out',
              isDestructive: true,
              showChevron: false,
              onTap: _logout,
            ),
            _Divider(),
            _SettingsTile(
              icon: Icons.delete_outline_rounded,
              label: 'Delete Account',
              isDestructive: true,
              showChevron: false,
              onTap: _showDeleteConfirmation,
            ),

            const SizedBox(height: 32),

            Center(
              child: Text(
                'MyQueue v1.0.0',
                style: GoogleFonts.dmSans(
                    fontSize: 12, color: const Color(0xFFADBCC8)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label — coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showDeleteConfirmation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Account',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700, color: Colors.red)),
        content: Text(
          'This will permanently delete your account and all data. This cannot be undone.',
          style: GoogleFonts.dmSans(color: const Color(0xFF5A7A8A)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.dmSans()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete',
                style: GoogleFonts.dmSans(
                    color: Colors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    _showComingSoon('Account deletion');
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

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDestructive;
  final bool showChevron;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final textColor =
        isDestructive ? Colors.red : const Color(0xFF1E293B);
    final iconColor =
        isDestructive ? Colors.red : const Color(0xFF0072BC);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label,
                  style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: textColor)),
            ),
            if (showChevron)
              const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFFADBCC8), size: 20),
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0072BC), size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1E293B))),
                Text(subtitle,
                    style: GoogleFonts.dmSans(
                        fontSize: 12, color: const Color(0xFF5A7A8A))),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF0072BC),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Divider(
      height: 1, indent: 20, endIndent: 20, color: Color(0xFFEEF2F6));
}
