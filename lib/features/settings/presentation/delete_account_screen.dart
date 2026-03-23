import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _controller = TextEditingController();
  bool _canDelete = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _canDelete = _controller.text == 'DELETE';
      });
    });
  }

  void _executeDelete() {
    if (!_canDelete) return;

    // F70 Multi-modal escalation (Mock wipe)
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Theme.of(context).scaffoldBackgroundColor,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );

    // Mock network request & local wipe
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        context.go('/welcome');
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: theme.colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text("Delete Account", style: AppTextStyles.headingMd.copyWith(color: theme.colorScheme.onSurface)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkRoseSolid.withOpacity(0.1) : AppColors.roseSolid.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.darkRoseSolid.withOpacity(0.3) : AppColors.roseSolid.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 48, color: isDark ? AppColors.darkRoseSolid : AppColors.roseSolid),
                  const SizedBox(height: 16),
                  Text("This action is irreversible", style: AppTextStyles.headingMd.copyWith(color: isDark ? AppColors.darkRoseSolid : AppColors.roseSolid)),
                  const SizedBox(height: 8),
                  Text("All your tasks, streaks, and personal data will be permanently erased. There is no way to recover your account.", style: AppTextStyles.bodyMd.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary), textAlign: TextAlign.center),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text("To confirm, type 'DELETE' below:", style: AppTextStyles.labelLg.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              style: AppTextStyles.bodyLg.copyWith(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDark ? AppColors.darkRoseSolid : AppColors.roseSolid, width: 2),
                ),
                hintText: "DELETE",
                hintStyle: AppTextStyles.bodyLg.copyWith(color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
        child: PrimaryButton(
          text: "Permanently Delete Account",
          onPressed: _canDelete ? _executeDelete : null,
        ),
      ),
    );
  }
}
