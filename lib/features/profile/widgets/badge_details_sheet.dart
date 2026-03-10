import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/models/user.dart';
import 'package:nowly/core/models/user_badge.dart';
import 'package:nowly/core/widgets/app_bottom_sheet.dart';
import 'package:nowly/core/widgets/app_button.dart';
import 'package:nowly/features/profile/profile_provider.dart';

class BadgeDetailsSheet extends ConsumerWidget {
  const BadgeDetailsSheet({
    super.key,
    required this.badge,
    required this.user,
  });

  final UserBadge badge;
  final User user;

  static void show(BuildContext context, {required UserBadge badge, required User user}) {
    AppBottomSheet.show(
      context: context,
      builder: (_) => BadgeDetailsSheet(badge: badge, user: user),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final progress = badge.progress(user);
    final current = badge.currentValue(user).clamp(0, badge.threshold);

    return Column(
      children: [
        Text(
          context.l10n.badgeYourProgress,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: context.colorScheme.onSurface.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(context.colorScheme.primary),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$current / ${badge.threshold}',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlocked = badge.isUnlocked(user);
    final currentAvatarUrl = ref.watch(
      currentUserProvider.select((async) => async.value?.avatarUrl),
    );
    final isSelected = currentAvatarUrl == 'badge:${badge.key}';
    final notifier = ref.read(profileProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: isSelected
                ? Border.all(
                    color: context.colorScheme.onSurface,
                    width: 3,
                  )
                : null,
            image: DecorationImage(
              image: AssetImage(badge.assetPath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          badge.name,
          style: context.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          badge.description,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        if (badge.type != BadgeType.defaultBadge) ...[
          const SizedBox(height: 20),
          _buildProgressBar(context),
        ],
        if (unlocked) ...[
          const SizedBox(height: 24),
          AppButton(
            text: isSelected
                ? context.l10n.badgeRemove
                : context.l10n.badgeUseAsAvatar,
            variant: isSelected
                ? AppButtonVariant.outlined
                : AppButtonVariant.filled,
            onPressed: () {
              final newValue = isSelected ? null : 'badge:${badge.key}';
              notifier.updateAvatar(newValue);
              Navigator.of(context).pop();
            },
          ),
        ],
      ],
    );
  }
}
