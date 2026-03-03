import 'dart:ui';

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

  Future<void> seedDefaultCategories(String userId, AppLocalizations l10n) async {
    final defaults = [
      _DefaultCategory(l10n.categoryStudy,    const Color(0xFF5C8DFF), 'book_outline'),
      _DefaultCategory(l10n.categoryWork,     const Color(0xFFE05A5A), 'briefcase_outline'),
      _DefaultCategory(l10n.categoryHealth,   const Color(0xFF4CAF7D), 'heart_outline'),
      _DefaultCategory(l10n.categoryPersonal, const Color(0xFF9C6ADE), 'person_outline'),
      _DefaultCategory(l10n.categoryHome,     const Color(0xFFFFB74D), 'home_outline'),
      _DefaultCategory(l10n.categorySocial,   const Color(0xFF4DD0C8), 'people_outline'),
    ];

    final batch = _firestore.batch();

    for (final data in defaults) {
      final doc = _categories.doc();
      batch.set(doc, {
        'userId': userId,
        'name': data.name,
        'color': data.color.toARGB32(),
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
  const _DefaultCategory(this.name, this.color, this.iconName);
  final String name;
  final Color color;
  final String iconName;
}

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (_) => CategoryRepository(FirebaseFirestore.instance),
);
