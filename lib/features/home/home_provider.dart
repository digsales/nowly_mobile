import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowly/core/models/category.dart';
import 'package:nowly/core/repositories/category_repository.dart';
import 'package:nowly/core/services/auth_service_provider.dart';

final categoriesProvider = StreamProvider.autoDispose<List<Category>>((ref) {
  final authService = ref.watch(authServiceProvider);
  final uid = authService.currentUser?.uid;
  if (uid == null) return Stream.value([]);

  final repo = ref.watch(categoryRepositoryProvider);
  return repo.watchCategories(uid).map((list) {
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  });
});
