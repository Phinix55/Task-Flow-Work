import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/ghost_button.dart';
import '../../../main.dart'; // for sharedPreferencesProvider

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _finishOnboarding() {
    ref.read(sharedPreferencesProvider).setBool('hasSeenOnboarding', true);
    context.go('/welcome');
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      _finishOnboarding();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Skip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_currentPage < 2)
                    GhostButton(
                      text: "Skip",
                      color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                      onPressed: _finishOnboarding,
                    )
                  else
                    const SizedBox(height: 48), // maintain height when last page
                ],
              ),
            ),

            // PageView
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildSlide(
                    context: context,
                    icon: LucideIcons.layoutList,
                    bgColor: isDark ? AppColors.darkVioletSurface : AppColors.violetSurface,
                    iconColor: isDark ? AppColors.darkVioletText : AppColors.violetSolid,
                    title: "Organise your day",
                    subtitle: "Create tasks, set priorities, and never miss a deadline again.",
                  ),
                  _buildSlide(
                    context: context,
                    icon: LucideIcons.target,
                    bgColor: isDark ? AppColors.darkMintSurface : AppColors.mintSurface,
                    iconColor: isDark ? AppColors.darkMintText : AppColors.mintSolid,
                    title: "Track your progress",
                    subtitle: "See how many tasks you crush each day. Watch your productivity grow.",
                  ),
                  _buildSlide(
                    context: context,
                    icon: LucideIcons.trophy,
                    bgColor: isDark ? AppColors.darkAmberSurface : AppColors.amberSurface,
                    iconColor: isDark ? AppColors.darkAmberText : AppColors.amberSolid,
                    title: "Build your streak",
                    subtitle: "Complete tasks daily to keep your streak alive. Consistency is the real superpower.",
                  ),
                ],
              ),
            ),

            // Bottom Navigation Area
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Dot indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? (isDark ? Colors.white : Colors.black)
                              : (isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    text: _currentPage == 2 ? "Get Started" : "Next",
                    onPressed: _nextPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide({
    required BuildContext context,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Mock Lottie Illustration
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            width: double.infinity,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Center(
              child: Icon(icon, size: 80, color: iconColor),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            style: AppTextStyles.displayLg.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: AppTextStyles.bodyLg.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
