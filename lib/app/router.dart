import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/onboarding/presentation/splash_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/auth/presentation/welcome_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/email_verification_screen.dart';
import '../features/auth/presentation/email_sent_screen.dart';
import '../features/auth/presentation/email_verified_screen.dart';
import '../features/auth/presentation/biometric_prompt_screen.dart';
import '../features/auth/presentation/reset_password_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/dashboard/presentation/timeline_screen.dart';
import '../features/focus/presentation/focus_screen.dart';
import '../features/tasks/presentation/task_detail_screen.dart';
import '../features/tasks/domain/models/task_model.dart';
import '../features/tasks/presentation/add_task_screen.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/edit_profile_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/settings/presentation/theme_settings_screen.dart';
import '../features/settings/presentation/notifications_screen.dart';
import '../features/settings/presentation/change_password_screen.dart';
import '../features/settings/presentation/delete_account_screen.dart';
import '../core/providers/supabase_provider.dart';

/// Auth-protected routes — unauthenticated users are bounced to /welcome
const _protectedRoutes = [
  '/dashboard',
  '/timeline',
  '/focus',
  '/profile',
  '/search',
  '/add-task',
  '/edit-task',
  '/task-detail',
  '/edit-profile',
  // NOTE: /reset-password is intentionally NOT protected — Supabase sets a
  // temporary session via the deep link, so the user is technically "logged in"
  // but should still be allowed to reach this screen without redirect.
];

/// Routes that authenticated users should NOT see (reverse guard)
const _authRoutes = ['/welcome', '/login', '/signup'];

final routerProvider = Provider<GoRouter>((ref) {
  // Listen to auth state changes and refresh the router automatically
  final notifier = _AuthRouterNotifier(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      final user = Supabase.instance.client.auth.currentUser;
      final location = state.uri.path;

      // Handle deep link callback path:
      // If we have a user and they are confirmed, go to the success screen.
      // If this is a password reset link, go to the reset screen immediately.
      if (location.contains('callback')) {
        if (user != null && user.emailConfirmedAt != null)
          return '/email-verified';
        return null;
      }

      // Allow the reset-password screen regardless of auth state
      // (Supabase provides a temporary session via the magic link)
      if (location == '/reset-password') return null;

      // Still on splash or handling deep link — let it decide
      if (location == '/') return null;

      final isProtected = _protectedRoutes.any((r) => location.startsWith(r));
      final isAuthRoute = _authRoutes.contains(location);

      if (user == null) {
        // Not logged in — block access to protected routes
        if (isProtected) return '/welcome';
        return null;
      }

      // User is logged in
      if (!user.emailConfirmedAt.toString().contains('null') &&
          user.emailConfirmedAt != null) {
        // Email confirmed — push auth screen visitors to dashboard
        if (isAuthRoute) return '/dashboard';
        return null;
      } else {
        // Email NOT confirmed — only allow email-sent related screens
        if (isProtected) return '/email-sent?email=${user.email}';
        return null;
      }
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCirc,
                    ),
                  ),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/welcome',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const WelcomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/email-verification',
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return EmailVerificationScreen(email: email);
        },
      ),
      // New: email sent after signup (waits for verification)
      GoRoute(
        path: '/email-sent',
        builder: (context, state) {
          final email =
              state.extra as String? ??
              state.uri.queryParameters['email'] ??
              '';
          return EmailSentScreen(email: email);
        },
      ),
      // New: shown when verification link is clicked + session confirmed
      GoRoute(
        path: '/email-verified',
        builder: (context, state) => const EmailVerifiedScreen(),
      ),
      GoRoute(
        path: '/callback',
        builder: (context, state) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(
        path: '/auth/callback',
        builder: (context, state) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(
        path: '/biometrics',
        builder: (context, state) => const BiometricPrePromptScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/timeline',
        builder: (context, state) => const TimelineScreen(),
      ),
      GoRoute(
        path: '/focus',
        builder: (context, state) {
          final task = state.extra as TaskItem?;
          return FocusScreen(task: task);
        },
      ),
      GoRoute(
        path: '/task-detail',
        builder: (context, state) {
          final task = state.extra as TaskItem;
          return TaskDetailScreen(initialTask: task);
        },
      ),
      GoRoute(
        path: '/add-task',
        builder: (context, state) => const AddTaskScreen(),
      ),
      GoRoute(
        path: '/edit-task',
        builder: (context, state) {
          final task = state.extra as TaskItem;
          return AddTaskScreen(initialTask: task);
        },
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'theme',
            builder: (context, state) => const ThemeSettingsScreen(),
          ),
          GoRoute(
            path: 'notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: 'security',
            builder: (context, state) => const ChangePasswordScreen(),
          ),
          GoRoute(
            path: 'delete-account',
            builder: (context, state) => const DeleteAccountScreen(),
          ),
        ],
      ),
    ],
  );
});

/// ChangeNotifier that triggers GoRouter refresh when auth state changes.
class _AuthRouterNotifier extends ChangeNotifier {
  _AuthRouterNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, __) {
      notifyListeners();
    });
  }
}
