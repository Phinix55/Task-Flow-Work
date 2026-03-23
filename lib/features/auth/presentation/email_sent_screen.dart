import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../app/theme/app_text_styles.dart';
import '../../../core/providers/supabase_provider.dart';

class EmailSentScreen extends ConsumerStatefulWidget {
  final String email;
  const EmailSentScreen({super.key, required this.email});

  @override
  ConsumerState<EmailSentScreen> createState() => _EmailSentScreenState();
}

class _EmailSentScreenState extends ConsumerState<EmailSentScreen> {
  bool _isResending = false;
  int _resendCooldown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Auto-navigate to email-verified when Supabase confirms the session
    ref.listenManual(authStateProvider, (_, next) {
      next.whenData((state) {
        if (state.event == AuthChangeEvent.signedIn &&
            state.session?.user.emailConfirmedAt != null &&
            mounted) {
          context.go('/email-verified');
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _resendEmail() async {
    if (_resendCooldown > 0) return;
    setState(() => _isResending = true);

    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: widget.email,
      );
      _startCooldown(30);
    } catch (_) {
      // Silently fail — user can try again after cooldown
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _startCooldown(int seconds) {
    setState(() => _resendCooldown = seconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCooldown <= 0) {
        t.cancel();
      } else {
        if (mounted) setState(() => _resendCooldown--);
      }
    });
  }

  Future<void> _openGmail() async {
    final uri = Uri.parse('googlegmail://');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Fallback — open any mail app
      await launchUrl(Uri.parse('mailto:'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Icon
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.mailCheck,
                  size: 40,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),

              const SizedBox(height: 32),

              Text(
                "Check your inbox",
                style: AppTextStyles.headingXl.copyWith(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                "We sent a verification link to",
                style: AppTextStyles.bodyLg.copyWith(
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                widget.email,
                style: AppTextStyles.bodyLg.copyWith(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                "Tap the link in the email to verify your account.",
                style: AppTextStyles.bodySm.copyWith(
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Open Gmail button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _openGmail,
                  icon: const Icon(Icons.mail_outline_rounded, size: 20),
                  label: const Text("Open Gmail"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : Colors.black,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Resend button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: _resendCooldown > 0 ? null : _resendEmail,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.black.withValues(alpha: 0.12),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isResending
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        )
                      : Text(
                          _resendCooldown > 0
                              ? "Resend in ${_resendCooldown}s"
                              : "Resend email",
                          style: AppTextStyles.bodyLg.copyWith(
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Change email
              GestureDetector(
                onTap: () => context.pop(),
                child: Text(
                  "Change email address",
                  style: AppTextStyles.bodySm.copyWith(
                    color: isDark ? Colors.white38 : Colors.black38,
                    decoration: TextDecoration.underline,
                    decorationColor: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
