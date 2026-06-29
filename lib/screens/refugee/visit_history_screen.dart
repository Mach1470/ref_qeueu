import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class VisitHistoryScreen extends StatefulWidget {
  const VisitHistoryScreen({super.key});

  @override
  State<VisitHistoryScreen> createState() => _VisitHistoryScreenState();
}

class _VisitHistoryScreenState extends State<VisitHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  List<_Visit> _visits = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this, initialIndex: 2);
    _loadVisits();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _loadVisits() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('visits')
          .orderBy('date', descending: true)
          .limit(50)
          .get();

      final list = snap.docs.map((doc) {
        final d = doc.data();
        DateTime? date;
        try {
          date = (d['date'] as Timestamp?)?.toDate();
        } catch (_) {}
        return _Visit(
          facility: d['facility']?.toString() ?? 'Health Facility',
          location: d['location']?.toString() ?? 'Camp Clinic',
          date: date ?? DateTime.now(),
          time: d['time']?.toString() ?? '',
          status: d['status']?.toString() ?? 'completed',
        );
      }).toList();

      if (mounted) setState(() => _visits = list);
    } catch (_) {
      // show empty state rather than crash
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<_Visit> _filtered(String tab) {
    return _visits.where((v) {
      switch (tab) {
        case 'upcoming':
          return v.status == 'upcoming' || v.status == 'scheduled';
        case 'active':
          return v.status == 'active' || v.status == 'in_progress';
        default:
          return v.status == 'completed' ||
              v.status == 'cancelled' ||
              v.status == 'past';
      }
    }).toList();
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
        title: Text('Visit History',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: const Color(0xFF001F47))),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Tabs ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F5F8),
                borderRadius: BorderRadius.circular(22),
              ),
              child: TabBar(
                controller: _tabs,
                indicator: BoxDecoration(
                  color: const Color(0xFF001F47),
                  borderRadius: BorderRadius.circular(20),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF5A7A8A),
                labelStyle: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w700, fontSize: 13),
                unselectedLabelStyle:
                    GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 13),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Active'),
                  Tab(text: 'Past'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Tab views ──
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF0072BC)))
                : TabBarView(
                    controller: _tabs,
                    children: [
                      _VisitList(visits: _filtered('upcoming')),
                      _VisitList(visits: _filtered('active')),
                      _VisitList(visits: _filtered('past')),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _VisitList extends StatelessWidget {
  final List<_Visit> visits;
  const _VisitList({required this.visits});

  @override
  Widget build(BuildContext context) {
    if (visits.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.medical_information_outlined,
                size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 14),
            Text('No visits found',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: const Color(0xFF001F47))),
            const SizedBox(height: 6),
            Text('Your healthcare visits will appear here',
                style: GoogleFonts.dmSans(
                    fontSize: 13, color: const Color(0xFF5A7A8A))),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: visits.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _VisitCard(visit: visits[i]),
    );
  }
}

class _VisitCard extends StatelessWidget {
  final _Visit visit;
  const _VisitCard({required this.visit});

  @override
  Widget build(BuildContext context) {
    final dateStr =
        DateFormat('d MMM, yyyy').format(visit.date);

    Color badgeColor;
    String badgeLabel;
    switch (visit.status) {
      case 'completed':
        badgeColor = const Color(0xFF0072BC);
        badgeLabel = 'Visit completed';
        break;
      case 'cancelled':
        badgeColor = Colors.red;
        badgeLabel = 'Cancelled';
        break;
      case 'active':
      case 'in_progress':
        badgeColor = const Color(0xFF10B981);
        badgeLabel = 'In progress';
        break;
      case 'upcoming':
      case 'scheduled':
        badgeColor = const Color(0xFFFCBE11);
        badgeLabel = 'Scheduled';
        break;
      default:
        badgeColor = const Color(0xFF5A7A8A);
        badgeLabel = visit.status;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEF2F6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A001F47),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon circle
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.local_hospital_rounded,
                color: Color(0xFF0072BC), size: 22),
          ),
          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(visit.facility,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: const Color(0xFF001F47))),
                const SizedBox(height: 4),
                Text(
                  '$dateStr  •  ${visit.location}',
                  style: GoogleFonts.dmSans(
                      fontSize: 12, color: const Color(0xFF5A7A8A)),
                ),
                if (visit.time.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(visit.time,
                      style: GoogleFonts.dmSans(
                          fontSize: 12, color: const Color(0xFF5A7A8A))),
                ],
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badgeLabel,
                    style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: badgeColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Visit {
  final String facility;
  final String location;
  final DateTime date;
  final String time;
  final String status;

  const _Visit({
    required this.facility,
    required this.location,
    required this.date,
    required this.time,
    required this.status,
  });
}
