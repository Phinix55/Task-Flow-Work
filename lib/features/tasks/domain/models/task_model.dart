import 'package:flutter/material.dart';

enum TaskPriority { low, medium, high }

class TaskCategory {
  final String id;
  final String userId;
  final String name;
  final Color color;
  final bool isSystem;

  const TaskCategory({
    required this.id,
    required this.userId,
    required this.name,
    required this.color,
    required this.isSystem,
  });

  factory TaskCategory.fromJson(Map<String, dynamic> json) {
    return TaskCategory(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      color: _colorFromHex(json['color_hex'] as String? ?? '#6C63FF'),
      isSystem: json['is_system'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'color_hex': _colorToHex(color),
      'is_system': isSystem,
    };
  }
}

class TaskItem {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final TaskPriority priority;
  final bool isCompleted;
  final DateTime? completedAt;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Relations
  final String? categoryId;
  final TaskCategory? category;

  const TaskItem({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.dueDate,
    this.priority = TaskPriority.low,
    this.isCompleted = false,
    this.completedAt,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
    this.categoryId,
    this.category,
  });

  bool get isOverdue {
    if (isCompleted || dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return due.isBefore(today);
  }

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    TaskPriority parsedPriority = TaskPriority.low;
    final pStr = json['priority'] as String?;
    if (pStr == 'medium') parsedPriority = TaskPriority.medium;
    if (pStr == 'high') parsedPriority = TaskPriority.high;

    TaskCategory? parsedCat;
    if (json['task_categories'] != null) {
      parsedCat = TaskCategory.fromJson(json['task_categories']);
    }

    return TaskItem(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      categoryId: json['category_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      priority: parsedPriority,
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      isCompleted: json['is_completed'] as bool? ?? false,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      category: parsedCat,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': category?.id ?? categoryId,
      'title': title,
      'description': description,
      'priority': priority.name,
      'due_date': dueDate?.toIso8601String(),
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
      'sort_order': sortOrder,
      // created_at / updated_at handled by DB triggers usually, but can be included
    };
  }

  TaskItem copyWith({
    String? id,
    String? userId,
    String? categoryId,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    bool? isCompleted,
    DateTime? completedAt,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    TaskCategory? category,
  }) {
    return TaskItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
    );
  }
}

// Helpers
Color _colorFromHex(String hexString) {
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
  buffer.write(hexString.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

String _colorToHex(Color color) {
  // Try to use modern color fields, fallback cleanly if needed
  try {
    return '#${(color.a * 255).toInt().toRadixString(16).padLeft(2, '0')}${(color.r * 255).toInt().toRadixString(16).padLeft(2, '0')}${(color.g * 255).toInt().toRadixString(16).padLeft(2, '0')}${(color.b * 255).toInt().toRadixString(16).padLeft(2, '0')}'.substring(3);
  } catch (_) {
    return '#${color.toARGB32().toRadixString(16).substring(2, 8)}';
  }
}
