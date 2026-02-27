import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
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
            Ionicons.chevron_back_outline,
            size: context.textTheme.labelLarge!.fontSize!,
            color: context.colorScheme.onPrimary,
          ),
          const SizedBox(width: 4),
          Text(
            "Voltar",
            style: context.textTheme.labelLarge?.copyWith(
              color: context.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}