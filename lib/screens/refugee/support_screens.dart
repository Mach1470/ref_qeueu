import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:ref_qeueu/widgets/glass_widgets.dart';
import 'package:ref_qeueu/widgets/safe_scaffold.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  COMMUNITY HELP — Self-service FAQ and how-to guides
//
//  This screen answers the common "how do I…?" questions so users can resolve
//  issues on their own without needing to contact support staff.
// ══════════════════════════════════════════════════════════════════════════════

class CommunityHelpScreen extends StatelessWidget {
  const CommunityHelpScreen({super.key});

  static const _faqs = [
    _FAQ(
      question: 'How do I join a medical queue?',
      answer:
          'From the home screen, tap "Join Queue". Select who needs care — yourself or a family member. '
          'Describe your symptoms, choose the severity level, and optionally add a photo. '
          'Then select the nearest health facility and submit. You will receive a queue number confirming your position.',
    ),
    _FAQ(
      question: 'What happens after I join the queue?',
      answer:
          'A Community Health Worker (CHW) may review your triage information remotely and prioritise urgent cases. '
          'When it is your turn, clinic staff will call your name or queue number. '
          'Keep your phone with you and stay near the facility. '
          'You can check your queue position at any time from the home screen.',
    ),
    _FAQ(
      question: 'Can I join the queue for a family member?',
      answer:
          'Yes. First register your household members under Profile → Household → Add Member. '
          'When joining the queue, you can select any registered family member. '
          'Each person receives their own queue number.',
    ),
    _FAQ(
      question: 'How do I request an ambulance?',
      answer:
          'Tap "Ambulance" on the home screen. This sends your GPS location and emergency details to the nearest available ambulance driver. '
          'Only use this service for genuine medical emergencies — cardiac events, serious injuries, difficulty breathing, or childbirth complications. '
          'For non-emergency transport, visit the health facility directly.',
    ),
    _FAQ(
      question: 'What is my Digital Identity / UNHCR Certificate?',
      answer:
          'Your Digital Identity is a secure, verifiable record linked to your UNHCR case file. '
          'It can be shown to healthcare workers as proof of registration when you do not have your physical documents. '
          'Access it from Profile → Digital Identity. Take a screenshot for offline use.',
    ),
    _FAQ(
      question: 'Does MyQueue work without internet?',
      answer:
          'Yes. MyQueue is designed for low-connectivity environments. '
          'If you have no signal, your queue requests and updates are saved on your device and sent automatically when you reconnect. '
          'A small sync icon will appear to confirm once data has been sent.',
    ),
    _FAQ(
      question: 'My queue position is not updating — what do I do?',
      answer:
          'First check your internet connection. Pull down on the home screen to refresh. '
          'If you have signal but the queue is still frozen, the facility system may be updating — try again in a few minutes. '
          'If the problem persists for more than 30 minutes, use Direct Support to report it.',
    ),
    _FAQ(
      question: 'How is my health data protected?',
      answer:
          'All data is stored with AES-256 encryption on your device. '
          'Only authorised healthcare providers at your assigned facility can access your medical information. '
          'UNHCR does not share or sell your personal data. '
          'See the Privacy Policy in About MyQueue for full details.',
    ),
    _FAQ(
      question: 'How do I add or change my profile photo?',
      answer:
          'Open Profile and tap the camera icon on your photo. '
          'You can choose a photo from your gallery. '
          'Your photo is only visible to healthcare staff when you check in.',
    ),
    _FAQ(
      question: 'What if I forget my PIN?',
      answer:
          'Go to Settings → Access PIN and choose "Reset PIN". '
          'You will need to verify your phone number via a one-time code. '
          'If you cannot receive SMS, visit the camp UNHCR field office with your registration documents.',
    ),
  ];

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
            colors: [Color(0xFF001530), Color(0xFF002147), Color(0xFF003D7A)],
          ),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 8),
              child: Row(
                children: [
                  _BackBtn(onTap: () => Navigator.pop(context)),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('HELP CENTER',
                          style: GoogleFonts.dmSans(
                              color: const Color(0xFF60A5FA),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.8)),
                      Text('Community Help',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Text(
                'Find answers to the most common questions about using MyQueue.',
                style: GoogleFonts.dmSans(color: Colors.white54, fontSize: 13, height: 1.5),
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                physics: const BouncingScrollPhysics(),
                itemCount: _faqs.length,
                itemBuilder: (ctx, i) => _FAQTile(faq: _faqs[i], index: i),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FAQ {
  final String question;
  final String answer;
  const _FAQ({required this.question, required this.answer});
}

class _FAQTile extends StatefulWidget {
  final _FAQ faq;
  final int index;
  const _FAQTile({required this.faq, required this.index});

  @override
  State<_FAQTile> createState() => _FAQTileState();
}

class _FAQTileState extends State<_FAQTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _open = !_open),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF60A5FA).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Text('${widget.index + 1}',
                              style: GoogleFonts.dmSans(
                                  color: const Color(0xFF60A5FA),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(widget.faq.question,
                              style: GoogleFonts.dmSans(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3)),
                        ),
                        const SizedBox(width: 8),
                        AnimatedRotation(
                          turns: _open ? 0.5 : 0,
                          duration: const Duration(milliseconds: 250),
                          child: const Icon(Icons.keyboard_arrow_down_rounded,
                              color: Colors.white38, size: 20),
                        ),
                      ],
                    ),
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Padding(
                        padding: const EdgeInsets.only(top: 14, left: 38),
                        child: Text(widget.faq.answer,
                            style: GoogleFonts.dmSans(
                                color: Colors.white60, fontSize: 13, height: 1.6)),
                      ),
                      crossFadeState:
                          _open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 250),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ).animate().fadeIn(delay: Duration(milliseconds: 60 * widget.index)),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  DIRECT SUPPORT — Contact UNHCR and humanitarian staff
