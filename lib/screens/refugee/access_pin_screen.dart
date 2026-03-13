import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ref_qeueu/widgets/safe_scaffold.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ref_qeueu/services/security_service.dart';

class AccessPinScreen extends StatefulWidget {
  const AccessPinScreen({super.key});

  @override
  State<AccessPinScreen> createState() => _AccessPinScreenState();
}

class _AccessPinScreenState extends State<AccessPinScreen> {
  final List<String> _pin = [];
  bool _isConfirming = false;
  String _firstPin = '';

  void _onNumberPress(String number) {
    if (_pin.length < 4) {
      setState(() {
        _pin.add(number);
      });
      if (_pin.length == 4) {
        _handlePinComplete();
      }
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin.removeLast();
      });
    }
  }

  void _handlePinComplete() async {
    final pinStr = _pin.join();
    if (!_isConfirming) {
      // First entry
      await Future.delayed(500.ms);
      setState(() {
        _firstPin = pinStr;
        _isConfirming = true;
        _pin.clear();
      });
    } else {
      // Confirm entry
      if (pinStr == _firstPin) {
        // Success
        await SecurityService.instance.savePin(pinStr);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PIN updated successfully'), backgroundColor: Colors.greenAccent),
        );
        Navigator.pop(context);
      } else {
        // Error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PINs do not match. Try again.'), backgroundColor: Colors.redAccent),
        );
        setState(() {
          _pin.clear();
          _isConfirming = false;
          _firstPin = '';
        });
      }
    }
  }

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
            const SizedBox(height: 60),
            Text(
              _isConfirming ? 'Confirm New PIN' : 'Set Access PIN',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ).animate().fadeIn().scale(),
            const SizedBox(height: 12),
            Text(
              'Secure your digital assets with a 4-digit passkey.',
              style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 13),
            ),
            const SizedBox(height: 48),
            _buildPinDots(),
            const Spacer(),
            _buildKeypad(),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        bool isActive = index < _pin.length;
        return Container(
          width: 20,
          height: 20,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFF6366F1) : Colors.white10,
            border: Border.all(color: isActive ? const Color(0xFF818CF8) : Colors.white24, width: 2),
            boxShadow: isActive ? [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.5), blurRadius: 10)] : [],
          ),
        );
      }),
    );
  }

  Widget _buildKeypad() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          ...List.generate(9, (index) => _buildKeyButton((index + 1).toString())),
          _buildEmptyButton(),
          _buildKeyButton('0'),
          _buildDeleteButton(),
        ],
      ),
    );
  }

  Widget _buildKeyButton(String label) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onNumberPress(label),
        borderRadius: BorderRadius.circular(40),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.05),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return IconButton(
      onPressed: _onDelete,
      icon: const Icon(Icons.backspace_rounded, color: Colors.white60, size: 24),
    );
  }

  Widget _buildEmptyButton() => const SizedBox.shrink();
}
