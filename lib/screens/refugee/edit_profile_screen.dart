import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/auth_service.dart';
import '../../services/storage_service.dart';

class EditProfileScreen extends StatefulWidget {
  final String? name;
  final String? email;
  final String? phone;
  final VoidCallback? onSaved;

  const EditProfileScreen({
    super.key,
    this.name,
    this.email,
    this.phone,
    this.onSaved,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;

  String? _photoUrl;
  bool _saving = false;

  static const _blue = Color(0xFF0072BC);
  static const _navy = Color(0xFF001F47);

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.name ?? '');
    _emailCtrl = TextEditingController(text: widget.email ?? '');
    _phoneCtrl = TextEditingController(text: widget.phone ?? '');
    final user = FirebaseAuth.instance.currentUser;
    _photoUrl = user?.photoURL;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final img = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (img == null) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final url = await StorageService.instance
          .uploadProfilePhoto(userId: uid, photoFile: File(img.path));
      if (url != null && mounted) {
        setState(() => _photoUrl = url);
        await AuthService().setProfilePicture(uid, url);
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', name);
      final phone = _phoneCtrl.text.trim();
      if (phone.isNotEmpty) await prefs.setString('user_phone', phone);

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateDisplayName(name);
      }

      widget.onSaved?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved')),
        );
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
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
            child:
                const Icon(Icons.chevron_left_rounded, color: _navy, size: 24),
          ),
        ),
        title: Text('Edit Profile',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700, fontSize: 17, color: _navy)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Profile photo ──
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFE8F1F8),
                              border: Border.all(
                                  color: const Color(0xFFD0E4F4), width: 2),
                            ),
                            child: ClipOval(
                              child: _photoUrl != null
                                  ? (_photoUrl!.startsWith('http')
                                      ? Image.network(_photoUrl!,
                                          fit: BoxFit.cover)
                                      : Image.file(File(_photoUrl!),
                                          fit: BoxFit.cover))
                                  : const Icon(Icons.person_rounded,
                                      color: Color(0xFF82C4E8), size: 44),
                            ),
                          ),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: _blue,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt_rounded,
                                  color: Colors.white, size: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Tap to change photo',
                      style: GoogleFonts.dmSans(
                          fontSize: 12, color: const Color(0xFF5A7A8A)),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Profile Info section ──
                  Text(
                    'Profile Info',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _navy,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _Field(
                    controller: _nameCtrl,
                    label: 'Full Name',
                    hint: 'Your name',
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 14),
                  _Field(
                    controller: _phoneCtrl,
                    label: 'Phone Number',
                    hint: '+254 712 345 678',
                    icon: Icons.phone_android_outlined,
                    inputType: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),
                  _Field(
                    controller: _emailCtrl,
                    label: 'Email',
                    hint: 'email@example.com',
                    icon: Icons.email_outlined,
                    inputType: TextInputType.emailAddress,
                    readOnly: FirebaseAuth.instance.currentUser?.email != null,
                  ),
                  if (FirebaseAuth.instance.currentUser?.email != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 2),
                      child: Text(
                        'Email is managed by your sign-in provider',
                        style: GoogleFonts.dmSans(
                            fontSize: 11, color: const Color(0xFF5A7A8A)),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Save button ──
          SafeArea(
            top: false,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _blue,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: const Color(0x440072BC),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text('Save',
                          style: GoogleFonts.poppins(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType inputType;
  final bool readOnly;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.inputType = TextInputType.text,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF5A7A8A),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: inputType,
          readOnly: readOnly,
          style: GoogleFonts.dmSans(
              fontSize: 14,
              color: readOnly
                  ? const Color(0xFF8FA8B8)
                  : const Color(0xFF001F47)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.dmSans(
                fontSize: 14, color: const Color(0xFFADBCC8)),
            prefixIcon:
                Icon(icon, color: const Color(0xFFADBCC8), size: 18),
            filled: true,
            fillColor:
                readOnly ? const Color(0xFFF0F5F8) : const Color(0xFFF5F8FB),
            contentPadding: const EdgeInsets.symmetric(
                vertical: 12, horizontal: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0EAF0), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF0072BC), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
