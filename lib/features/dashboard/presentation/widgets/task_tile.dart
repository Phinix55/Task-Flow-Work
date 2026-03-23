import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../tasks/domain/models/task_model.dart';
import 'package:intl/intl.dart';

// Helper widget for the dotted separator lines required by the new reference
class DottedSeparator extends StatelessWidget {
  final Color color;
  const DottedSeparator({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 3.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(decoration: BoxDecoration(color: color)),
            );
          }),
        );
      },
    );
  }
}

class TaskTile extends StatefulWidget {
  final TaskItem task;
  final VoidCallback onToggleComplete;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final bool isLast;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggleComplete,
    required this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.isLast = false,
  });

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.task.isCompleted;
  }

  @override
  void didUpdateWidget(covariant TaskTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.isCompleted != widget.task.isCompleted) {
      _isCompleted = widget.task.isCompleted;
    }
  }

  void _handleToggle() {
    setState(() {
      _isCompleted = !_isCompleted;
    });
    widget.onToggleComplete();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String timeStr = "";
    if (widget.task.dueDate != null) {
      timeStr = DateFormat('HH:mm').format(widget.task.dueDate!);
    } else {
      timeStr = "--:--";
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _isCompleted ? 0.4 : 1.0,
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: Container(
          color: Colors.transparent, // Required for tap targets on 'flat' whitespace
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left element: Checkbox
                    GestureDetector(
                      onTap: _handleToggle,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isCompleted 
                              ? AppColors.brandOrange 
                              : Colors.transparent,
                          border: Border.all(
                            color: _isCompleted 
                                ? AppColors.brandOrange 
                                : (isDark ? AppColors.darkBorderStrong.withValues(alpha: 0.5) : AppColors.borderStrong.withValues(alpha: 0.4)),
                            width: 1.5,
                          ),
                        ),
                        child: _isCompleted 
                            ? const Icon(Icons.check, size: 14, color: Colors.white) 
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Center Element: Title and Optional Description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.task.title,
                            style: AppTextStyles.bodyLg.copyWith(
                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              decoration: _isCompleted ? TextDecoration.lineThrough : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.task.description != null && widget.task.description!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.task.description!,
                              style: AppTextStyles.labelXs.copyWith(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ]
                        ]
                      )
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Right Element: Time string
                    Text(
                      timeStr,
                      style: AppTextStyles.labelMd.copyWith(
                        color: isDark ? AppColors.darkTextDisabled : AppColors.textDisabled,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Bottom Dotted Separator
              if (!widget.isLast)
                DottedSeparator(
                  color: isDark ? AppColors.darkBorderDefault.withValues(alpha: 0.3) : AppColors.borderSubtle,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
