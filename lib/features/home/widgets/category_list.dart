import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/router/app_router.dart';
import 'package:nowly/core/theme/theme_provider.dart';
import 'package:nowly/core/widgets/category_tile.dart';
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
              CategoryTile(
                icon: Ionicons.add,
                label: context.l10n.addCategory,
                backgroundColor: context.colorScheme.surface,
                iconColor: context.colorScheme.onSurface,
                border: Border.all(
                  color: context.colorScheme.onSurface,
                  width: 2,
                ),
                textColor: context.colorScheme.onSurface,
                onTap: () => context.push(AppRoutes.categoryForm),
              ),
              ...value.map((category) {
                final color = category.resolveColor(
                  brightness: brightness,
                  highContrast: highContrast,
                );
                return CategoryTile(
                  icon: category.icon,
                  label: category.name,
                  backgroundColor: color,
                  iconColor: context.colorScheme.onPrimary,
                  onTap: () => context.push(
                    AppRoutes.categoryForm,
                    extra: category,
                  ),
                );
              }),
            ],
          ),
        ),
      _ => const SizedBox.shrink(),
    };
  }
}
