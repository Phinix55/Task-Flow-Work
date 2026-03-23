import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../tasks/presentation/providers/filter_provider.dart';
import '../../../tasks/domain/models/task_model.dart';

class FilterBottomSheet extends ConsumerWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final filters = ref.watch(filterProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: AppRadius.sheet,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle & Header
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkBorderStrong
                    : AppColors.borderStrong,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Filters",
                  style: AppTextStyles.headingMd.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                TextButton(
                  onPressed: () => ref.read(filterProvider.notifier).clearAll(),
                  child: Text(
                    "Reset",
                    style: AppTextStyles.labelMd.copyWith(
                      color: isDark
                          ? AppColors.darkActionPrimary
                          : AppColors.actionPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Status", isDark),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildStatusChip(
                        context,
                        "All",
                        'all',
                        filters.status == 'all',
                        ref,
                      ),
                      _buildStatusChip(
                        context,
                        "Pending",
                        'pending',
                        filters.status == 'pending',
                        ref,
                      ),
                      _buildStatusChip(
                        context,
                        "Completed",
                        'completed',
                        filters.status == 'completed',
                        ref,
                      ),
                      _buildStatusChip(
                        context,
                        "Overdue",
                        'overdue',
                        filters.status == 'overdue',
                        ref,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  _buildSectionTitle("Priority", isDark),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: TaskPriority.values
                        .map(
                          (p) => _buildPriorityChip(
                            context,
                            p,
                            filters.priorities.contains(p),
                            ref,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 32),

                  // Assuming Categories is hardcoded here for testing or injected from a provider
                  _buildSectionTitle("Categories", isDark),
                  const SizedBox(height: 12),
                  Text(
                    "Categories filtering can be mapped dynamically here.",
                    style: AppTextStyles.bodySm.copyWith(
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Apply Button
          Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              16,
              24,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            child: PrimaryButton(
              text: "Show results",
              onPressed: () => context.pop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: AppTextStyles.labelLg.copyWith(
        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
      ),
    );
  }

  Widget _buildStatusChip(
    BuildContext context,
    String label,
    String value,
    bool isSelected,
    WidgetRef ref,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => ref.read(filterProvider.notifier).setStatus(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.darkActionPrimary : AppColors.actionPrimary)
              : (isDark ? AppColors.darkSurface : AppColors.violetSurface),
          borderRadius: AppRadius.button,
          border: isSelected
              ? null
              : Border.all(
                  color: isDark
                      ? AppColors.darkBorderSubtle
                      : AppColors.borderSubtle,
                ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMd.copyWith(
            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(
    BuildContext context,
    TaskPriority priority,
    bool isSelected,
    WidgetRef ref,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color activeColor;
    if (priority == TaskPriority.high) {
      activeColor = isDark ? AppColors.darkRoseSolid : AppColors.roseSolid;
    } else if (priority == TaskPriority.medium)
      activeColor = isDark ? AppColors.darkAmberSolid : AppColors.amberSolid;
    else
      activeColor = isDark ? AppColors.darkMintSolid : AppColors.mintSolid;

    return GestureDetector(
      onTap: () => ref.read(filterProvider.notifier).togglePriority(priority),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withOpacity(0.15)
              : (isDark ? AppColors.darkSurface : Colors.white),
          borderRadius: AppRadius.button,
          border: Border.all(
            color: isSelected
                ? activeColor
                : (isDark
                      ? AppColors.darkBorderSubtle
                      : AppColors.borderSubtle),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.flag,
              size: 14,
              color: isSelected ? activeColor : theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Text(
              priority.name.toUpperCase(),
              style: AppTextStyles.labelMd.copyWith(
                color: isSelected ? activeColor : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
