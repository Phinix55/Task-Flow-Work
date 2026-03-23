enum SessionStatus { completed, abandoned, paused }

class SubtaskItem {
  final String text;
  final bool done;

  SubtaskItem({required this.text, this.done = false});

  factory SubtaskItem.fromJson(Map<String, dynamic> json) {
    return SubtaskItem(
      text: json['text'] as String,
      done: json['done'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'done': done,
    };
  }
}

class FocusSession {
  final String id;
  final String userId;
  final String? taskId;
  final String objective;
  final int durationMins;
  final SessionStatus status;
  final List<SubtaskItem> subtasks;
  final DateTime startedAt;
  final DateTime? endedAt;
  final DateTime createdAt;

  FocusSession({
    required this.id,
    required this.userId,
    this.taskId,
    required this.objective,
    this.durationMins = 25,
    this.status = SessionStatus.completed,
    this.subtasks = const [],
    required this.startedAt,
    this.endedAt,
    required this.createdAt,
  });

  factory FocusSession.fromJson(Map<String, dynamic> json) {
    SessionStatus parsedStatus = SessionStatus.completed;
    final sStr = json['status'] as String?;
    if (sStr == 'abandoned') parsedStatus = SessionStatus.abandoned;
    if (sStr == 'paused') parsedStatus = SessionStatus.paused;

    List<SubtaskItem> parsedSubtasks = [];
    if (json['subtasks'] != null) {
      final subList = json['subtasks'] as List;
      parsedSubtasks = subList.map((e) => SubtaskItem.fromJson(e as Map<String, dynamic>)).toList();
    }

    return FocusSession(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      taskId: json['task_id'] as String?,
      objective: json['objective'] as String,
      durationMins: json['duration_mins'] as int? ?? 25,
      status: parsedStatus,
      subtasks: parsedSubtasks,
      startedAt: DateTime.parse(json['started_at']),
      endedAt: json['ended_at'] != null ? DateTime.parse(json['ended_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'task_id': taskId,
      'objective': objective,
      'duration_mins': durationMins,
      'status': status.name,
      'subtasks': subtasks.map((e) => e.toJson()).toList(),
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      // created_at handled by DB
    };
  }
}
