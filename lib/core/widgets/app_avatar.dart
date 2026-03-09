import 'package:flutter/material.dart';
import 'package:nowly/core/models/app_badge.dart';

import '../extensions/context_extensions.dart';

/// Circular avatar that shows a badge asset, a network image, or falls back
/// to the user's initials on a primary-colored background.
///
/// When [imageUrl] starts with `badge:`, it resolves the matching
/// [AppBadge] asset. Otherwise it loads a network image.
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

  /// Full name used to extract initials (e.g. "Diogo Sales" -> "DS").
  final String name;

  /// Optional image URL or badge key (e.g. `badge:level_0025`).
  final String? imageUrl;

  /// Diameter of the avatar. Defaults to 80.
  final double size;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  ImageProvider? _resolveImage() {
    final url = imageUrl;
    if (url == null) return null;

    if (url.startsWith('badge:')) {
      final key = url.substring(6);
      final badge = AppBadges.values.where((b) => b.key == key).firstOrNull;
      if (badge != null) return AssetImage(badge.assetPath);
      return null;
    }

    return NetworkImage(url);
  }

  @override
  Widget build(BuildContext context) {
    final image = _resolveImage();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colorScheme.inversePrimary,
        image: image != null
            ? DecorationImage(image: image, fit: BoxFit.cover)
            : null,
      ),
      child: image == null
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
