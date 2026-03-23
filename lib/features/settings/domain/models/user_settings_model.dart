class UserSettings {
  final String userId;
  final bool notificationsEnabled;
  final bool dailyReminderEnabled;
  final String dailyReminderTime;
  final bool focusReminderEnabled;
  final bool streakAlertsEnabled;
  final String themeMode; // 'light', 'dark', 'system'
  final DateTime updatedAt;

  UserSettings({
    required this.userId,
    this.notificationsEnabled = true,
    this.dailyReminderEnabled = true,
    this.dailyReminderTime = '08:00:00',
    this.focusReminderEnabled = true,
    this.streakAlertsEnabled = true,
    this.themeMode = 'system',
    required this.updatedAt,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      userId: json['user_id'] as String,
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      dailyReminderEnabled: json['daily_reminder_enabled'] as bool? ?? true,
      dailyReminderTime: json['daily_reminder_time'] as String? ?? '08:00:00',
      focusReminderEnabled: json['focus_reminder_enabled'] as bool? ?? true,
      streakAlertsEnabled: json['streak_alerts_enabled'] as bool? ?? true,
      themeMode: json['theme_mode'] as String? ?? 'system',
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'notifications_enabled': notificationsEnabled,
      'daily_reminder_enabled': dailyReminderEnabled,
      'daily_reminder_time': dailyReminderTime,
      'focus_reminder_enabled': focusReminderEnabled,
      'streak_alerts_enabled': streakAlertsEnabled,
      'theme_mode': themeMode,
    };
  }
}
