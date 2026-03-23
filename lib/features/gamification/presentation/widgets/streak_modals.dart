import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';

void showStreakClaimModal(BuildContext context, int streakCount) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.8), // Deep dimmed background
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(32), // large rounding
          boxShadow: [
            BoxShadow(
              color: AppColors.brandOrange.withValues(alpha: 0.15),
              blurRadius: 40,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 3D Hexagonal Badge Mock
            SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Glow
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.brandOrange.withValues(alpha: 0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                  // Render Hexagon Shape
                  Icon(
                    LucideIcons.hexagon, 
                    size: 140, 
                    color: AppColors.brandOrange,
                    weight: 800,
                  ),
                  // Inner gradient overlay
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.white, AppColors.brandPink],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Icon(
                      LucideIcons.hexagon,
                      size: 130,
                      color: Colors.white,
                    ),
                  ),
                  // The Number
                  Text(
                    "$streakCount",
                    style: AppTextStyles.headingXl.copyWith(
                      fontSize: 48,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      shadows: [
                        const Shadow(
                          color: Colors.black26,
                          offset: Offset(0, 4),
                          blurRadius: 10,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            Text(
              "Congratulations",
              style: AppTextStyles.headingXl.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            Text(
              "You've completed $streakCount days progress!",
              style: AppTextStyles.bodyLg.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 48),
            
            // Full Width Black Continue Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.darkActionPrimary : const Color(0xFF1A1A1A),
                  foregroundColor: isDark ? AppColors.darkActionPrimaryText : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Text(
                  "Continue",
                  style: AppTextStyles.labelLg.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// Keeping the other modals intact with minor color adjustments to match the theme
void showStreakLostModal(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.darkSurface : AppColors.brandOrange.withValues(alpha: 0.1),
              ),
              child: Center(
                child: Icon(LucideIcons.flame, size: 48, color: AppColors.brandOrange),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Streak Lost",
              style: AppTextStyles.headingXl.copyWith(color: theme.colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "It happens to the best of us! Let's start fresh today and build a new habit.",
              style: AppTextStyles.bodyLg.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: "Start New Streak",
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    ),
  );
}

void showDailyCompleteModal(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.darkMintSolid.withValues(alpha: 0.2) : AppColors.mintSolid.withValues(alpha: 0.2),
              ),
              child: Center(
                child: Icon(Icons.check_circle_outline, size: 48, color: isDark ? AppColors.darkMintSolid : AppColors.mintSolid),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Day Complete!",
              style: AppTextStyles.headingXl.copyWith(color: theme.colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "You finished all your tasks for today. Rest up and prepare for tomorrow.",
              style: AppTextStyles.bodyLg.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: "Got it",
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    ),
  );
}
