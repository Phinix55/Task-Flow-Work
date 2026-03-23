import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../../features/tasks/domain/models/task_model.dart';

// ──────────────────────────────────────────────────────────────────
// NOTIFICATION ID RANGES
//   1       → Daily motivational (daily repeating)
//   2       → Streak keep-alive  (daily repeating @ 8pm)
//   3–999   → Instant / test
//   1000+   → Task due reminders  (hash of task ID → even = 30min, odd = on-time)
// ──────────────────────────────────────────────────────────────────

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId   = 'taskflow_main';
  static const _channelName = 'TaskFlow Notifications';
  static const _channelDesc = 'Task reminders and daily motivational messages';

  // ── Motivational pool (10 rotating) ──────────────────────────────
  static const _motivational = [
    ('Your focus determines your reality. 🎯', 'What will you accomplish today?'),
    ('Small steps every day.',                  'Consistency beats perfection. Let\'s go!'),
    ('Today is the day.',                        'Your future self is counting on you. Start now!'),
    ('You\'ve got this! 💪',                    'Every task you complete is progress. Keep pushing.'),
    ('One task at a time.',                      'You don\'t need everything. Just the next thing.'),
    ('Rise and grind! ☀️',                      'Your consistency is showing. Keep it up.'),
    ('New day, fresh start.',                    'Clear your list. Rule your day.'),
    ('Excellence is a habit.',                   'Do a little more each day. It compounds.'),
    ('No shortcuts.',                            'Good work today means a better tomorrow.'),
    ('Your to-do list is waiting 📝',           'Let\'s knock it out one by one!'),
  ];

  // ── Init ──────────────────────────────────────────────────────────
  Future<void> initialize() async {
    tz_data.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      settings: InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onTapped,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDesc,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ));
  }

  void _onTapped(NotificationResponse response) {
    // Route to task detail when payload is a task ID.
    // Full navigation can be wired via a GlobalKey<NavigatorState> if desired.
  }

  // ── Permission ───────────────────────────────────────────────────
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    return true;
  }

  // ── NotificationDetails helper ───────────────────────────────────
  NotificationDetails get _details => const NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFF7C3AED),
      enableVibration: true,
      playSound: true,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  // ── TASK REMINDERS ────────────────────────────────────────────────

  /// Schedule 30-min warning + on-time reminder for a task.
  Future<void> scheduleTaskReminder(TaskItem task) async {
    if (task.dueDate == null || task.isCompleted) return;

    final baseId = _taskBaseId(task.id);
    final now    = DateTime.now();
    final due    = task.dueDate!;

    // 30-minute early warning
    final thirtyBefore = due.subtract(const Duration(minutes: 30));
    if (thirtyBefore.isAfter(now)) {
      await _zonedSchedule(
        id:    baseId,
        title: '⏰ Due in 30 minutes',
        body:  task.title,
        at:    thirtyBefore,
        payload: task.id,
      );
    }

    // On-time "due now" ping
    if (due.isAfter(now)) {
      await _zonedSchedule(
        id:    baseId + 1,
        title: '🔴 Task Due Now',
        body:  task.title,
        at:    due,
        payload: task.id,
      );
    }
  }

  /// Cancel both reminders for a task.
  Future<void> cancelTaskReminder(String taskId) async {
    final baseId = _taskBaseId(taskId);
    await _plugin.cancel(id: baseId);
    await _plugin.cancel(id: baseId + 1);
  }

  /// Re-schedule reminders for all pending tasks (on cache seed).
  Future<void> refreshTaskReminders(List<TaskItem> tasks) async {
    // Cancel all task-range pending notifications
    final pending = await _plugin.pendingNotificationRequests();
    for (final n in pending) {
      if (n.id >= 1000) await _plugin.cancel(id: n.id);
    }
    for (final task in tasks) {
      await scheduleTaskReminder(task);
    }
  }

  // ── DAILY MOTIVATIONAL ────────────────────────────────────────────

  /// Schedule a repeating daily motivational at [time] (default 8:00am).
  Future<void> scheduleDailyMotivational({
    TimeOfDay time = const TimeOfDay(hour: 8, minute: 0),
  }) async {
    await _plugin.cancel(id: 1);

    final now  = DateTime.now();
    final index = now.day % _motivational.length;
    final msg  = _motivational[index];

    var schedAt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (schedAt.isBefore(now)) schedAt = schedAt.add(const Duration(days: 1));

    await _zonedSchedule(
      id:    1,
      title: msg.$1,
      body:  msg.$2,
      at:    schedAt,
      matchDateTimeComponents: DateTimeComponents.time, // repeat daily
    );
  }

  Future<void> cancelDailyMotivational() => _plugin.cancel(id: 1);

  // ── STREAK REMINDER ───────────────────────────────────────────────

  /// Daily streak reminder at [time] (default 8:00pm).
  Future<void> scheduleStreakReminder({
    TimeOfDay time = const TimeOfDay(hour: 20, minute: 0),
  }) async {
    await _plugin.cancel(id: 2);

    final now = DateTime.now();
    var schedAt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (schedAt.isBefore(now)) schedAt = schedAt.add(const Duration(days: 1));

    await _zonedSchedule(
      id:    2,
      title: '🔥 Keep your streak alive!',
      body:  'Complete a task today to maintain your streak.',
      at:    schedAt,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelStreakReminder() => _plugin.cancel(id: 2);

  // ── INSTANT (for test / immediate trigger) ────────────────────────
  Future<void> showInstant({
    required String title,
    required String body,
    int id = 99,
  }) async {
    await _plugin.show(
      id: id,
      title: title,
      body:  body,
      notificationDetails: _details,
    );
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  // ── PRIVATE HELPERS ───────────────────────────────────────────────

  Future<void> _zonedSchedule({
    required int id,
    required String title,
    required String body,
    required DateTime at,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body:  body,
      scheduledDate: tz.TZDateTime.from(at, tz.local),
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
      matchDateTimeComponents: matchDateTimeComponents,
    );
  }

  /// Converts a UUID string into a stable int ID in the range [1000, ~1.5M]
  int _taskBaseId(String taskId) {
    final hex = taskId.replaceAll('-', '');
    final trimmed = hex.substring(hex.length - 7);
    // Multiply by 2 so even = early warning, odd = on-time
    return (1000 + (int.tryParse(trimmed, radix: 16) ?? 0) % 500000) * 2;
  }
}
