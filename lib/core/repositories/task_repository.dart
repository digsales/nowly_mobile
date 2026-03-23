import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowly/core/models/subtask.dart';
import 'package:nowly/core/models/task.dart';

const defaultTaskPoints = 5;
const subtaskPoints = 2;

class TaskRepository {
  TaskRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _tasks =>
      _firestore.collection('tasks');

  DocumentReference<Map<String, dynamic>> _userDoc(String userId) =>
      _firestore.collection('users').doc(userId);

  CollectionReference<Map<String, dynamic>> _subtasks(String taskId) =>
      _tasks.doc(taskId).collection('subtasks');

  Stream<List<Task>> watchPendingTasks(String userId) {
    return _tasks
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Task.fromJson(doc.id, doc.data()))
            .toList());
  }

  Future<String> createTask(Task task) async {
    try {
      final doc = task.id.isEmpty ? _tasks.doc() : _tasks.doc(task.id);
      await doc.set(task.toJson());
      return doc.id;
    } on FirebaseException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> updateTask(String taskId, {
    String? categoryId,
    bool clearCategory = false,
    String? title,
    String? description,
    bool clearDescription = false,
    int? pointsEarned,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (clearCategory) {
        data['categoryId'] = null;
      } else if (categoryId != null) {
        data['categoryId'] = categoryId;
      }
      if (title != null) data['title'] = title;
      if (clearDescription) {
        data['description'] = null;
      } else if (description != null) {
        data['description'] = description;
      }
      if (pointsEarned != null) data['pointsEarned'] = pointsEarned;
      if (data.isEmpty) return;

      await _tasks.doc(taskId).update(data);
    } on FirebaseException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> completeTask(Task task) async {
    try {
      await _firestore.runTransaction((tx) async {
        final userSnap = await tx.get(_userDoc(task.userId));
        final data = userSnap.data();

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final lastStreakRaw = data?['lastStreakDate'] as String?;
        final lastStreakDate = lastStreakRaw != null ? DateTime.parse(lastStreakRaw) : null;
        final lastStreakDay = lastStreakDate != null
            ? DateTime(lastStreakDate.year, lastStreakDate.month, lastStreakDate.day)
            : null;

        final currentStreak = data?['currentStreak'] as int? ?? 0;

        final Map<String, dynamic> streakUpdate;
        if (lastStreakDay == today) {
          // Already completed today — don't change streak
          streakUpdate = {};
        } else if (lastStreakDay == today.subtract(const Duration(days: 1))) {
          // Completed yesterday — increment streak
          streakUpdate = {
            'currentStreak': currentStreak + 1,
            'lastStreakDate': today.toIso8601String(),
          };
        } else {
          // First time or streak broken — reset to 1
          streakUpdate = {
            'currentStreak': 1,
            'lastStreakDate': today.toIso8601String(),
          };
        }

        tx.update(_tasks.doc(task.id), {
          'status': 'completed',
          'completedAt': now.toIso8601String(),
        });
        tx.update(_userDoc(task.userId), {
          'totalCompleted': FieldValue.increment(1),
          'totalPoints': FieldValue.increment(task.pointsEarned),
          ...streakUpdate,
        });
      });
    } on FirebaseException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> cancelTask(Task task) async {
    try {
      await _firestore.runTransaction((tx) async {
        final userSnap = await tx.get(_userDoc(task.userId));
        final currentPoints = userSnap.data()?['totalPoints'] as int? ?? 0;

        tx.update(_tasks.doc(task.id), {
          'status': 'cancelled',
          'cancelledAt': DateTime.now().toIso8601String(),
        });
        tx.update(_userDoc(task.userId), {
          'totalCancelled': FieldValue.increment(1),
          'totalPoints': max(0, currentPoints - 1),
        });
      });
    } on FirebaseException catch (e) {
      throw Exception(e.message);
    }
  }

  /// Only allowed if [Task.endDate] has not passed yet.
  Future<void> uncancelTask(Task task) async {
    if (task.endDate.isBefore(DateTime.now())) {
      throw Exception('Cannot uncancel a task whose deadline has passed.');
    }

    try {
      final batch = _firestore.batch();
      batch.update(_tasks.doc(task.id), {
        'status': 'pending',
        'cancelledAt': null,
      });
      batch.update(_userDoc(task.userId), {
        'totalCancelled': FieldValue.increment(-1),
        'totalPoints': FieldValue.increment(1),
      });
      await batch.commit();
    } on FirebaseException catch (e) {
      throw Exception(e.message);
    }
  }

  /// Only allowed within 30 minutes of creation.
  Future<void> deleteTask(Task task) async {
    final elapsed = DateTime.now().difference(task.createdAt);
    if (elapsed.inMinutes >= 30) {
      throw Exception('Task can only be deleted within 30 minutes of creation.');
    }

    try {
      await _tasks.doc(task.id).delete();
    } on FirebaseException catch (e) {
      throw Exception(e.message);
    }
  }

  // ─── Stats by period ────────────────────────────────────────────────────────

  Future<({int completed, int cancelled, int expired})> fetchStatsByPeriod({
    required String userId,
    required DateTime from,
  }) async {
    final snapshot = await _tasks
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: ['completed', 'cancelled', 'expired'])
        .where('createdAt', isGreaterThan: from.toIso8601String())
        .get();

    var completed = 0;
    var cancelled = 0;
    var expired = 0;

    for (final doc in snapshot.docs) {
      final status = doc.data()['status'] as String;
      switch (status) {
        case 'completed':
          completed++;
        case 'cancelled':
          cancelled++;
        case 'expired':
          expired++;
      }
    }

    return (completed: completed, cancelled: cancelled, expired: expired);
  }

  // ─── History (paginated) ────────────────────────────────────────────────────

  Future<QuerySnapshot<Map<String, dynamic>>> fetchHistoryPage({
    required String userId,
    required int limit,
    String? statusFilter,
    DocumentSnapshot? startAfter,
  }) {
    final statuses = statusFilter != null
        ? [statusFilter]
        : ['completed', 'cancelled', 'expired'];

    Query<Map<String, dynamic>> query = _tasks
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: statuses)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.get();
  }

  // ─── Subtasks ────────────────────────────────────────────────────────────────

  Stream<List<Subtask>> watchSubtasks(String taskId) {
    return _subtasks(taskId)
        .orderBy('order')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Subtask.fromJson(doc.id, doc.data())).toList());
  }

  Future<void> addSubtask(String taskId, Subtask subtask, {int? order}) async {
    final data = order != null ? subtask.copyWith(order: order).toJson() : subtask.toJson();
    await _subtasks(taskId).add(data);
  }

  Future<void> removeSubtask(String taskId, String subtaskId) async {
    await _subtasks(taskId).doc(subtaskId).delete();
  }

  Future<void> toggleSubtask(String taskId, String subtaskId, bool isDone) async {
    await _subtasks(taskId).doc(subtaskId).update({'isDone': isDone});
  }

  Future<void> addSubtasks(String taskId, List<Subtask> subtasks, {int startOrder = 0}) async {
    final batch = _firestore.batch();
    for (var i = 0; i < subtasks.length; i++) {
      final data = subtasks[i].copyWith(order: startOrder + i).toJson();
      batch.set(_subtasks(taskId).doc(), data);
    }
    await batch.commit();
  }

  Future<void> reorderSubtasks(String taskId, List<Subtask> subtasks) async {
    final batch = _firestore.batch();
    for (var i = 0; i < subtasks.length; i++) {
      batch.update(_subtasks(taskId).doc(subtasks[i].id), {'order': i});
    }
    await batch.commit();
  }

  Future<void> markAsExpired(List<String> taskIds, {required String userId}) async {
    if (taskIds.isEmpty) return;

    final penalty = taskIds.length * 3;

    await _firestore.runTransaction((tx) async {
      final userSnap = await tx.get(_userDoc(userId));
      final currentPoints = userSnap.data()?['totalPoints'] as int? ?? 0;

      for (final id in taskIds) {
        tx.update(_tasks.doc(id), {'status': 'expired'});
      }
      tx.update(_userDoc(userId), {
        'totalExpired': FieldValue.increment(taskIds.length),
        'totalPoints': max(0, currentPoints - penalty),
      });
    });
  }
}

final taskRepositoryProvider = Provider<TaskRepository>(
  (_) => TaskRepository(FirebaseFirestore.instance),
);
