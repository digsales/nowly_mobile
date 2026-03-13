import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/models/user.dart';
import 'package:nowly/core/models/user_badge.dart';
import 'package:nowly/core/widgets/badge_details_sheet.dart';
import 'package:nowly/core/widgets/touchable_opacity.dart';
import 'package:nowly/features/profile/profile_provider.dart';
import 'package:expandable_page_view/expandable_page_view.dart';

class BadgeProgressCarousel extends ConsumerStatefulWidget {
  const BadgeProgressCarousel({super.key});

  @override
  ConsumerState<BadgeProgressCarousel> createState() =>
      _BadgeProgressCarouselState();
}

class _BadgeProgressCarouselState extends ConsumerState<BadgeProgressCarousel> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<UserBadge> _sortedBadges(User user) {
    final notUnlocked = UserBadges.values
        .where((b) => !b.isUnlocked(user))
        .toList()
      ..sort((a, b) => b.progress(user).compareTo(a.progress(user)));

    final unlocked = user.unlockedBadges
        .map((key) => UserBadges.values.firstWhere((b) => b.key == key))
        .toList();

    return [...notUnlocked, ...unlocked];
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return switch (userAsync) {
      AsyncData(:final value) when value != null => _buildCarousel(value),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildCarousel(User user) {
    final badges = _sortedBadges(user);
    if (badges.isEmpty) return const SizedBox.shrink();

    return ExpandablePageView.builder(
      controller: _controller,
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        final isCurrent = (_controller.page?.round() ?? 0) == index;
        return TouchableOpacity(
          onTap: () {
            if (isCurrent) {
              BadgeDetailsSheet.show(context, badge: badge, user: user);
            } else {
              _controller.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          },
          child: _BadgeCard(badge: badge, user: user),
        );
      },
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.badge, required this.user});

  final UserBadge badge;
  final User user;

  @override
  Widget build(BuildContext context) {
    final progress = badge.progress(user);
    final current = badge.currentValue(user);
    final total = badge.threshold;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ColorFiltered(
                colorFilter: progress < 1.0
                    ? const ColorFilter.mode(
                        Colors.grey,
                        BlendMode.saturation,
                      )
                    : const ColorFilter.mode(
                        Colors.transparent,
                        BlendMode.dst,
                      ),
                child: Image.asset(
                  badge.assetPath,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    badge.name(context.l10n),
                    style: context.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    badge.description(context.l10n),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor:
                                context.colorScheme.onSurface.withValues(alpha: 0.12),
                            valueColor: AlwaysStoppedAnimation(
                              context.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (total > 0)
                        Text(
                          context.l10n.badgeProgressLabel(current < total ? current : total, total),
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
