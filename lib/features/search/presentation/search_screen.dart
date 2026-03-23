import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:taskflow/app/theme/app_colors.dart';
import 'package:taskflow/app/theme/app_text_styles.dart';
import 'package:taskflow/app/theme/app_radius.dart';
import 'package:taskflow/features/tasks/domain/models/task_model.dart';
import 'package:taskflow/features/tasks/presentation/providers/tasks_provider.dart';
import 'providers/search_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitSearch(String val) {
    if (val.trim().isNotEmpty) {
      ref.read(recentSearchesProvider.notifier).addSearch(val.trim());
    }
  }

  void _applyRecent(String query) {
    _controller.text = query;
    ref.read(searchQueryProvider.notifier).update(query);
    _focusNode.unfocus();
  }

  void _clearSearch() {
    _controller.clear();
    ref.read(searchQueryProvider.notifier).update('');
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final query = ref.watch(searchQueryProvider);
    final results = ref.watch(searchResultsProvider);
    final recent = ref.watch(recentSearchesProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Search Bar ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      ref.read(searchQueryProvider.notifier).update('');
                      context.pop();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle),
                      ),
                      child: Icon(LucideIcons.arrowLeft, size: 18, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorderDefault : AppColors.borderDefault,
                        ),
                        boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(LucideIcons.search, size: 18, color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              style: AppTextStyles.bodyLg.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                              decoration: InputDecoration(
                                hintText: 'Search tasks, categories, priority…',
                                hintStyle: AppTextStyles.bodyLg.copyWith(color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              textInputAction: TextInputAction.search,
                              onChanged: (val) => ref.read(searchQueryProvider.notifier).update(val),
                              onSubmitted: _submitSearch,
                            ),
                          ),
                          if (query.isNotEmpty)
                            GestureDetector(
                              onTap: _clearSearch,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkBorderStrong : AppColors.borderStrong,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.close, size: 14, color: isDark ? AppColors.darkSurface : Colors.white),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Content ─────────────────────────────────────────────
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: query.isEmpty
                    ? _buildIdleState(isDark, recent)
                    : results.isEmpty
                        ? _buildEmptyState(isDark)
                        : _buildResults(isDark, results),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── IDLE STATE ────────────────────────────────────────────────────
  Widget _buildIdleState(bool isDark, List<String> recent) {
    return ListView(
      key: const ValueKey('idle'),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        if (recent.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Recent Searches",
                  style: AppTextStyles.labelLg.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      fontWeight: FontWeight.w700)),
              GestureDetector(
                onTap: () => ref.read(recentSearchesProvider.notifier).clear(),
                child: Text("Clear all",
                    style: AppTextStyles.labelSm.copyWith(
                        color: isDark ? AppColors.darkRoseSolid : AppColors.roseSolid)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recent.map((r) {
              return GestureDetector(
                onTap: () => _applyRecent(r),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: AppRadius.button,
                    border: Border.all(color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.history, size: 14,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(r,
                          style: AppTextStyles.bodyMd.copyWith(
                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => ref.read(recentSearchesProvider.notifier).remove(r),
                        child: Icon(LucideIcons.x, size: 12,
                            color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
        ],

        // Quick tips
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.violetSurface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? AppColors.darkBorderSubtle : AppColors.violetSurface),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.lightbulb, size: 16, color: AppColors.brandOrange),
                  const SizedBox(width: 8),
                  Text("Search Tips",
                      style: AppTextStyles.labelMd.copyWith(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              ...[
                ("Task title", "e.g. 'email', 'gym'"),
                ("Category", "e.g. 'work', 'health'"),
                ("Priority", "e.g. 'high', 'medium', 'low'"),
                ("Description", "any keyword in task notes"),
              ].map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(width: 4, height: 4, decoration: BoxDecoration(color: AppColors.brandOrange, shape: BoxShape.circle)),
                        const SizedBox(width: 10),
                        Text("${tip.$1} — ",
                            style: AppTextStyles.labelSm.copyWith(
                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                fontWeight: FontWeight.w600)),
                        Text(tip.$2,
                            style: AppTextStyles.labelSm.copyWith(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  // ── EMPTY STATE ───────────────────────────────────────────────────
  Widget _buildEmptyState(bool isDark) {
    return Center(
      key: const ValueKey('empty'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.bgSecondary,
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.searchX, size: 32,
                color: isDark ? AppColors.darkBorderStrong : AppColors.borderStrong),
          ),
          const SizedBox(height: 20),
          Text("No tasks found",
              style: AppTextStyles.headingMd.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text("Try different keywords",
              style: AppTextStyles.bodyMd.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
        ],
      ),
    );
  }

  // ── RESULTS ───────────────────────────────────────────────────────
  Widget _buildResults(bool isDark, List<TaskItem> results) {
    return Column(
      key: const ValueKey('results'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text("${results.length} result${results.length == 1 ? '' : 's'}",
              style: AppTextStyles.labelMd.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: results.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, i) => _buildTaskCard(results[i], isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(TaskItem task, bool isDark) {
    final query = ref.read(searchQueryProvider).toLowerCase();

    Color priorityColor;
    switch (task.priority) {
      case TaskPriority.high:
        priorityColor = isDark ? AppColors.darkRoseSolid : AppColors.roseSolid;
        break;
      case TaskPriority.medium:
        priorityColor = isDark ? AppColors.darkAmberSolid : AppColors.amberSolid;
        break;
      default:
        priorityColor = isDark ? AppColors.darkMintSolid : AppColors.mintSolid;
    }

    return GestureDetector(
      onTap: () {
        _submitSearch(query);
        context.push('/task-detail', extra: task);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? AppColors.darkBorderSubtle : AppColors.borderDefault.withValues(alpha: 0.5)),
          boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Completion toggle
            GestureDetector(
              onTap: () {
                ref.read(taskActionsProvider).toggleTaskCompletion(task.id, !task.isCompleted);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isCompleted ? AppColors.brandOrange : Colors.transparent,
                  border: Border.all(
                    color: task.isCompleted
                        ? AppColors.brandOrange
                        : (isDark ? AppColors.darkBorderStrong.withValues(alpha: 0.5) : AppColors.borderStrong.withValues(alpha: 0.4)),
                    width: 1.5,
                  ),
                ),
                child: task.isCompleted
                    ? const Icon(Icons.check, size: 13, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 14),

            // Task Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    task.title,
                    style: AppTextStyles.bodyLg.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (task.description != null && task.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description!,
                      style: AppTextStyles.bodySm.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 10),

                  // Tags row
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      // Priority badge
                      _buildTag(
                        task.priority.name[0].toUpperCase() + task.priority.name.substring(1),
                        priorityColor.withValues(alpha: 0.15),
                        priorityColor,
                      ),

                      // Category badge
                      if (task.category != null)
                        _buildTag(
                          task.category!.name,
                          isDark ? AppColors.darkVioletSurface : AppColors.violetSurface,
                          isDark ? AppColors.darkVioletText : AppColors.violetSolid,
                        ),

                      // Due date
                      if (task.dueDate != null)
                        _buildTag(
                          DateFormat('MMM d, h:mma').format(task.dueDate!),
                          isDark ? AppColors.darkSurfaceRaised : AppColors.bgSecondary,
                          isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          icon: LucideIcons.calendar,
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(LucideIcons.chevronRight, size: 16,
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color bg, Color fg, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: fg),
            const SizedBox(width: 4),
          ],
          Text(label,
              style: AppTextStyles.labelXs.copyWith(
                  color: fg, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
