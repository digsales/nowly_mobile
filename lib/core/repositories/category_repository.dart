import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowly/core/models/category.dart';
import 'package:nowly/l10n/app_localizations.dart';

class CategoryRepository {
  CategoryRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _categories =>
      _firestore.collection('categories');

  Future<void> createCategory(Category category) async {
    try {
      await _categories.doc(category.id).set(category.toJson());
    } on FirebaseException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await _categories.doc(category.id).update(category.toJson());
    } on FirebaseException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _categories.doc(categoryId).delete();
    } on FirebaseException catch (e) {
      throw Exception(e.message);
    }
  }

  Stream<List<Category>> watchCategories(String userId) {
    return _categories
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Category.fromJson(doc.id, doc.data()))
            .toList());
  }

  Future<void> seedDefaultCategories(String userId, AppLocalizations l10n) async {
    final defaults = [
      _DefaultCategory(l10n.categoryStudy, 'blue', 'book_outline'),
      _DefaultCategory(l10n.categoryWork, 'red', 'briefcase_outline'),
      _DefaultCategory(l10n.categoryHealth, 'green', 'heart_outline'),
      _DefaultCategory(l10n.categoryPersonal, 'purple', 'person_outline'),
      _DefaultCategory(l10n.categoryHome, 'orange', 'home_outline'),
      _DefaultCategory(l10n.categorySocial, 'pink', 'people_outline'),
    ];

    final batch = _firestore.batch();

    for (final data in defaults) {
      final doc = _categories.doc();
      batch.set(doc, {
        'userId': userId,
        'name': data.name,
        'colorKey': data.colorKey,
        'iconName': data.iconName,
      });
    }

    try {
      await batch.commit();
    } on FirebaseException catch (e) {
      throw Exception(e.message);
    }
  }
}

class _DefaultCategory {
  const _DefaultCategory(this.name, this.colorKey, this.iconName);
  final String name;
  final String colorKey;
  final String iconName;
}

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (_) => CategoryRepository(FirebaseFirestore.instance),
);
