import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/widgets/app_layout.dart';
import 'package:nowly/core/widgets/app_title.dart';
import 'package:nowly/features/performance/performance_provider.dart';
import 'package:nowly/features/performance/widgets/task_pie_chart.dart';

class PerformanceScreen extends ConsumerWidget {
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppLayout(
      headerText: context.l10n.performance,
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
        ]
      ),
    );
  }
}
