import 'package:flutter/material.dart';

class Topic {
  final String id;
  final String title;

  Topic({
    required this.id,
    required this.title,
  });

  factory Topic.fromMap(Map<String, dynamic> map) {
    return Topic(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
    };
  }
}

class Course {
  final String id;
  final String title;
  final String category;
  final int colorHex;
  final String iconName;
  final int questionCount;
  final List<Topic> topics;

  Course({
    required this.id,
    required this.title,
    required this.category,
    required this.colorHex,
    required this.iconName,
    required this.questionCount,
    required this.topics,
  });

  Color get color => Color(colorHex);

  factory Course.fromMap(Map<String, dynamic> map) {
    final topicsRaw = map['topics'] as List<dynamic>? ?? [];
    return Course(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      category: map['category'] as String? ?? 'Genel Yetenek',
      colorHex: int.tryParse(map['color']?.toString() ?? '0xFF2196F3') ?? 0xFF2196F3,
      iconName: map['icon'] as String? ?? 'book',
      questionCount: map['questionCount'] as int? ?? 30,
      topics: topicsRaw.map((t) => Topic.fromMap(Map<String, dynamic>.from(t as Map))).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'color': '0x${colorHex.toRadixString(16).padLeft(8, '0').toUpperCase()}',
      'icon': iconName,
      'questionCount': questionCount,
      'topics': topics.map((t) => t.toMap()).toList(),
    };
  }
}
