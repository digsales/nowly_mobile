import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/router/app_router.dart';
import 'package:nowly/core/widgets/app_button.dart';
import 'package:nowly/core/widgets/app_snack_bar.dart';
import 'package:nowly/core/widgets/app_text_field.dart';
import 'package:nowly/core/widgets/auth_layout.dart';
import 'package:nowly/core/widgets/touchable_opacity.dart';
import 'package:nowly/features/forgot_password/forgot_password_provider.dart';

class ForgotPasswordPage extends ConsumerWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(forgotPasswordProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        AppSnackBar.show(context, next.errorMessage!);
      }
      if (next.successMessage != null &&
          next.successMessage != prev?.successMessage) {
        AppSnackBar.show(
          context,
          next.successMessage!,
          type: SnackBarType.success,
        );
      }
    });

    return AuthLayout(
      headerText: context.l10n.forgotPasswordGreeting,
      showBackButton: true,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox.shrink(),
          _form(context, ref),
          const SizedBox.shrink(),
          const SizedBox(height: 32),
          _footer(context),
        ],
      ),
    );
  }

  Widget _form(BuildContext context, WidgetRef ref) {
    final state = ref.watch(forgotPasswordProvider);
    final notifier = ref.read(forgotPasswordProvider.notifier);
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        AppTextField(
          controller: notifier.email.controller,
          label: l10n.textFieldLabelEmail,
          hintText: l10n.textFieldHintEmail,
          prefixIcon: Ionicons.mail_outline,
          keyboardType: TextInputType.emailAddress,
          errorText: notifier.email.error,
          onChanged: notifier.onEmailChanged,
        ),
        const SizedBox(height: 24),
        AppButton(
          text: l10n.forgotPasswordButton,
          onPressed: () => notifier.sendResetEmail(l10n),
          isProcessing: state.isLoading,
        ),
      ],
    );
  }

  Widget _footer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TouchableOpacity(
            onTap: () => context.pushReplacement(AppRoutes.signin),
            child: Text.rich(
              TextSpan(
                text: context.l10n.forgotPasswordRemembered,
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
                children: [
                  TextSpan(
                    text: context.l10n.forgotPasswordSignin,
                    style: context.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          TouchableOpacity(
            onTap: () => context.pushReplacement(AppRoutes.signup),
            child: Text.rich(
              textAlign: TextAlign.end,
              TextSpan(
                text: context.l10n.forgotPasswordNoAccount,
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
                children: [
                  TextSpan(
                    text: context.l10n.forgotPasswordSignup,
                    style: context.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
