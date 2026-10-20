class ChatMessage {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.isRead = false,
  });

  ChatMessage copyWith({
    String? id,
    String? chatRoomId,
    String? senderId,
    String? senderName,
    String? content,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
