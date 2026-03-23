import 'package:flutter/material.dart';
import 'package:nowly/core/extensions/context_extensions.dart';

class AppDivider extends StatelessWidget {
  const AppDivider({
    super.key,
    this.text,
  });

  final String? text;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Divider(
                  height: 32,
                  color: context.colorScheme.outlineVariant,
                ),
            ),
            if (text != null) ...[
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth * 0.6,
                ),
                child: Text(
                  text!,
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Divider(
                  height: 32,
                  color: context.colorScheme.outlineVariant,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}