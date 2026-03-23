import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/snackbar_manager.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/models/task_model.dart';
import '../providers/tasks_provider.dart';
import '../../../../core/providers/supabase_provider.dart';
import 'pickers/category_picker_sheet.dart';
import 'pickers/due_date_picker_sheet.dart';
import 'pickers/inline_priority_picker.dart';

class AddTaskBottomSheet extends ConsumerStatefulWidget {
  final TaskItem? initialTask; // If provided, acts as F35 Edit mode

  const AddTaskBottomSheet({super.key, this.initialTask});

  @override
  ConsumerState<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends ConsumerState<AddTaskBottomSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  final FocusNode _titleFocus = FocusNode();

  DateTime? _selectedDate;
  TaskPriority _selectedPriority = TaskPriority.low;
  TaskCategory? _selectedCategory;
  bool _isPriorityPickerVisible = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTask?.title ?? '');
    _descController = TextEditingController(text: widget.initialTask?.description ?? '');
    
    if (widget.initialTask != null) {
      _selectedDate = widget.initialTask!.dueDate;
      _selectedPriority = widget.initialTask!.priority;
      _selectedCategory = widget.initialTask!.category;
    }

    // Auto focus title
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _titleFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (_titleController.text.trim().isEmpty) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final newTask = TaskItem(
      id: widget.initialTask?.id ?? const Uuid().v4(),
      userId: widget.initialTask?.userId ?? user.id,
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      isCompleted: widget.initialTask?.isCompleted ?? false,
      priority: _selectedPriority,
      dueDate: _selectedDate,
      category: _selectedCategory,
      createdAt: widget.initialTask?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.initialTask != null) {
      ref.read(taskActionsProvider).updateTask(newTask);
    } else {
      ref.read(taskActionsProvider).addTask(newTask);
    }

    Navigator.pop(context);
    // Trigger Success Snackbar (F43/F44)
    SnackbarManager.showSuccess(
      context,
      widget.initialTask != null ? "Task updated." : "Task added successfully.",
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // View insets handles keyboard
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: bottomInset > 0 ? bottomInset + 16 : 32,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorderStrong : AppColors.borderStrong,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title Input (Borderless) F33
          TextField(
            controller: _titleController,
            focusNode: _titleFocus,
            style: AppTextStyles.headingMd,
            decoration: InputDecoration(
              hintText: "What do you want to do?",
              hintStyle: AppTextStyles.headingMd.copyWith(
                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          // Description Input F34
          TextField(
            controller: _descController,
            style: AppTextStyles.bodyMd,
            maxLines: 3,
            minLines: 1,
            decoration: InputDecoration(
              hintText: "Add description...",
              hintStyle: AppTextStyles.bodyMd.copyWith(
                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          
          const SizedBox(height: 24),

          // Display Selected Chips
          if (_selectedDate != null || _selectedCategory != null) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (_selectedCategory != null)
                  _buildStatusChip(
                    _selectedCategory!.name,
                    _selectedCategory!.color,
                    isDark,
                  ),
                if (_selectedDate != null)
                  _buildStatusChip(
                    DateFormat('MMM d').format(_selectedDate!),
                    isDark ? AppColors.darkActionPrimary : AppColors.actionPrimary,
                    isDark,
                    icon: LucideIcons.calendar,
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          
          const Divider(),
          const SizedBox(height: 16),

          if (_isPriorityPickerVisible) ...[
            InlinePriorityPicker(
              selectedPriority: _selectedPriority,
              onPriorityChanged: (p) => setState(() => _selectedPriority = p),
            ),
            const SizedBox(height: 16),
          ],

          // Pickers Row (F37, F38, F39 triggers)
          Row(
            children: [
              _buildActionIcon(LucideIcons.calendar, isDark, isActive: _selectedDate != null, onTap: () async {
                final date = await showDueDatePickerBottomSheet(context, _selectedDate);
                if (date != null) {
                  setState(() {
                    if (date.millisecondsSinceEpoch == 0) {
                      _selectedDate = null;
                    } else {
                      _selectedDate = date;
                    }
                  });
                }
              }),
              const SizedBox(width: 16),
              _buildActionIcon(LucideIcons.flag, isDark, isActive: _selectedPriority != TaskPriority.low || _isPriorityPickerVisible, onTap: () {
                setState(() => _isPriorityPickerVisible = !_isPriorityPickerVisible);
              }),
              const SizedBox(width: 16),
              _buildActionIcon(LucideIcons.tag, isDark, isActive: _selectedCategory != null, onTap: () async {
                final cat = await showCategoryPickerBottomSheet(context, ref);
                if (cat != null) {
                  setState(() => _selectedCategory = cat);
                }
              }),
              const Spacer(),
              // Save Button
              GestureDetector(
                onTap: _saveTask,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkActionPrimary : AppColors.actionPrimary,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Icon(
                    LucideIcons.arrowUp,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, bool isDark, {required VoidCallback onTap, bool isActive = false}) {
    final color = isActive 
        ? AppColors.violetSolid
        : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary);
        
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.1) : Colors.transparent,
          border: Border.all(
            color: isActive ? color.withValues(alpha: 0.5) : (isDark ? AppColors.darkBorderDefault : AppColors.borderSubtle),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color, bool isDark, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
          ],
          Text(label, style: AppTextStyles.labelSm.copyWith(color: color)),
        ],
      ),
    );
  }
}
