import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowly/core/models/user.dart';

class UserRepository {
  UserRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<void> createUser(User user) async {
    try {
      await _users.doc(user.id).set(user.toJson());
    } on FirebaseException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _users.doc(uid).update(data);
    } on FirebaseException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<bool> emailExists(String email) async {
    final query = await _users.where('email', isEqualTo: email).limit(1).get();
    return query.docs.isNotEmpty;
  }

  Future<User?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return User.fromJson(doc.id, doc.data()!);
  }

  Future<void> deleteAllUserData(String uid) async {
    final batch = _firestore.batch();

    batch.delete(_users.doc(uid));

    final categories = await _firestore
        .collection('categories')
        .where('userId', isEqualTo: uid)
        .get();
    for (final doc in categories.docs) {
      batch.delete(doc.reference);
    }

    final tasks = await _firestore
        .collection('tasks')
        .where('userId', isEqualTo: uid)
        .get();
    for (final doc in tasks.docs) {
      batch.delete(doc.reference);
    }

    try {
      await batch.commit();
    } on FirebaseException catch (e) {
      throw Exception(e.message);
    }
  }

  Stream<User?> watchUser(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return User.fromJson(doc.id, doc.data()!);
    });
  }
}

final userRepositoryProvider = Provider<UserRepository>(
  (_) => UserRepository(FirebaseFirestore.instance),
);
