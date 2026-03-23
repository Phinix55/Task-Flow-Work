import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../widgets/primary_button.dart';

class SessionManager {
  // F16 Session Expired Dialog
  static void showSessionExpiredDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Unclosable
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final isDark = theme.brightness == Brightness.dark;

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Blurred background
          child: AlertDialog(
            backgroundColor: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Column(
              children: [
                Icon(
                  Icons.lock_clock, 
                  size: 48, 
                  color: isDark ? AppColors.darkActionDestructive : AppColors.actionDestructive,
                ),
                const SizedBox(height: 16),
                Text(
                  "Session Expired",
                  style: AppTextStyles.headingLg.copyWith(color: theme.colorScheme.onSurface),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: Text(
              "For your security, your session has expired. Please log in again to continue.",
              style: AppTextStyles.bodyMd.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
              textAlign: TextAlign.center,
            ),
            actions: [
              PrimaryButton(
                text: "Login",
                onPressed: () {
                  // Actually should reset router to prevent back stack, but for prototype:
                  ctx.go('/login');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
