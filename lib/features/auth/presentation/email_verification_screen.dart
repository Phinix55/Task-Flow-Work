import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'dart:async';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Mock periodic checking (F14)
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      // Simulate verification success after 4 seconds
      timer.cancel();
      context.go('/dashboard');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Loading spinner ring placeholder
                SizedBox(
                  width: 64,
                  height: 64,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? AppColors.darkVioletText : AppColors.violetSolid,
                    ),
                    backgroundColor: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle,
                  ),
                ),
                const SizedBox(height: 32),
                
                Text(
                  "Verify your email",
                  style: AppTextStyles.headingXl.copyWith(color: theme.colorScheme.onSurface),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                
                Text(
                  "We're waiting for you to click the link sent to\n${widget.email}",
                  style: AppTextStyles.bodyLg.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 48),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.mail,
                      size: 20,
                      color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Open Email App",
                      style: AppTextStyles.labelLg.copyWith(
                        color: theme.colorScheme.onSurface,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
