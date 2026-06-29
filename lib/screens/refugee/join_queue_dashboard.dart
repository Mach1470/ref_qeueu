import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  // All members: self is always index 0
  List<Map<String, dynamic>> _allMembers = [];
  final Set<String> _selectedIds = {'SELF'}; // Self pre-selected
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final selfName = prefs.getString('user_name') ?? 'You';

      final self = <String, dynamic>{
        'id': 'SELF',
        'name': selfName,
        'relationship': 'Primary Account Holder',
        'isPrimary': true,
      };

      final family = await _authService.getFamilyMembers();
      final mappedFamily = family.map((m) {
        return <String, dynamic>{
          ...m,
          'id': m['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          'isPrimary': false,
        };
      }).toList();

      if (mounted) {
        setState(() {
          _allMembers = [self, ...mappedFamily];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('JoinQueueDashboard._loadData error: $e');
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

  void _continueToSymptoms() {
    if (_selectedIds.isEmpty) return;

    final selected = _allMembers
        .where((m) => _selectedIds.contains(m['id']))
        .toList();

    Navigator.pushNamed(
      context,
      '/symptom_input',
      arguments: {'selectedMembers': selected},
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
              Color(0xFF001530),
              Color(0xFF002147),
              Color(0xFF002147),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFCBE11).withOpacity(0.05),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fadeIn(duration: 3.seconds)
                  .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.2, 1.2)),
            ),
            Column(
              children: [
                // Header
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
                              'Step 1 of 3',
                              style: GoogleFonts.dmSans(
                                color: const Color(0xFF82C4E8),
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
                                  color: Color(0xFFFCBE11), strokeWidth: 3),
                              const SizedBox(height: 24),
                              Text(
                                'Loading accounts...',
                                style: GoogleFonts.dmSans(
                                    color: Colors.white38, letterSpacing: 1),
                              ),
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
                              _buildInfoBanner(),
                              const SizedBox(height: 32),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Who needs medical attention?',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (_selectedIds.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFCBE11)
                                            .withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: const Color(0xFFFCBE11)
                                                .withOpacity(0.3)),
                                      ),
                                      child: Text(
                                        '${_selectedIds.length} SELECTED',
                                        style: GoogleFonts.dmSans(
                                          color: const Color(0xFF82C4E8),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildMembersList(),
                              const SizedBox(height: 24),
                              _buildAddMemberButton(),
                              const SizedBox(height: 140),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomSheet: !_isLoading ? _buildBottomAction() : null,
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFCBE11).withOpacity(0.12),
            const Color(0xFFFCBE11).withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFCBE11).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFCBE11).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.people_alt_rounded,
                color: Color(0xFF82C4E8), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Select everyone who needs to be seen today. You can join for yourself and family members at once.',
              style: GoogleFonts.dmSans(color: Colors.white60, fontSize: 13),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }

  Widget _buildMembersList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _allMembers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final m = _allMembers[index];
        final id = m['id'] as String;
        final isSelected = _selectedIds.contains(id);
        final isPrimary = m['isPrimary'] == true;

        return InkWell(
          onTap: () => _toggleSelection(id),
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFCBE11).withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      )
                    ]
                  : [],
            ),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              opacity: isSelected ? 0.15 : 0.05,
              borderColor: isSelected
                  ? const Color(0xFFFCBE11).withOpacity(0.6)
                  : Colors.white.withOpacity(0.08),
              borderWidth: isSelected ? 2 : 1,
              child: Row(
                children: [
                  Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: isSelected
                            ? [const Color(0xFFFCBE11), const Color(0xFF0072BC)]
                            : [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.02)
                              ],
                      ),
                      border:
                          Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Icon(
                      isSelected
                          ? Icons.check_rounded
                          : (isPrimary
                              ? Icons.stars_rounded
                              : Icons.person_rounded),
                      color: isSelected
                          ? Colors.white
                          : (isPrimary
                              ? const Color(0xFF82C4E8)
                              : Colors.white38),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              m['name'] ?? 'Member',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            if (isPrimary) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFCBE11)
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'YOU',
                                  style: GoogleFonts.dmSans(
                                    color: const Color(0xFF82C4E8),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          m['relationship'] ?? 'Family Member',
                          style: GoogleFonts.dmSans(
                              color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  _buildCheckCircle(isSelected),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(delay: (index * 80).ms).slideX(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildCheckCircle(bool selected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? const Color(0xFFFCBE11) : Colors.white24,
          width: 2,
        ),
        color: selected ? const Color(0xFFFCBE11) : Colors.transparent,
      ),
      child: selected
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
          : null,
    );
  }

  Widget _buildAddMemberButton() {
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, '/refugee/family_registration')
              .then((_) => _loadData()),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline_rounded,
                color: Colors.white38, size: 20),
            const SizedBox(width: 10),
            Text(
              'Add Family Member',
              style: GoogleFonts.dmSans(
                  color: Colors.white38,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    final canContinue = _selectedIds.isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      decoration: BoxDecoration(
        color: const Color(0xFF001530).withOpacity(0.95),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            onPressed: canContinue ? _continueToSymptoms : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFCBE11),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.white.withOpacity(0.06),
              disabledForegroundColor: Colors.white24,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  canContinue
                      ? 'CONTINUE (${_selectedIds.length} ${_selectedIds.length == 1 ? 'person' : 'people'})'
                      : 'SELECT WHO IS VISITING',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                if (canContinue) ...[
                  const SizedBox(width: 10),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ],
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
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
