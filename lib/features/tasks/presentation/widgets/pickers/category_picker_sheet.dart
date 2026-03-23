import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../domain/models/task_model.dart';
import '../../providers/tasks_provider.dart';

Future<TaskCategory?> showCategoryPickerBottomSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<TaskCategory>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _CategoryPickerSheet(),
  );
}

class _CategoryPickerSheet extends ConsumerWidget {
  const _CategoryPickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(taskCategoriesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Select Category", style: AppTextStyles.headingMd),
          const SizedBox(height: 24),
          categories.when(
            data: (catList) => Wrap(
              spacing: 12,
              runSpacing: 12,
              children: catList.map((cat) {
                return GestureDetector(
                  onTap: () => Navigator.pop(context, cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: cat.color.withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cat.color.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.tag, size: 16, color: cat.color),
                        const SizedBox(width: 8),
                        Text(cat.name, style: AppTextStyles.labelMd.copyWith(color: cat.color)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text("Error: $err")),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
