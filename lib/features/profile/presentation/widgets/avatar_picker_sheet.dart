import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_radius.dart';
import '../providers/profile_provider.dart';

class AvatarPickerSheet extends ConsumerWidget {
  const AvatarPickerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<String> avatars = [
      'https://api.dicebear.com/7.x/notionists/png?seed=Felix',
      'https://api.dicebear.com/7.x/notionists/png?seed=Aneka',
      'https://api.dicebear.com/7.x/notionists/png?seed=Caleb',
      'https://api.dicebear.com/7.x/notionists/png?seed=Jasmine',
      'https://api.dicebear.com/7.x/notionists/png?seed=Oliver',
      'https://api.dicebear.com/7.x/notionists/png?seed=Abby',
    ];

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: AppRadius.sheet,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle & Header
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorderStrong : AppColors.borderStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Choose Avatar", style: AppTextStyles.headingMd.copyWith(color: theme.colorScheme.onSurface)),
                IconButton(
                  icon: Icon(LucideIcons.x, color: theme.colorScheme.onSurface),
                  onPressed: () => context.pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.of(context).padding.bottom + 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: avatars.length + 1, // +1 for "Initials" default
              itemBuilder: (context, index) {
                if (index == 0) {
                  return GestureDetector(
                    onTap: () {
                      ref.read(profileActionsProvider).updateAvatar(''); // Use '' instead of null for simplicity or add a clear method
                      context.pop();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.violetSurface,
                        shape: BoxShape.circle,
                        border: Border.all(color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle),
                      ),
                      child: Center(
                        child: Text("Aa", style: AppTextStyles.headingLg.copyWith(color: isDark ? AppColors.darkVioletText : AppColors.violetSolid)),
                      ),
                    ),
                  );
                }

                final avatarUrl = avatars[index - 1];
                return GestureDetector(
                  onTap: () {
                    ref.read(profileActionsProvider).updateAvatar(avatarUrl);
                    context.pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle),
                      image: DecorationImage(
                        image: NetworkImage(avatarUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
