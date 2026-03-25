import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowly/core/models/category.dart';
import 'package:nowly/core/models/subtask.dart';
import 'package:nowly/core/models/task.dart';
import 'package:nowly/core/repositories/category_repository.dart';
import 'package:nowly/core/repositories/task_repository.dart';
import 'package:nowly/core/services/auth_service_provider.dart';

final categoriesProvider = StreamProvider<List<Category>>((ref) {
  final authService = ref.watch(authServiceProvider);
  final uid = authService.currentUser?.uid;
  if (uid == null) return Stream.value([]);

  final repo = ref.watch(categoryRepositoryProvider);
  return repo.watchCategories(uid).map((list) {
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  });
});

final pendingTasksProvider = StreamProvider<List<Task>>((ref) {
  final authService = ref.watch(authServiceProvider);
  final uid = authService.currentUser?.uid;
  if (uid == null) return Stream.value([]);

  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchPendingTasks(uid).map((list) {
    final now = DateTime.now();
    final expired = list.where((t) => t.endDate.isBefore(now)).toList();

    if (expired.isNotEmpty) {
      repo.markAsExpired(expired, userId: uid);
    }

    final pending = list.where((t) => !t.endDate.isBefore(now)).toList()
      ..sort((a, b) => a.endDate.compareTo(b.endDate));

    return pending;
  });
});

final subtasksProvider = StreamProvider.family<List<Subtask>, String>((ref, taskId) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchSubtasks(taskId);
});
