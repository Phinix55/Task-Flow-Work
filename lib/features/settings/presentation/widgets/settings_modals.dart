import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

void showLogoutDialog(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text("Log Out",
          style: AppTextStyles.headingMd
              .copyWith(color: theme.colorScheme.onSurface)),
      content: Text(
          "Are you sure you want to log out? You will need to re-authenticate to access your tasks.",
          style: AppTextStyles.bodyMd.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text("Cancel",
              style: AppTextStyles.labelMd.copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted)),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(ctx);
            // Real Supabase sign out
            try {
              await Supabase.instance.client.auth.signOut();
            } catch (_) {
              // Even if it fails, we want to pop back to welcome via router if possible
              // but signOut usually won't fail in a way that blocks local cleanup
            }
          },
          child: Text("Log Out",
              style: AppTextStyles.labelMd.copyWith(
                  color: isDark ? AppColors.darkRoseSolid : AppColors.roseSolid)),
        ),
      ],
    ),
  );
}
