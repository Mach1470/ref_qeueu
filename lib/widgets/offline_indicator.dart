import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/offline_sync_service.dart';

/// A slim banner shown at the top of the screen when the device is offline
/// or has pending sync work. Sits above the [Scaffold] body via [Stack].
class OfflineIndicator extends StatelessWidget {
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<OfflineSyncService>();

    final String? message;
    final Color bg;
    final Color fg;
    final IconData icon;

    if (!svc.online) {
      message = svc.pendingCount > 0
          ? 'Offline — ${svc.pendingCount} update${svc.pendingCount == 1 ? '' : 's'} will sync when online'
          : 'Offline mode — data will save locally';
      bg = const Color(0xFFFFA000);
      fg = Colors.black;
      icon = Icons.cloud_off_rounded;
    } else if (svc.syncing) {
      message = 'Syncing ${svc.pendingCount} update${svc.pendingCount == 1 ? '' : 's'}…';
      bg = const Color(0xFF1976D2);
      fg = Colors.white;
      icon = Icons.cloud_sync_rounded;
    } else if (svc.pendingCount > 0) {
      message = '${svc.pendingCount} update${svc.pendingCount == 1 ? '' : 's'} pending sync';
      bg = const Color(0xFFE0E0E0);
      fg = Colors.black87;
      icon = Icons.cloud_queue_rounded;
    } else {
      message = null;
      bg = Colors.transparent;
      fg = Colors.transparent;
      icon = Icons.cloud_done_rounded;
    }

    if (message == null) {
      return const SizedBox.shrink();
    }

    return Material(
      color: bg,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(icon, color: fg, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
