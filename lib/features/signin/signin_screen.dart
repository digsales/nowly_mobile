import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monno_money/core/extensions/context_extensions.dart';
import 'package:monno_money/core/widgets/app_button.dart';
import 'package:monno_money/core/widgets/app_text_field.dart';
import 'package:monno_money/core/widgets/touchable_opacity.dart';
import 'package:monno_money/features/signin/signin_provider.dart';
import 'package:sizer/sizer.dart';

class SigninPage extends ConsumerWidget {
  const SigninPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Device.orientation == Orientation.portrait
              ? _buildPortrait(context, ref)
              : _buildLandscape(context, ref);
        },
      ),
    );
  }

  Widget _buildPortrait(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: context.paddingScreen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              _introductionText(context),
              SizedBox(height: 60 - context.paddingBottom),
            ],
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
              ),
            ),
            padding: context.paddingScreen,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox.shrink(),
                        _loginForm(context, ref),
                        const SizedBox.shrink(),
                        const SizedBox(height: 32),
                        _footer(context),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscape(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox.shrink(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        _introductionText(context),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ],
                ),
                _footer(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _loginForm(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(signinProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        AppTextField(
          controller: controller.emailController,
          label: context.l10n.textFieldLabelEmail,
          hintText: context.l10n.textFieldHintEmail,
          prefixIcon: Icons.person_outline,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: controller.passwordController,
          label: context.l10n.textFieldLabelPassword,
          hintText: context.l10n.textFieldHintPassword,
          prefixIcon: Icons.lock_outline,
          obscureText: controller.obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              controller.obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: context.colorScheme.onSurfaceVariant,
            ),
            onPressed: controller.toggleObscurePassword,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TouchableOpacity(
            onTap: () {
              // TODO: navegar para tela de recuperação de senha
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
          onPressed: controller.signin,
          isProcessing: controller.isLoading,
        ),
      ],
    );
  }

  Widget _introductionText(BuildContext context) {
    return Text(
      context.l10n.signinGreeting,
      style: context.textTheme.displayMedium?.copyWith(
        fontWeight: FontWeight.w500,
        color: context.isDark
            ? context.colorScheme.onSurface
            : context.colorScheme.surface,
      ),
    );
  }

  Widget _footer(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        children: [
          TouchableOpacity(
            onTap: () {
              // TODO: navegar para tela de cadastro
            },
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
