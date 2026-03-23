import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/theme/app_radius.dart';
import '../domain/models/task_model.dart';
import './providers/tasks_provider.dart';
import 'package:intl/intl.dart';
import 'widgets/pickers/due_date_picker_sheet.dart';
import 'package:go_router/go_router.dart';

class TaskDetailScreen extends ConsumerWidget {
  final TaskItem initialTask;

  const TaskDetailScreen({super.key, required this.initialTask});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Watch the tasks list to get real-time updates for this specific task
    final tasksAsync = ref.watch(tasksProvider);
    
    return tasksAsync.when(
      data: (tasks) {
        // Find the task by ID to get the most up-to-date version from cache
        final task = tasks.firstWhere(
          (t) => t.id == initialTask.id,
          orElse: () => initialTask, // Fallback to initial if not found (e.g. just deleted)
        );

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(LucideIcons.arrowLeft, color: theme.colorScheme.onSurface),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.edit, color: theme.colorScheme.onSurface),
                onPressed: () {
                  context.push('/edit-task', extra: task);
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'task_title_${task.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        task.title,
                        style: AppTextStyles.headingXl.copyWith(color: theme.colorScheme.onSurface),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  if (task.description != null && task.description!.isNotEmpty) ...[
                    Text(
                      task.description!,
                      style: AppTextStyles.bodyLg.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // 2-column detail UI grid
                  Row(
                    children: [
                        if (task.dueDate != null)
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final result = await showDueDatePickerBottomSheet(context, task.dueDate);
                                if (result != null) {
                                  final updatedTask = task.copyWith(
                                    dueDate: result.millisecondsSinceEpoch == 0 ? null : result,
                                    updatedAt: DateTime.now(),
                                  );
                                  ref.read(taskActionsProvider).updateTask(updatedTask);
                                }
                              },
                              child: _buildDetailCard(
                                context,
                                icon: LucideIcons.calendar,
                                title: "Due Date",
                                value: DateFormat('MMM d, HH:mm').format(task.dueDate!),
                                color: AppColors.brandPink,
                              ),
                            ),
                          ),
                       if (task.dueDate != null && task.category != null) const SizedBox(width: 16),
                       if (task.category != null)
                         Expanded(
                           child: _buildDetailCard(
                             context,
                             icon: LucideIcons.tag,
                             title: "Category",
                             value: task.category!.name,
                             color: task.category!.color,
                           ),
                         ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailCard(
                          context,
                          icon: LucideIcons.flag,
                          title: "Priority",
                          value: task.priority.name.toUpperCase(),
                          color: _getPriorityColor(task.priority, isDark),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDetailCard(
                          context,
                          icon: LucideIcons.activity,
                          title: "Status",
                          value: task.isCompleted ? "Completed" : "In Progress",
                          color: task.isCompleted ? AppColors.actionPrimary : AppColors.amberSolid,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text("Error syncing task: $err"))),
    );
  }

  Color _getPriorityColor(TaskPriority priority, bool isDark) {
    switch (priority) {
      case TaskPriority.high: return isDark ? AppColors.darkRoseSolid : AppColors.roseSolid;
      case TaskPriority.medium: return isDark ? AppColors.darkAmberSolid : AppColors.amberSolid;
      case TaskPriority.low: return isDark ? AppColors.darkMintSolid : AppColors.mintSolid;
    }
  }

  Widget _buildDetailCard(BuildContext context, {required IconData icon, required String title, required String value, required Color color}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: AppRadius.cardMd,
        border: Border.all(color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.labelSm.copyWith(color: isDark ? AppColors.darkTextMuted : AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.bodyLg.copyWith(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
