class ChatMessageModel {
  final String id;
  final String userId;
  final String? habitId;
  final bool isUser;
  final String message;
  final DateTime timestamp;

  ChatMessageModel({
    required this.id,
    required this.userId,
    this.habitId,
    required this.isUser,
    required this.message,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'habitId': habitId,
      'isUser': isUser,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessageModel.fromMap(Map<dynamic, dynamic> map) {
    return ChatMessageModel(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      habitId: map['habitId'] as String?,
      isUser: map['isUser'] as bool? ?? false,
      message: map['message'] as String? ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
