import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../tasks/presentation/providers/tasks_provider.dart';
import '../../../gamification/presentation/providers/streak_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final allTasks = ref.watch(tasksProvider).value ?? [];
    final completedCount = allTasks.where((t) => t.isCompleted).length;
    final totalCount = allTasks.length;
    
    final streak = ref.watch(streakProvider).value;
    final profile = ref.watch(profileProvider).value;
    final userName = profile?.name.split(' ').first ?? '';
    final greetingPrefix = _getGreeting();
    final greetingText = userName.isNotEmpty ? "$greetingPrefix, $userName" : greetingPrefix;

    final today = DateTime.now();
    final dayString = DateFormat('dd').format(today); // "09"
    final monthYearString = DateFormat("MMM`yy").format(today); // "Jan'24"
    final weekdayString = DateFormat('EEEE').format(today); // "Tuesday"

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Row: Greeting + Icons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                greetingText,
                style: AppTextStyles.headingMd.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary, 
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () => context.push('/search'),
                  icon: Icon(LucideIcons.search, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary, size: 22),
                ),
                IconButton(
                  onPressed: () => context.push('/settings/notifications'),
                  icon: Icon(LucideIcons.bell, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary, size: 22),
                ),
              ],
            ),
          ],
        ),
        
        const SizedBox(height: 24),

        // Massive Reference Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Left: Huge Date + Dot
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  dayString,
                  style: AppTextStyles.headingXl.copyWith(
                    fontSize: 76,
                    height: 1.0,
                    letterSpacing: -3,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: const BoxDecoration(
                    color: AppColors.roseSolid, 
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            // Right: Month/Year and Weekday
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  monthYearString,
                  style: AppTextStyles.bodyLg.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  weekdayString,
                  style: AppTextStyles.bodyLg.copyWith(
                    color: isDark ? AppColors.darkTextMuted : AppColors.textDisabled,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            )
          ],
        ),
        
        const SizedBox(height: 24),

        // Unboxed Clean Bold Stats Row
        _buildNakedStats(completedCount, totalCount, streak, isDark),
      ],
    );
  }

  Widget _buildNakedStats(int completedCount, int totalCount, dynamic streak, bool isDark) {
    final remainingCount = totalCount - completedCount;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.local_fire_department_rounded, color: AppColors.brandOrange, size: 26),
            const SizedBox(width: 8),
            Text(
              "${streak?.currentStreak ?? 0} Day Streak",
              style: AppTextStyles.headingSm.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: (totalCount > 0 && remainingCount == 0) ? AppColors.mintSolid : (isDark ? AppColors.darkBorderDefault : AppColors.borderSubtle),
                shape: BoxShape.circle,
              ),
              child: Icon(
                remainingCount == 0 && totalCount > 0 ? Icons.check : LucideIcons.listTodo,
                color: remainingCount == 0 && totalCount > 0 ? Colors.white : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                size: 14,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              remainingCount == 0 && totalCount > 0 ? "All done!" : "$remainingCount Tasks Left",
              style: AppTextStyles.headingSm.copyWith(
                color: (totalCount > 0 && remainingCount == 0) ? AppColors.mintText : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
