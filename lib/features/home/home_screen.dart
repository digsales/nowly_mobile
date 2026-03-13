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
      body: Column(
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
            ),
          ),
          const SizedBox(height: 32),
          const BadgeProgressCarousel(),
          const SizedBox(height: 32),
          Padding(
            padding: horizontalPadding,
            child: AppTitle(
              title: context.l10n.homeSectionTasks,
            ),
          ),
        ],
      ),
    );
  }
}