//
//  This screen provides real contact channels for situations where the user
//  has a problem that cannot be solved via the FAQ — registration errors,
//  protection concerns, urgent medical needs, or app-level issues.
// ══════════════════════════════════════════════════════════════════════════════

class DirectSupportScreen extends StatelessWidget {
  const DirectSupportScreen({super.key});

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
            colors: [Color(0xFF001530), Color(0xFF002147), Color(0xFF003D7A)],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 8),
              child: Row(
                children: [
                  _BackBtn(onTap: () => Navigator.pop(context)),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CONTACT US',
                          style: GoogleFonts.dmSans(
                              color: const Color(0xFF34D399),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.8)),
                      Text('Direct Support',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Text(
                'Real people are here to help. Choose the right channel for your situation.',
                style: GoogleFonts.dmSans(color: Colors.white54, fontSize: 13, height: 1.5),
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 60),
                physics: const BouncingScrollPhysics(),
                children: [
                  // EMERGENCY
                  _sectionLabel('EMERGENCY & PROTECTION'),
                  const SizedBox(height: 10),
                  _ContactCard(
                    icon: Icons.emergency_share_rounded,
                    iconColor: const Color(0xFFEF4444),
                    title: 'UNHCR Emergency Hotline',
                    subtitle: 'Protection concerns, feeling unsafe, or urgent humanitarian needs',
                    detail: '0800 720 310',
                    detailLabel: 'Free call · Available 24 / 7',
                    actionLabel: 'Copy Number',
                    onAction: (ctx) => _copy(ctx, '0800720310'),
                    urgent: true,
                  ),
                  const SizedBox(height: 10),
                  _ContactCard(
                    icon: Icons.woman_rounded,
                    iconColor: const Color(0xFFF472B6),
                    title: 'Gender-Based Violence (GBV) Line',
                    subtitle: 'Confidential support for survivors of sexual violence, exploitation, or abuse',
                    detail: '0800 720 630',
                    detailLabel: 'Free call · Confidential · 24 / 7',
                    actionLabel: 'Copy Number',
                    onAction: (ctx) => _copy(ctx, '0800720630'),
                    urgent: true,
                  ),
                  const SizedBox(height: 24),

                  // GENERAL SUPPORT
                  _sectionLabel('GENERAL SUPPORT'),
                  const SizedBox(height: 10),
                  _ContactCard(
                    icon: Icons.phone_in_talk_rounded,
                    iconColor: const Color(0xFF34D399),
                    title: 'UNHCR Kenya Office',
                    subtitle: 'Registration issues, lost documents, case enquiries, and general assistance',
                    detail: '+254 20 4288000',
                    detailLabel: 'Monday – Friday · 8 am – 5 pm',
                    actionLabel: 'Copy Number',
                    onAction: (ctx) => _copy(ctx, '+254204288000'),
                  ),
                  const SizedBox(height: 10),
                  _ContactCard(
                    icon: Icons.chat_rounded,
                    iconColor: const Color(0xFF34D399),
                    title: 'WhatsApp Support',
                    subtitle: 'Send a message for app issues, queue problems, or account questions',
                    detail: '+254 703 047 000',
                    detailLabel: 'Monday – Friday · 8 am – 6 pm',
                    actionLabel: 'Copy Number',
                    onAction: (ctx) => _copy(ctx, '+254703047000'),
                  ),
                  const SizedBox(height: 24),

                  // APP ISSUES
                  _sectionLabel('APP & ACCOUNT ISSUES'),
                  const SizedBox(height: 10),
                  _ContactCard(
                    icon: Icons.bug_report_outlined,
                    iconColor: const Color(0xFF82C4E8),
                    title: 'Report a Technical Issue',
                    subtitle: 'App crash, wrong queue number, data not loading, or login problem',
                    detail: 'myqueue-support@unhcr.org',
                    detailLabel: 'Response within 1 business day',
                    actionLabel: 'Copy Email',
                    onAction: (ctx) => _copy(ctx, 'myqueue-support@unhcr.org'),
                  ),
                  const SizedBox(height: 24),

                  // IN PERSON
                  _sectionLabel('IN-PERSON ASSISTANCE'),
                  const SizedBox(height: 10),
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFBBF24).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.place_outlined,
                                  color: Color(0xFFFBBF24), size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text('Visit the Camp Reception Centre',
                                  style: GoogleFonts.dmSans(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Staff at the reception centre can help with account issues, family registration corrections, medical card reprints, and urgent healthcare referrals. Bring any documents you have.',
                          style: GoogleFonts.dmSans(
                              color: Colors.white60, fontSize: 13, height: 1.6),
                        ),
                        const SizedBox(height: 12),
                        _detail('Hours', 'Monday – Saturday · 7 am – 6 pm'),
                        const SizedBox(height: 6),
                        _detail('Closed', 'Sundays and public holidays'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4, left: 2),
        child: Text(text,
            style: GoogleFonts.dmSans(
                color: const Color(0xFF82C4E8),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.8)),
      );

  Widget _detail(String label, String value) => Row(
        children: [
          Text('$label: ',
              style: GoogleFonts.dmSans(
                  color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w600)),
          Text(value,
              style: GoogleFonts.dmSans(color: Colors.white60, fontSize: 12)),
        ],
      );

  static void _copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Copied to clipboard'),
          duration: Duration(seconds: 2)));
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String detail;
  final String detailLabel;
  final String actionLabel;
  final void Function(BuildContext ctx) onAction;
  final bool urgent;

  const _ContactCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.detailLabel,
    required this.actionLabel,
    required this.onAction,
    this.urgent = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: urgent
                      ? Border.all(color: iconColor.withOpacity(0.3))
                      : null,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(title,
                              style: GoogleFonts.dmSans(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700)),
                        ),
                        if (urgent)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('URGENT',
                                style: GoogleFonts.dmSans(
                                    color: const Color(0xFFEF4444),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: GoogleFonts.dmSans(
                            color: Colors.white54, fontSize: 12, height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(detail,
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3)),
                      Text(detailLabel,
                          style: GoogleFonts.dmSans(
                              color: Colors.white38, fontSize: 11)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => onAction(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: iconColor.withOpacity(0.3)),
                    ),
                    child: Text(actionLabel,
                        style: GoogleFonts.dmSans(
                            color: iconColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
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

// ══════════════════════════════════════════════════════════════════════════════
//  ABOUT MYQUEUE — Version, mission, partnership, and legal
//
//  Standard "About" screen — what the app is, who built it, legal links.
//  No marketing copy. Just factual, honest information.
// ══════════════════════════════════════════════════════════════════════════════

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

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
            colors: [Color(0xFF001530), Color(0xFF002147), Color(0xFF003D7A)],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
              child: Row(
                children: [
                  _BackBtn(onTap: () => Navigator.pop(context)),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('INFORMATION',
                          style: GoogleFonts.dmSans(
                              color: const Color(0xFFA78BFA),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.8)),
                      Text('About MyQueue',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 32),

                    // Logo
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [
                          Colors.white.withOpacity(0.12),
                          Colors.white.withOpacity(0.04),
                        ]),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.15), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFCBE11).withOpacity(0.3),
                            blurRadius: 40,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Image.asset(
                            'assets/illustrations/app_logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ).animate().fadeIn().scale(
                          begin: const Offset(0.7, 0.7),
                          duration: 600.ms,
                          curve: Curves.elasticOut,
                        ),

                    const SizedBox(height: 20),
                    Text('MyQueue',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800)),
                    Text('Version 1.0.0',
                        style: GoogleFonts.dmSans(
                            color: Colors.white38, fontSize: 13)),

                    const SizedBox(height: 32),

                    // Mission
                    GlassCard(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _aboutLabel('OUR MISSION'),
                          const SizedBox(height: 10),
                          Text(
                            'MyQueue was built to reduce wait times, ease overcrowding, and improve the quality of healthcare for refugees and displaced populations in camp settings.\n\n'
                            'By giving every person a digital queue number, a digital identity, and direct access to emergency services from their phone, we aim to make healthcare more dignified, fair, and accessible.',
                            style: GoogleFonts.dmSans(
                                color: Colors.white70, fontSize: 13, height: 1.65),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 16),

                    // Partnership
                    GlassCard(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _aboutLabel('PARTNERSHIP'),
                          const SizedBox(height: 12),
                          _partnerRow(
                            Icons.public_rounded,
                            'UNHCR',
                            'United Nations High Commissioner for Refugees',
                            const Color(0xFF60A5FA),
                          ),
                          const SizedBox(height: 14),
                          _partnerRow(
                            Icons.local_hospital_rounded,
                            'Ministry of Health Kenya',
                            'Primary healthcare delivery in Kakuma, Kalobeyei & Dadaab',
                            const Color(0xFF34D399),
                          ),
                          const SizedBox(height: 14),
                          _partnerRow(
                            Icons.cloud_rounded,
                            'Google Firebase',
                            'Secure cloud infrastructure and real-time data',
                            const Color(0xFFFBBF24),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 300.ms),

                    const SizedBox(height: 16),

                    // Legal links
                    GlassCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _legalTile(context, 'Privacy Policy',
                              'How we collect, use, and protect your data'),
                          const Divider(
                              color: Colors.white10, height: 1, indent: 20, endIndent: 20),
                          _legalTile(context, 'Terms of Use',
                              'Conditions for using the MyQueue platform'),
                          const Divider(
                              color: Colors.white10, height: 1, indent: 20, endIndent: 20),
                          _legalTile(context, 'Open Source Licences',
                              'Third-party libraries used in this app'),
                          const Divider(
                              color: Colors.white10, height: 1, indent: 20, endIndent: 20),
                          _legalTile(context, 'Data Retention Policy',
                              'How long your information is kept and your rights'),
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms),

                    const SizedBox(height: 32),

                    Text(
                      '© 2026 UNHCR / MyQueue\nBuilt for displaced communities worldwide.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                          color: Colors.white24, fontSize: 11, height: 1.6),
                    ),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _aboutLabel(String text) => Text(
        text,
        style: GoogleFonts.dmSans(
            color: const Color(0xFF82C4E8),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8),
      );

  Widget _partnerRow(IconData icon, String name, String desc, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: GoogleFonts.dmSans(
                      color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
              Text(desc,
                  style: GoogleFonts.dmSans(
                      color: Colors.white38, fontSize: 11, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legalTile(BuildContext context, String title, String sub) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('$title — coming soon'),
                duration: const Duration(seconds: 2)));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    Text(sub,
                        style: GoogleFonts.dmSans(
                            color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white24, size: 13),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
//  Shared back button
// ──────────────────────────────────────────

class _BackBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _BackBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white70, size: 16),
      ),
    );
  }
}
