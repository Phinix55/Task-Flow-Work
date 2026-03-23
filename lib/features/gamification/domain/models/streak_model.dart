class Streak {
  final String userId;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastClaimedAt;
  final DateTime updatedAt;

  Streak({
    required this.userId,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastClaimedAt,
    required this.updatedAt,
  });

  factory Streak.fromJson(Map<String, dynamic> json) {
    return Streak(
      userId: json['user_id'] as String,
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      lastClaimedAt: json['last_claimed_at'] != null 
          ? DateTime.tryParse(json['last_claimed_at']) 
          : null,
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_claimed_at': lastClaimedAt?.toIso8601String().split('T')[0], // DATE only
      // updated_at handled by DB
    };
  }

  // Helper logic to check if claimed today
  bool get isClaimedToday {
    if (lastClaimedAt == null) return false;
    final now = DateTime.now();
    return lastClaimedAt!.year == now.year &&
           lastClaimedAt!.month == now.month &&
           lastClaimedAt!.day == now.day;
  }
}

class StreakLog {
  final String id;
  final String userId;
  final DateTime logDate;
  final int tasksDone;
  final int focusMins;

  StreakLog({
    required this.id,
    required this.userId,
    required this.logDate,
    this.tasksDone = 0,
    this.focusMins = 0,
  });

  factory StreakLog.fromJson(Map<String, dynamic> json) {
    return StreakLog(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      logDate: DateTime.parse(json['log_date']),
      tasksDone: json['tasks_done'] as int? ?? 0,
      focusMins: json['focus_mins'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'log_date': logDate.toIso8601String().split('T')[0],
      'tasks_done': tasksDone,
      'focus_mins': focusMins,
    };
  }
}
