import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ref_qeueu/services/auth_service.dart';
import 'package:ref_qeueu/widgets/safe_scaffold.dart';
import 'package:ref_qeueu/widgets/glass_widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AccountSelectorScreen extends StatefulWidget {
  const AccountSelectorScreen({super.key});

  @override
  State<AccountSelectorScreen> createState() => _AccountSelectorScreenState();
}

class _AccountSelectorScreenState extends State<AccountSelectorScreen> {
  final AuthService _auth = AuthService();
  List<Map<String, String>> _accounts = [];

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final accounts = await _auth.getRememberedAccounts();
    setState(() => _accounts = accounts);
  }

  void _selectAccount(Map<String, String> account) async {
    // Log in with the selected account
    // For now, we simulate switching by saving the refugee login
    if (account['role'] == 'refugee') {
      await _auth.saveRefugeeLogin(
        account['phone']!,
        displayName: account['name'],
        demoId: account['id'],
      );
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/refugee_home');
      }
    } else {
      // Handle other roles if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeScaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 80),
            Text(
              'Switch Account',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a profile to continue',
              style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 16),
            ),
            const SizedBox(height: 48),
            Expanded(
              child: _accounts.isEmpty
                  ? Center(child: Text('No saved accounts', style: GoogleFonts.dmSans(color: Colors.white24)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _accounts.length,
                      itemBuilder: (context, index) {
                        final account = _accounts[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GlassCard(
                            padding: EdgeInsets.zero,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF6366F1).withOpacity(0.2),
                                child: Text(account['name']![0].toUpperCase(), style: const TextStyle(color: Color(0xFF818CF8))),
                              ),
                              title: Text(account['name']!, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                              subtitle: Text(account['phone'] ?? account['id']!, style: GoogleFonts.dmSans(color: Colors.white38)),
                              trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
                              onTap: () => _selectAccount(account),
                            ),
                          ),
                        ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1, end: 0);
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Use Another Account'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel', style: GoogleFonts.dmSans(color: Colors.white38)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
