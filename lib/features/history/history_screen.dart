import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/widgets/app_layout.dart';
import 'package:nowly/core/widgets/app_title.dart';
import 'package:nowly/features/history/history_provider.dart';
import 'package:nowly/features/history/widgtes/task_history.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppLayout(
      headerText: context.l10n.history,
      onScrollNearEnd: () => ref.read(historyProvider.notifier).loadMore(),
      body: Column(
        children: [
          AppTitle(
            title: "Tarefas",
            onRefresh: () async {
              ref.invalidate(historyProvider);
              await ref.read(historyProvider.future);
            },
            helpText: context.l10n.historyTasksHelpText,
          ),
          const SizedBox(height: 32),
          const TaskHistory(),
        ]
      ),
    );
  }
}
