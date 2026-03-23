import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/snackbar_manager.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  bool _obscureCurrent = true;
  bool _obscureNew = true;

  final _currentController = TextEditingController();
  final _newController = TextEditingController();

  void _save() {
    if (_currentController.text.isEmpty || _newController.text.isEmpty) {
      SnackbarManager.showError(context, "Please fill in all fields.");
      return;
    }
    
    // F68 Success Snackbar
    SnackbarManager.showSuccess(context, "Password updated successfully");
    context.pop();
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
        title: Text("Change Password", style: AppTextStyles.headingMd.copyWith(color: theme.colorScheme.onSurface)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            Text("Current Password", style: AppTextStyles.labelLg.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
            const SizedBox(height: 12),
            _buildField(isDark, theme, _currentController, _obscureCurrent, () => setState(() => _obscureCurrent = !_obscureCurrent)),
            const SizedBox(height: 24),
            Text("New Password", style: AppTextStyles.labelLg.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
            const SizedBox(height: 12),
            _buildField(isDark, theme, _newController, _obscureNew, () => setState(() => _obscureNew = !_obscureNew)),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
        child: PrimaryButton(
          text: "Update Password",
          onPressed: _save,
        ),
      ),
    );
  }

  Widget _buildField(bool isDark, ThemeData theme, TextEditingController controller, bool obscureText, VoidCallback toggle) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: AppTextStyles.bodyLg.copyWith(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? AppColors.darkVioletText : AppColors.violetSolid, width: 2),
        ),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? LucideIcons.eye : LucideIcons.eyeOff, color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
          onPressed: toggle,
        ),
      ),
    );
  }
}
