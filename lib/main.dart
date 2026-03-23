import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_links/app_links.dart';

import 'app/router.dart';
import 'app/theme/app_theme.dart';
import 'app/theme/app_theme_provider.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize local notifications
  await NotificationService().initialize();
  await NotificationService().requestPermission();
  // Schedule daily motivational (8am) and streak reminder (8pm)
  await NotificationService().scheduleDailyMotivational();
  await NotificationService().scheduleStreakReminder();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const TaskHubApp(),
    ),
  );
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

class TaskHubApp extends ConsumerStatefulWidget {
  const TaskHubApp({super.key});

  @override
  ConsumerState<TaskHubApp> createState() => _TaskHubAppState();
}

class _TaskHubAppState extends ConsumerState<TaskHubApp> {
  late final AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  /// Listens to incoming deep links (e.g. taskflow://auth/callback?...)
  /// and hands them off to Supabase to extract the session.
  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // Handle link if app was opened from a cold start via the deep link
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      await _handleDeepLink(initialLink);
    }

    // Handle links while the app is already running (warm start)
    _appLinks.uriLinkStream.listen((uri) async {
      await _handleDeepLink(uri);
    });
  }

  Future<void> _handleDeepLink(Uri uri) async {
    // Let Supabase parse the token from the URL — this creates the session
    await Supabase.instance.client.auth.getSessionFromUrl(uri);

    // After Supabase exchanges the token, navigate based on the URI host
    if (uri.scheme == 'taskflow' && uri.host == 'reset-password') {
      // Navigate to the reset password screen
      // We use addPostFrameCallback so the router is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(routerProvider).go('/reset-password');
      });
    }
    // For taskflow://auth/callback the router redirect guard handles navigation
    // automatically via the GoRouter refreshListenable + auth state change.
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'TaskFlow',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
