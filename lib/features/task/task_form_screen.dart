import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/models/task.dart';
import 'package:nowly/core/repositories/task_repository.dart';
import 'package:nowly/core/theme/theme_provider.dart';
import 'package:nowly/core/utils/app_max_width.dart';
import 'package:nowly/core/widgets/app_button.dart';
import 'package:nowly/core/widgets/app_layout.dart';
import 'package:nowly/core/widgets/app_snack_bar.dart';
import 'package:nowly/core/widgets/app_text_field.dart';
import 'package:nowly/core/widgets/task_card.dart';
import 'package:nowly/features/home/home_provider.dart';
import 'package:nowly/features/task/task_form_provider.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  const TaskFormScreen({super.key});

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  @override
  Widget build(BuildContext context) {
    ref.listen(taskFormProvider, (prev, next) {
      if (next.errorMessage != null && prev?.errorMessage != next.errorMessage) {
        AppSnackBar.show(context, next.errorMessage!, type: SnackBarType.error);
      }
    });

    final formState = ref.watch(taskFormProvider);
    final notifier = ref.read(taskFormProvider.notifier);

    return AppLayout(
      showBackButton: true,
      headerText: context.l10n.taskFormTitleAdd,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 600;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPreview(notifier, formState),
              const SizedBox(height: 32),
              if (wide) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitleField(notifier),
                          const SizedBox(height: 24),
                          _buildDescriptionField(notifier),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCategoryPicker(formState, notifier),
                          const SizedBox(height: 24),
                          _buildDeadlinePicker(formState, notifier),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                _buildTitleField(notifier),
                const SizedBox(height: 24),
                _buildDescriptionField(notifier),
                const SizedBox(height: 24),
                _buildCategoryPicker(formState, notifier),
                const SizedBox(height: 24),
                _buildDeadlinePicker(formState, notifier),
              ],
              const SizedBox(height: 32),
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: appMaxWidth),
                  child: AppButton(
                    text: context.l10n.taskFormSave,
                    isProcessing: formState.isLoading,
                    onPressed: () async {
                      final nav = Navigator.of(context);
                      final success = await notifier.save(context.l10n);
                      if (success && mounted) {
                        nav.pop();
                      }
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPreview(TaskFormNotifier notifier, TaskFormState formState) {
    final now = DateTime.now();
    final previewTask = Task(
      id: '',
      userId: '',
      categoryId: formState.selectedCategoryId,
      title: notifier.title.text.isEmpty
          ? context.l10n.taskFormPreviewTitle
          : notifier.title.text,
      description: notifier.description.text.isEmpty
          ? null
          : notifier.description.text,
      endDate: now.add(formState.selectedDeadline.duration),
      status: TaskStatus.pending,
      createdAt: now,
      pointsEarned: defaultTaskPoints,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TaskCard(task: previewTask),
    );
  }

  Widget _buildTitleField(TaskFormNotifier notifier) {
    return AppTextField(
      controller: notifier.title.controller,
      label: context.l10n.taskFormName,
      hintText: context.l10n.taskFormNameHint,
      prefixIcon: Ionicons.text_outline,
      textCapitalization: TextCapitalization.sentences,
      errorText: notifier.title.error,
      onChanged: notifier.onTitleChanged,
    );
  }

  Widget _buildDescriptionField(TaskFormNotifier notifier) {
    return AppTextField(
      controller: notifier.description.controller,
      label: context.l10n.taskFormDescription,
      hintText: context.l10n.taskFormDescriptionHint,
      prefixIcon: Ionicons.document_text_outline,
      textCapitalization: TextCapitalization.sentences,
      multiline: true,
      minLines: 2,
      maxLines: 4,
      onChanged: notifier.onDescriptionChanged,
    );
  }

  Widget _buildCategoryPicker(TaskFormState formState, TaskFormNotifier notifier) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final highContrast = ref.watch(highContrastProvider);
    final brightness = Theme.of(context).brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.taskFormCategory,
          style: context.textTheme.labelLarge?.copyWith(
            color: context.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip(
              label: context.l10n.taskFormCategoryNone,
              isSelected: formState.selectedCategoryId == null,
              onTap: () => notifier.selectCategory(null),
            ),
            ...switch (categoriesAsync) {
              AsyncData(:final value) => value.map((category) {
                  final isSelected = category.id == formState.selectedCategoryId;
                  final color = category.resolveColor(
                    brightness: brightness,
                    highContrast: highContrast,
                  );
                  return _buildChip(
                    label: category.name,
                    icon: category.icon,
                    color: color,
                    isSelected: isSelected,
                    onTap: () => notifier.selectCategory(category.id),
                  );
                }),
              _ => <Widget>[],
            },
          ],
        ),
      ],
    );
  }

  Widget _buildChip({
    required String label,
    IconData? icon,
    Color? color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? context.colorScheme.primary)
              : context.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? context.colorScheme.onPrimary
                    : context.colorScheme.onSurface,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: context.textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? context.colorScheme.onPrimary
                    : context.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeadlinePicker(TaskFormState formState, TaskFormNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.taskFormDeadline,
          style: context.textTheme.labelLarge?.copyWith(
            color: context.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TaskDeadline.values.map((deadline) {
            final isSelected = deadline == formState.selectedDeadline;
            return _buildChip(
              label: deadline.label(context.l10n),
              isSelected: isSelected,
              onTap: () => notifier.selectDeadline(deadline),
            );
          }).toList(),
        ),
      ],
    );
  }
}
