import 'package:flutter/material.dart';
import 'package:monno_money/core/extensions/context_extensions.dart';
import 'package:sizer/sizer.dart';

class SigninPage extends StatelessWidget {
  const SigninPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Device.orientation == Orientation.portrait ? _buildPortrait(context) : _buildLandscape(context);
        },
      ),
    );
  }

  Widget _buildPortrait(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: context.paddingScreen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              _introductionText(context),
              SizedBox(height: 32 - context.paddingBottom),
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
                const SizedBox.shrink(),
                _footer(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscape(BuildContext context) {
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

  Widget _introductionText(BuildContext context) {
    return Text(
      "Olá\nEntre em sua conta",
      style: context.textTheme.displayMedium?.copyWith(
        fontWeight: FontWeight.w500,
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
