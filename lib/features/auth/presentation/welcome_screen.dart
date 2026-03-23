import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final List<String> _words = ["Focused.", "Productive.", "Organised."];
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) return;
      setState(() {
        _currentIndex = (_currentIndex + 1) % _words.length;
      });
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
      body: Stack(
        children: [
          // Top White Area with Logo
          Positioned.fill(
            bottom: MediaQuery.of(context).size.height * 0.6,
            child: Container(
              color: theme.scaffoldBackgroundColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // New Taskflow Logo
                  Image.asset(
                    'assets/images/logo.png',
                    width: 64,
                    height: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'TaskHub',
                    style: AppTextStyles.headingLg.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Rotating Text
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      _words[_currentIndex],
                      key: ValueKey<int>(_currentIndex),
                      style: AppTextStyles.bodyLg.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom area with gradient blob and buttons
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    isDark
                        ? AppColors.darkVioletSurface.withOpacity(0.8)
                        : AppColors.violetSurface.withOpacity(0.8),
                    theme.scaffoldBackgroundColor.withOpacity(0.0),
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Your most productive self starts here.",
                      style: AppTextStyles.displayLg.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    PrimaryButton(
                      text: "Sign in",
                      onPressed: () {
                        context.push('/login');
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () {
                          context.push('/signup');
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: isDark ? Colors.white : Colors.black,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: Text(
                          "Create an account",
                          style: AppTextStyles.labelLg.copyWith(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text.rich(
                      TextSpan(
                        text: "By continuing you agree to our ",
                        children: [
                          TextSpan(
                            text: "Terms",
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkVioletText
                                  : AppColors.violetSolid,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const TextSpan(text: " & "),
                          TextSpan(
                            text: "Privacy Policy",
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkVioletText
                                  : AppColors.violetSolid,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      style: AppTextStyles.labelXs.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        letterSpacing: 0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
