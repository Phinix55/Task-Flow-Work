import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import 'ghost_button.dart';

Future<bool?> showDeleteConfirmationDialog(BuildContext context, {required String title, int count = 1}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      
      return AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          count > 1 ? "Delete $count items?" : "Delete '$title'?",
          style: AppTextStyles.headingMd,
        ),
        content: Text(
          "Are you sure you want to delete ${count > 1 ? 'these items' : 'this task'}? This action cannot be undone.",
          style: AppTextStyles.bodyMd.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: GhostButton(
                  text: "Cancel",
                  onPressed: () => Navigator.pop(context, false),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.darkRoseSolid : AppColors.roseSolid,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Delete", style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
