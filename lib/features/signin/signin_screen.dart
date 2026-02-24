import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monno_money/core/extensions/context_extensions.dart';
import 'package:monno_money/core/widgets/app_button.dart';
import 'package:monno_money/core/widgets/app_text_field.dart';
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox.shrink(),
                _loginForm(context, ref),
                const SizedBox.shrink(),
                const SizedBox.shrink(),
                _footer(context),
              ],
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
          label: 'E-mail',
          hintText: 'Digite seu e-mail',
          prefixIcon: Icons.person_outline,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: controller.passwordController,
          label: 'Senha',
          hintText: 'Digite sua senha',
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
          child: Text(
            'Esqueceu a senha?',
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 24),
        AppButton(
          text: 'Entrar',
          onPressed: controller.isLoading ? null : controller.signin,
        ),
      ],
    );
  }

  Widget _introductionText(BuildContext context) {
    return Text(
      "Olá\nEntre em sua conta",
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
          Text.rich(
            textAlign: TextAlign.end,
            TextSpan(
              text: "Não tem uma conta?\n",
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              children: [
                TextSpan(
                  text: "Cadastre-se",
                  style: context.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
