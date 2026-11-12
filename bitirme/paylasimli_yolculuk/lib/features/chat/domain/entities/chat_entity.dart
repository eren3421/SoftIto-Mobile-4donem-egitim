/// 02_veri_depolama_ve_sema.md Bölüm 2.5 `chats` şemasına uygun Domain Entity.
class ChatEntity {
  final String id;
  final String rideId;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final String rideSummaryTitle;
  final String lastMessage;
  final DateTime lastMessageTime;
  final Map<String, int> unreadCounts;

  const ChatEntity({
    required this.id,
    required this.rideId,
    required this.participantIds,
    this.participantNames = const {},
    this.rideSummaryTitle = '',
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCounts = const {},
  });

  String otherParticipantName(String currentUserId) {
    for (final entry in participantNames.entries) {
      if (entry.key != currentUserId) return entry.value;
    }
    return 'Yolculuk Katılımcısı';
  }

  String otherParticipantId(String currentUserId) {
    for (final id in participantIds) {
      if (id != currentUserId) return id;
    }
    return participantIds.isNotEmpty ? participantIds.first : '';
  }

  int unreadCountFor(String userId) => unreadCounts[userId] ?? 0;

  ChatEntity copyWith({
    String? id,
    String? rideId,
    List<String>? participantIds,
    Map<String, String>? participantNames,
    String? rideSummaryTitle,
    String? lastMessage,
    DateTime? lastMessageTime,
    Map<String, int>? unreadCounts,
  }) {
    return ChatEntity(
      id: id ?? this.id,
      rideId: rideId ?? this.rideId,
      participantIds: participantIds ?? this.participantIds,
      participantNames: participantNames ?? this.participantNames,
      rideSummaryTitle: rideSummaryTitle ?? this.rideSummaryTitle,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCounts: unreadCounts ?? this.unreadCounts,
    );
  }
}

/// 02_veri_depolama_ve_sema.md Bölüm 2.5 `messages` alt koleksiyon şemasına uygun Domain Entity.
/// Gerçek zamanlı canlı konum (`lat`, `lng`, `locationName`, `isLiveLocation`) alanlarını destekler.
class MessageEntity {
  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final String type; // 'text', 'location'
  final bool isRead;
  final DateTime createdAt;
  final double? lat;
  final double? lng;
  final String? locationName;
  final bool isLiveLocation;

  const MessageEntity({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    this.type = 'text',
    this.isRead = false,
    required this.createdAt,
    this.lat,
    this.lng,
    this.locationName,
    this.isLiveLocation = false,
  });

  MessageEntity copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? text,
    String? type,
    bool? isRead,
    DateTime? createdAt,
    double? lat,
    double? lng,
    String? locationName,
    bool? isLiveLocation,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      locationName: locationName ?? this.locationName,
      isLiveLocation: isLiveLocation ?? this.isLiveLocation,
    );
  }
}
