import 'package:flutter/material.dart';
import 'package:ref_qeueu/widgets/safe_scaffold.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ref_qeueu/services/auth_service.dart';
import 'package:ref_qeueu/services/database_service.dart';

class RefugeeHomeScreenNew extends StatefulWidget {
  const RefugeeHomeScreenNew({super.key});

  @override
  State<RefugeeHomeScreenNew> createState() => _RefugeeHomeScreenNewState();
}

class _RefugeeHomeScreenNewState extends State<RefugeeHomeScreenNew> {
  int _selectedIndex = 0;
  bool _subScreenActive = false;
  String? _activeSubScreen;
  String? _userName;
  int? _queuePosition;

  @override
  void initState() {
    super.initState();
    _loadLocalProfile();
  }

  Future<void> _loadLocalProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('user_name');
      final qp = prefs.getInt('queue_position');
      if (mounted) setState(() {
        _userName = name;
        _queuePosition = qp;
      });
    } catch (_) {}
  }

  Future<void> _showCreateIdDialog() async {
    final nameCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    final genderCtrl = TextEditingController();
    final dobCtrl = TextEditingController();
    final auth = AuthService();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create ID for family member'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full name')),
            TextField(controller: ageCtrl, decoration: const InputDecoration(labelText: 'Age'), keyboardType: TextInputType.number),
            TextField(controller: genderCtrl, decoration: const InputDecoration(labelText: 'Gender')),
            TextField(controller: dobCtrl, decoration: const InputDecoration(labelText: 'DOB (YYYY-MM)')),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final member = {
                'name': nameCtrl.text.trim(),
                'age': ageCtrl.text.trim(),
                'gender': genderCtrl.text.trim(),
                'dob': dobCtrl.text.trim(),
              };
              await auth.addFamilyMember(member);
              if (mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Family member added')));
                _loadFamilyMembers();
              }
            },
            child: const Text('Register'),
          )
        ],
      ),
    );
  }

  List<Map<String, String>> _familyMembers = [];

  Future<void> _loadFamilyMembers() async {
    try {
      final auth = AuthService();
      final list = await auth.getFamilyMembers();
      if (mounted) setState(() => _familyMembers = list);
    } catch (_) {}
  }

  Future<void> _joinQueueFor(Map<String, String> member) async {
    // Request location and push to joinQueue
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enable location services')));
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permission denied')));
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permission permanently denied')));
      return;
    }

    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    final profile = {
      'name': member['name'] ?? _userName ?? 'Unknown',
      'age': member['age'] ?? '',
      'gender': member['gender'] ?? '',
      'dob': member['dob'] ?? '',
      'owner': _userName ?? 'owner',
    };
    try {
      final key = await DatabaseService.instance.addToJoinQueue(profile, lat: pos.latitude, lng: pos.longitude);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added to join queue (id: ${key ?? 'unknown'})')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not add to queue: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Colors.teal;
    const Color scaffoldBg = Color(0xFFF5F9FA);

    return SafeScaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left (logo + title)
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color:
                                    Colors.white.withAlpha((0.2 * 255).round()),
                                shape: BoxShape.circle),
                            child: const Icon(Icons.layers_outlined,
                                color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Text('MyQueue',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5)),
                        ],
                      ),

                        // Right side intentionally left empty: profile/settings
                        // removed here. Refugee profile should be set in the
                        // profile flow; if not provided, show empty avatar elsewhere.
                    ],
                  ),
                ),

                // BODY
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                        color: scaffoldBg,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30))),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24)),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Text('Hi, ${_userName ?? 'there'}',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 10),
                                    Text('Queue position: ${_queuePosition ?? 5}',
                                      style: TextStyle(
                                        color: Colors.grey.shade700))
                                ]),
                          ),
                          const SizedBox(height: 20),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.05,
                            children: [
                              _DashboardCard(
                                  title: 'Join Queue',
                                  subtitle: 'Find nearest hospital',
                                  icon: Icons.queue,
                                  color: const Color(0xFFFFE0B2),
                                  iconColor: const Color(0xFFE65100),
                                  onTap: () async {
                                    // If no family members exist, add primary user as a virtual member
                                    await _loadFamilyMembers();
                                    if (_familyMembers.isEmpty) {
                                      // create a primary member from stored profile
                                      final prefs = await SharedPreferences.getInstance();
                                      final name = prefs.getString('user_name') ?? _userName ?? 'You';
                                      final primary = {'name': name, 'age': '', 'gender': '', 'dob': ''};
                                      await _joinQueueFor(primary);
                                    } else if (_familyMembers.length == 1) {
                                      // show the single card with join
                                      await _joinQueueFor(_familyMembers.first);
                                    } else {
                                      // multiple members: show selection dialog
                                      showDialog(
                                          context: context,
                                          builder: (ctx) {
                                            return AlertDialog(
                                              title: const Text('Select family member to join'),
                                              content: SizedBox(
                                                width: double.maxFinite,
                                                child: ListView.separated(
                                                  shrinkWrap: true,
                                                  itemBuilder: (_, idx) {
                                                    final m = _familyMembers[idx];
                                                    return ListTile(
                                                      title: Text(m['name'] ?? 'Unnamed'),
                                                      subtitle: Text('Age: ${m['age'] ?? '-'}'),
                                                      trailing: ElevatedButton(
                                                        onPressed: () async {
                                                          Navigator.of(ctx).pop();
                                                          await _joinQueueFor(m);
                                                        },
                                                        child: const Text('Join'),
                                                      ),
                                                    );
                                                  },
                                                  separatorBuilder: (_, __) => const Divider(),
                                                  itemCount: _familyMembers.length,
                                                ),
                                              ),
                                              actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close'))],
                                            );
                                          });
                                    }
                                  }),
                              _DashboardCard(
                                  title: 'My ID Card',
                                  subtitle: 'Show to doctor',
                                  icon: Icons.badge_outlined,
                                  color: const Color(0xFFE1BEE7),
                                  iconColor: const Color(0xFF4A148C),
                                  onTap: () => _openSubScreen('id_card')),
                              _DashboardCard(
                                  title: 'Medical History',
                                  subtitle: 'Past records & visits',
                                  icon: Icons.history_edu,
                                  color: const Color(0xFFB2DFDB),
                                  iconColor: const Color(0xFF00695C),
                                  onTap: () => _openSubScreen('history')),
                              _DashboardCard(
                                  title: 'Help Center',
                                  subtitle: 'Get support',
                                  icon: Icons.support_agent,
                                  color: const Color(0xFFBBDEFB),
                                  iconColor: const Color(0xFF0D47A1),
                                  onTap: () {}),
                            ],
                          ),
                          const SizedBox(height: 80),
                          // Small row of quick actions: Create ID
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _showCreateIdDialog,
                                  child: const Text('Create ID'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _loadFamilyMembers,
                                  child: const Text('Refresh Members'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
                                  color: Colors.teal),
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
          ],
        ),
      ),
      // Use a simple bottom area instead of BottomNavigationBar to avoid
      // the Flutter assertion that requires at least 2 items.
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.teal.withAlpha((0.1 * 255).round()),
              blurRadius: 20,
              offset: const Offset(0, -5))
        ]),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Center(
              child: Text('Home',
                  style: TextStyle(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ),
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
                              color: Colors.teal),
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
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;
  const _DashboardCard(
      {required this.title,
      required this.subtitle,
      required this.icon,
      required this.color,
      required this.iconColor,
      required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(16)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: iconColor),
            const Spacer(),
            Text(title,
                style:
                    TextStyle(color: iconColor, fontWeight: FontWeight.bold)),
            Text(subtitle,
                style: TextStyle(
                    color: iconColor.withAlpha((0.7 * 255).round()),
                    fontSize: 12))
          ])));
}
