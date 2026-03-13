import 'package:flutter/material.dart';

/// RoleAvatar shows a user's uploaded image when available; otherwise it
/// falls back to a role-specific asset logo. For the "refugee" role we
/// intentionally render an empty avatar when no image is provided.
class RoleAvatar extends StatelessWidget {
  final String
      roleId; // e.g. 'lab','pharmacy','maternity','ambulance','doctor','refugee'
  final String? imageUrl; // network/local image URL if user uploaded
  final double size;
  final Color? backgroundColor;

  const RoleAvatar(
      {super.key,
      required this.roleId,
      this.imageUrl,
      this.size = 40,
      this.backgroundColor});

  String _assetForRole(String role) {
    switch (role) {
      case 'lab':
        return 'assets/illustrations/lab.png';
      case 'pharmacy':
        return 'assets/illustrations/pharmacy.png';
      case 'maternity':
        return 'assets/illustrations/maternity.png';
      case 'ambulance':
        return 'assets/illustrations/ambulance_final.png';
      case 'doctor':
        return 'assets/illustrations/doctor.png';
      case 'refugee':
      default:
        return 'assets/illustrations/refugee_final.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? Colors.transparent;

    // If an imageUrl is provided, show it (uploaded image)
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      // Support both network and asset URIs. If it looks like an http URL, use NetworkImage.
      final isNetwork = imageUrl!.startsWith('http');
      final imageProvider = isNetwork
          ? NetworkImage(imageUrl!)
          : AssetImage(imageUrl!) as ImageProvider;

      return CircleAvatar(
        radius: size / 2,
        backgroundColor: bg,
        backgroundImage: imageProvider,
      );
    }

    // No uploaded image. For refugee role, show an empty/outline avatar.
    if (roleId == 'refugee') {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: bg == Colors.transparent ? Colors.white : bg,
        child: Icon(Icons.person_outline, size: size * 0.5, color: Colors.grey),
      );
    }

    // For other roles, show the role asset as a temporary profile image.
    final asset = _assetForRole(roleId);
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: bg == Colors.transparent ? Colors.white : bg,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Image.asset(asset, fit: BoxFit.contain),
      ),
    );
  }
}
