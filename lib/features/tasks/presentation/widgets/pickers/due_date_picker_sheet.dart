import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';

Future<DateTime?> showDueDatePickerBottomSheet(BuildContext context, DateTime? initialDate) {
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _DueDatePickerSheet(initialDate: initialDate),
  );
}

class _DueDatePickerSheet extends StatefulWidget {
  final DateTime? initialDate;
  const _DueDatePickerSheet({this.initialDate});

  @override
  State<_DueDatePickerSheet> createState() => _DueDatePickerSheetState();
}

class _DueDatePickerSheetState extends State<_DueDatePickerSheet> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 32),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Select Due Date", style: AppTextStyles.headingMd),
              TextButton(
                onPressed: () => Navigator.pop(context, _selectedDate),
                child: Text("Done", style: AppTextStyles.labelMd.copyWith(color: isDark ? AppColors.darkActionPrimary : AppColors.actionPrimary)),
              ),
            ],
          ),
          if (_selectedDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate!),
                style: AppTextStyles.bodyLg.copyWith(
                  color: isDark ? AppColors.darkActionPrimary : AppColors.actionPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 16),
          // Smart Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildShortcutChip("Today", today, isDark),
                const SizedBox(width: 8),
                _buildShortcutChip("Tomorrow", tomorrow, isDark),
                const SizedBox(width: 8),
                
                // Clear Date Button
                GestureDetector(
                  onTap: () {
                    setState(() => _selectedDate = null);
                    Navigator.pop(context, DateTime.fromMillisecondsSinceEpoch(0)); // Sentinel for clear
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark ? AppColors.darkBorderDefault : AppColors.borderSubtle,
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      "Clear",
                      style: AppTextStyles.labelSm.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Calendar
          SizedBox(
            height: 280,
            child: Theme(
              data: theme.copyWith(
                colorScheme: theme.colorScheme.copyWith(
                  primary: isDark ? Colors.white : Colors.black, // Literal white/black for the circle
                  onPrimary: isDark ? Colors.black : Colors.white, // Invert for the text
                  onSurface: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  secondary: isDark ? AppColors.darkVioletText : AppColors.violetSolid,
                  surface: isDark ? AppColors.darkSurfaceRaised : Colors.white,
                ),
                datePickerTheme: DatePickerThemeData(
                   headerForegroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                   headerHeadlineStyle: AppTextStyles.headingMd,
                   dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) return isDark ? Colors.black : Colors.white;
                      return isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
                   }),
                   // Remove any border for today, just a dot or circle is enough.
                   todayBackgroundColor: WidgetStateProperty.all(isDark ? AppColors.darkVioletBorder.withValues(alpha: 0.2) : AppColors.violetSurface),
                   todayForegroundColor: WidgetStateProperty.all(isDark ? AppColors.darkVioletText : AppColors.violetSolid),
                   todayBorder: BorderSide.none,
                ),
              ),
              child: CalendarDatePicker(
                initialDate: (_selectedDate != null && _selectedDate!.isAfter(today)) ? _selectedDate! : today,
                firstDate: today,
                lastDate: DateTime(2100),
                onDateChanged: (date) {
                  // Keep the time if one was already selected
                  final newDate = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    _selectedDate?.hour ?? 0,
                    _selectedDate?.minute ?? 0,
                  );
                  setState(() => _selectedDate = newDate);
                },
              ),
            ),
          ),

          const Divider(height: 32),

          // Time Selection
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.access_time_rounded, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
            title: Text("Set Time", style: AppTextStyles.bodyLg),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceRaised : AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _selectedDate != null ? DateFormat('HH:mm').format(_selectedDate!) : "--:--",
                style: AppTextStyles.labelMd.copyWith(
                  color: isDark ? AppColors.darkActionPrimary : AppColors.actionPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(_selectedDate ?? DateTime.now()),
              );
              if (picked != null) {
                final base = _selectedDate ?? DateTime.now();
                setState(() {
                  _selectedDate = DateTime(
                    base.year, base.month, base.day,
                    picked.hour, picked.minute,
                  );
                });
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildShortcutChip(String label, DateTime date, bool isDark) {
    final isSelected = _selectedDate != null ? DateUtils.isSameDay(_selectedDate, date) : false;
    final color = isDark ? AppColors.darkActionPrimary : AppColors.actionPrimary;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedDate = date);
      },
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
