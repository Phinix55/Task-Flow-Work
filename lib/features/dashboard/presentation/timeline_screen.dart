import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../tasks/presentation/providers/tasks_provider.dart';
import '../../tasks/domain/models/task_model.dart';
import 'widgets/floating_nav_bar.dart';

class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  DateTime _selectedDate = DateTime.now();

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tasksAsync = ref.watch(tasksProvider);

    final today = DateTime.now();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/dashboard');
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingNavBar(
          onFabTap: () {
            context.push('/add-task');
          },
        ),
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Standard Back Button + Title
              SliverSafeArea(
                bottom: false,
                sliver: SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 24, top: 12, bottom: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(LucideIcons.arrowLeft, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                          onPressed: () => context.go('/dashboard'),
                        ),
                      const SizedBox(width: 8),
                      Text(
                        "Timeline",
                        style: AppTextStyles.headingLg.copyWith(
                           color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                           fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Large Date display
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 24),
                child: Text(
                  "${_selectedDate.day == today.day && _selectedDate.month == today.month && _selectedDate.year == today.year ? 'Today, ' : ''}${DateFormat('MMM dd').format(_selectedDate)}",
                  style: AppTextStyles.headingXl.copyWith(
                     color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                     fontWeight: FontWeight.w800,
                     letterSpacing: -1,
                     fontSize: 32,
                  ),
                ),
              ),
            ),
            
            // Week Strip Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                     color: isDark ? AppColors.darkSurface : Colors.white,
                     borderRadius: BorderRadius.circular(32),
                     boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 16, offset: const Offset(0, 8))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(7, (index) {
                       final date = today.subtract(Duration(days: today.weekday - 1 - index));
                       final isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month && date.year == _selectedDate.year;
                       
                       return GestureDetector(
                         onTap: () => setState(() => _selectedDate = date),
                         behavior: HitTestBehavior.opaque,
                         child: Column(
                           children: [
                             Text(DateFormat('E').format(date), style: AppTextStyles.labelXs.copyWith(color: isDark ? AppColors.darkTextDisabled : AppColors.textDisabled, fontWeight: FontWeight.w600)),
                             const SizedBox(height: 12),
                             Text(
                               date.day.toString(),
                               style: AppTextStyles.headingMd.copyWith(
                                 color: isSelected ? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary) : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                                 fontWeight: FontWeight.w700,
                               ),
                             ),
                             const SizedBox(height: 8),
                             if (isSelected) 
                               Container(
                                 height: 4, width: 24,
                                 decoration: BoxDecoration(color: AppColors.brandOrange, borderRadius: BorderRadius.circular(4)),
                               )
                             else
                               const SizedBox(height: 4),
                           ]
                         ),
                       );
                    }),
                  ),
                ),
              ),
            ),

            // Timelines
            tasksAsync.when(
              data: (allTasks) {
                final tasks = allTasks.where((task) {
                  if (task.dueDate == null) {
                    // Unscheduled tasks are only shown on 'Today'
                    return _selectedDate.day == today.day && _selectedDate.month == today.month && _selectedDate.year == today.year;
                  }
                  return task.dueDate!.day == _selectedDate.day && task.dueDate!.month == _selectedDate.month && task.dueDate!.year == _selectedDate.year;
                }).toList();

                if (tasks.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(child: Text("Focus time!", style: AppTextStyles.bodyLg)),
                  );
                }

                final groupedTasks = _groupTasks(tasks);

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final groupKey = groupedTasks.keys.elementAt(index);
                      final groupTasks = groupedTasks[groupKey]!;
                      return _buildGroupCard(groupKey, groupTasks, isDark);
                    },
                    childCount: groupedTasks.length,
                  ),
                );
              },
              loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
              error: (_, __) => const SliverFillRemaining(child: Center(child: Text("Error fetching timeline"))),
            ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 140)), // For FAB
          ],
        ),
      ),
    ), // end Scaffold
    ); // end PopScope
  }

  Widget _buildGroupCard(String title, List<TaskItem> tasks, bool isDark) {
    return Padding(
       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Text(
             title,
             style: AppTextStyles.headingSm.copyWith(
               color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
               fontWeight: FontWeight.w700,
               letterSpacing: 0.5,
             ),
           ),
           const SizedBox(height: 16),
           ...tasks.map((task) => _buildTaskRowItem(task, isDark)),
         ]
       )
    );
  }

  Widget _buildTaskRowItem(TaskItem task, bool isDark) {
    // Determine random pastel aesthetic for the icon box based on hash
    final colors = [
      const Color(0xFFC8F4FC), // pastel cyan
      const Color(0xFFE4DAFF), // pastel purple
      const Color(0xFFC7F4C8), // pastel green
      const Color(0xFFFFD1D1), // pastel red
    ];
    final colorIdx = task.id.hashCode.abs() % colors.length;
    final boxColor = isDark ? colors[colorIdx].withValues(alpha: 0.1) : colors[colorIdx];
    final iconColor = isDark ? colors[colorIdx] : Colors.black87;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: GestureDetector(
        onTap: () => context.push('/task-detail', extra: task),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image/Icon Box
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(color: boxColor, borderRadius: BorderRadius.circular(16)),
              child: Icon(
                task.isCompleted 
                  ? Icons.check_circle_rounded 
                  : (task.priority == TaskPriority.high ? LucideIcons.flame : Icons.radio_button_unchecked_rounded), 
                color: task.isCompleted ? AppColors.mintSolid : iconColor,
              ),
            ),
            const SizedBox(width: 16),
            
            // Text Core
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: AppTextStyles.bodyLg.copyWith(
                       color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                       fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (task.description != null && task.description!.isNotEmpty)
                    Text(
                       task.description!,
                       style: AppTextStyles.labelSm.copyWith(color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                       maxLines: 1, overflow: TextOverflow.ellipsis,
                    )
                  else if (task.dueDate != null)
                    Text(
                       "Scheduled: ${DateFormat('HH:mm').format(task.dueDate!)}",
                       style: AppTextStyles.labelSm.copyWith(color: AppColors.brandPink),
                       maxLines: 1, overflow: TextOverflow.ellipsis,
                    )
                  else
                    Text(
                       "Unscheduled task",
                       style: AppTextStyles.labelSm.copyWith(color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                       maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                ]
              ),
            ),

            const SizedBox(width: 12),

            // Edit Pill
            GestureDetector(
               onTap: task.isCompleted ? null : () => context.push('/task-detail', extra: task), // Act as edit route
               child: Container(
                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                 decoration: BoxDecoration(
                   color: task.isCompleted 
                       ? (isDark ? AppColors.darkBgSecondary : AppColors.bgSecondary)
                       : (isDark ? AppColors.darkSurfaceRaised : AppColors.bgSecondary),
                   borderRadius: BorderRadius.circular(20),
                   border: Border.all(
                     color: task.isCompleted 
                         ? (isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle)
                         : (isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle),
                   ),
                 ),
                 child: Text(
                   "Edit", 
                   style: AppTextStyles.labelSm.copyWith(
                     color: task.isCompleted 
                         ? (isDark ? AppColors.darkTextMuted : AppColors.textMuted)
                         : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary), 
                     fontWeight: FontWeight.bold,
                   ),
                 ),
               ),
            ),
          ]
        ),
      )
    );
  }
}
