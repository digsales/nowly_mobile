import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowly/core/models/task.dart';
import 'package:nowly/core/repositories/task_repository.dart';
import 'package:nowly/core/services/auth_service_provider.dart';

// ─── History ──────────────────────────────────────────────────────────────────

enum HistoryFilter { all, completed, cancelled, expired }

class HistoryFilterNotifier extends Notifier<HistoryFilter> {
  @override
  HistoryFilter build() => HistoryFilter.all;

  void set(HistoryFilter filter) => state = filter;
}

final historyFilterProvider =
    NotifierProvider<HistoryFilterNotifier, HistoryFilter>(
        HistoryFilterNotifier.new);

class HistoryState {
  const HistoryState({
    this.tasks = const [],
    this.lastDocument,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  final List<Task> tasks;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;
  final bool isLoadingMore;

  HistoryState copyWith({
    List<Task>? tasks,
    DocumentSnapshot? lastDocument,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return HistoryState(
      tasks: tasks ?? this.tasks,
      lastDocument: lastDocument ?? this.lastDocument,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class HistoryNotifier extends AsyncNotifier<HistoryState> {
  static const _pageSize = 16;

  @override
  Future<HistoryState> build() async {
    ref.watch(historyFilterProvider);
    ref.watch(authStateProvider);
    return _fetchPage();
  }

  Future<HistoryState> _fetchPage({DocumentSnapshot? startAfter}) async {
    final uid = ref.read(authStateProvider).asData?.value?.uid;
    if (uid == null) return const HistoryState(hasMore: false);

    final filter = ref.read(historyFilterProvider);
    final statusFilter = switch (filter) {
      HistoryFilter.all => null,
      HistoryFilter.completed => 'completed',
      HistoryFilter.cancelled => 'cancelled',
      HistoryFilter.expired => 'expired',
    };

    final snapshot = await ref.read(taskRepositoryProvider).fetchHistoryPage(
      userId: uid,
      limit: _pageSize,
      statusFilter: statusFilter,
      startAfter: startAfter,
    );

    final tasks = snapshot.docs
        .map((doc) => Task.fromJson(doc.id, doc.data()))
        .toList();

    return HistoryState(
      tasks: tasks,
      lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      hasMore: tasks.length >= _pageSize,
    );
  }

  Future<void> loadMore() async {
    final current = state.asData?.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final next = await _fetchPage(startAfter: current.lastDocument);
      state = AsyncData(HistoryState(
        tasks: [...current.tasks, ...next.tasks],
        lastDocument: next.lastDocument,
        hasMore: next.hasMore,
      ));
    } catch (e, st) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
      state = AsyncError(e, st);
    }
  }
}

final historyProvider =
    AsyncNotifierProvider<HistoryNotifier, HistoryState>(HistoryNotifier.new);

class TaskStats {
  final int completed;
  final int cancelled;
  final int expired;

  const TaskStats({
    required this.completed,
    required this.cancelled,
    required this.expired,
  });

  static const empty = TaskStats(completed: 0, cancelled: 0, expired: 0);

  int get total => completed + cancelled + expired;
  bool get isEmpty => total == 0;
}
