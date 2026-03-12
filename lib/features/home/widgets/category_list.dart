import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/theme/theme_provider.dart';
import 'package:nowly/core/widgets/touchable_opacity.dart';
import 'package:nowly/features/home/home_provider.dart';

class CategoryList extends ConsumerWidget {
  const CategoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final highContrast = ref.watch(highContrastProvider);
    final brightness = Theme.of(context).brightness;

    return switch (categoriesAsync) {
      AsyncData(:final value) when value.isNotEmpty => SingleChildScrollView(
          clipBehavior: Clip.none,
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 16,
            children: [
              _buildCategoryTile(
                context,
                icon: Ionicons.add,
                label: context.l10n.addCategory,
                backgroundColor: context.colorScheme.surface,
                iconColor: context.colorScheme.onSurface,
                border: Border.all(
                  color: context.colorScheme.onSurface,
                  width: 2,
                ),
                textColor: context.colorScheme.onSurface,
                onTap: () {
                  // TODO: abrir tela de adicionar categoria
                },
              ),
              ...value.map((category) {
                final color = category.resolveColor(
                  brightness: brightness,
                  highContrast: highContrast,
                );
                return _buildCategoryTile(
                  context,
                  icon: category.icon,
                  label: category.name,
                  backgroundColor: color,
                  iconColor: context.colorScheme.onPrimary,
                  onTap: () {
                    // TODO: abrir tela de edição de categoria
                  },
                );
              }),
            ],
          ),
        ),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildCategoryTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color iconColor,
    required VoidCallback onTap,
    BoxBorder? border,
    Color? textColor,
  }) {
    return TouchableOpacity(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              border: border,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 30,
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
      ),
    );
  }
}
