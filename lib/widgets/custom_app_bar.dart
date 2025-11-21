import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom App Bar that handles notches and dynamic island properly
/// Works on both Android (notch) and iOS (dynamic island)
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.backgroundColor,
    this.foregroundColor,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final statusBarHeight = mediaQuery.padding.top;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.teal,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: kToolbarHeight,
          padding: EdgeInsets.only(top: statusBarHeight > 20 ? 0 : 8),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
            ),
            leading: showBackButton
                ? IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: foregroundColor ?? Colors.white,
                    ),
                    onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                  )
                : null,
            title: Text(
              title,
              style: TextStyle(
                color: foregroundColor ?? Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: actions,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize {
    // Account for status bar and notch/dynamic island
    return const Size.fromHeight(kToolbarHeight + 44); // Base + safe area
  }
}
