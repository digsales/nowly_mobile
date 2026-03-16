import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/models/category.dart' as models;
import 'package:nowly/core/theme/primary_colors.dart';
import 'package:nowly/core/utils/app_max_width.dart';
import 'package:nowly/core/widgets/app_button.dart';
import 'package:nowly/core/widgets/app_layout.dart';
import 'package:nowly/core/widgets/app_snack_bar.dart';
import 'package:nowly/core/widgets/app_text_field.dart';
import 'package:nowly/core/widgets/category_tile.dart';
import 'package:nowly/features/category/category_form_provider.dart';
import 'package:nowly/features/category/widgets/delete_category_dialog.dart';

class CategoryFormScreen extends ConsumerStatefulWidget {
  const CategoryFormScreen({super.key, this.category});

  final models.Category? category;

  @override
  ConsumerState<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends ConsumerState<CategoryFormScreen> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialized) {
        ref.read(categoryFormProvider.notifier).init(widget.category);
        _initialized = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(categoryFormProvider, (prev, next) {
      if (next.errorMessage != null && prev?.errorMessage != next.errorMessage) {
        AppSnackBar.show(context, next.errorMessage!, type: SnackBarType.error);
      }
    });

    final formState = ref.watch(categoryFormProvider);
    final notifier = ref.read(categoryFormProvider.notifier);
    final isEditing = widget.category != null;

    final previewCategory = models.Category(
      id: '',
      userId: '',
      name: notifier.name.text.isEmpty
          ? context.l10n.categoryFormName
          : notifier.name.text,
      colorKey: formState.selectedColorKey,
      iconName: formState.selectedIconName,
    );

    final previewColor = ref.usePrimaryColor(previewCategory.colorKey);

    return AppLayout(
      showBackButton: true,
      headerText: isEditing
          ? context.l10n.categoryFormTitleEdit
          : context.l10n.categoryFormTitleAdd,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 600;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPreview(previewCategory, previewColor),
              const SizedBox(height: 32),
              if (wide) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildNameField(notifier),
                          const SizedBox(height: 24),
                          _buildColorPicker(formState, notifier),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildIconPicker(formState, notifier),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                _buildNameField(notifier),
                const SizedBox(height: 24),
                _buildColorPicker(formState, notifier),
                const SizedBox(height: 24),
                _buildIconPicker(formState, notifier),
              ],
              const SizedBox(height: 32),
              Center(child: _buildActions(formState, notifier, isEditing)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPreview(models.Category category, Color color) {
    return Center(
      child: CategoryTile(
        icon: category.icon,
        label: category.name,
        backgroundColor: color,
        iconColor: context.colorScheme.onPrimary,
        size: 100,
      ),
    );
  }

  Widget _buildNameField(CategoryFormNotifier notifier) {
    return AppTextField(
      controller: notifier.name.controller,
      label: context.l10n.categoryFormName,
      hintText: context.l10n.categoryFormNameHint,
      prefixIcon: Ionicons.text_outline,
      textCapitalization: TextCapitalization.sentences,
      errorText: notifier.name.error,
      onChanged: notifier.onNameChanged,
    );
  }

  Widget _buildColorPicker(
    CategoryFormState formState,
    CategoryFormNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.categoryFormColor,
          style: context.textTheme.labelLarge?.copyWith(
            color: context.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: AppPrimaryColors.values.map((colors) {
            final isSelected = colors.key == formState.selectedColorKey;
            return GestureDetector(
              onTap: () => notifier.selectColor(colors.key),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: ref.usePrimaryColor(colors.key),
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(
                          color: context.colorScheme.onSurface,
                          width: 3,
                        )
                      : null,
                ),
                child: isSelected
                    ? Icon(
                        Ionicons.checkmark,
                        size: 20,
                        color: context.colorScheme.onSurface,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildIconPicker(
    CategoryFormState formState,
    CategoryFormNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.categoryFormIcon,
          style: context.textTheme.labelLarge?.copyWith(
            color: context.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: models.Category.iconMap.entries.map((entry) {
            final isSelected = entry.key == formState.selectedIconName;
            return GestureDetector(
              onTap: () => notifier.selectIcon(entry.key),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.colorScheme.primary
                      : context.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  entry.value,
                  size: 24,
                  color: isSelected
                      ? context.colorScheme.onPrimary
                      : context.colorScheme.onSurface,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActions(
    CategoryFormState formState,
    CategoryFormNotifier notifier,
    bool isEditing,
  ) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: appMaxWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            text: context.l10n.categoryFormSave,
            isProcessing: formState.isLoading,
            onPressed: () async {
              final success = await notifier.save(
                context.l10n,
                existing: widget.category,
              );
              if (success && mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          if (isEditing) ...[
            const SizedBox(height: 16),
            AppButton(
              text: context.l10n.categoryFormDelete,
              detailColor: context.colorScheme.error,
              textColor: context.colorScheme.onError,
              onPressed: () async {
                final deleted = await showDialog<bool>(
                  context: context,
                  builder: (_) => DeleteCategoryDialog(
                    category: widget.category!,
                  ),
                );
                if (deleted == true && mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}
