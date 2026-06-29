import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ref_qeueu/widgets/glass_widgets.dart';
import 'package:ref_qeueu/widgets/safe_scaffold.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SymptomInputScreen extends StatefulWidget {
  const SymptomInputScreen({super.key});

  @override
  State<SymptomInputScreen> createState() => _SymptomInputScreenState();
}

class _SymptomInputScreenState extends State<SymptomInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _symptomsCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();

  List<Map<String, dynamic>> _selectedMembers = [];
  String _severity = 'Medium';
  final List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();

  static const int _maxImages = 3;

  static const List<Map<String, dynamic>> _severityOptions = [
    {'label': 'Low', 'color': Color(0xFF22C55E), 'icon': Icons.sentiment_satisfied_alt_rounded},
    {'label': 'Medium', 'color': Color(0xFFF59E0B), 'icon': Icons.sentiment_neutral_rounded},
    {'label': 'High', 'color': Color(0xFFEF4444), 'icon': Icons.sentiment_very_dissatisfied_rounded},
    {'label': 'Critical', 'color': Color(0xFF9333EA), 'icon': Icons.emergency_rounded},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _selectedMembers = List<Map<String, dynamic>>.from(args['selectedMembers'] ?? []);
    }
  }

  @override
  void dispose() {
    _symptomsCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_images.length >= _maxImages) {
      _showSnack('Maximum $_maxImages photos allowed');
      return;
    }
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1280,
      );
      if (picked != null && mounted) {
        setState(() => _images.add(picked));
      }
    } catch (e) {
      _showSnack('Could not access camera/gallery');
    }
  }

  void _removeImage(int index) => setState(() => _images.removeAt(index));

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF002147),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add Photo',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _imageSourceTile(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickImage(ImageSource.camera);
                    },
                  )),
                  const SizedBox(width: 16),
                  Expanded(child: _imageSourceTile(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickImage(ImageSource.gallery);
                    },
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageSourceTile({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF82C4E8), size: 32),
            const SizedBox(height: 8),
            Text(label,
                style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  void _onNext() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pushNamed(
      context,
      '/hospital_selection',
      arguments: {
        'selectedMembers': _selectedMembers,
        'symptoms': _symptomsCtrl.text.trim(),
        'symptomDuration': _durationCtrl.text.trim(),
        'severity': _severity,
        'imageFiles': _images.map((f) => f.path).toList(),
      },
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.dmSans()),
        backgroundColor: const Color(0xFF002147),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
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
            colors: [Color(0xFF001530), Color(0xFF002147)],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_selectedMembers.isNotEmpty) _buildMembersChips(),
                      const SizedBox(height: 24),
                      _buildSectionLabel('Describe the symptoms', Icons.medical_services_outlined),
                      const SizedBox(height: 10),
                      _buildTextArea(),
                      const SizedBox(height: 24),
                      _buildSectionLabel('How long have symptoms lasted?', Icons.access_time_rounded),
                      const SizedBox(height: 10),
                      _buildDurationField(),
                      const SizedBox(height: 24),
                      _buildSectionLabel('Severity level', Icons.warning_amber_rounded),
                      const SizedBox(height: 10),
                      _buildSeveritySelector(),
                      const SizedBox(height: 24),
                      _buildSectionLabel(
                        'Photos (optional, up to $_maxImages)',
                        Icons.camera_alt_outlined,
                      ),
                      const SizedBox(height: 10),
                      _buildPhotoRow(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step 2 of 3',
                  style: GoogleFonts.dmSans(
                    color: const Color(0xFF82C4E8),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'Describe Symptoms',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }

  Widget _buildMembersChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recording symptoms for:',
          style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _selectedMembers.map((m) {
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFCBE11).withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFFFCBE11).withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_rounded,
                      color: Color(0xFF82C4E8), size: 14),
                  const SizedBox(width: 6),
                  Text(
                    m['name'] ?? 'Member',
                    style: GoogleFonts.dmSans(
                        color: const Color(0xFF82C4E8),
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildSectionLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF82C4E8), size: 18),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTextArea() {
    return GlassCard(
      padding: EdgeInsets.zero,
      opacity: 0.05,
      borderColor: Colors.white.withOpacity(0.08),
      child: TextFormField(
        controller: _symptomsCtrl,
        maxLines: 4,
        style: GoogleFonts.dmSans(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: 'e.g. Fever, severe headache, coughing for 2 days...',
          hintStyle: GoogleFonts.dmSans(color: Colors.white30, fontSize: 14),
          contentPadding: const EdgeInsets.all(20),
          border: InputBorder.none,
        ),
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Please describe the symptoms' : null,
      ),
    ).animate().fadeIn(delay: 150.ms);
  }

  Widget _buildDurationField() {
    return GlassCard(
      padding: EdgeInsets.zero,
      opacity: 0.05,
      borderColor: Colors.white.withOpacity(0.08),
      child: TextFormField(
        controller: _durationCtrl,
        style: GoogleFonts.dmSans(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: 'e.g. Since this morning, 2 days, 1 week',
          hintStyle: GoogleFonts.dmSans(color: Colors.white30, fontSize: 14),
          contentPadding: const EdgeInsets.all(20),
          border: InputBorder.none,
        ),
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Please enter duration' : null,
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildSeveritySelector() {
    return Row(
      children: _severityOptions.asMap().entries.map((entry) {
        final opt = entry.value;
        final label = opt['label'] as String;
        final color = opt['color'] as Color;
        final icon = opt['icon'] as IconData;
        final isSelected = _severity == label;

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _severity = label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: entry.key < 3 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.2) : Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? color : Colors.white.withOpacity(0.08),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(icon,
                    color: isSelected ? color : Colors.white30,
                    size: 22),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: GoogleFonts.dmSans(
                      color: isSelected ? color : Colors.white30,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    ).animate().fadeIn(delay: 250.ms);
  }

  Widget _buildPhotoRow() {
    return Row(
      children: [
        // Existing image thumbnails
        ..._images.asMap().entries.map((e) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(
                    File(e.value.path),
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _removeImage(e.key),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded,
                          color: Colors.white, size: 12),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),

        // Add button (if under max)
        if (_images.length < _maxImages)
          GestureDetector(
            onTap: _showImageSourceSheet,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFFCBE11).withOpacity(0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_photo_alternate_rounded,
                      color: Color(0xFF82C4E8), size: 26),
                  const SizedBox(height: 4),
                  Text(
                    'Add',
                    style: GoogleFonts.dmSans(
                        color: const Color(0xFF82C4E8), fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      decoration: BoxDecoration(
        color: const Color(0xFF001530).withOpacity(0.95),
        border:
            Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            onPressed: _onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFCBE11),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'CONTINUE TO HOSPITAL SELECTION',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ),
      ),
    ).animate().slideY(begin: 1.0, end: 0, curve: Curves.easeOutBack);
  }
}
