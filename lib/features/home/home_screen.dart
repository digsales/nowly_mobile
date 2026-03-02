import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/services/auth_service_provider.dart';
import 'package:nowly/core/widgets/app_button.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Início")),
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
