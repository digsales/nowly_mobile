import 'package:flutter/material.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:sizer/sizer.dart';
import 'package:shimmer/shimmer.dart';

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final boneColor = context.colorScheme.onSurface;

    return Shimmer.fromColors(
      baseColor: boneColor.withValues(alpha: 0.08),
      highlightColor: boneColor.withValues(alpha: 0.16),
      child: Column(
        children: [
          // Avatar
          _circle(40.sp),
          const SizedBox(height: 16),
          // Name
          _bone(width: 140, height: 20, radius: 8),
          const SizedBox(height: 8),
          // Email
          _bone(width: 180, height: 14, radius: 6),
          const SizedBox(height: 24),
          // Badges row
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: List.generate(6, (_) => _circle(60)),
          ),
          const SizedBox(height: 32),
          // Setting tiles
          ...List.generate(5, (_) => _settingTile(context)),
        ],
      ),
    );
  }

  Widget _circle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
    );
  }

  Widget _bone({required double width, required double height, double radius = 8}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _settingTile(BuildContext context) {
    final iconSize = context.textTheme.bodyLarge!.fontSize! * 2.21;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          const SizedBox(width: 16),
          _bone(width: 120, height: 16),
          const Spacer(),
          _bone(width: 48, height: 16),
        ],
      ),
    );
  }
}
