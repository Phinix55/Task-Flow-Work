import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/snackbar_manager.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../domain/models/task_model.dart';
import 'providers/tasks_provider.dart';
import '../../../../core/providers/supabase_provider.dart';
import 'widgets/pickers/inline_priority_picker.dart';
import 'widgets/pickers/due_date_picker_sheet.dart';

class AddTaskScreen extends ConsumerStatefulWidget {
  final TaskItem? initialTask;

  const AddTaskScreen({super.key, this.initialTask});

  @override
  ConsumerState<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _descFocus = FocusNode();

  DateTime? _selectedDate;
  TaskPriority _selectedPriority = TaskPriority.low;
  TaskCategory? _selectedCategory;
  bool _isPriorityPickerVisible = false;
  bool _isCategoryPickerVisible = false;

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

    if (widget.initialTask == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _titleFocus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _titleFocus.dispose();
    _descFocus.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (_titleController.text.trim().isEmpty) {
      SnackbarManager.showError(context, "Please enter a task heading");
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) {
      SnackbarManager.showError(context, "You must be logged in to create a task.");
      return;
    }

    final newTask = TaskItem(
      id: widget.initialTask?.id ?? const Uuid().v4(),
      userId: widget.initialTask?.userId ?? user.id,
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      isCompleted: widget.initialTask?.isCompleted ?? false,
      priority: _selectedPriority,
      dueDate: _selectedDate,
      categoryId: _selectedCategory?.id,
      category: _selectedCategory,
      createdAt: widget.initialTask?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.initialTask != null) {
      ref.read(taskActionsProvider).updateTask(newTask);
    } else {
      ref.read(taskActionsProvider).addTask(newTask);
    }

    context.pop();
    SnackbarManager.showSuccess(
      context,
      widget.initialTask != null ? "Task updated." : "Task created.",
    );
  }

