import 'package:flutter/foundation.dart';

@immutable
class WorkoutSession {
  final String id;
  final String title;
  final String category;
  final int durationMinutes;
  final int caloriesBurned;
  final DateTime date;

  const WorkoutSession({
    required this.id,
    required this.title,
    required this.category,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.date,
  });

  WorkoutSession copyWith({
    String? id,
    String? title,
    String? category,
    int? durationMinutes,
    int? caloriesBurned,
    DateTime? date,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'durationMinutes': durationMinutes,
    'caloriesBurned': caloriesBurned,
    'date': date.toIso8601String(),
  };

  factory WorkoutSession.fromJson(Map<String, dynamic> json) => WorkoutSession(
    id: json['id'] as String,
    title: json['title'] as String,
    category: json['category'] as String,
    durationMinutes: json['durationMinutes'] as int,
    caloriesBurned: json['caloriesBurned'] as int,
    date: DateTime.parse(json['date'] as String),
  );
}
