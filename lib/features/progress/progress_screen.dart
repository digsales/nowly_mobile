import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/widgets/app_layout.dart';
import 'package:nowly/core/widgets/app_title.dart';
import 'package:nowly/features/progress/progress_provider.dart';
import 'package:nowly/features/progress/widgets/task_history.dart';
import 'package:nowly/features/progress/widgets/task_pie_chart.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppLayout(
      headerText: context.l10n.progress,
      onScrollNearEnd: () => ref.read(historyProvider.notifier).loadMore(),
      body: Column(
        children: [
          AppTitle(
            title: context.l10n.progressSectionStatistics,
            onRefresh: () async {
              ref.invalidate(filteredTaskStatsProvider);
              await ref.read(filteredTaskStatsProvider.future);
            },
            helpText: context.l10n.progressStatisticsHelpText,
          ),
          const SizedBox(height: 32),
          const TaskPieChart(),
          const SizedBox(height: 48),
          AppTitle(
            title: context.l10n.progressSectionHistory,
            onRefresh: () async {
              ref.invalidate(historyProvider);
              await ref.read(historyProvider.future);
            },
            helpText: context.l10n.progressHistoryHelpText,
          ),
          const SizedBox(height: 32),
          const TaskHistory(),
        ]
      ),
    );
  }
}
