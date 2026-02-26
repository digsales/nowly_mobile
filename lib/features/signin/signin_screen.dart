import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/router/app_router.dart';
import 'package:nowly/core/widgets/app_button.dart';
import 'package:nowly/core/widgets/app_snack_bar.dart';
import 'package:nowly/core/widgets/app_text_field.dart';
import 'package:nowly/core/widgets/auth_layout.dart';
import 'package:nowly/core/widgets/touchable_opacity.dart';
import 'package:nowly/features/signin/signin_provider.dart';

class SigninPage extends ConsumerWidget {
  const SigninPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(signinProvider, (prev, next) {
      if (next.errorMessage != null && next.errorMessage != prev?.errorMessage) {
        AppSnackBar.show(context, next.errorMessage!);
      }
    });
    return AuthLayout(
      header: Text(
        context.l10n.signinGreeting,
        style: context.textTheme.displayMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: context.colorScheme.onPrimary,
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox.shrink(),
          _loginForm(context, ref),
          const SizedBox.shrink(),
          const SizedBox(height: 32),
          _footer(context),
        ],
      ),
    );
  }

  Widget _loginForm(BuildContext context, WidgetRef ref) {
    final state = ref.watch(signinProvider);
    final notifier = ref.read(signinProvider.notifier);
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        AppTextField(
          controller: notifier.email.controller,
          label: l10n.textFieldLabelEmail,
          hintText: l10n.textFieldHintEmail,
          prefixIcon: Icons.person_outline,
          keyboardType: TextInputType.emailAddress,
          errorText: notifier.email.error,
          onChanged: notifier.onEmailChanged,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: notifier.password.controller,
          label: l10n.textFieldLabelPassword,
          hintText: l10n.textFieldHintPassword,
          prefixIcon: Icons.lock_outline,
          isPassword: true,
          errorText: notifier.password.error,
          onChanged: notifier.onPasswordChanged,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TouchableOpacity(
            onTap: () {
              // TODO: context.push(AppRoutes.forgotPassword);
            },
            child: Text(
              context.l10n.signinForgotPassword,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        AppButton(
          text: context.l10n.signinButton,
          onPressed: () => notifier.signin(l10n),
          isProcessing: state.isLoading,
        ),
      ],
    );
  }

  Widget _footer(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        children: [
          TouchableOpacity(
            onTap: () => context.pushReplacement(AppRoutes.signup),
            child: Text.rich(
              textAlign: TextAlign.end,
              TextSpan(
                text: context.l10n.signinNoAccount,
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
                children: [
                  TextSpan(
                    text: context.l10n.signinRegister,
                    style: context.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
