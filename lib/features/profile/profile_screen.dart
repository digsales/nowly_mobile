import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/models/user_badge.dart';
import 'package:nowly/core/models/app_language.dart';
import 'package:nowly/core/models/user.dart';
import 'package:nowly/core/utils/app_max_width.dart';
import 'package:nowly/core/widgets/app_avatar.dart';
import 'package:nowly/core/widgets/app_button.dart';
import 'package:nowly/core/widgets/app_error_state.dart';
import 'package:nowly/core/widgets/app_layout.dart';
import 'package:nowly/features/profile/widgets/profile_skeleton.dart';
import 'package:nowly/core/widgets/badge_details_sheet.dart';
import 'package:nowly/core/widgets/app_setting_tile.dart';
import 'package:nowly/core/theme/theme_provider.dart';
import 'package:nowly/core/widgets/touchable_opacity.dart';
import 'package:nowly/features/profile/profile_provider.dart';
import 'package:nowly/features/profile/widgets/delete_account_dialog.dart';
import 'package:nowly/features/profile/widgets/language_dialog.dart';
import 'package:nowly/features/profile/widgets/reset_preferences_dialog.dart';
import 'package:nowly/features/profile/widgets/change_password_dialog.dart';
import 'package:nowly/features/profile/widgets/edit_name_dialog.dart';
import 'package:nowly/features/profile/widgets/primary_color_dialog.dart';
import 'package:sizer/sizer.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(profileProvider.notifier);
    final userAsync = ref.watch(currentUserProvider);

    return AppLayout(
      headerText: context.l10n.profile,
      body: switch (userAsync) {
        AsyncData(:final value) when value != null => LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 600;

              if (wide) {
                return Column(
                  children: [
                    _buildUserInfo(context, value),
                    const SizedBox(height: 24),
                    _buildBadges(context, ref, value),
                    const SizedBox(height: 32),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildAccountSettings(context, ref, value)),
                        const SizedBox(width: 32),
                        Expanded(child: _buildPreferenceSettings(context, ref)),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: appMaxWidth),
                      child: _buildActions(context, notifier),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  _buildUserInfo(context, value),
                  const SizedBox(height: 24),
                  _buildBadges(context, ref, value),
                  Divider(height: 32, color: context.colorScheme.outlineVariant),
                  _buildAccountSettings(context, ref, value),
                  Divider(height: 32, color: context.colorScheme.outlineVariant),
                  _buildPreferenceSettings(context, ref),
                  const SizedBox(height: 32),
                  _buildActions(context, notifier),
                ],
              );
            },
          ),
        AsyncError() => AppErrorState(
            onRetry: () => ref.invalidate(currentUserProvider),
          ),
        _ => const ProfileSkeleton(),
      },
    );
  }

  Widget _buildUserInfo(BuildContext context, User user) {
    return Column(
      children: [
        AppAvatar(
          name: user.name,
          imageUrl: user.avatarUrl,
          size: 40.sp,
        ),
        const SizedBox(height: 16),
        Text(
          user.name,
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildBadges(BuildContext context, WidgetRef ref, User user) {
    final currentAvatarUrl = user.avatarUrl;
    final notifier = ref.read(profileProvider.notifier);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: UserBadges.values.map((badge) {
        final unlocked = badge.isUnlocked(user);
        final isSelected = currentAvatarUrl == 'badge:${badge.key}';

        return GestureDetector(
          onTap: unlocked
              ? () {
                  final newValue =
                      isSelected ? null : 'badge:${badge.key}';
                  notifier.updateAvatar(newValue);
                }
              : () => BadgeDetailsSheet.show(context, badge: badge, user: user),
          onLongPress: () {
                HapticFeedback.mediumImpact();
                BadgeDetailsSheet.show(context, badge: badge, user: user);
              },
          onSecondaryTap: () {
                HapticFeedback.mediumImpact();
                BadgeDetailsSheet.show(context, badge: badge, user: user);
              },
          child: Opacity(
            opacity: unlocked ? 1.0 : 0.3,
            child: Container(
              width: 60,
              height: 60,
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
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAccountSettings(BuildContext context, WidgetRef ref, User user) {
    return Column(
      children: [
        AppSettingTile(
          icon: Ionicons.person_outline,
          label: context.l10n.settingsName,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                user.name,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Ionicons.chevron_forward_outline, size: 18),
            ],
          ),
          onTap: () => showDialog(
            context: context,
            builder: (_) => EditNameDialog(currentName: user.name),
          ),
        ),
        AppSettingTile(
          icon: Ionicons.lock_closed_outline,
          label: context.l10n.settingsChangePassword,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "********",
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Ionicons.chevron_forward_outline, size: 18),
            ],
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => const ChangePasswordDialog(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPreferenceSettings(BuildContext context, WidgetRef ref) {
    final highContrast = ref.watch(highContrastProvider);
    final currentColor = ref.watch(primaryColorProvider).primary;
    final fontScale = ref.watch(fontScaleProvider);
    final locale = ref.watch(localeProvider);
    final languageLabel = locale == null
        ? context.l10n.settingsLanguageSystem
        : AppLanguage.supported
            .firstWhere(
              (lang) =>
                  lang.locale.languageCode == locale.languageCode &&
                  lang.locale.countryCode == locale.countryCode,
              orElse: () => AppLanguage.supported.first,
            )
            .nativeName;

    return Column(
      children: [
        AppSettingTile(
          icon: Ionicons.moon_outline,
          label: context.l10n.settingsDarkMode,
          trailing: Switch(
            value: context.isDark,
            onChanged: (value) => ref.read(themeModeProvider.notifier).set(
              value ? ThemeMode.dark : ThemeMode.light,
            ),
          ),
        ),
        AppSettingTile(
          icon: Ionicons.contrast_outline,
          label: context.l10n.settingsHighContrast,
          trailing: Switch(
            value: highContrast,
            onChanged: (value) => ref.read(highContrastProvider.notifier).set(value),
          ),
        ),
        AppSettingTile(
          icon: Ionicons.color_palette_outline,
          label: context.l10n.settingsPrimaryColor,
          onTap: () => showDialog(
            context: context,
            builder: (_) => const PrimaryColorDialog(),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: currentColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Ionicons.chevron_forward_outline, size: 18),
            ],
          ),
        ),
        AppSettingTile(
          icon: Ionicons.text_outline,
          label: context.l10n.settingsFontSize,
          trailing: SizedBox(
            width: 140,
            child: Slider(
              value: fontScale,
              min: 0.8,
              max: 1.2,
              divisions: 2,
              onChanged: (value) => ref.read(fontScaleProvider.notifier).set(value),
            ),
          ),
        ),
        AppSettingTile(
          icon: Ionicons.language_outline,
          label: context.l10n.settingsLanguage,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                languageLabel,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Ionicons.chevron_forward_outline, size: 18),
            ],
          ),
          onTap: () => showDialog(
            context: context,
            builder: (_) => const LanguageDialog(),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TouchableOpacity(
            onTap: () => showDialog(
              context: context,
              builder: (_) => const ResetPreferencesDialog(),
            ),
            child: Text(
              context.l10n.settingsRestoreDefaults,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, ProfileNotifier notifier) {
    return Column(
      children: [
        AppButton(
          text: context.l10n.signoutButton,
          variant: AppButtonVariant.outlined,
          detailColor: context.colorScheme.onSurfaceVariant,
          textColor: context.colorScheme.onSurfaceVariant,
          onPressed: () async {
            await notifier.signout();
          },
        ),
        const SizedBox(height: 16),
        AppButton(
          text: context.l10n.deleteAccountButton,
          detailColor: context.colorScheme.error,
          textColor: context.colorScheme.onError,
          onPressed: () {
            HapticFeedback.heavyImpact();
            showDialog(
              context: context,
              builder: (_) => const DeleteAccountDialog(),
            );
          }
        ),
      ],
    );
  }
}
