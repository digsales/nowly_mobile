import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowly/core/models/task.dart';

const defaultTaskPoints = 5;

class TaskRepository {
  TaskRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _tasks =>
      _firestore.collection('tasks');

  DocumentReference<Map<String, dynamic>> _userDoc(String userId) =>
      _firestore.collection('users').doc(userId);

  Stream<List<Task>> watchPendingTasks(String userId) {
    return _tasks
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Task.fromJson(doc.id, doc.data()))
            .toList());
  }

  Future<void> createTask(Task task) async {
    try {
      final doc = task.id.isEmpty ? _tasks.doc() : _tasks.doc(task.id);
      await doc.set(task.toJson());
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
      if (data.isEmpty) return;

      await _tasks.doc(taskId).update(data);
    } on FirebaseException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> completeTask(Task task) async {
    try {
      final batch = _firestore.batch();
      batch.update(_tasks.doc(task.id), {
        'status': 'completed',
        'completedAt': DateTime.now().toIso8601String(),
      });
      batch.update(_userDoc(task.userId), {
        'totalCompleted': FieldValue.increment(1),
        'totalPoints': FieldValue.increment(task.pointsEarned),
      });
      await batch.commit();
    } on FirebaseException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> cancelTask(Task task) async {
    try {
      await _firestore.runTransaction((tx) async {
        final userSnap = await tx.get(_userDoc(task.userId));
        final currentPoints = userSnap.data()?['totalPoints'] as int? ?? 0;

        tx.update(_tasks.doc(task.id), {'status': 'cancelled'});
        tx.update(_userDoc(task.userId), {
          'totalCanceled': FieldValue.increment(1),
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
      batch.update(_tasks.doc(task.id), {'status': 'pending'});
      batch.update(_userDoc(task.userId), {
        'totalCanceled': FieldValue.increment(-1),
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
