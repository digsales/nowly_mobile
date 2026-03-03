import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';

/// Circular avatar that shows an image from [imageUrl] or falls back
/// to the user's initials on a primary-colored background.
///
/// ```dart
/// AppAvatar(name: 'Diogo Sales', imageUrl: user.avatarUrl, size: 80)
/// ```
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 80,
  });

  /// Full name used to extract initials (e.g. "Diogo Sales" → "DS").
  final String name;

  /// Optional image URL. When provided, displays the image.
  final String? imageUrl;

  /// Diameter of the avatar. Defaults to 80.
  final double size;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colorScheme.primary,
        image: imageUrl != null
            ? DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: imageUrl == null
          ? Center(
              child: Text(
                _initials,
                style: TextStyle(
                  color: context.colorScheme.onPrimary,
                  fontSize: size * 0.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }
}
