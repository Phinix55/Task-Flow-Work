import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/snackbar_manager.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController    = TextEditingController();
  final _confirmController     = TextEditingController();
  bool _isLoading              = false;
  bool _showPassword           = false;
  bool _showConfirm            = false;
  bool _success                = false;

  // Password strength
  double get _strength {
    final p = _passwordController.text;
    if (p.isEmpty) return 0;
    double s = 0;
    if (p.length >= 8)                             s += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(p))              s += 0.25;
    if (RegExp(r'[0-9]').hasMatch(p))              s += 0.25;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(p)) s += 0.25;
    return s;
  }

  Color get _strengthColor {
    if (_strength <= 0.25) return AppColors.roseSolid;
    if (_strength <= 0.50) return AppColors.amberSolid;
    if (_strength <= 0.75) return AppColors.amberSolid;
    return AppColors.mintSolid;
  }

  String get _strengthLabel {
    if (_strength <= 0.25) return 'Weak';
    if (_strength <= 0.50) return 'Fair';
    if (_strength <= 0.75) return 'Good';
    return 'Strong';
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final password = _passwordController.text;
    final confirm  = _confirmController.text;

    if (password.isEmpty || confirm.isEmpty) {
      SnackbarManager.showError(context, 'Please fill in both fields');
      return;
    }
    if (password != confirm) {
      SnackbarManager.showError(context, 'Passwords do not match');
      return;
    }
    if (password.length < 8) {
      SnackbarManager.showError(context, 'Password must be at least 8 characters');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: password),
      );
      // Sign out so user logs in fresh with new password
      await Supabase.instance.client.auth.signOut();

      if (!mounted) return;
      setState(() { _isLoading = false; _success = true; });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      SnackbarManager.showError(context, e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      SnackbarManager.showError(context, 'Something went wrong. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: 24),
          onPressed: () => context.go('/login'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: _success ? _buildSuccess(isDark) : _buildForm(isDark),
          ),
        ),
      ),
    );
  }

  // ── FORM ────────────────────────────────────────────────────────────────────
  Widget _buildForm(bool isDark) {
    return ListView(
      key: const ValueKey('form'),
      children: [
        const SizedBox(height: 8),
        Text('Create new password',
            style: AppTextStyles.headingXl.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
        const SizedBox(height: 8),
        Text('Your new password must be at least 8 characters long.',
            style: AppTextStyles.bodyLg.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
        const SizedBox(height: 36),

        // New password
        AppTextField(
          controller: _passwordController,
          labelText: 'New password',
          obscureText: !_showPassword,
          suffixIcon: IconButton(
            icon: Icon(_showPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                size: 20,
                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
            onPressed: () => setState(() => _showPassword = !_showPassword),
          ),
          onChanged: (_) => setState(() {}),
        ),

        // Strength bar
        const SizedBox(height: 10),
        if (_passwordController.text.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _strength,
              minHeight: 4,
              backgroundColor: isDark ? AppColors.darkBorderDefault : AppColors.borderSubtle,
              valueColor: AlwaysStoppedAnimation(_strengthColor),
            ),
          ),
          const SizedBox(height: 4),
          Text(_strengthLabel,
              style: AppTextStyles.labelSm.copyWith(color: _strengthColor, fontWeight: FontWeight.w600)),
        ],

        const SizedBox(height: 20),

        // Confirm
        AppTextField(
          controller: _confirmController,
          labelText: 'Confirm new password',
          obscureText: !_showConfirm,
          suffixIcon: IconButton(
            icon: Icon(_showConfirm ? LucideIcons.eyeOff : LucideIcons.eye,
                size: 20,
                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
            onPressed: () => setState(() => _showConfirm = !_showConfirm),
          ),
        ),

        const SizedBox(height: 36),

        PrimaryButton(
          text: 'Reset password',
          isLoading: _isLoading,
          onPressed: _handleSubmit,
        ),
      ],
    );
  }

  // ── SUCCESS STATE ────────────────────────────────────────────────────────────
  Widget _buildSuccess(bool isDark) {
    return Center(
      key: const ValueKey('success'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkMintSurface : AppColors.mintSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.circleCheck, size: 44,
                color: isDark ? AppColors.darkMintText : AppColors.mintSolid),
          ),
          const SizedBox(height: 28),
          Text('Password updated!',
              style: AppTextStyles.headingXl.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text('Your password has been changed\nsuccessfully.',
              style: AppTextStyles.bodyLg.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
              textAlign: TextAlign.center),
          const SizedBox(height: 48),
          PrimaryButton(
            text: 'Back to login',
            onPressed: () => context.go('/login'),
          ),
        ],
      ),
    );
  }
}
