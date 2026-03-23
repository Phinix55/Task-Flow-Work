import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class FloatingNavBar extends StatelessWidget {
  final VoidCallback onFabTap;

  const FloatingNavBar({
    super.key,
    required this.onFabTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final location = GoRouterState.of(context).uri.path;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 32, right: 32),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E1E1E).withValues(alpha: 0.88)
                  : Colors.white.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(36),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.09),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 28,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  route: '/dashboard',
                  currentLocation: location,
                  isDark: isDark,
                  onTap: () => context.go('/dashboard'),
                ),
                _NavItem(
                  icon: Icons.calendar_month_rounded,
                  label: 'Timeline',
                  route: '/timeline',
                  currentLocation: location,
                  isDark: isDark,
                  onTap: () => context.go('/timeline'),
                ),
                // CENTER FAB — inline, perfectly fitted
                GestureDetector(
                  onTap: onFabTap,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white
                          : const Color(0xFF1A1A1A),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: isDark ? Colors.black : Colors.white,
                      size: 26,
                    ),
                  ),
                ),
                _NavItem(
                  icon: Icons.timer_rounded,
                  label: 'Focus',
                  route: '/focus',
                  currentLocation: location,
                  isDark: isDark,
                  onTap: () => context.go('/focus'),
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  route: '/profile',
                  currentLocation: location,
                  isDark: isDark,
                  onTap: () => context.go('/profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String currentLocation;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.currentLocation,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentLocation == route || currentLocation.startsWith(route);
    final activeColor = AppColors.brandOrange;
    final inactiveColor = isDark ? AppColors.darkTextDisabled : AppColors.textDisabled;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                key: ValueKey(isActive),
                size: 22,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AppTextStyles.labelSm.copyWith(
                color: isActive ? activeColor : inactiveColor,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                fontSize: 10,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
