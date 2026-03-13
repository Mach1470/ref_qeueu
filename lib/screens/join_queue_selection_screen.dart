import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ref_qeueu/services/database_service.dart';
import 'package:ref_qeueu/services/auth_service.dart';

class JoinQueueSelectionScreen extends StatefulWidget {
  const JoinQueueSelectionScreen({super.key});

  @override
  State<JoinQueueSelectionScreen> createState() =>
      _JoinQueueSelectionScreenState();
}

class _JoinQueueSelectionScreenState extends State<JoinQueueSelectionScreen> {
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _familyMembers = [];
  Map<String, dynamic>? _currentUser;
  final Set<String> _selectedIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load current user
      // Mocking current user for UI demo if prefs are empty
      _currentUser = {
        'id': 'SELF',
        'name': 'My Profile', // Replace with real name
        'individualNumber': '123-456',
        'age': '34',
        'gender': 'Male',
        'isSelf': true,
      };

      // Load family
      final members = await _authService.getFamilyMembers();
      _familyMembers = members
          .map((m) => {
                ...m,
                'id': m['individualNumber'] ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
              })
          .toList();
    } catch (e) {
      debugPrint("Error loading data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _joinQueue() async {
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Select at least one person to join.")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final db = DatabaseService.instance;

      for (final id in _selectedIds) {
        final personData = id == 'SELF'
            ? _currentUser
            : _familyMembers.firstWhere((p) => p['id'] == id);

        final profile = {
          'name': personData?['name'] ?? 'Unknown',
          'id': personData?['individualNumber'] ?? id,
          'age': personData?['age'] ?? '',
          'gender': personData?['gender'] ?? '',
          'isFamily': id != 'SELF',
        };

        await db.addToJoinQueue(profile, hospitalId: 'fac_001');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Successfully joined the queue!")));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error joining queue: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text('Join Queue',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: Colors.black),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    "Who is visiting today?",
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),

                  // Myself
                  if (_currentUser != null) _buildIdCard(_currentUser!, true),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Family Members",
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700]),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          // Navigate to Add Family
                          Navigator.pushNamed(context, '/add_family_member')
                              .then((_) => _loadData());
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text("Add Member"),
                      )
                    ],
                  ),

                  if (_familyMembers.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text("No family members added yet.",
                          style: GoogleFonts.dmSans(color: Colors.grey)),
                    ),

                  ..._familyMembers.map((m) => _buildIdCard(m, false)),

                  const SizedBox(height: 32),

                  // Emergency Ambulance Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE11900), Color(0xFFFF4D4D)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE11900).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                            context, '/refugee_ambulance_request');
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.emergency,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Request Ambulance',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Emergency medical transport',
                                  style: GoogleFonts.dmSans(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 80), // Space for FAB/Button
                ],
              ),
        bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0)))),
            child: ElevatedButton(
                onPressed: _joinQueue,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF386BB8),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text("Join Queue (${_selectedIds.length})",
                    style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)))));
  }

  Widget _buildIdCard(Map<String, dynamic> person, bool isSelf) {
    final id = person['id'];
    final isSelected = _selectedIds.contains(id);

    return GestureDetector(
      onTap: () => _toggleSelection(id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color:
                    isSelected ? const Color(0xFF386BB8) : Colors.transparent,
                width: 2),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ]),
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                        color: isSelf
                            ? const Color(0xFF386BB8).withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12)),
                    child: Icon(isSelf ? Icons.person : Icons.people,
                        color: isSelf ? const Color(0xFF386BB8) : Colors.orange,
                        size: 30)),
                const SizedBox(width: 16),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person['name'] ?? 'Unknown',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "ID: ${person['individualNumber'] ?? 'N/A'}",
                      style:
                          GoogleFonts.dmSans(color: Colors.grey, fontSize: 12),
                    ),
                    if (person['age'] != null)
                      Text(
                        "Age: ${person['age']} yrs",
                        style: GoogleFonts.dmSans(
                            color: Colors.grey, fontSize: 12),
                      ),
                  ],
                )),
                Checkbox(
                  value: isSelected,
                  activeColor: const Color(0xFF386BB8),
                  onChanged: (v) => _toggleSelection(id),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                )
              ],
            )),
      ),
    );
  }
}
