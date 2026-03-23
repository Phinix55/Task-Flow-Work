import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/utils/snackbar_manager.dart';

class NoInternetScreen extends StatefulWidget {
  const NoInternetScreen({super.key});

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  bool _isLoading = false;

  void _handleRetry() async {
    setState(() => _isLoading = true);
    
    // Mock network check delay
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;
    
    setState(() => _isLoading = false);
    
    // Show toast indicating still offline since it's just a mock
    SnackbarManager.showSnackbar(
      context,
      message: 'Still offline. Please check your connection.',
      type: SnackbarType.warning,
      iconOverride: LucideIcons.wifiOff,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration placeholder
              Icon(
                LucideIcons.wifiOff,
                size: 80,
                color: theme.colorScheme.onSurface.withOpacity(0.2),
              ),
              const SizedBox(height: 32),
              
              Text(
                "No internet connection",
                style: AppTextStyles.headingXl.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              Text(
                "Check your wifi or mobile data and try again.",
                style: AppTextStyles.bodyLg.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              PrimaryButton(
                text: "Retry",
                isLoading: _isLoading,
                onPressed: _handleRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
