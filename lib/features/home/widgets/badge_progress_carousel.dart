import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/models/user.dart';
import 'package:nowly/core/models/user_badge.dart';
import 'package:nowly/core/widgets/badge_details_sheet.dart';
import 'package:nowly/core/widgets/touchable_opacity.dart';
import 'package:nowly/features/home/widgets/badge_carousel_skeleton.dart';
import 'package:nowly/features/profile/profile_provider.dart';

class BadgeProgressCarousel extends ConsumerStatefulWidget {
  const BadgeProgressCarousel({super.key});

  @override
  ConsumerState<BadgeProgressCarousel> createState() =>
      _BadgeProgressCarouselState();
}

class _BadgeProgressCarouselState extends ConsumerState<BadgeProgressCarousel> {
  final CarouselSliderController _controller = CarouselSliderController();
  int _currentIndex = 0;

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
      AsyncError() => _buildCarousel(null),
      _ => const BadgeCarouselSkeleton(),
    };
  }

  Widget _buildCarousel(User? user) {
    final badges = user != null ? _sortedBadges(user) : UserBadges.values;
    if (badges.isEmpty) return const SizedBox.shrink();

    const padding = 16.0 * 2;
    final titleSize = context.textTheme.labelLarge!.fontSize!;
    final subtitleSize = context.textTheme.labelSmall!.fontSize!;
    final progressBar = context.textTheme.labelSmall!.fontSize! * 3;
    const spacings = 4.0 + 8.0; // between title-subtitle + subtitle-progress
    final contentHeight = padding + titleSize + spacings + subtitleSize + progressBar;
    final carouselHeight = contentHeight < 80 ? 80.0 : contentHeight;
    final imageSize = carouselHeight - padding;

    return Column(
      children: [
        CarouselSlider.builder(
          carouselController: _controller,
          itemCount: badges.length,
          itemBuilder: (context, index, realIndex) {
            final badge = badges[index];
            return TouchableOpacity(
              onTap: () {
                if (index == _currentIndex && user != null) {
                  BadgeDetailsSheet.show(context, badge: badge, user: user);
                } else {
                  _controller.animateToPage(index);
                }
              },
              child: _BadgeCard(badge: badge, user: user, imageSize: imageSize),
            );
          },
          options: CarouselOptions(
            height: carouselHeight,
            viewportFraction: 0.85,
            enlargeCenterPage: false,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 400),
            autoPlayCurve: Curves.easeInOut,
            pauseAutoPlayOnTouch: true,
            pauseAutoPlayOnManualNavigate: true,
            pauseAutoPlayInFiniteScroll: true,
            onPageChanged: (index, _) => setState(() => _currentIndex = index),
          ),
        ),
        const SizedBox(height: 12),
        _ScrollIndicator(current: _currentIndex, count: badges.length),
      ],
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.badge, this.user, required this.imageSize});

  final UserBadge badge;
  final User? user;
  final double imageSize;

  @override
  Widget build(BuildContext context) {
    final hasUser = user != null;
    final progress = hasUser ? badge.progress(user!) : 0.0;
    final current = hasUser ? badge.currentValue(user!) : 0;
    final total = badge.threshold;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
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
                width: imageSize,
                height: imageSize,
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
                if (hasUser)
                  Row(
                    children: [
                      Expanded(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: progress),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) => ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: value,
                              minHeight: 6,
                              backgroundColor:
                                  context.colorScheme.onSurface.withValues(alpha: 0.12),
                              valueColor: AlwaysStoppedAnimation(
                                context.colorScheme.primary,
                              ),
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
                  )
                else
                  Text(
                    context.l10n.badgeDataUnavailable,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.error,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScrollIndicator extends StatelessWidget {
  const _ScrollIndicator({required this.current, required this.count});

  final int current;
  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 1) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth * 0.80;
        const height = 4.0;
        final thumbWidth = trackWidth / count;
        final offset = (current / (count - 1)) * (trackWidth - thumbWidth);

        return Center(
          child: SizedBox(
            width: trackWidth,
            height: height,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(height / 2),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: thumbWidth,
                  height: height,
                  margin: EdgeInsets.only(left: offset),
                  decoration: BoxDecoration(
                    color: context.colorScheme.primary,
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
