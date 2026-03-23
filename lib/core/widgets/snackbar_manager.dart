import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

class SnackbarManager {
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTextStyles.labelMd.copyWith(color: AppColors.actionPrimaryText)),
        backgroundColor: AppColors.actionPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTextStyles.labelMd.copyWith(color: AppColors.roseSolid)),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.roseSolid, width: 2),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  static void showUndo(BuildContext context, String message, VoidCallback onUndo) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTextStyles.labelMd.copyWith(color: Colors.white)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF2D2D2D), // Dark pill
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        duration: const Duration(seconds: 4), // F42 4s degrading action line
        action: SnackBarAction(
          label: "Undo",
          textColor: AppColors.actionPrimary,
          onPressed: onUndo,
        ),
      ),
    );
  }
}
