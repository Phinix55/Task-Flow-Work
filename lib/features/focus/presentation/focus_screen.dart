import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../dashboard/presentation/widgets/floating_nav_bar.dart';
import '../../tasks/domain/models/task_model.dart';
import '../../../../core/widgets/snackbar_manager.dart';

class FocusScreen extends ConsumerStatefulWidget {
  final TaskItem? task;
  
  const FocusScreen({super.key, this.task});

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  
  // Setup Mode vs Active Mode
  bool _isSelectionMode = true;
  bool _isPlaying = false;
  
  // Instant Task Config
  final TextEditingController _titleController = TextEditingController();
  final List<TextEditingController> _subtaskControllers = [TextEditingController()];
  int _selectedDuration = 25; // in minutes
  
  // Active Running Config
  List<Map<String, dynamic>> _activeSubtasks = [];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: Duration(minutes: _selectedDuration),
      value: 1.0, 
    );
    
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _isSelectionMode = false;
      _initActiveSessionFromSetup();
    }
  }

  void _initActiveSessionFromSetup() {
    _activeSubtasks = _subtaskControllers
        .where((c) => c.text.trim().isNotEmpty)
        .map((c) => {"title": c.text.trim(), "isCompleted": false})
        .toList();

    _progressController.duration = Duration(minutes: _selectedDuration);
    _progressController.value = 1.0;
    _progressController.reverse(from: 1.0);
    _isPlaying = true;
  }

  @override
  void dispose() {
    _progressController.dispose();
    _titleController.dispose();
    for (var c in _subtaskControllers) { c.dispose(); }
    super.dispose();
  }

  void _beginFocusSession() {
    if (_titleController.text.trim().isEmpty) {
      SnackbarManager.showError(context, "Please enter a focus objective");
      return;
    }
    
    setState(() {
      _isSelectionMode = false;
      _initActiveSessionFromSetup();
    });
    SnackbarManager.showSuccess(context, "Session started");
  }

  void _toggleTimer() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _progressController.reverse(from: _progressController.value);
      } else {
        _progressController.stop();
      }
    });
  }
  
  void _finishSession() {
    _progressController.stop();
    SnackbarManager.showSuccess(context, "Focus Session Complete! 🎉");
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _isSelectionMode) context.go('/dashboard');
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: _isSelectionMode 
                ? _buildSetupMode(context, isDark) 
                : _buildActiveMode(context, isDark),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: _isSelectionMode 
            ? FloatingNavBar(
                onFabTap: () {
                  context.push('/add-task');
                },
              )
            : null, // HIDDEN DURING ACTIVE FOCUS
      ),
    );
  }

  // ==== SETUP MODE (Instant Task Creation) ====
  Widget _buildSetupMode(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      key: const ValueKey("setup_mode"),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
               GestureDetector(
                 onTap: () => context.go('/dashboard'),
                 child: Icon(LucideIcons.arrowLeft, size: 28, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
               ),
               const SizedBox(width: 16),
               Text(
                 "Instant Focus",
                 style: AppTextStyles.headingLg.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary, fontWeight: FontWeight.bold),
               ),
            ]
          ),
          const SizedBox(height: 48),

          TextField(
            controller: _titleController,
            style: AppTextStyles.headingXl.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary, fontSize: 32),
            decoration: InputDecoration(
               hintText: "What's the main objective?",
               hintStyle: AppTextStyles.headingXl.copyWith(color: isDark ? AppColors.darkTextMuted : AppColors.textMuted, fontSize: 32),
               filled: false,
               fillColor: Colors.transparent,
               border: InputBorder.none,
               enabledBorder: InputBorder.none,
               focusedBorder: InputBorder.none,
               contentPadding: EdgeInsets.zero,
            ),
          ),
          
          const SizedBox(height: 48),
          
          Text("Break it down", style: AppTextStyles.headingMd.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          ...List.generate(_subtaskControllers.length, (index) {
             return Padding(
               padding: const EdgeInsets.only(bottom: 16),
               child: TextField(
                  controller: _subtaskControllers[index],
                  style: AppTextStyles.bodyLg.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                  decoration: InputDecoration(
                     hintText: "Add a subtask...",
                     hintStyle: AppTextStyles.bodyLg.copyWith(color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                     filled: false,
                     fillColor: Colors.transparent,
                     contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                     border: UnderlineInputBorder(borderSide: BorderSide(color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle)),
                     enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle)),
                     focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
                     suffixIcon: IconButton(
                       icon: Icon(LucideIcons.x, size: 18, color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                       onPressed: () {
                         setState(() {
                           if (_subtaskControllers.length > 1) {
                             _subtaskControllers.removeAt(index);
                           } else {
                             _subtaskControllers[index].clear();
                           }
                         });
                       },
                     ),
                  ),
               ),
             );
          }),
          const SizedBox(height: 8),
          GestureDetector(
             onTap: () => setState(() => _subtaskControllers.add(TextEditingController())),
             child: Row(
               children: [
                  Icon(LucideIcons.plus, size: 20, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                  const SizedBox(width: 12),
                  Text("Add another step", style: AppTextStyles.bodyLg.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary, fontWeight: FontWeight.w500)),
               ]
             )
          ),

          const SizedBox(height: 64),

          Text("Duration", style: AppTextStyles.headingMd.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [15, 25, 45, 60].map((mins) => _buildDurationChip(mins, isDark)).toList(),
          ),

          const SizedBox(height: 80),

          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _beginFocusSession,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white : Colors.black,
                foregroundColor: isDark ? Colors.black : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text(
                "Start Session",
                style: AppTextStyles.labelLg.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildDurationChip(int mins, bool isDark) {
    bool isSelected = _selectedDuration == mins;
    return GestureDetector(
      onTap: () => setState(() => _selectedDuration = mins),
      child: AnimatedContainer(
         duration: const Duration(milliseconds: 200),
         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
         decoration: BoxDecoration(
            color: isSelected ? (isDark ? Colors.white : Colors.black) : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isSelected ? Colors.transparent : (isDark ? AppColors.darkBorderSubtle : AppColors.borderStrong)),
         ),
         child: Text(
            "$mins m",
            style: AppTextStyles.bodyLg.copyWith(
               color: isSelected ? (isDark ? Colors.black : Colors.white) : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
               fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
         ),
      ),
    );
  }

  // ==== ACTIVE MODE (Full Screen Timer Layout) ====
  Widget _buildActiveMode(BuildContext context, bool isDark) {
    final title = _titleController.text.trim().isEmpty ? "Deep Focus" : _titleController.text.trim();
    final allDone = _activeSubtasks.isNotEmpty && _activeSubtasks.every((s) => s["isCompleted"] == true);

    return SingleChildScrollView(
      key: const ValueKey("active_mode"),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Top Pill Banner (Equalizer)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceRaised : AppColors.bgSecondary,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: AppColors.brandOrange, shape: BoxShape.circle),
                  child: const Icon(Icons.equalizer_rounded, color: Colors.white, size: 12),
                ),
                const SizedBox(width: 8),
                Text(
                  "Deep Focus Active",
                  style: AppTextStyles.labelSm.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    setState(() {
                       _isSelectionMode = true;
                       _progressController.stop();
                       _isPlaying = false;
                    });
                  },
                  child: Icon(LucideIcons.x, size: 16, color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                ),
              ],
            ),
          ),

          const SizedBox(height: 48),
          
          Text(title, style: AppTextStyles.headingXl.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text("$_selectedDuration Minute Session", style: AppTextStyles.bodyLg.copyWith(color: isDark ? AppColors.darkTextMuted : AppColors.textMuted)),
          
          const SizedBox(height: 56),

          // Thick Custom Arc Timer
          SizedBox(
            width: 260,
            height: 260,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background track (lighter pink/rose)
                CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 24,
                  color: isDark ? AppColors.darkSurfaceRaised : AppColors.brandPink.withValues(alpha: 0.2),
                ),
                // Foreground Progress (Orange Thick)
                AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) {
                    return CircularProgressIndicator(
                      value: _progressController.value,
                      strokeWidth: 24,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation(AppColors.brandOrange),
                      strokeCap: StrokeCap.round,
                    );
                  },
                ),
                // Center Digits
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) {
                        final duration = _progressController.duration! * _progressController.value;
                        final minutes = duration.inMinutes.toString().padLeft(2, '0');
                        final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
                        
                        return Text(
                          "$minutes:$seconds",
                          style: AppTextStyles.headingXl.copyWith(
                            fontSize: 48,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        );
                      }
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isPlaying ? "Focusing..." : "Paused",
                      style: AppTextStyles.bodyLg.copyWith(
                        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 56),

          // Subtasks Flat List rendering
          ...List.generate(_activeSubtasks.length, (index) {
            final subtask = _activeSubtasks[index];
            return _buildFlatSubtaskRow(subtask["title"], subtask["isCompleted"], isDark, () {
              setState(() {
                _activeSubtasks[index]["isCompleted"] = !subtask["isCompleted"];
              });
            });
          }),

          const SizedBox(height: 56),

          // Action Pill (Floating Style black/white pill)
          allDone 
            ? GestureDetector(
                onTap: _finishSession,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  decoration: BoxDecoration(color: AppColors.brandOrange, borderRadius: BorderRadius.circular(32)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text("Finish Session", style: AppTextStyles.labelLg.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              )
            : GestureDetector(
                onTap: _toggleTimer,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [BoxShadow(color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.2), blurRadius: 16, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded, 
                        color: isDark ? Colors.black : Colors.white, 
                        size: 20
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _isPlaying ? "Pause" : "Resume",
                        style: AppTextStyles.labelLg.copyWith(
                          color: isDark ? Colors.black : Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildFlatSubtaskRow(String title, bool isCompleted, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? (isDark ? AppColors.darkSurfaceRaised : AppColors.borderDefault) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? Colors.transparent : (isDark ? AppColors.darkBorderDefault : AppColors.borderStrong),
                  width: 2,
                ),
              ),
              child: isCompleted 
                  ? Icon(Icons.check, size: 14, color: isDark ? AppColors.darkTextPrimary : Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: AppTextStyles.bodyLg.copyWith(
                  color: isCompleted 
                      ? (isDark ? AppColors.darkTextMuted : AppColors.textMuted)
                      : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                  fontWeight: FontWeight.w500,
                ),
                child: Text(title),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
