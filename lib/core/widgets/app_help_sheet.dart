import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/widgets/app_bottom_sheet.dart';

/// Shows a help bottom sheet with a title and explanatory text.
///
/// ```dart
/// AppHelpSheet.show(
///   context: context,
///   title: 'Categorias',
///   text: 'Organize suas tarefas por categoria.',
/// );
/// ```
abstract final class AppHelpSheet {
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String text,
  }) {
    return AppBottomSheet.show(
      context: context,
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Ionicons.help_circle_outline,
                color: context.colorScheme.primary,
                size: context.textTheme.titleMedium!.fontSize! * 1.5,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            text,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
