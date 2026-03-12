import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/theme/theme_provider.dart';
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
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 16,
            children: value.map((category) {
              final color = category.resolveColor(
                brightness: brightness,
                highContrast: highContrast,
              );
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Icon(
                      category.icon,
                      color: context.colorScheme.onPrimary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.name,
                    style: context.textTheme.labelSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      _ => const SizedBox.shrink(),
    };
  }
}
