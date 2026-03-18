import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/models/category.dart';
import 'package:nowly/core/repositories/category_repository.dart';
import 'package:nowly/core/services/auth_service_provider.dart';
import 'package:nowly/core/widgets/app_dialog.dart';

class DeleteCategoryDialog extends ConsumerStatefulWidget {
  const DeleteCategoryDialog({super.key, required this.category});

  final Category category;

  @override
  ConsumerState<DeleteCategoryDialog> createState() =>
      _DeleteCategoryDialogState();
}

class _DeleteCategoryDialogState extends ConsumerState<DeleteCategoryDialog> {
  bool _isProcessing = false;

  Future<void> _delete() async {
    setState(() => _isProcessing = true);
    try {
      final uid = ref.read(authServiceProvider).currentUser!.uid;
      await ref.read(categoryRepositoryProvider).deleteCategory(
            widget.category.id,
            userId: uid,
          );
      if (mounted) Navigator.of(context).pop(true);
    } on Exception {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      icon: Ionicons.trash_outline,
      color: context.colorScheme.error,
      onColor: context.colorScheme.onError,
      title: context.l10n.categoryFormDelete,
      subtitle: context.l10n.categoryFormDeleteMessage,
      buttonText: context.l10n.categoryFormDelete,
      isProcessing: _isProcessing,
      onPressed: _delete,
      cancelText: context.l10n.dialogBack,
      onCancel: () => Navigator.of(context).pop(false),
    );
  }
}
