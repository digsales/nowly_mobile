import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/services/auth_service_provider.dart';
import 'package:nowly/core/widgets/app_button.dart';
import 'package:nowly/core/widgets/app_layout.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);

    return AppLayout(
      headerText: context.l10n.profile,
      body: Center(
        child: AppButton(
          text: "Sair do app",
          detailColor: context.colorScheme.error,
          textColor: context.colorScheme.onError,
          onPressed: () async {
            await authService.signout();
          },
        ),
      ),
    );
  }
}
