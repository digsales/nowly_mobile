import 'package:flutter/material.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/widgets/app_layout.dart';
import 'package:nowly/core/widgets/app_title.dart';
import 'package:nowly/features/home/widgets/badge_progress_carousel.dart';
import 'package:nowly/features/home/widgets/category_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = EdgeInsets.only(
      left: context.paddingLeft + 32,
      right: context.paddingRight + 32,
    );

    return AppLayout(
      headerText: context.l10n.appName,
      bodyPadding: EdgeInsets.only(
        top: 32,
        bottom: context.paddingBottom + 50,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 600;

          if (wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: context.paddingLeft + 32),
                            child:AppTitle(
                              title: context.l10n.homeSectionCategories,
                              helpText: context.l10n.homeCategoryHelpText,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _FadingEdges(
                            color: context.colorScheme.surface,
                            side: FadeSize.right,
                            child: const CategoryList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: context.paddingRight + 32),
                            child: AppTitle(
                              title: context.l10n.homeSectionBadges,
                              helpText: context.l10n.homeBadgesHelpText,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _FadingEdges(
                            color: context.colorScheme.surface,
                            side: FadeSize.left,
                            child: const BadgeProgressCarousel(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: horizontalPadding,
                  child: AppTitle(
                    title: context.l10n.homeSectionTasks,
                  ),
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: horizontalPadding,
                child: AppTitle(
                  title: context.l10n.homeSectionCategories,
                  helpText: context.l10n.homeCategoryHelpText,
                ),
              ),
              const SizedBox(height: 32),
              const CategoryList(),
              const SizedBox(height: 32),
              Padding(
                padding: horizontalPadding,
                child: AppTitle(
                  title: context.l10n.homeSectionBadges,
                  helpText: context.l10n.homeBadgesHelpText,
                ),
              ),
              const SizedBox(height: 32),
              const BadgeProgressCarousel(),
              const SizedBox(height: 32),
              Padding(
                padding: horizontalPadding,
                child: AppTitle(
                  title: context.l10n.homeSectionTasks,
                  helpText: context.l10n.homeTasksHelpText,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

enum FadeSize {left, right, both}

class _FadingEdges extends StatelessWidget {
  const _FadingEdges({required this.color, this.side = FadeSize.both, required this.child});

  final Color color;
  final FadeSize side;
  final Widget child;

  static const _fadeWidth = 24.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (side != FadeSize.right)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: _fadeWidth,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0)],
                  ),
                ),
              ),
            ),
          ),
        if (side != FadeSize.left)
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: _fadeWidth,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0), color],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
