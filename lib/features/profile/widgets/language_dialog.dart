import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/models/app_language.dart';
import 'package:nowly/core/theme/theme_provider.dart';
import 'package:nowly/core/widgets/app_dialog.dart';
import 'package:nowly/core/widgets/touchable_opacity.dart';

class LanguageDialog extends ConsumerWidget {
  const LanguageDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final l10n = context.l10n;

    return AppDialog(
      icon: Ionicons.language_outline,
      title: l10n.settingsLanguageDialogTitle,
      body: Column(
        children: [
          _LanguageTile(
            flag: '🌐',
            label: l10n.settingsLanguageSystem,
            selected: currentLocale == null,
            onTap: () {
              ref.read(localeProvider.notifier).set(null);
              Navigator.of(context).pop();
            },
          ),
          ...AppLanguage.supported.map(
            (lang) => _LanguageTile(
              flag: lang.flag,
              label: lang.nativeName,
              selected: currentLocale?.languageCode == lang.locale.languageCode &&
                  currentLocale?.countryCode == lang.locale.countryCode,
              onTap: () {
                ref.read(localeProvider.notifier).set(lang.locale);
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
      cancelText: l10n.deleteAccountCancel,
      onCancel: () => Navigator.of(context).pop(),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.flag,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String flag;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TouchableOpacity(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (selected)
              Icon(
                Ionicons.checkmark_outline,
                size: 18,
                color: context.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
