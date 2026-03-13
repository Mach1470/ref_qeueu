import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ref_qeueu/widgets/glass_widgets.dart';
import 'package:ref_qeueu/widgets/safe_scaffold.dart';

class PushAlertsScreen extends StatefulWidget {
  const PushAlertsScreen({super.key});

  @override
  State<PushAlertsScreen> createState() => _PushAlertsScreenState();
}

class _PushAlertsScreenState extends State<PushAlertsScreen> {
  bool _systemNotifs = true;
  bool _emergencySms = true;
  bool _proximityAlert = false;
  bool _queueUpdates = true;

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
            colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF312E81)],
          ),
        ),
        child: Column(
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
                    _buildSectionHeader('System Notifications'),
                    const SizedBox(height: 16),
                    _buildAlertTile(
                      Icons.notifications_active_rounded,
                      'Push Notifications',
                      'Receive instant alerts on your device.',
                      _systemNotifs,
                      (val) => setState(() => _systemNotifs = val),
                    ),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Priority Alerts'),
                    const SizedBox(height: 16),
                    _buildAlertTile(
                      Icons.sms_rounded,
                      'Emergency SMS',
                      'Fallback alerts when internet is offline.',
                      _emergencySms,
                      (val) => setState(() => _emergencySms = val),
                    ),
                    _buildAlertTile(
                      Icons.near_me_rounded,
                      'Proximity Alert',
                      'Alert when within calling range.',
                      _proximityAlert,
                      (val) => setState(() => _proximityAlert = val),
                    ),
                    if (_proximityAlert)
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 4, bottom: 12),
                        child: Text(
                          '• Using background geofencing to track camp distance\n• High-priority notification when position < 3',
                          style: GoogleFonts.dmSans(color: Colors.greenAccent.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ).animate().fadeIn().slideX(),
                    _buildAlertTile(
                      Icons.update_rounded,
                      'Queue Status',
                      'Real-time updates on your queue movement.',
                      _queueUpdates,
                      (val) => setState(() => _queueUpdates = val),
                    ),
                    const SizedBox(height: 40),
                    GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Icon(Icons.bolt_rounded, color: Colors.amberAccent, size: 32),
                          const SizedBox(height: 16),
                          Text(
                            'Battery Optimization',
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enable high-priority alerts to ensure you never miss your turn, even in low-power mode.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(color: Colors.white60, fontSize: 12, height: 1.5),
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
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), shape: BoxShape.circle),
            child: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18)),
          ),
          const SizedBox(width: 16),
          Text('Alert Settings', style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.dmSans(color: const Color(0xFF818CF8), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5),
    );
  }

  Widget _buildAlertTile(IconData icon, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white70, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                  Text(subtitle, style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 11)),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: const Color(0xFF6366F1),
              activeTrackColor: const Color(0xFF6366F1).withOpacity(0.3),
              inactiveThumbColor: Colors.white24,
              inactiveTrackColor: Colors.white10,
            ),
          ],
        ),
      ),
    );
  }
}
