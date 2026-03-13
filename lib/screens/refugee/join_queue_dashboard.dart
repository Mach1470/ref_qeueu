import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ref_qeueu/widgets/glass_widgets.dart';
import 'package:ref_qeueu/widgets/safe_scaffold.dart';
import 'package:ref_qeueu/services/auth_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

class JoinQueueDashboard extends StatefulWidget {
  const JoinQueueDashboard({super.key});

  @override
  State<JoinQueueDashboard> createState() => _JoinQueueDashboardState();
}

class _JoinQueueDashboardState extends State<JoinQueueDashboard> {
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _familyMembers = [];
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
      final members = await _authService.getFamilyMembers();
      _familyMembers = members
          .map((m) => {
                ...m,
                'id':
                    m['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
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

  Future<void> _navigateToSymptomInput(Map<String, dynamic> member) async {
    // Map dynamic to String, String as expected by symptom input
    final Map<String, String> memberStr = {};
    member.forEach((k, v) => memberStr[k] = v.toString());

    Navigator.pushNamed(
      context,
      '/symptom_input',
      arguments: memberStr,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeScaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A), // Slate 900
              Color(0xFF1E1B4B), // Indigo 950
              Color(0xFF1E1B4B), // Indigo 950
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background Orbs
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6366F1).withOpacity(0.05),
                ),
              )
                  .animate(
                      onPlay: (controller) => controller.repeat(reverse: true))
                  .fadeIn(duration: 3.seconds)
                  .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.2, 1.2)),
            ),

            Column(
              children: [
                // HEADER
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                    child: Row(
                      children: [
                        _buildGlassIconButton(
                          Icons.arrow_back_ios_new_rounded,
                          () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Clinic Access',
                              style: GoogleFonts.dmSans(
                                color: const Color(0xFF818CF8),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              'Join Queue',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn().slideY(begin: -0.2, end: 0),

                Expanded(
                  child: _isLoading
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(
                                  color: Color(0xFF6366F1), strokeWidth: 3),
                              const SizedBox(height: 24),
                              Text('Syncing secure records...',
                                  style: GoogleFonts.dmSans(
                                      color: Colors.white38, letterSpacing: 1)),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              _buildInfoSection(),

                              const SizedBox(height: 40),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Who is visiting store?',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (_familyMembers.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF6366F1)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${_selectedIds.length} SELECTED',
                                        style: GoogleFonts.dmSans(
                                          color: const Color(0xFF818CF8),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              if (_familyMembers.isEmpty)
                                _buildEmptyState()
                              else
                                _buildMembersList(),

                              const SizedBox(
                                  height: 140), // Bottom padding for action bar
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomSheet: (!_isLoading && _familyMembers.isNotEmpty)
          ? _buildBottomAction()
          : null,
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6366F1).withOpacity(0.1),
            const Color(0xFF6366F1).withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.flash_on_rounded,
                color: Color(0xFF818CF8), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Priority Entry',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Select multiple members to join the same check-in session.',
                  style: GoogleFonts.dmSans(
                    color: Colors.white60,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }

  Widget _buildEmptyState() {
    return GlassCard(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.group_add_outlined,
                  color: Colors.white.withOpacity(0.2), size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              'Your circle is empty',
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Add members to your Digital ID to join the queue together.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/refugee/family_registration')
                      .then((_) => _loadData()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text('Add First Member',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildMembersList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _familyMembers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final m = _familyMembers[index];
        final isSelected = _selectedIds.contains(m['id']);
        return InkWell(
          onTap: () => _toggleSelection(m['id']!),
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ]
                  : [],
            ),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              opacity: isSelected ? 0.15 : 0.05,
              borderColor: isSelected
                  ? const Color(0xFF6366F1).withOpacity(0.5)
                  : Colors.white.withOpacity(0.08),
              borderWidth: isSelected ? 2 : 1,
              child: Row(
                children: [
                  Container(
                    height: 58,
                    width: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isSelected
                            ? [
                                const Color(0xFF6366F1),
                                const Color(0xFF4F46E5),
                              ]
                            : [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.02),
                              ],
                      ),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Icon(
                      isSelected ? Icons.check_rounded : Icons.person_rounded,
                      color: isSelected ? Colors.white : Colors.white24,
                      size: isSelected ? 28 : 26,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m['name'] ?? 'Family Member',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${m['id']}'.toUpperCase(),
                          style: GoogleFonts.dmSans(
                            color: isSelected
                                ? const Color(0xFF818CF8)
                                : Colors.white38,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildRadioButton(isSelected),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildRadioButton(bool selected) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? const Color(0xFF6366F1) : Colors.white24,
          width: 2,
        ),
        color: selected ? const Color(0xFF6366F1) : Colors.transparent,
      ),
      child: selected
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
          : null,
    )
        .animate(target: selected ? 1 : 0)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 40,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _selectedIds.isEmpty
                    ? null
                    : () {
                        final selectedMember = _familyMembers.firstWhere(
                            (element) => _selectedIds.contains(element['id']));
                        _navigateToSymptomInput(selectedMember);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.white.withOpacity(0.04),
                  disabledForegroundColor: Colors.white12,
                  elevation: 0,
                  shadowColor: const Color(0xFF6366F1).withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _selectedIds.isEmpty
                          ? 'SELECT MEMBERS'
                          : 'CONTINUE (${_selectedIds.length})',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    if (_selectedIds.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      const Icon(Icons.arrow_forward_rounded, size: 22),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate().slideY(begin: 1.0, end: 0, curve: Curves.easeOutBack);
  }

  Widget _buildGlassIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
