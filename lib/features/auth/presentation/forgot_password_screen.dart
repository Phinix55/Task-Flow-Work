import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/ghost_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/snackbar_manager.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  
  bool _isLoading = false;
  bool _emailSent = false;
  int _countdown = 30;
  Timer? _timer;

  @override
  void dispose() {
    _emailController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _handleReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      SnackbarManager.showError(context, 'Please enter your email address');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'taskflow://reset-password',
      );
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _emailSent = true;
      });
      _startCountdown();
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      SnackbarManager.showError(context, e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      SnackbarManager.showError(context, 'Something went wrong. Please try again.');
    }
  }
  
  void _startCountdown() {
    setState(() => _countdown = 30);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: 24),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _emailSent ? _buildSentState(theme, isDark) : _buildInputState(theme, isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildInputState(ThemeData theme, bool isDark) {
    return Column(
      key: const ValueKey('input'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Forgot password",
          style: AppTextStyles.headingXl.copyWith(color: theme.colorScheme.onSurface),
        ),
        const SizedBox(height: 8),
        Text(
          "Enter your email and we'll send you a link to reset your password.",
          style: AppTextStyles.bodyLg.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
        ),
        const SizedBox(height: 32),
        AppTextField(
          controller: _emailController,
          labelText: "Email",
        ),
        const SizedBox(height: 32),
        PrimaryButton(
          text: "Send reset link",
          isLoading: _isLoading,
          onPressed: _handleReset,
        ),
      ],
    );
  }

  Widget _buildSentState(ThemeData theme, bool isDark) {
    return Center(
      key: const ValueKey('sent'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Mocking F13 Checkmark Lottie
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkMintSurface : AppColors.mintSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.mailCheck,
              size: 40,
              color: isDark ? AppColors.darkMintText : AppColors.mintSolid,
            ),
          ),
          const SizedBox(height: 24),
          
          Text(
            "Check your email",
            style: AppTextStyles.headingXl.copyWith(color: theme.colorScheme.onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "We have sent a password reset link to\n${_emailController.text}",
            style: AppTextStyles.bodyLg.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 48),
          
          GhostButton(
            text: _countdown > 0 ? "Resend link in ${_countdown}s" : "Resend link",
            color: _countdown > 0
                ? (isDark ? AppColors.darkTextDisabled : AppColors.textDisabled)
                : (isDark ? AppColors.darkVioletText : AppColors.violetSolid),
            onPressed: _countdown > 0
                ? null
                : () async {
                    try {
                      await Supabase.instance.client.auth.resetPasswordForEmail(
                        _emailController.text.trim(),
                        redirectTo: 'taskflow://reset-password',
                      );
                      _startCountdown();
                    } catch (_) {}
                  },
          ),
          const SizedBox(height: 16),
          GhostButton(
            text: "Back to login",
            color: theme.colorScheme.onSurface,
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }
}
