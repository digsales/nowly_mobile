import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/models/app_language.dart';
import 'package:nowly/core/models/user.dart';
import 'package:nowly/core/widgets/app_avatar.dart';
import 'package:nowly/core/widgets/app_button.dart';
import 'package:nowly/core/widgets/app_layout.dart';
import 'package:nowly/core/widgets/app_loading.dart';
import 'package:nowly/core/widgets/app_setting_tile.dart';
import 'package:nowly/core/theme/theme_provider.dart';
import 'package:nowly/core/widgets/touchable_opacity.dart';
import 'package:nowly/features/profile/profile_provider.dart';
import 'package:nowly/features/profile/widgets/delete_account_dialog.dart';
import 'package:nowly/features/profile/widgets/language_dialog.dart';
import 'package:nowly/features/profile/widgets/reset_preferences_dialog.dart';
import 'package:nowly/features/profile/widgets/change_password_dialog.dart';
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
    final l10n = context.l10n;
    final highContrast = ref.watch(highContrastProvider);
    final fontScale = ref.watch(fontScaleProvider);
    final locale = ref.watch(localeProvider);
    final languageLabel = locale == null
        ? l10n.settingsLanguageSystem
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
          label: l10n.settingsDarkMode,
          trailing: Switch(
            value: context.isDark,
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
              l10n.settingsRestoreDefaults,
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
