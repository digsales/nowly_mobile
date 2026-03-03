import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/models/user.dart';
import 'package:nowly/core/widgets/app_avatar.dart';
import 'package:nowly/core/widgets/app_button.dart';
import 'package:nowly/core/widgets/app_layout.dart';
import 'package:nowly/core/widgets/app_loading.dart';
import 'package:nowly/core/widgets/app_setting_tile.dart';
import 'package:nowly/core/theme/theme_provider.dart';
import 'package:nowly/features/profile/profile_provider.dart';
import 'package:nowly/features/profile/widgets/delete_account_dialog.dart';
import 'package:nowly/features/profile/widgets/edit_name_dialog.dart';
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
        AsyncData(:final value) when value != null => Column(
            children: [
              _buildUserInfo(context, value),
              const SizedBox(height: 32),
              _buildAccountSettings(context, ref, value),
              Divider(height: 32, color: context.colorScheme.outlineVariant),
              _buildPreferenceSettings(context, ref),
              const SizedBox(height: 32),
              _buildActions(context, notifier),
            ],
          ),
        AsyncError() => const SizedBox.shrink(),
        _ => const Center(child: AppLoading()),
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

  Widget _buildAccountSettings(BuildContext context, WidgetRef ref, User user) {
    final l10n = context.l10n;

    return Column(
      children: [
        AppSettingTile(
          icon: Ionicons.person_outline,
          label: l10n.settingsName,
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
          label: l10n.settingsChangePassword,
          trailing: const Icon(Ionicons.chevron_forward_outline, size: 18),
          onTap: () {
            // TODO: navigate to change password
          },
        ),
      ],
    );
  }

  Widget _buildPreferenceSettings(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final themeMode = ref.watch(themeModeProvider);
    final highContrast = ref.watch(highContrastProvider);
    final fontScale = ref.watch(fontScaleProvider);

    return Column(
      children: [
        AppSettingTile(
          icon: Ionicons.moon_outline,
          label: l10n.settingsDarkMode,
          trailing: Switch(
            value: themeMode == ThemeMode.dark,
            onChanged: (value) => ref.read(themeModeProvider.notifier).set(
              value ? ThemeMode.dark : ThemeMode.light,
            ),
          ),
        ),
        AppSettingTile(
          icon: Ionicons.contrast_outline,
          label: l10n.settingsHighContrast,
          trailing: Switch(
            value: highContrast,
            onChanged: (value) => ref.read(highContrastProvider.notifier).set(value),
          ),
        ),
        AppSettingTile(
          icon: Ionicons.text_outline,
          label: l10n.settingsFontSize,
          trailing: SizedBox(
            width: 140,
            child: Slider(
              value: fontScale,
              min: 0.8,
              max: 1.4,
              divisions: 3,
              onChanged: (value) => ref.read(fontScaleProvider.notifier).set(value),
            ),
          ),
        ),
        AppSettingTile(
          icon: Ionicons.language_outline,
          label: l10n.settingsLanguage,
          trailing: const Icon(Ionicons.chevron_forward_outline, size: 18),
          onTap: () {
            // TODO: navigate to language selection
          },
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, ProfileNotifier notifier) {
    final l10n = context.l10n;

    return Column(
      children: [
        AppButton(
          text: l10n.signoutButton,
          variant: AppButtonVariant.outlined,
          detailColor: context.colorScheme.onSurfaceVariant,
          textColor: context.colorScheme.onSurfaceVariant,
          onPressed: () async {
            await notifier.signout();
          },
        ),
        const SizedBox(height: 16),
        AppButton(
          text: l10n.deleteAccountButton,
          detailColor: context.colorScheme.error,
          textColor: context.colorScheme.onError,
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const DeleteAccountDialog(),
          ),
        ),
      ],
    );
  }
}
