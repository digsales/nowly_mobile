import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/widgets/app_help_sheet.dart';
import 'package:nowly/core/widgets/app_layout.dart';
import 'package:nowly/core/widgets/touchable_opacity.dart';
import 'package:nowly/features/home/widgets/badge_progress_carousel.dart';
import 'package:nowly/features/home/widgets/category_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      headerText: context.l10n.appName,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.homeSectionCategories,
                  style: context.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Ultra',
                    color: context.colorScheme.onSurface,
                  ),
                ),
              ),
              TouchableOpacity(
                onTap: () => AppHelpSheet.show(
                  context: context,
                  title: context.l10n.homeSectionCategories,
                  text: context.l10n.homeCategoryHelpText,
                ),
                child: Icon(
                    Ionicons.help_circle_outline,
                    color: context.colorScheme.onSurface,
                    size: context.textTheme.displaySmall!.fontSize,
                  ),
              )
            ],
          ),
          const SizedBox(height: 32),
          const CategoryList(),
          const SizedBox(height: 32),
          Text(
            context.l10n.homeSectionBadges,
            style: context.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.w500,
              fontFamily: 'Ultra',
              color: context.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 32),
          const BadgeProgressCarousel(),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  context.l10n.homeSectionTasks,
                  style: context.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Ultra',
                    color: context.colorScheme.onSurface,
                  ),
                ),
              ),
              TouchableOpacity(
                child: Text(
                  context.l10n.homeEdit,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
