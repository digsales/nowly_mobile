import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowly/core/models/category.dart';
import 'package:nowly/core/repositories/category_repository.dart';
import 'package:nowly/core/services/auth_service_provider.dart';
import 'package:nowly/core/validators/field_controller.dart';
import 'package:nowly/core/validators/validators.dart';
import 'package:nowly/l10n/app_localizations.dart';

final categoryFormProvider =
    NotifierProvider.autoDispose<CategoryFormNotifier, CategoryFormState>(
        CategoryFormNotifier.new);

class CategoryFormState {
  const CategoryFormState({
    this.selectedColorKey = 'purple',
    this.selectedIconName = 'book_outline',
    this.isLoading = false,
    this.errorMessage,
  });

  final String selectedColorKey;
  final String selectedIconName;
  final bool isLoading;
  final String? errorMessage;

  CategoryFormState copyWith({
    String? selectedColorKey,
    String? selectedIconName,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CategoryFormState(
      selectedColorKey: selectedColorKey ?? this.selectedColorKey,
      selectedIconName: selectedIconName ?? this.selectedIconName,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class CategoryFormNotifier extends Notifier<CategoryFormState> {
  late final CategoryRepository _categoryRepository;
  final name = FieldController();

  @override
  CategoryFormState build() {
    _categoryRepository = ref.read(categoryRepositoryProvider);
    ref.onDispose(() => name.dispose());
    return const CategoryFormState();
  }

  void init(Category? category) {
    if (category != null) {
      name.controller.text = category.name;
      state = state.copyWith(
        selectedColorKey: category.colorKey,
        selectedIconName: category.iconName,
      );
    }
  }

  void selectColor(String colorKey) {
    state = state.copyWith(selectedColorKey: colorKey);
  }

  void selectIcon(String iconName) {
    state = state.copyWith(selectedIconName: iconName);
  }

  void onNameChanged(String value) {
    name.onChanged(value);
    state = state.copyWith();
  }

  Future<bool> save(AppLocalizations l10n, {Category? existing}) async {
    name.validator = Validators.combine([
      Validators.required(l10n.validatorRequired),
      Validators.minLength(2, l10n.validatorMinLength(2)),
    ]);

    if (!name.validate()) {
      state = state.copyWith();
      return false;
    }

    state = state.copyWith(isLoading: true);

    try {
      if (existing != null) {
        final updated = existing.copyWith(
          name: name.text,
          colorKey: state.selectedColorKey,
          iconName: state.selectedIconName,
        );
        await _categoryRepository.updateCategory(updated);
      } else {
        final uid = ref.read(authServiceProvider).currentUser?.uid;
        if (uid == null) return false;

        final category = Category(
          id: '',
          userId: uid,
          name: name.text,
          colorKey: state.selectedColorKey,
          iconName: state.selectedIconName,
        );
        await _categoryRepository.createCategory(category);
      }
      state = state.copyWith(isLoading: false);
      return true;
    } on Exception catch (e) {
      debugPrint('Category save error: $e');
      state = state.copyWith(isLoading: false, errorMessage: l10n.authErrorUnknown);
      return false;
    }
  }

  Future<bool> delete(Category category) async {
    state = state.copyWith(isLoading: true);
    try {
      await _categoryRepository.deleteCategory(category.id);
      return true;
    } on Exception catch (e) {
      debugPrint('Category delete error: $e');
      state = state.copyWith(isLoading: false);
      return false;
    }
  }
}
