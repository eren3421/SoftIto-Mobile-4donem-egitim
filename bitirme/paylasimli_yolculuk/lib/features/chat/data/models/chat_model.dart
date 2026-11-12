import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_entity.dart';

/// `chats` ve `messages` koleksiyonları için JSON/Hive ve Firestore `Timestamp` serileştirme modelleri.
class ChatModel extends ChatEntity {
  const ChatModel({
    required super.id,
    required super.rideId,
    required super.participantIds,
    super.participantNames,
    super.rideSummaryTitle,
    required super.lastMessage,
    required super.lastMessageTime,
    super.unreadCounts,
  });

  factory ChatModel.fromEntity(ChatEntity entity) {
    return ChatModel(
      id: entity.id,
      rideId: entity.rideId,
      participantIds: entity.participantIds,
      participantNames: entity.participantNames,
      rideSummaryTitle: entity.rideSummaryTitle,
      lastMessage: entity.lastMessage,
      lastMessageTime: entity.lastMessageTime,
      unreadCounts: entity.unreadCounts,
    );
  }

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    final participantsRaw = json['participantIds'] as List<dynamic>? ?? [];
    final unreadRaw = json['unreadCounts'] as Map? ?? {};
    final namesRaw = json['participantNames'] as Map? ?? {};

    return ChatModel(
      id: json['id'] as String? ?? '',
      rideId: json['rideId'] as String? ?? '',
      participantIds: participantsRaw.map((e) => e.toString()).toList(),
      participantNames: namesRaw.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      ),
      rideSummaryTitle: json['rideSummaryTitle'] as String? ?? '',
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageTime: _parseDate(json['lastMessageTime']),
      unreadCounts: unreadRaw.map(
        (key, value) => MapEntry(key.toString(), (value as num).toInt()),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rideId': rideId,
      'participantIds': participantIds,
      'participantNames': participantNames,
      'rideSummaryTitle': rideSummaryTitle,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toUtc().toIso8601String(),
      'unreadCounts': unreadCounts,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      ...toJson(),
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
    };
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.chatId,
    required super.senderId,
    required super.text,
    super.type,
    super.isRead,
    required super.createdAt,
    super.lat,
    super.lng,
    super.locationName,
    super.isLiveLocation,
  });

  factory MessageModel.fromEntity(MessageEntity entity) {
    return MessageModel(
      id: entity.id,
      chatId: entity.chatId,
      senderId: entity.senderId,
      text: entity.text,
      type: entity.type,
      isRead: entity.isRead,
      createdAt: entity.createdAt,
      lat: entity.lat,
      lng: entity.lng,
      locationName: entity.locationName,
      isLiveLocation: entity.isLiveLocation,
    );
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String? ?? '',
      chatId: json['chatId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      text: json['text'] as String? ?? '',
      type: json['type'] as String? ?? 'text',
      isRead: json['isRead'] as bool? ?? false,
      createdAt: ChatModel._parseDate(json['createdAt']),
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      locationName: json['locationName'] as String?,
      isLiveLocation: json['isLiveLocation'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'text': text,
      'type': type,
      'isRead': isRead,
      'createdAt': createdAt.toUtc().toIso8601String(),
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (locationName != null) 'locationName': locationName,
      'isLiveLocation': isLiveLocation,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      ...toJson(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
