import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/router/app_router.dart';
import 'package:nowly/core/theme/primary_colors.dart';
import 'package:nowly/core/widgets/category_tile.dart';
import 'package:nowly/features/home/home_provider.dart';
import 'package:nowly/features/home/widgets/category_skeleton.dart';

class CategoryList extends ConsumerWidget {
  const CategoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final horizontalPadding = EdgeInsets.only(
      left: context.paddingLeft + 32,
      right: context.paddingRight + 32,
    );

    return switch (categoriesAsync) {
      AsyncData(:final value) when value.isNotEmpty => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: horizontalPadding,
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
                return CategoryTile(
                  icon: category.icon,
                  label: category.name,
                  backgroundColor: ref.usePrimaryColor(category.colorKey),
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
      AsyncData(:final value) when value.isEmpty => Row(
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
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                context.l10n.emptyCategoryHint,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      AsyncLoading() => const CategorySkeleton(),
      AsyncError() => Padding(
          padding: horizontalPadding,
          child: Text(
            context.l10n.errorMessage,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.error,
            ),
          ),
        ),
      _ => const SizedBox.shrink(),
    };
  }
}
