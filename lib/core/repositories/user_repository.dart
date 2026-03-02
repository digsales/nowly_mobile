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

  Future<User?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return User.fromJson(doc.id, doc.data()!);
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
