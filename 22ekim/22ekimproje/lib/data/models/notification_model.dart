class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String? habitId;
  final String? habitTitle;
  final DateTime timestamp;
  final bool isRead;
  final String type; // 'reminder', 'test', 'streak', 'system'

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.habitId,
    this.habitTitle,
    DateTime? timestamp,
    this.isRead = false,
    this.type = 'reminder',
  }) : timestamp = timestamp ?? DateTime.now();

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? habitId,
    String? habitTitle,
    DateTime? timestamp,
    bool? isRead,
    String? type,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      habitId: habitId ?? this.habitId,
      habitTitle: habitTitle ?? this.habitTitle,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'habitId': habitId,
      'habitTitle': habitTitle,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'type': type,
    };
  }

  factory NotificationModel.fromMap(Map<dynamic, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      habitId: map['habitId'] as String?,
      habitTitle: map['habitTitle'] as String?,
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isRead: map['isRead'] as bool? ?? false,
      type: map['type'] as String? ?? 'reminder',
    );
  }
}
