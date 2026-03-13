import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ref_qeueu/services/theme_service.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final ts = context.watch<ThemeService>();

    return IconButton(
      icon: Icon(ts.isDark ? Icons.dark_mode : Icons.light_mode),
      tooltip: ts.isDark ? 'Switch to light mode' : 'Switch to dark mode',
      onPressed: () => ts.toggleDark(),
    );
  }
}
