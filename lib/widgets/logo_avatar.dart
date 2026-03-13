import 'package:flutter/material.dart';

class LogoAvatar extends StatelessWidget {
  final double size;
  final Color? background;
  const LogoAvatar({super.key, this.size = 56, this.background});

  @override
  Widget build(BuildContext context) {
    final bg = background ??
        Theme.of(context).primaryColor.withAlpha((0.06 * 255).round());
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
      child: Image.asset('assets/illustrations/app_logo.png',
          height: size - 24, width: size - 24),
    );
  }
}
