import 'package:flutter/material.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/widgets/touchable_opacity.dart';

/// A square tile with a rounded-rectangle background, an icon, and a label.
///
/// Used to display categories in the home screen and as a live preview
/// in the category form screen.
class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.iconColor,
    this.border,
    this.textColor,
    this.onTap,
    this.size = 80,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final BoxBorder? border;
  final Color? textColor;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final child = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(size * 0.25)),
            border: border,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: size * 0.375,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: textColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );

    return TouchableOpacity(onTap: onTap, child: child);
  }
}
