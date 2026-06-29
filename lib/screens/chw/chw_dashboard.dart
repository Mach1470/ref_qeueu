import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CHWDashboard extends StatefulWidget {
  const CHWDashboard({super.key});

  @override
  State<CHWDashboard> createState() => _CHWDashboardState();
}

class _CHWDashboardState extends State<CHWDashboard> {
  static const Color _bg = Color(0xFF001530);
  static const Color _emerald = Color(0xFF10B981);
  static const Color _emeraldDark = Color(0xFF065F46);
  static const Color _surface = Color(0xFF1E293B);

  String _chwId = '';
  String _chwName = 'Health Worker';
  String _facilityId = '';
  String _facilityName = 'Health Facility';
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _chwId = prefs.getString('chw_id') ?? '';
          _chwName = prefs.getString('chw_name') ?? 'Health Worker';
          _facilityId = prefs.getString('chw_facility_id') ?? '';
          _facilityName = prefs.getString('chw_facility_name') ?? 'Health Facility';
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      debugPrint('CHW profile load error: $e');
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chw_id');
    await prefs.remove('chw_doc_id');
    await prefs.remove('chw_name');
    await prefs.remove('chw_facility_id');
    await prefs.remove('chw_facility_name');
    await prefs.remove('chw_role');
    await prefs.remove('chw_logged_in');
    await prefs.remove('chw_status');
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/role_selection');
    }
  }

  String _timeAgo(dynamic queuedAt) {
    if (queuedAt == null) return '';
    try {
      final ts = queuedAt is int ? queuedAt : int.tryParse(queuedAt.toString()) ?? 0;
      final queued = DateTime.fromMillisecondsSinceEpoch(ts);
      final diff = DateTime.now().difference(queued);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      return '${diff.inHours}h ago';
    } catch (_) {
      return '';
    }
  }

  Color _priorityColor(String? priority) {
    switch (priority) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.amber;
      case 'low':
        return _emerald;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: _isLoadingProfile
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
            : Column(
                children: [
                  _buildHeader(),
                  _buildStatsRow(),
                  Expanded(child: _buildPatientQueue()),
                  _buildBottomBar(),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: _surface,
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF065F46), Color(0xFF10B981)],
              ),
            ),
            child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _chwName,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _facilityName.isEmpty ? 'No facility assigned' : _facilityName,
                  style: GoogleFonts.dmSans(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _emerald.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _emerald.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(color: _emerald, shape: BoxShape.circle),
                ),
                const SizedBox(width: 5),
                Text(
                  'Active',
                  style: GoogleFonts.dmSans(
                    color: _emerald,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white54, size: 20),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(child: _buildWaitingCountCard()),
          const SizedBox(width: 12),
          Expanded(child: _buildTriagedTodayCard()),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildWaitingCountCard() {
    if (_facilityId.isEmpty) {
      return _statCard('Waiting', '—', Icons.people_alt_rounded, const Color(0xFF0072BC));
    }

    return StreamBuilder<DatabaseEvent>(
      stream: FirebaseDatabase.instance
          .ref('active_queues/$_facilityId/tickets')
          .onValue,
      builder: (context, snap) {
        int count = 0;
        if (snap.hasData && snap.data!.snapshot.value != null) {
          final map = snap.data!.snapshot.value as Map;
          count = map.values
              .where((v) {
                final m = v as Map;
                return (m['status'] ?? 'waiting') == 'waiting';
              })
              .length;
        }
        return _statCard(
          'Waiting',
          '$count',
          Icons.people_alt_rounded,
          const Color(0xFF0072BC),
        );
      },
    );
  }

  Widget _buildTriagedTodayCard() {
    if (_chwId.isEmpty) {
      return _statCard('Triaged Today', '0', Icons.check_circle_rounded, _emerald);
    }

    final todayStart = DateTime.now().copyWith(
      hour: 0, minute: 0, second: 0, millisecond: 0,
    );

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('refugee_queue_system')
          .doc('triage')
          .collection('triage_assessments')
          .where('chwId', isEqualTo: _chwId)
          .where('assessmentTime', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .snapshots(),
      builder: (context, snap) {
        final count = snap.data?.docs.length ?? 0;
        return _statCard('Triaged Today', '$count', Icons.check_circle_rounded, _emerald);
      },
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.dmSans(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientQueue() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Text(
            'PATIENT QUEUE',
            style: GoogleFonts.dmSans(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Expanded(
          child: _facilityId.isEmpty
              ? _emptyState('No facility assigned', 'Contact your administrator to be assigned to a facility.')
              : StreamBuilder<DatabaseEvent>(
                  stream: FirebaseDatabase.instance
                      .ref('active_queues/$_facilityId/tickets')
                      .orderByChild('queuedAt')
                      .onValue,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Color(0xFF10B981)),
                      );
                    }

                    if (snap.hasError) {
                      return _emptyState('Connection error', 'Could not load patient queue.');
                    }

                    if (!snap.hasData || snap.data!.snapshot.value == null) {
                      return _emptyState(
                        'No patients waiting',
                        'The queue is currently empty.',
                      );
                    }

                    final raw = snap.data!.snapshot.value as Map;
                    final tickets = raw.entries.map((e) {
                      return {
                        'id': e.key,
                        ...Map<String, dynamic>.from(e.value as Map),
                      };
                    }).toList();

                    tickets.sort((a, b) {
                      final aT = (a['queuedAt'] ?? 0) as int;
                      final bT = (b['queuedAt'] ?? 0) as int;
                      return aT.compareTo(bT);
                    });

                    if (tickets.isEmpty) {
                      return _emptyState('No patients waiting', 'The queue is currently empty.');
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: tickets.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return _patientCard(tickets[index], index + 1);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _patientCard(Map<String, dynamic> ticket, int queueNum) {
    final name = ticket['name']?.toString() ?? 'Patient $queueNum';
    final priority = ticket['priority']?.toString();
    final triaged = ticket['triaged'] == true;
    final timeAgo = _timeAgo(ticket['queuedAt']);
    final color = priority != null ? _priorityColor(priority) : Colors.white24;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/chw_triage',
        arguments: {
          'patientName': name,
          'ticketId': ticket['id'],
          'facilityId': _facilityId,
        },
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: triaged ? _emerald.withOpacity(0.3) : Colors.white.withOpacity(0.06),
          ),
        ),
        child: Row(
          children: [
            // Queue number badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$queueNum',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (timeAgo.isNotEmpty)
                    Text(
                      'Waiting: $timeAgo',
                      style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 11),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (priority != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withOpacity(0.4)),
                    ),
                    child: Text(
                      priority.toUpperCase(),
                      style: GoogleFonts.dmSans(
                        color: color,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                if (triaged)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Triaged',
                      style: GoogleFonts.dmSans(color: _emerald, fontSize: 10),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.05, end: 0);
  }

  Widget _emptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _emerald.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.people_outline_rounded, color: _emerald.withOpacity(0.5), size: 48),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: _surface,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(
            context,
            '/chw_triage',
            arguments: {'facilityId': _facilityId},
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _emerald,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: const Icon(Icons.medical_services_rounded, size: 20),
          label: Text(
            'Start New Triage',
            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
