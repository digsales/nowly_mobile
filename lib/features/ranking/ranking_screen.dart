import 'package:flutter/material.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/widgets/app_layout.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppLayout(
        headerText: context.l10n.ranking,
        body: Center(child: Text(context.l10n.ranking)),
      ),
    );
  }
}