  void _injectMarkdown(String prefix, String suffix) {
    final text = _descController.text;
    final selection = _descController.selection;
    
    if (selection.isValid && selection.start >= 0) {
      final selectedText = text.substring(selection.start, selection.end);
      final newText = text.replaceRange(selection.start, selection.end, '$prefix$selectedText$suffix');
      _descController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start + prefix.length + selectedText.length),
      );
    } else {
      final newText = text + prefix + suffix;
      _descController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length - suffix.length),
      );
    }
    _descFocus.requestFocus();
  }

  void _injectList(String marker) {
    final text = _descController.text;
    final selection = _descController.selection;
    final isNewLine = text.isEmpty || text.endsWith('\n');
    final injection = isNewLine ? marker : '\n$marker';
    
    if (selection.isValid && selection.start >= 0) {
        final newText = text.replaceRange(selection.start, selection.end, injection);
        _descController.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: selection.start + injection.length),
        );
    } else {
        final newText = text + injection;
        _descController.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
    }
    _descFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 100,
        leading: TextButton(
          onPressed: () => context.pop(),
          child: Text("Cancel", style: AppTextStyles.bodyLg.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
        ),
        title: Text(widget.initialTask != null ? "Edit Task" : "New Task", style: AppTextStyles.headingMd.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: _saveTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white : Colors.black,
                foregroundColor: isDark ? Colors.black : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: Text(widget.initialTask != null ? "Save" : "Add", style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Input
                  TextField(
                    controller: _titleController,
                    focusNode: _titleFocus,
                    style: AppTextStyles.headingXl.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary, fontSize: 32),
                    decoration: InputDecoration(
                      hintText: "Heading",
                      hintStyle: AppTextStyles.headingXl.copyWith(color: isDark ? AppColors.darkTextMuted : AppColors.textMuted, fontSize: 32),
                      filled: false,
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Description Input
                  TextField(
                    controller: _descController,
                    focusNode: _descFocus,
                    style: AppTextStyles.bodyLg.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary, height: 1.6),
                    maxLines: null,
                    minLines: 4,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: "Description\n\nYou can format this text with the toolbar below.",
                      hintStyle: AppTextStyles.bodyLg.copyWith(color: isDark ? AppColors.darkTextMuted : AppColors.textMuted, height: 1.6),
                      filled: false,
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Properties section (Apple-style grouped rectangles)
                  Text("PROPERTIES", style: AppTextStyles.labelSm.copyWith(letterSpacing: 1.5, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextMuted : AppColors.textMuted)),
                  const SizedBox(height: 12),
                  
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceRaised : AppColors.bgSecondary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildPropertyRow(
                          icon: LucideIcons.calendar,
                          title: "Due Date",
                          value: _selectedDate != null ? DateFormat('MMM d, HH:mm').format(_selectedDate!) : "None",
                          valueColor: _selectedDate != null ? AppColors.brandPink : null,
                          isDark: isDark,
                          onTap: () async {
                            final result = await showDueDatePickerBottomSheet(context, _selectedDate);
                            if (result != null) {
                              setState(() {
                                if (result.millisecondsSinceEpoch == 0) {
                                  _selectedDate = null;
                                } else {
                                  _selectedDate = result;
                                }
                                _isPriorityPickerVisible = false;
                                _isCategoryPickerVisible = false;
                              });
                            }
                          }
                        ),
                        Divider(height: 1, indent: 48, color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle),
                        _buildPropertyRow(
                          icon: LucideIcons.flag,
                          title: "Priority",
                          value: _selectedPriority.name.toUpperCase(),
                          valueColor: _selectedPriority != TaskPriority.low ? AppColors.brandOrange : null,
                          isDark: isDark,
                          onTap: () => setState(() {
                            _isPriorityPickerVisible = !_isPriorityPickerVisible;
                            _isCategoryPickerVisible = false;
                          }),
                        ),
                        if (_isPriorityPickerVisible)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: InlinePriorityPicker(
                              selectedPriority: _selectedPriority,
                              onPriorityChanged: (p) => setState(() {
                                _selectedPriority = p;
                                _isPriorityPickerVisible = false;
                              }),
                            ),
                          ),
                        Divider(height: 1, indent: 48, color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle),
                        _buildPropertyRow(
                          icon: LucideIcons.tag,
                          title: "Category",
                          customTrailing: _selectedCategory != null ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: _selectedCategory!.color)),
                              const SizedBox(width: 8),
                              Text(_selectedCategory!.name, style: AppTextStyles.bodyLg.copyWith(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w500)),
                            ],
                          ) : null,
                          value: _selectedCategory == null ? "None" : "",
                          isDark: isDark,
                          onTap: () {
                            setState(() {
                              _isCategoryPickerVisible = !_isCategoryPickerVisible;
                              _isPriorityPickerVisible = false;
                            });
                          }
                        ),
                        if (_isCategoryPickerVisible)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0).copyWith(bottom: 24),
                            child: Consumer(
                              builder: (context, ref, child) {
                                final categories = ref.watch(taskCategoriesProvider);
                                return Center(
                                  child: categories.when(
                                    data: (catList) => Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      alignment: WrapAlignment.center,
                                      children: catList.map((cat) {
                                        final isSelected = _selectedCategory?.id == cat.id;
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedCategory = cat;
                                              _isCategoryPickerVisible = false;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: isSelected 
                                                ? cat.color.withValues(alpha: 0.15) 
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(100),
                                            border: Border.all(
                                              color: isSelected 
                                                  ? cat.color 
                                                  : (isDark ? AppColors.darkBorderDefault : AppColors.borderDefault),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(LucideIcons.tag, size: 14, color: cat.color),
                                              const SizedBox(width: 6),
                                              Text(cat.name, style: AppTextStyles.labelMd.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
                                            ],
                                          ),
                                        ),
                                        );
                                      }).toList(),
                                    ),
                                    loading: () => const CircularProgressIndicator(),
                                    error: (e, st) => Text("Error loading categories", style: AppTextStyles.bodyMd.copyWith(color: AppColors.roseSolid)),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
          
          // Markdown Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              border: Border(top: BorderSide(color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  _buildToolbarButton(Icons.format_bold_rounded, () => _injectMarkdown('**', '**'), isDark),
                  const SizedBox(width: 8),
                  _buildToolbarButton(Icons.format_italic_rounded, () => _injectMarkdown('_', '_'), isDark),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: SizedBox(height: 24, child: VerticalDivider())),
                  _buildToolbarButton(Icons.format_list_bulleted_rounded, () => _injectList('- '), isDark),
                  const SizedBox(width: 8),
                  _buildToolbarButton(Icons.format_list_numbered_rounded, () => _injectList('1. '), isDark),
                  const Spacer(),
                  _buildToolbarButton(Icons.keyboard_hide_rounded, () => FocusScope.of(context).unfocus(), isDark),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPropertyRow({required IconData icon, required String title, String? value, Color? valueColor, Widget? customTrailing, required bool isDark, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
            const SizedBox(width: 16),
            Text(title, style: AppTextStyles.bodyLg.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
            const Spacer(),
            if (customTrailing != null) 
               customTrailing
            else if (value != null)
              Row(
                children: [
                  Text(value, style: AppTextStyles.bodyLg.copyWith(color: valueColor ?? (isDark ? AppColors.darkTextMuted : AppColors.textMuted), fontWeight: valueColor != null ? FontWeight.bold : FontWeight.normal)),
                  const SizedBox(width: 8),
                  Icon(LucideIcons.chevronRight, size: 16, color: isDark ? AppColors.darkBorderStrong : AppColors.borderStrong),
                ],
              )
          ],
        ),
      ),
    );
  }
  
  Widget _buildToolbarButton(IconData icon, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 22, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
      ),
    );
  }
}
