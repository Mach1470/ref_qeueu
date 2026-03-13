import 'package:flutter/material.dart';
import 'package:ref_qeueu/widgets/logo_avatar.dart';

class LoginCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget children;
  final Widget actionButton;
  final Widget? footer;
  final bool isDarkMode;

  const LoginCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    required this.actionButton,
    this.footer,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge!.color;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.center,
                  child: LogoAvatar(size: 70),
                ),
                const SizedBox(height: 12),
                Text(title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor)),
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(subtitle!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium),
                ],
                const SizedBox(height: 20),
                children,
                const SizedBox(height: 20),
                actionButton,
                const SizedBox(height: 12),
                if (footer != null) footer!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
