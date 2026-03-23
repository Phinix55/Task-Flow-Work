import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../providers/streak_provider.dart';
import 'streak_modals.dart';

class StreakBadge extends ConsumerWidget {
  const StreakBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final streakAsync = ref.watch(streakProvider);
    final streak = streakAsync.value;
    final count = streak?.currentStreak ?? 0;
    final isClaimed = streak?.isClaimedToday ?? false;

    // F57 Color variants based on streak
    Color activeColor;
    if (count == 0) {
      activeColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
    } else if (count < 7) {
      activeColor = isDark ? AppColors.darkAmberSolid : AppColors.amberSolid;
    } else if (count < 30) {
      activeColor = isDark ? AppColors.darkMintSolid : AppColors.mintSolid;
    } else {
      activeColor = isDark ? AppColors.darkVioletText : AppColors.violetSolid;
    }

    return GestureDetector(
      onTap: () async {
        if (!isClaimed) {
          final user = ref.read(currentUserProvider);
          if (user != null) {
            await ref.read(streakActionsProvider).logTaskCompleted(user.id);
            if (context.mounted) showStreakClaimModal(context, count + 1);
          }
        } else {
          // Already claimed today, just show progress
          showStreakClaimModal(context, count);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: count > 0 ? activeColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: AppRadius.button,
          border: Border.all(
            color: count > 0 ? activeColor.withOpacity(0.3) : (isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.flame, size: 16, color: activeColor),
            const SizedBox(width: 6),
            Text(
              "$count",
              style: AppTextStyles.labelMd.copyWith(color: activeColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
