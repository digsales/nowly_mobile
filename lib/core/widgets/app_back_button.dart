import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/widgets/touchable_opacity.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TouchableOpacity(
      onTap: () => context.pop(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.arrow_back_ios_new,
            size: 16,
            color: context.colorScheme.onPrimary,
          ),
          const SizedBox(width: 6),
          Text(
            "Voltar",
            style: context.textTheme.labelLarge?.copyWith(
              color: context.colorScheme.onPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}