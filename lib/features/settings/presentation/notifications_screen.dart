import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/widgets/snackbar_manager.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _remindersEnabled = true;
  bool _motivationEnabled = true;
  bool _streakEnabled = true;

  Future<void> _handleToggleReminders(bool enabled) async {
    if (enabled) {
      final granted = await NotificationService().requestPermission();
      if (!granted) {
        if (mounted) SnackbarManager.showError(context, 'Notification permission denied');
        return;
      }
    }
    setState(() => _remindersEnabled = enabled);
  }

  Future<void> _handleToggleMotivation(bool enabled) async {
    setState(() => _motivationEnabled = enabled);
    if (enabled) {
      await NotificationService().scheduleDailyMotivational();
    } else {
      await NotificationService().cancelDailyMotivational();
    }
  }

  Future<void> _handleToggleStreak(bool enabled) async {
    setState(() => _streakEnabled = enabled);
    if (enabled) {
      await NotificationService().scheduleStreakReminder();
    } else {
      await NotificationService().cancelStreakReminder();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: theme.colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Notifications",
          style: AppTextStyles.headingMd.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              "Push Notifications",
              style: AppTextStyles.labelLg.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                "Task Reminders",
                style: AppTextStyles.bodyLg.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                "Get reminded 30m before tasks are due",
                style: AppTextStyles.bodySm.copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                ),
              ),
              value: _remindersEnabled,
              activeThumbColor: isDark ? AppColors.darkVioletText : AppColors.violetSolid,
              onChanged: _handleToggleReminders,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                "Daily Motivation",
                style: AppTextStyles.bodyLg.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                "A morning boost to start your day",
                style: AppTextStyles.bodySm.copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                ),
              ),
              value: _motivationEnabled,
              activeThumbColor: isDark ? AppColors.darkVioletText : AppColors.violetSolid,
              onChanged: _handleToggleMotivation,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                "Streak Alerts",
                style: AppTextStyles.bodyLg.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                "Don't let your productive streak die",
                style: AppTextStyles.bodySm.copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                ),
              ),
              value: _streakEnabled,
              activeThumbColor: isDark ? AppColors.darkVioletText : AppColors.violetSolid,
              onChanged: _handleToggleStreak,
            ),

            const SizedBox(height: 48),
            Text(
              "Test Notifications",
              style: AppTextStyles.labelLg.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _TestButton(
                  label: "Instant Ping",
                  onPressed: () => NotificationService().showInstant(
                    title: "Hello from TaskFlow! 👋",
                    body: "This is a test notification.",
                  ),
                ),
                _TestButton(
                  label: "Motivational",
                  onPressed: () => NotificationService().scheduleDailyMotivational(
                    time: TimeOfDay.fromDateTime(DateTime.now().add(const Duration(seconds: 5))),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TestButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _TestButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.violetSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkBorderDefault : AppColors.violetBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMd.copyWith(
            color: isDark ? AppColors.darkVioletText : AppColors.violetSolid,
          ),
        ),
      ),
    );
  }
}
