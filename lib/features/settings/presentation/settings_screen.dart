import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_radius.dart';
import 'widgets/settings_modals.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        title: Text("Settings", style: AppTextStyles.headingMd.copyWith(color: theme.colorScheme.onSurface)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Display", isDark),
              _buildSettingsCard(
                context,
                isDark,
                items: [
                  _SettingsItem(
                    icon: LucideIcons.palette,
                    title: "Theme",
                    subtitle: "System default",
                    onTap: () => context.push('/settings/theme'),
                  ),
                  _SettingsItem(
                    icon: LucideIcons.paintBucket,
                    title: "Accent Color",
                    subtitle: "Violet",
                    onTap: () {}, // => context.push('/settings/accent'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildSectionTitle("Preferences", isDark),
              _buildSettingsCard(
                context,
                isDark,
                items: [
                  _SettingsItem(
                    icon: LucideIcons.bellRing,
                    title: "Notifications",
                    subtitle: "Enabled",
                    onTap: () => context.push('/settings/notifications'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildSectionTitle("Security", isDark),
              _buildSettingsCard(
                context,
                isDark,
                items: [
                  _SettingsItem(
                    icon: LucideIcons.lock,
                    title: "Change Password",
                    onTap: () => context.push('/settings/security'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildSectionTitle("Danger Zone", isDark),
              _buildSettingsCard(
                context,
                isDark,
                items: [
                  _SettingsItem(
                    icon: LucideIcons.logOut,
                    title: "Log out",
                    isDestructive: true,
                    onTap: () => showLogoutDialog(context),
                  ),
                  _SettingsItem(
                    icon: LucideIcons.trash2,
                    title: "Delete Account",
                    subtitle: "Irreversible",
                    isDestructive: true,
                    onTap: () => context.push('/settings/delete-account'),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              Center(
                child: Text(
                  "Mini TaskHub v1.0.0",
                  style: AppTextStyles.labelMd.copyWith(color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.labelSm.copyWith(
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, bool isDark, {required List<_SettingsItem> items}) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: AppRadius.cardMd,
        border: Border.all(color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          
          return Column(
            children: [
              ListTile(
                leading: Icon(
                  item.icon,
                  size: 20,
                  color: item.isDestructive 
                      ? (isDark ? AppColors.darkRoseSolid : AppColors.roseSolid)
                      : theme.colorScheme.onSurface,
                ),
                title: Text(
                  item.title,
                  style: AppTextStyles.bodyLg.copyWith(
                    color: item.isDestructive 
                        ? (isDark ? AppColors.darkRoseSolid : AppColors.roseSolid)
                        : theme.colorScheme.onSurface,
                  ),
                ),
                subtitle: item.subtitle != null 
                    ? Text(item.subtitle!, style: AppTextStyles.bodySm.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary))
                    : null,
                trailing: Icon(LucideIcons.chevronRight, size: 20, color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                onTap: item.onTap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: index == 0 ? Radius.circular(AppRadius.cardMd.topLeft.x) : Radius.zero,
                    topRight: index == 0 ? Radius.circular(AppRadius.cardMd.topRight.x) : Radius.zero,
                    bottomLeft: index == items.length - 1 ? Radius.circular(AppRadius.cardMd.bottomLeft.x) : Radius.zero,
                    bottomRight: index == items.length - 1 ? Radius.circular(AppRadius.cardMd.bottomRight.x) : Radius.zero,
                  ),
                ),
              ),
              if (index < items.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 52,
                  color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isDestructive;
  final VoidCallback onTap;

  _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.isDestructive = false,
    required this.onTap,
  });
}
