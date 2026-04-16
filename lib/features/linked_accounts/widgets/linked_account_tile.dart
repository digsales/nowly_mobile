import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/theme/primary_colors.dart';
import 'package:nowly/core/widgets/app_dialog.dart';
import 'package:nowly/core/widgets/app_loading.dart';
import 'package:nowly/core/widgets/touchable_opacity.dart';
import 'package:nowly/features/linked_accounts/linked_accounts_provider.dart';

/// Settings tile representing a single social login provider.
///
/// Shows the linked email when [LinkedAccount.isLinked] is `true`, or a
/// "not linked" label otherwise. Tapping opens a confirmation dialog and
/// triggers link/unlink via [linkedAccountsProvider].
///
/// While [busy] is `true`, a spinner replaces the trailing chevron.
/// When [anyBusy] is `true`, the tile is inert to avoid starting a second
/// concurrent link/unlink operation.
///
/// ```dart
/// LinkedAccountTile(
///   account: account,
///   busy: state.isBusy(account.provider),
///   anyBusy: state.busyProvider != null,
/// )
/// ```
class LinkedAccountTile extends ConsumerWidget {
  const LinkedAccountTile({
    super.key,
    required this.account,
    required this.busy,
    required this.anyBusy,
  });

  /// The provider entry (provider + linked email) rendered by this tile.
  final LinkedAccount account;

  /// When `true`, this tile is performing a link/unlink and shows a spinner.
  final bool busy;

  /// When `true`, some tile (possibly another one) is busy. Disables interaction
  /// to prevent overlapping operations.
  final bool anyBusy;
  
  Image _imageFor(LinkedProvider p) => switch (p) {
        LinkedProvider.google => Image.asset('assets/images/social/google.png', width: 40, height: 40),
      };

  String _labelFor(BuildContext context, LinkedProvider p) => switch (p) {
        LinkedProvider.google => "Google",
      };

  Future<void> _onTap(BuildContext context, WidgetRef ref) async {
    if (anyBusy) return;
    final notifier = ref.read(linkedAccountsProvider.notifier);
    final l10n = context.l10n;

    if (account.isLinked) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AppDialog(
          icon: Ionicons.unlink_outline,
          color: context.colorScheme.error,
          onColor: context.colorScheme.onError,
          title: l10n.linkedAccountsUnlink,
          subtitle: l10n.linkedAccountsUnlinkConfirm,
          buttonText: l10n.linkedAccountsUnlink,
          onPressed: () => Navigator.of(ctx).pop(true),
          cancelText: l10n.dialogBack,
          onCancel: () => Navigator.of(ctx).pop(false),
        ),
      );
      if (confirmed == true) await notifier.unlink(account.provider, l10n);
    } else {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AppDialog(
          icon: Ionicons.link_outline,
          color: ref.usePrimaryColor('green'),
          title: l10n.linkedAccountsLink,
          subtitle: l10n.linkedAccountsLinkConfirm,
          buttonText: l10n.linkedAccountsLink,
          onPressed: () => Navigator.of(ctx).pop(true),
          cancelText: l10n.dialogBack,
          onCancel: () => Navigator.of(ctx).pop(false),
        ),
      );
      if (confirmed == true) await notifier.link(account.provider, l10n);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        _imageFor(account.provider),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                account.email ?? context.l10n.linkedAccountsNotLinked,
                style: context.textTheme.headlineSmall,
                textAlign: TextAlign.start,
              ),
              Text(
                _labelFor(context, account.provider),
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant
                ),
                textAlign: TextAlign.start,
              ),
              
            ],
          ),
        ),
        if (busy)
          SizedBox(
            width: 18,
            height: 18,
            child: AppLoading(
              color: context.colorScheme.onSurfaceVariant,
              size: 18,
            ),
          )
        else
          TouchableOpacity(
            onTap: anyBusy ? null : () => _onTap(context, ref),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 0, 4),
              child: account.isLinked
                  ? Icon(
                      Ionicons.close,
                      size: 20,
                      color: context.colorScheme.error,
                    )
                  : Text(
                      "Vincular",
                      style: context.textTheme.labelMedium?.copyWith(
                        color: context.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
      ],
    );
  }
}
