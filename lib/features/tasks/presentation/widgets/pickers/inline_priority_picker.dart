import 'package:flutter/material.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../domain/models/task_model.dart';

class InlinePriorityPicker extends StatelessWidget {
  final TaskPriority selectedPriority;
  final ValueChanged<TaskPriority> onPriorityChanged;

  const InlinePriorityPicker({
    super.key,
    required this.selectedPriority,
    required this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        _buildPill(TaskPriority.low, "Low", isDark ? AppColors.darkMintSolid : AppColors.mintSolid, isDark),
        const SizedBox(width: 8),
        _buildPill(TaskPriority.medium, "Normal", isDark ? AppColors.darkAmberSolid : AppColors.amberSolid, isDark),
        const SizedBox(width: 8),
        _buildPill(TaskPriority.high, "High", isDark ? AppColors.darkRoseSolid : AppColors.roseSolid, isDark),
      ],
    );
  }

  Widget _buildPill(TaskPriority priority, String label, Color color, bool isDark) {
    final isSelected = priority == selectedPriority;
    
    return GestureDetector(
      onTap: () => onPriorityChanged(priority),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: isDark ? 0.3 : 0.15) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : (isDark ? AppColors.darkBorderDefault : AppColors.borderSubtle),
            width: isSelected ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: isSelected ? color : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
