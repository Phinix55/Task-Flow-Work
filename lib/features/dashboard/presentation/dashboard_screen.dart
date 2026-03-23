import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../tasks/presentation/providers/tasks_provider.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/widgets/delete_confirmation_dialog.dart';
import '../../../core/widgets/snackbar_manager.dart';
import 'widgets/task_tile.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/floating_nav_bar.dart';
import '../../../core/widgets/pulsing_skeleton.dart';

import 'package:confetti/confetti.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../tasks/domain/models/task_model.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late ConfettiController _celebrationController;
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _celebrationController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  Map<String, List<TaskItem>> _groupTasks(List<TaskItem> tasks) {
    final morning = <TaskItem>[];
    final afternoon = <TaskItem>[];
    final evening = <TaskItem>[];
    final unscheduled = <TaskItem>[];

    for (var task in tasks) {
      if (task.dueDate != null) {
        final hour = task.dueDate!.hour;
        if (hour < 12) {
          morning.add(task);
        } else if (hour < 17) {
          afternoon.add(task);
        } else {
          evening.add(task);
        }
      } else {
        unscheduled.add(task);
      }
    }

    return {
      if (morning.isNotEmpty) "Morning": morning,
      if (afternoon.isNotEmpty) "Afternoon": afternoon,
      if (evening.isNotEmpty) "Evening": evening,
      if (unscheduled.isNotEmpty) "Anytime": unscheduled,
    };
  }

  @override
  Widget build(BuildContext context) {
    // F46 Full screen confetti listener when lists zero-out
    ref.listen(tasksProvider, (previous, next) {
      if (previous != null && next.hasValue) {
        if (previous.value != null && previous.value!.isNotEmpty && next.value!.isEmpty) {
          _celebrationController.play();
        }
      }
    });

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Watch tasks
    final tasksAsync = ref.watch(tasksProvider);
    final dailyTasks = ref.watch(dailyTasksProvider);
    final selectedTasks = ref.watch(selectedTasksProvider);
    final isSelectionMode = selectedTasks.isNotEmpty;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            title: Text('Exit App', style: AppTextStyles.headingMd.copyWith(color: isDark ? Colors.white : Colors.black)),
            content: Text('Are you sure you want to exit?', style: AppTextStyles.bodyMd.copyWith(color: isDark ? Colors.white60 : Colors.black54)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text('Cancel', style: AppTextStyles.bodyMd.copyWith(color: isDark ? Colors.white60 : Colors.black54)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : Colors.black,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Exit'),
              ),
            ],
          ),
        );
        if (shouldExit == true && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: RefreshIndicator(
          color: isDark ? AppColors.darkVioletText : AppColors.violetSolid,
          onRefresh: () async {
            // F23 Pull to refresh — force a full re-seed from Supabase
            ref.invalidate(tasksProvider);
            await ref.read(tasksProvider.future);
          },
          child: CustomScrollView(
            slivers: [
              if (isSelectionMode)
                SliverAppBar(
                  floating: true,
                  backgroundColor: isDark ? AppColors.darkVioletSurface : AppColors.violetSurface,
                  title: Text(
                    "${selectedTasks.length} selected",
                    style: AppTextStyles.headingMd.copyWith(
                      color: isDark ? AppColors.darkVioletText : AppColors.violetSolid,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(LucideIcons.trash2, color: isDark ? AppColors.darkRoseSolid : AppColors.roseSolid),
                      onPressed: () {
                        for (final id in selectedTasks) {
                          ref.read(taskActionsProvider).deleteTask(id);
                        }
                        ref.read(selectedTasksProvider.notifier).clear();
                      },
                    ),
                    IconButton(
                      icon: Icon(LucideIcons.x, color: isDark ? AppColors.darkVioletText : AppColors.violetSolid),
                      onPressed: () => ref.read(selectedTasksProvider.notifier).clear(),
                    ),
                  ],
                ),
              SliverPadding(
                padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 16),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const DashboardHeader(),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "START YOUR DAY", 
                            style: AppTextStyles.labelSm.copyWith(
                              letterSpacing: 1.2, 
                              fontWeight: FontWeight.bold, 
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary
                            )
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _isGridView = !_isGridView),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Icon(
                                _isGridView ? LucideIcons.list : LucideIcons.layoutGrid, 
                                key: ValueKey(_isGridView),
                                size: 18, 
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Tasks List Area
              ...tasksAsync.when<List<Widget>>(
                data: (_) {
                  if (dailyTasks.isEmpty) {
                    return [
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        sliver: SliverFillRemaining(
                          child: _buildEmptyState(theme, isDark),
                        ),
                      )
                    ];
                  }
                  
                  final groupedTasks = _groupTasks(dailyTasks);
                  final slivers = <Widget>[];

                  for (final entry in groupedTasks.entries) {
                    final title = entry.key;
                    final list = entry.value;

                    slivers.add(
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        sliver: SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 24, bottom: 16),
                            child: Text(
                              title,
                              style: AppTextStyles.headingSm.copyWith(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );

                    if (_isGridView) {
                      slivers.add(
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.9,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return _buildGridCard(list[index], theme, isDark);
                              },
                              childCount: list.length,
                            ),
                          ),
                        ),
                      );
                    } else {
                      slivers.add(
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          sliver: SliverList.builder(
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              final task = list[index];
                              return Padding(
                                key: ValueKey(task.id),
                                padding: EdgeInsets.zero,
                                child: Dismissible(
                                  key: ValueKey('dismiss_${task.id}'),
                                  direction: DismissDirection.horizontal,
                                  background: Container(
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.darkMintSolid : AppColors.mintSolid,
                                    ),
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.only(left: 24),
                                    child: const Icon(LucideIcons.check, color: Colors.white),
                                  ),
                                  secondaryBackground: Container(
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.darkRoseSolid : AppColors.roseSolid,
                                    ),
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 24),
                                    child: const Icon(LucideIcons.trash2, color: Colors.white),
                                  ),
                                  confirmDismiss: (direction) async {
                                    if (direction == DismissDirection.endToStart) {
                                      return await showDeleteConfirmationDialog(context, title: task.title);
                                    }
                                    return true;
                                  },
                                  onDismissed: (direction) {
                                    if (direction == DismissDirection.startToEnd) {
                                      ref.read(taskActionsProvider).toggleTaskCompletion(task.id, !task.isCompleted);
                                      SnackbarManager.showSuccess(context, "Task completed");
                                    } else {
                                      ref.read(taskActionsProvider).deleteTask(task.id);
                                      SnackbarManager.showUndo(context, "Task deleted", () {
                                        ref.read(taskActionsProvider).addTask(task);
                                      });
                                    }
                                  },
                                  child: TaskTile(
                                    task: task,
                                    isSelected: selectedTasks.contains(task.id),
                                    isLast: index == list.length - 1,
                                    onLongPress: () {
                                      ref.read(selectedTasksProvider.notifier).toggle(task.id);
                                    },
                                    onToggleComplete: () {
                                      ref.read(taskActionsProvider).toggleTaskCompletion(task.id, !task.isCompleted);
                                    },
                                    onTap: () {
                                      if (isSelectionMode) {
                                        ref.read(selectedTasksProvider.notifier).toggle(task.id);
                                      } else {
                                        context.push('/task-detail', extra: task);
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }
                  }
                  return slivers;
                },
                loading: () => [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverFillRemaining(
                      child: _buildLoadingSkeletons(theme, isDark),
                    ),
                  )
                ],
                error: (err, stack) => [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverFillRemaining(
                      child: Center(
                        child: Text("Error loading tasks", style: AppTextStyles.bodyMd),
                      ),
                    ),
                  )
                ],
              ),
              
              // Bottom padding
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ),
        ),
      ),
      Align(
        alignment: Alignment.center,
        child: ConfettiWidget(
          confettiController: _celebrationController,
          blastDirectionality: BlastDirectionality.explosive,
          maxBlastForce: 60,
          minBlastForce: 20,
          emissionFrequency: 0.05,
          numberOfParticles: 50,
          gravity: 0.2,
          colors: const [
            AppColors.mintSolid, AppColors.violetSolid, 
            AppColors.amberSolid, AppColors.roseSolid,
            Colors.blue, Colors.pink
          ],
        ),
      ),
      ],
      ),
      // Floating Navigation Bar (F22)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingNavBar(
        onFabTap: () {
          context.push('/add-task');
        },
      ),
    ), // end Scaffold
    ); // end PopScope
  }

  // F20 Empty State
  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.inbox,
            size: 80,
            color: isDark ? AppColors.darkBorderStrong : AppColors.borderStrong,
          ),
          const SizedBox(height: 24),
          Text(
            "All clear!",
            style: AppTextStyles.headingLg.copyWith(color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            "You have no tasks for today.",
            style: AppTextStyles.bodyMd.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }

  // F21 Loading Skeletons
  Widget _buildLoadingSkeletons(ThemeData theme, bool isDark) {
    return Column(
      children: List.generate(
        4,
        (index) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: PulsingSkeleton(
            width: double.infinity,
            height: 90,
            borderRadius: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard(TaskItem task, ThemeData theme, bool isDark) {
    final isSelected = ref.read(selectedTasksProvider).contains(task.id);
    
    Color priorityColor;
    String priorityText;
    switch (task.priority) {
      case TaskPriority.high: priorityColor = AppColors.brandPink; priorityText = "High"; break;
      case TaskPriority.medium: priorityColor = AppColors.brandOrange; priorityText = "Medium"; break;
      case TaskPriority.low: priorityColor = AppColors.mintSolid; priorityText = "Low"; break;
    }

    if (task.isCompleted) {
      priorityColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
      priorityText = "Done";
    }

    return GestureDetector(
      onTap: () => context.push('/task-detail', extra: task),
      onLongPress: () => ref.read(selectedTasksProvider.notifier).toggle(task.id),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.brandOrange : (isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle), 
            width: isSelected ? 2 : 1
          ),
          boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 GestureDetector(
                   onTap: () => ref.read(taskActionsProvider).toggleTaskCompletion(task.id, !task.isCompleted),
                   child: Container(
                     width: 24, height: 24,
                     decoration: BoxDecoration(
                       shape: BoxShape.circle,
                       color: task.isCompleted ? AppColors.brandOrange : Colors.transparent,
                       border: Border.all(color: task.isCompleted ? AppColors.brandOrange : (isDark ? AppColors.darkBorderStrong : AppColors.borderStrong), width: 1.5),
                     ),
                     child: task.isCompleted ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                   ),
                 ),
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                   decoration: BoxDecoration(
                     color: priorityColor.withValues(alpha: 0.1),
                     borderRadius: BorderRadius.circular(20),
                   ),
                   child: Text(
                     priorityText,
                     style: AppTextStyles.labelXs.copyWith(color: priorityColor, fontWeight: FontWeight.w700),
                   ),
                 ),
               ]
             ),
             const Spacer(),
             Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   task.title,
                   style: AppTextStyles.headingSm.copyWith(
                     color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                     fontWeight: FontWeight.w700,
                     height: 1.2,
                     decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                   ),
                   maxLines: 2,
                   overflow: TextOverflow.ellipsis,
                 ),
                 if (task.description != null && task.description!.isNotEmpty) ...[
                   const SizedBox(height: 6),
                   Text(
                     task.description!,
                     style: AppTextStyles.labelSm.copyWith(
                       color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                     ),
                     maxLines: 2,
                     overflow: TextOverflow.ellipsis,
                   ),
                 ]
               ],
             ),
             const SizedBox(height: 16),
             Row(
               children: [
                 Icon(LucideIcons.calendar, size: 14, color: isDark ? AppColors.darkTextDisabled : AppColors.textDisabled),
                 const SizedBox(width: 6),
                 Text(
                   task.dueDate != null ? DateFormat('MMM dd').format(task.dueDate!) : "Anytime", 
                   style: AppTextStyles.labelXs.copyWith(color: isDark ? AppColors.darkTextDisabled : AppColors.textDisabled, fontWeight: FontWeight.w600),
                 ),
                 const Spacer(),
                 if (task.dueDate != null)
                   Text(
                     DateFormat('HH:mm').format(task.dueDate!), 
                     style: AppTextStyles.labelXs.copyWith(color: isDark ? AppColors.darkTextDisabled : AppColors.textDisabled, fontWeight: FontWeight.w600),
                   ),
               ],
             ),
          ]
        )
      )
    );
  }
}
