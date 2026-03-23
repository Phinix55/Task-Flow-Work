import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_theme_provider.dart';

class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentThemeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: theme.colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text("Theme Override", style: AppTextStyles.headingMd.copyWith(color: theme.colorScheme.onSurface)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Choose how the app looks. System default automatically switches between light and dark modes based on your device settings.", style: AppTextStyles.bodyLg.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
              const SizedBox(height: 32),

              _buildThemeCard(
                context, 
                "System Default", 
                ThemeMode.system, 
                currentThemeMode, 
                LucideIcons.monitorSmartphone,
                ref,
              ),
              const SizedBox(height: 16),
              _buildThemeCard(
                context, 
                "Light", 
                ThemeMode.light, 
                currentThemeMode, 
                LucideIcons.sun,
                ref,
              ),
              const SizedBox(height: 16),
              _buildThemeCard(
                context, 
                "Dark", 
                ThemeMode.dark, 
                currentThemeMode, 
                LucideIcons.moon,
                ref,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context, String title, ThemeMode mode, ThemeMode currentMode, IconData icon, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = currentMode == mode;

    return GestureDetector(
      onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(mode),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isDark ? AppColors.darkActionPrimary.withOpacity(0.1) : AppColors.actionPrimary.withOpacity(0.1))
              : (isDark ? AppColors.darkSurface : Colors.white),
          borderRadius: AppRadius.cardMd,
          border: Border.all(
            color: isSelected 
                ? (isDark ? AppColors.darkActionPrimary : AppColors.actionPrimary) 
                : (isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? (isDark ? AppColors.darkActionPrimary : AppColors.actionPrimary)
                    : (isDark ? AppColors.darkSurface : AppColors.violetSurface),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon, 
                size: 20, 
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.headingMd.copyWith(color: theme.colorScheme.onSurface),
              ),
            ),
            if (isSelected)
              Icon(LucideIcons.check, size: 24, color: isDark ? AppColors.darkActionPrimary : AppColors.actionPrimary),
          ],
        ),
      ),
    );
  }
}
