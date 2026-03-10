import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
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
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              unlocked
                  ? Ionicons.lock_open_outline
                  : Ionicons.lock_closed_outline,
              size: 16,
              color: unlocked
                  ? context.colorScheme.primary
                  : context.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              unlocked
                  ? context.l10n.badgeUnlocked
                  : context.l10n.badgeLocked,
              style: context.textTheme.bodyMedium?.copyWith(
                color: unlocked
                    ? context.colorScheme.primary
                    : context.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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
