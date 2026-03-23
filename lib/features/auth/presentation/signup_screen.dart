import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/app_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _termsAccepted = false;
  String? _serverError;

  final Map<String, String?> _errors = {};

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _validateAndSubmit() async {
    setState(() {
      _errors.clear();
      _serverError = null;
    });

    if (_nameController.text.trim().isEmpty) {
      _errors['name'] = "Name is required";
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(_emailController.text.trim())) {
      _errors['email'] = "Enter a valid email address";
    }
    if (_passwordController.text.length < 8) {
      _errors['password'] = "Password must be at least 8 characters";
    }
    if (!_termsAccepted) {
      _errors['terms'] = "You must accept the terms";
    }

    if (_errors.isNotEmpty) {
      setState(() {});
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {'name': _nameController.text.trim()},
      );

      if (!mounted) return;
      // Navigate to email sent screen passing the email
      context.go('/email-sent', extra: _emailController.text.trim());
    } on AuthException catch (e) {
      setState(() => _serverError = _friendlyError(e.message));
    } catch (_) {
      setState(() => _serverError = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _friendlyError(String message) {
    if (message.contains('already registered')) {
      return 'This email is already in use. Try signing in instead.';
    }
    if (message.contains('weak')) {
      return 'Please choose a stronger password.';
    }
    return message;
  }

  // Password Strength
  double _passwordStrength = 0;
  Color _passwordColor = AppColors.borderSubtle;

  void _evaluatePassword(String val) {
    if (val.isEmpty) {
      _passwordStrength = 0;
      _passwordColor = AppColors.borderSubtle;
    } else if (val.length < 6) {
      _passwordStrength = 0.33;
      _passwordColor = AppColors.roseSolid;
    } else if (val.length < 10 && !val.contains(RegExp(r'[0-9]'))) {
      _passwordStrength = 0.66;
      _passwordColor = AppColors.amberSolid;
    } else {
      _passwordStrength = 1.0;
      _passwordColor = AppColors.mintSolid;
    }
    setState(() {});
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Create an account",
                style: AppTextStyles.headingXl.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Let's get your day organised.",
                style: AppTextStyles.bodyLg.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 32),

              AppTextField(
                controller: _nameController,
                labelText: "Full Name",
                errorText: _errors['name'],
                onChanged: (_) => setState(() => _errors.remove('name')),
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _emailController,
                labelText: "Email",
                errorText: _errors['email'],
                onChanged: (_) {
                  setState(() {
                    _errors.remove('email');
                    _serverError = null;
                  });
                },
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _passwordController,
                labelText: "Password",
                obscureText: _obscurePassword,
                errorText: _errors['password'],
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff,
                    color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                onChanged: (val) {
                  _evaluatePassword(val);
                  setState(() => _errors.remove('password'));
                },
              ),

              // Password Strength Bar
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 4,
                      decoration: BoxDecoration(
                        color: _passwordStrength >= 0.33
                            ? _passwordColor
                            : (isDark
                                ? AppColors.darkBorderDefault
                                : AppColors.borderSubtle),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 4,
                      decoration: BoxDecoration(
                        color: _passwordStrength >= 0.66
                            ? _passwordColor
                            : (isDark
                                ? AppColors.darkBorderDefault
                                : AppColors.borderSubtle),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 4,
                      decoration: BoxDecoration(
                        color: _passwordStrength >= 1.0
                            ? _passwordColor
                            : (isDark
                                ? AppColors.darkBorderDefault
                                : AppColors.borderSubtle),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Terms checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _termsAccepted,
                      onChanged: (val) => setState(() {
                        _termsAccepted = val ?? false;
                        _errors.remove('terms');
                      }),
                      activeColor: AppColors.violetSolid,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "I agree to the Terms of Service and Privacy Policy.",
                      style: AppTextStyles.bodySm.copyWith(
                        color: _errors['terms'] != null
                            ? (isDark
                                ? AppColors.darkActionDestructive
                                : AppColors.actionDestructive)
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),

              // Server-side error
              if (_serverError != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.roseSolid.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 16, color: AppColors.roseSolid),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _serverError!,
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.roseSolid,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              PrimaryButton(
                text: "Create account",
                isLoading: _isLoading,
                onPressed: _validateAndSubmit,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
