import 'package:flutter/material.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:shimmer/shimmer.dart';

class CategorySkeleton extends StatelessWidget {
  const CategorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = EdgeInsets.only(
      left: context.paddingLeft + 32,
      right: context.paddingRight + 32,
    );

    return SingleChildScrollView(
      padding: horizontalPadding,
      clipBehavior: Clip.none,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Shimmer.fromColors(
        baseColor: context.colorScheme.onSurface.withValues(alpha: 0.08),
        highlightColor: context.colorScheme.onSurface.withValues(alpha: 0.16),
        child: Row(
          spacing: 16,
          children: List.generate(5, (_) => _tile()),
        ),
      ),
    );
  }

  Widget _tile() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 52,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }
}
