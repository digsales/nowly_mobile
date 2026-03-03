import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/widgets/app_button.dart';
import 'package:nowly/core/widgets/app_layout.dart';
import 'package:nowly/core/widgets/app_loading.dart';
import 'package:nowly/features/profile/profile_provider.dart';
import 'package:nowly/features/profile/widgets/delete_account_dialog.dart';

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
              Text(
                value.name,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.email,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
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
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const DeleteAccountDialog(),
                ),
              ),
            ],
          ),
        AsyncError() => const SizedBox.shrink(),
        _ => const Center(child: AppLoading()),
      },
    );
  }
}
