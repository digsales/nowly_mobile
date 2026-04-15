import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/widgets/app_layout.dart';
import 'package:nowly/core/widgets/app_snack_bar.dart';
import 'package:nowly/features/linked_accounts/linked_accounts_provider.dart';
import 'package:nowly/features/linked_accounts/widgets/linked_account_tile.dart';

class LinkedAccountsScreen extends ConsumerWidget {
  const LinkedAccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(linkedAccountsProvider);

    ref.listen(linkedAccountsProvider, (prev, next) {
      final msg = next.errorMessage;
      if (msg != null && msg != prev?.errorMessage) {
        AppSnackBar.show(context, msg, type: SnackBarType.error);
      }
    });

    return AppLayout(
      headerText: context.l10n.linkedAccountsTitle,
      headerHelpText: context.l10n.linkedAccountsHelpText,
      showBackButton: true,
      body: Column(
        children: [
          for (final account in state.accounts)
            LinkedAccountTile(
              account: account,
              busy: state.isBusy(account.provider),
              anyBusy: state.busyProvider != null,
            ),

          // TODO: Add Apple sign in configuration in Firebase.
          // LinkedAccountTile for Apple goes here once enabled.

          // TODO: Add Facebook sign in configuration in Firebase.
          // LinkedAccountTile for Facebook goes here once enabled.
        ],
      ),
    );
  }
}
