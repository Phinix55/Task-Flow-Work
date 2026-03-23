import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../tasks/presentation/providers/filter_provider.dart';

class FilterBadgeRow extends ConsumerWidget {
  const FilterBadgeRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(filterProvider);
    if (filters.isEmpty) return const SizedBox.shrink();

    final chips = <Widget>[];

    // Status chip
    if (filters.status != 'all') {
      chips.add(_buildChip(
        context, 
        filters.status.toUpperCase(), 
        () => ref.read(filterProvider.notifier).setStatus('all'),
      ));
    }

    // Priority chips
    for (final p in filters.priorities) {
      chips.add(_buildChip(
        context, 
        p.name.toUpperCase(), 
        () => ref.read(filterProvider.notifier).togglePriority(p),
      ));
    }

    // Category chips
    for (final c in filters.categoryIds) {
      chips.add(_buildChip(
        context, 
        c, 
        () => ref.read(filterProvider.notifier).toggleCategory(c),
      ));
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        height: 32,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: chips.length,
          separatorBuilder: (ctx, i) => const SizedBox(width: 8),
          itemBuilder: (ctx, i) => chips[i],
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, VoidCallback onRemove) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.violetSurface,
        borderRadius: AppRadius.button,
        border: Border.all(color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTextStyles.labelSm.copyWith(color: theme.colorScheme.onSurface)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Icon(LucideIcons.x, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }
}
