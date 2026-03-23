import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_text_styles.dart';

enum SnackbarType { success, error, warning, info }

class SnackbarManager {
  static void showSnackbar(
    BuildContext context, {
    required String message,
    required SnackbarType type,
    String? actionText,
    VoidCallback? onActionTap,
    Duration duration = const Duration(seconds: 4),
    IconData? iconOverride,
  }) {
    Color leftBarColor;
    IconData defaultIcon;
    Color iconColor;

    switch (type) {
      case SnackbarType.success:
        leftBarColor = AppColors.mintSolid;
        defaultIcon = Icons.check;
        iconColor = AppColors.mintSolid;
        duration = const Duration(seconds: 2);
        break;
      case SnackbarType.error:
        leftBarColor = AppColors.roseSolid;
        defaultIcon = Icons.error_outline;
        iconColor = AppColors.roseSolid;
        duration = const Duration(seconds: 5);
        break;
      case SnackbarType.warning:
        leftBarColor = AppColors.amberSolid;
        defaultIcon = Icons.warning_amber_rounded;
        iconColor = AppColors.amberSolid;
        break;
      default:
        leftBarColor = AppColors.violetSolid;
        defaultIcon = Icons.info_outline;
        iconColor = AppColors.violetSolid;
        duration = const Duration(seconds: 3);
        break;
    }

    final effectiveIcon = iconOverride ?? defaultIcon;

    final snackBar = SnackBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
      duration: duration,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      content: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A24), // Dark near-black for both modes
          borderRadius: AppRadius.chip,
          boxShadow: [
            const BoxShadow(
              color: Color(0x24000000),
              blurRadius: 20,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Stack(
          children: [
            // Left Accent Bar
            Positioned(
              left: -16,
              top: -14,
              bottom: -14,
              child: Container(
                width: 3,
                color: leftBarColor,
              ),
            ),
            Row(
              children: [
                Icon(effectiveIcon, color: iconColor, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: AppTextStyles.bodySm.copyWith(color: Colors.white),
                  ),
                ),
                if (actionText != null && onActionTap != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        onActionTap();
                      },
                      child: Text(
                        actionText.toUpperCase(),
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.violetSolid,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
