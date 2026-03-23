import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/ghost_button.dart';
import '../../../core/utils/snackbar_manager.dart';

class BiometricPrePromptScreen extends StatelessWidget {
  const BiometricPrePromptScreen({super.key});

  void _triggerBiometric(BuildContext context) async {
    // F17 Native prompt mock
    await Future.delayed(const Duration(milliseconds: 500));
    
    // F18 Failure mock route or success
    bool mockSuccess = true;
    
    if (mockSuccess) {
      if (context.mounted) context.go('/dashboard');
    } else {
      if (context.mounted) {
        SnackbarManager.showSnackbar(
          context,
          message: 'Biometric scan failed. Please login manually.',
          type: SnackbarType.error,
        );
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.x, size: 24),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkVioletSurface : AppColors.violetSurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.fingerprint,
                  size: 40,
                  color: isDark ? AppColors.darkVioletText : AppColors.violetSolid,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                "Unlock TaskHub",
                style: AppTextStyles.headingXl.copyWith(color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: 12),
              Text(
                "Use your fingerprint or face to quickly and securely access your tasks.",
                style: AppTextStyles.bodyLg.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              PrimaryButton(
                text: "Enable Biometrics",
                onPressed: () => _triggerBiometric(context),
              ),
              const SizedBox(height: 16),
              GhostButton(
                text: "Not now",
                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                onPressed: () => context.go('/login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
