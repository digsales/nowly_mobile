import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/models/category.dart' as models;
import 'package:nowly/core/theme/primary_colors.dart';
import 'package:nowly/core/theme/theme_provider.dart';
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
    final highContrast = ref.watch(highContrastProvider);
    final brightness = Theme.of(context).brightness;

    final previewCategory = models.Category(
      id: '',
      userId: '',
      name: notifier.name.text.isEmpty
          ? context.l10n.categoryFormName
          : notifier.name.text,
      colorKey: formState.selectedColorKey,
      iconName: formState.selectedIconName,
    );

    final previewColor = previewCategory.resolveColor(
      brightness: brightness,
      highContrast: highContrast,
    );

    return AppLayout(
      showBackButton: true,
      headerText: isEditing
          ? context.l10n.categoryFormTitleEdit
          : context.l10n.categoryFormTitleAdd,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live preview
          Center(
            child: CategoryTile(
              icon: previewCategory.icon,
              label: previewCategory.name,
              backgroundColor: previewColor,
              iconColor: context.colorScheme.onPrimary,
              size: 100,
            ),
          ),
          const SizedBox(height: 32),

          // Name field
          AppTextField(
            controller: notifier.name.controller,
            label: context.l10n.categoryFormName,
            hintText: context.l10n.categoryFormNameHint,
            prefixIcon: Ionicons.text_outline,
            textCapitalization: TextCapitalization.sentences,
            errorText: notifier.name.error,
            onChanged: notifier.onNameChanged,
          ),
          const SizedBox(height: 24),

          // Color picker
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
                    color: colors.primary,
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
          const SizedBox(height: 24),

          // Icon picker
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
          const SizedBox(height: 32),

          // Save button
          AppButton(
            text: context.l10n.categoryFormSave,
            isProcessing: formState.isLoading,
            onPressed: () async {
              final success = await notifier.save(
                context.l10n,
                existing: widget.category,
              );
              if (success && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),

          // Delete button (only when editing)
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
                if (deleted == true && context.mounted) {
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
