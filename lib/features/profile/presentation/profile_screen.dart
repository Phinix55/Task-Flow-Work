import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../gamification/presentation/providers/streak_provider.dart';
import '../../tasks/presentation/providers/tasks_provider.dart';
import '../../tasks/domain/models/task_model.dart';
import '../../../../core/utils/snackbar_manager.dart';
import 'providers/profile_provider.dart';
import 'widgets/avatar_picker_sheet.dart';
import '../../settings/presentation/widgets/settings_modals.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final profile = ref.watch(profileProvider).value;
    final streak = ref.watch(streakProvider).value;
    final tasks = ref.watch(tasksProvider).value ?? [];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/dashboard');
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Profile",
            style: AppTextStyles.headingMd.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: Icon(LucideIcons.arrowLeft, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
            onPressed: () => context.go('/dashboard'),
          ),
          // Removed settings gear icon from top
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // 1. One Card Row: Avatar, Name, Email, Edit
              _buildHeaderCard(context, profile, isDark),
              const SizedBox(height: 24),

              // 2. Collage Card: Stats + Heatmap + Badge Hook
              _buildCollageCard(context, streak, tasks, isDark),
              const SizedBox(height: 32),

              // 3. Natively Ported Settings
              _buildSettingsBlock(context, isDark),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ), // end Scaffold
    ); // end PopScope
  }

  Widget _buildHeaderCard(BuildContext context, dynamic profile, bool isDark) {
    if (profile == null) return const SizedBox(height: 104, child: Center(child: CircularProgressIndicator()));

    final initials = profile.name.isNotEmpty 
        ? profile.name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase() 
        : "?";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: isDark ? AppColors.darkBorderSubtle : AppColors.borderDefault.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (ctx) => const AvatarPickerSheet(),
              );
            },
            child: Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceRaised : AppColors.brandOrange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.brandOrange.withValues(alpha: 0.3), width: 2),
                image: profile.avatarUrl != null ? DecorationImage(
                  image: NetworkImage(profile.avatarUrl!),
                  fit: BoxFit.cover,
                ) : null,
              ),
              child: profile.avatarUrl == null
                  ? Center(child: Text(initials, style: AppTextStyles.headingMd.copyWith(color: AppColors.brandOrange)))
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: AppTextStyles.headingMd.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary, fontWeight: FontWeight.w800),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                Text(
                  profile.email,
                  style: AppTextStyles.labelSm.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Edit Button (Icon directly mapping to Edit Profile)
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceRaised : AppColors.bgSecondary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(LucideIcons.pencil, size: 18, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
              onPressed: () => context.push('/edit-profile'),
            ),
          )
        ],
      )
    );
  }

  Widget _buildCollageCard(BuildContext context, dynamic streak, List<TaskItem> tasks, bool isDark) {
    final tasksDone = tasks.where((t) => t.isCompleted).length;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: isDark ? AppColors.darkBorderSubtle : AppColors.borderDefault.withValues(alpha: 0.5)),
        boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Collage Row 1: Metrics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricStat("${streak?.currentStreak ?? 0}", "Current Streak", isDark),
              _buildMetricStat("${streak?.longestStreak ?? 0}", "Longest Streak", isDark),
              _buildMetricStat("$tasksDone", "Tasks Done", isDark),
            ],
          ),
          const SizedBox(height: 32),
          
          // Collage Row 2: Contribution Heatmap
          Text(
            "Contribution",
            style: AppTextStyles.labelSm.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary, letterSpacing: 1.2, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSpanningHeatmap(tasks, isDark),
          
          const SizedBox(height: 32),
          
          // Collage Row 3: Hook Button
          Opacity(
            opacity: (streak?.currentStreak ?? 0) >= 7 ? 1.0 : 0.5,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                 color: isDark ? Colors.white : Colors.black,
                 borderRadius: BorderRadius.circular(28),
                 boxShadow: isDark ? [BoxShadow(color: Colors.white.withValues(alpha: 0.1), blurRadius: 10)] : [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(28),
                  onTap: (streak?.currentStreak ?? 0) >= 7 
                      ? () => _showBadgeModal(context, streak) 
                      : () => SnackbarManager.showSnackbar(context, message: "Keep up a 7-day streak to unlock your badge!", type: SnackbarType.error),
                  child: Center(
                    child: Text(
                      "View your badge",
                      style: AppTextStyles.labelMd.copyWith(
                        color: isDark ? Colors.black : Colors.white, 
                        fontWeight: FontWeight.bold, 
                        letterSpacing: 0.5
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSpanningHeatmap(List<TaskItem> tasks, bool isDark) {
    final tasksDone = tasks.where((t) => t.isCompleted).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (tasksDone == 0) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 32),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(LucideIcons.calendarDays, size: 48, color: isDark ? AppColors.darkBorderStrong : AppColors.borderStrong),
                const SizedBox(height: 16),
                Text(
                  "Complete tasks to build your timeline chart!", 
                  style: AppTextStyles.labelMd.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ]
            ),
          );
        }

        final availableWidth = constraints.maxWidth;
        const boxSize = 12.0;
        const gap = 4.0;
        final weekCount = (availableWidth / (boxSize + gap)).floor();
        
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        
        final Map<DateTime, int> completionsPerDay = {};
        for (var task in tasks) {
          if (task.isCompleted && task.completedAt != null) {
            final date = DateTime(task.completedAt!.year, task.completedAt!.month, task.completedAt!.day);
            completionsPerDay[date] = (completionsPerDay[date] ?? 0) + 1;
          }
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(weekCount, (weekIndex) {
            return Column(
              children: List.generate(7, (dayIndex) {
                 final daysAgo = ((weekCount - 1 - weekIndex) * 7) + (now.weekday - 1 - dayIndex);
                 final targetDate = today.subtract(Duration(days: daysAgo));
                 
                 final isFuture = daysAgo < 0;
                 final count = completionsPerDay[targetDate] ?? 0;
                 
                 int intensity = 0;
                 if (count > 0) intensity = 1;
                 if (count > 2) intensity = 2;
                 if (count > 4) intensity = 3;
                 if (count > 6) intensity = 4;
                 
                 BoxDecoration decor;
                 if (isFuture || intensity == 0) {
                   decor = BoxDecoration(
                     border: Border.all(color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle),
                     borderRadius: BorderRadius.circular(3),
                   );
                 } else {
                   Color boxColor;
                   switch (intensity) {
                     case 4: boxColor = AppColors.brandOrange; break; 
                     case 3: boxColor = AppColors.brandOrange.withValues(alpha: 0.7); break;
                     case 2: boxColor = AppColors.brandOrange.withValues(alpha: 0.4); break;
                     default: boxColor = AppColors.brandOrange.withValues(alpha: 0.2); break;
                   }
                   decor = BoxDecoration(color: boxColor, borderRadius: BorderRadius.circular(3));
                 }
                 
                 return Container(
                   margin: const EdgeInsets.only(bottom: gap),
                   width: boxSize, height: boxSize,
                   decoration: decor,
                 );
              })
            );
          })
        );
      }
    );
  }

  Widget _buildMetricStat(String value, String label, bool isDark) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.headingXl.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary, fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.labelXs.copyWith(color: isDark ? AppColors.darkTextMuted : AppColors.textMuted, fontWeight: FontWeight.w600)),
      ],
    );
  }

  void _showBadgeModal(BuildContext context, dynamic streak) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Badge Modal",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
             width: double.infinity, height: double.infinity,
             decoration: const BoxDecoration(
               gradient: LinearGradient(
                 colors: [Color(0xFF2E004F), AppColors.brandOrange],
                 begin: Alignment.topLeft,
                 end: Alignment.bottomRight,
               )
             ),
             child: SafeArea(
               child: Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     const Spacer(),
                     // The Badge Icon
                     Container(
                       width: 140, height: 140,
                       decoration: BoxDecoration(
                         shape: BoxShape.circle,
                         color: Colors.white.withValues(alpha: 0.1),
                         border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
                         boxShadow: [BoxShadow(color: AppColors.brandOrange.withValues(alpha: 0.3), blurRadius: 40)],
                       ),
                       child: const Center(child: Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 72)),
                     ),
                     const SizedBox(height: 40),
                     Text(
                       "Level ${streak.currentStreak ~/ 5 + 1} Ignited",
                       style: AppTextStyles.headingXl.copyWith(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                     ),
                     const SizedBox(height: 16),
                     Text(
                       "Your consistency is forging a masterpiece. Keep up the phenomenal momentum and claim the higher ranks.",
                       textAlign: TextAlign.center,
                       style: AppTextStyles.bodyLg.copyWith(color: Colors.white.withValues(alpha: 0.8), height: 1.5),
                     ),
                     const Spacer(),
                     // Close Button mapping
                     SizedBox(
                       width: double.infinity,
                       height: 56,
                       child: ElevatedButton(
                         onPressed: () => Navigator.of(context).pop(),
                         style: ElevatedButton.styleFrom(
                           backgroundColor: Colors.white,
                           foregroundColor: const Color(0xFF2E004F),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                         ),
                         child: Text("Let's get back to work", style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.bold)),
                       ),
                     ),
                     const SizedBox(height: 16),
                   ]
                 )
               )
             )
          )
        );
      }
    );
  }

  Widget _buildSettingsBlock(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text("App Settings", style: AppTextStyles.labelSm.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary, letterSpacing: 1.0)),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isDark ? AppColors.darkBorderSubtle : AppColors.borderDefault.withValues(alpha: 0.5)),
            boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            children: [
              _buildSettingsRow(context, LucideIcons.palette, "Theme", onTap: () => context.push('/settings/theme'), isDark: isDark),
              Divider(height: 1, thickness: 1, indent: 56, color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle),
              _buildSettingsRow(context, LucideIcons.bellRing, "Notifications", onTap: () => context.push('/settings/notifications'), isDark: isDark),
              Divider(height: 1, thickness: 1, indent: 56, color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle),
              _buildSettingsRow(context, LucideIcons.lock, "Security", onTap: () => context.push('/settings/security'), isDark: isDark),
              Divider(height: 1, thickness: 1, indent: 56, color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isDark ? AppColors.darkBorderSubtle : AppColors.borderDefault.withValues(alpha: 0.5)),
            boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            children: [
              _buildSettingsRow(context, LucideIcons.logOut, "Log out", isDestructive: true, onTap: () => showLogoutDialog(context), isDark: isDark),
              Divider(height: 1, thickness: 1, indent: 56, color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle),
              _buildSettingsRow(context, LucideIcons.trash2, "Delete Account", isDestructive: true, onTap: () => context.push('/settings/delete-account'), isDark: isDark),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSettingsRow(BuildContext context, IconData icon, String title, {required VoidCallback onTap, bool isDestructive = false, required bool isDark}) {
    final activeColor = isDestructive ? (isDark ? AppColors.darkRoseSolid : AppColors.roseSolid) : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary);
    return ListTile(
      leading: Icon(icon, size: 20, color: activeColor),
      title: Text(title, style: AppTextStyles.bodyLg.copyWith(color: activeColor, fontWeight: FontWeight.w500)),
      trailing: Icon(LucideIcons.chevronRight, size: 20, color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
  }
}
