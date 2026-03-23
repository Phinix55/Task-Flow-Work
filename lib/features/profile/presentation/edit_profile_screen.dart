import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/snackbar_manager.dart';
import 'providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider).value;
    _nameController = TextEditingController(text: profile?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      SnackbarManager.showError(context, "Name cannot be empty");
      return;
    }

    ref.read(profileActionsProvider).updateName(name);
    // Profile Avatar updating is handled immediately by bottom sheet normally, F60
    
    // F61 Profile Save Notification
    SnackbarManager.showSuccess(context, "Profile updated successfully");
    context.pop();
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
        title: Text("Edit Profile", style: AppTextStyles.headingMd.copyWith(color: theme.colorScheme.onSurface)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text("Display Name", style: AppTextStyles.labelLg.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
               const SizedBox(height: 12),
               TextField(
                 controller: _nameController,
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
                     borderSide: BorderSide(color: isDark ? AppColors.darkVioletText : AppColors.violetSolid, width: 2),
                   ),
                 ),
               ),
               const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
        child: PrimaryButton(
          text: "Save Changes",
          onPressed: _saveProfile,
        ),
      ),
    );
  }
}
