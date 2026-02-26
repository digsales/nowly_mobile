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
import 'package:nowly/features/signup/signup_provider.dart';

class SignupPage extends ConsumerWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(signupProvider, (prev, next) {
      if (next.errorMessage != null && next.errorMessage != prev?.errorMessage) {
        AppSnackBar.show(context, next.errorMessage!);
      }
    });
    return AuthLayout(
      header: Text(
        context.l10n.signupGreeting,
        style: context.textTheme.displayMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: context.colorScheme.onPrimary,
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox.shrink(),
          _signupForm(context, ref),
          const SizedBox.shrink(),
          const SizedBox(height: 32),
          _footer(context),
        ],
      ),
    );
  }

  Widget _signupForm(BuildContext context, WidgetRef ref) {
    final state = ref.watch(signupProvider);
    final notifier = ref.read(signupProvider.notifier);
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        AppTextField(
          controller: notifier.name.controller,
          label: l10n.textFieldLabelName,
          hintText: l10n.textFieldHintName,
          prefixIcon: Icons.person_outline,
          textCapitalization: TextCapitalization.words,
          errorText: notifier.name.error,
          onChanged: notifier.onNameChanged,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: notifier.email.controller,
          label: l10n.textFieldLabelEmail,
          hintText: l10n.textFieldHintEmail,
          prefixIcon: Icons.email_outlined,
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
        const SizedBox(height: 16),
        AppTextField(
          controller: notifier.confirmPassword.controller,
          label: l10n.textFieldLabelPasswordConfirm,
          hintText: l10n.textFieldHintPasswordConfirm,
          prefixIcon: Icons.lock_outline,
          isPassword: true,
          errorText: notifier.confirmPassword.error,
          onChanged: notifier.onConfirmPasswordChanged,
        ),
        const SizedBox(height: 24),
        AppButton(
          text: l10n.signupButton,
          onPressed: () => notifier.signup(l10n),
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
            onTap: () => context.pushReplacement(AppRoutes.signin),
            child: Text.rich(
              textAlign: TextAlign.end,
              TextSpan(
                text: context.l10n.signupHasAccount,
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
                children: [
                  TextSpan(
                    text: context.l10n.signupSignin,
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
