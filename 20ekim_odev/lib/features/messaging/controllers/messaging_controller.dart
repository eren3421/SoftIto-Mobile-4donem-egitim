import 'package:flutter/foundation.dart';
import '../../auth/domain/models/app_user.dart';
import '../../auth/domain/models/user_role.dart';
import '../../vehicles/domain/models/vehicle_model.dart';
import '../../vehicles/domain/models/vehicle_type.dart';
import '../domain/models/chat_message.dart';
import '../domain/models/chat_room.dart';

class MessagingController extends ChangeNotifier {
  static final MessagingController instance = MessagingController._();
  MessagingController._() {
    _initDemoChat();
  }

  final ValueNotifier<List<ChatRoom>> _chatRoomsNotifier = ValueNotifier<List<ChatRoom>>([]);
  final Map<String, List<ChatMessage>> _roomMessages = {};

  ValueListenable<List<ChatRoom>> get chatRooms => _chatRoomsNotifier;

  static const List<String> quickReplies = [
    'Aracı teslim almaya geliyorum.',
    'Konum paylaşır mısınız?',
    'Rezervasyon talebinizi onayladım.',
    'Aracın güncel durumu nedir?',
    'Anahtar ve evrak teslimi için hazırım.',
  ];

  void _initDemoChat() {
    final now = DateTime.now();

    final room1 = ChatRoom(
      id: 'room_1',
      vehicleId: 'v_land_1',
      vehicleTitle: 'Mercedes-Benz G63 AMG',
      plateNumber: '34 VR 1923',
      vehicleType: VehicleCategory.land,
      unitPrice: 8500,
      reservationId: 'res_101',
      ownerId: 'civ_1',
      ownerName: 'Ahmet Yılmaz',
      ownerRole: UserRole.civilian,
      renterCivilianId: 'civ_selin',
      renterName: 'Selin Arslan',
      lastMessage: 'Aracı teslim almaya geliyorum, otoparkta mısınız?',
      lastMessageAt: now.subtract(const Duration(minutes: 15)),
      unreadCount: 1,
    );

    final room2 = ChatRoom(
      id: 'room_2',
      vehicleId: 'v_air_1',
      vehicleTitle: 'Cessna Citation CJ4 Gen2',
      plateNumber: 'TC-SKY',
      vehicleType: VehicleCategory.air,
      unitPrice: 42000,
      reservationId: 'res_102',
      ownerId: 'comp_1',
      ownerName: 'SkyJet Havacılık',
      ownerRole: UserRole.company,
      renterCivilianId: 'civ_1',
      renterName: 'Ahmet Yılmaz',
      lastMessage: 'Uçuş planı onaylandı, Atatürk HL Genel Havacılık Hangar 4 te bekliyoruz.',
      lastMessageAt: now.subtract(const Duration(hours: 2)),
      unreadCount: 0,
    );

    _chatRoomsNotifier.value = [room1, room2];

    _roomMessages['room_1'] = [
      ChatMessage(
        id: 'm1',
        chatRoomId: 'room_1',
        senderId: 'civ_1',
        senderName: 'Ahmet Yılmaz',
        content: 'Merhaba Selin Hanım, araç kiralama rezervasyonunuz onaylandı. Araç temizlendi ve hazır.',
        timestamp: now.subtract(const Duration(hours: 1)),
        isRead: true,
      ),
      ChatMessage(
        id: 'm2',
        chatRoomId: 'room_1',
        senderId: 'civ_selin',
        senderName: 'Selin Arslan',
        content: 'Harika Ahmet Bey, çok teşekkürler. Takip numarasından konumu görebiliyorum.',
        timestamp: now.subtract(const Duration(minutes: 30)),
        isRead: true,
      ),
      ChatMessage(
        id: 'm3',
        chatRoomId: 'room_1',
        senderId: 'civ_selin',
        senderName: 'Selin Arslan',
        content: 'Aracı teslim almaya geliyorum, otoparkta mısınız?',
        timestamp: now.subtract(const Duration(minutes: 15)),
        isRead: false,
      ),
    ];

    _roomMessages['room_2'] = [
      ChatMessage(
        id: 'm201',
        chatRoomId: 'room_2',
        senderId: 'civ_1',
        senderName: 'Ahmet Yılmaz',
        content: 'İyi günler, İstanbul - Bodrum uçuşu için rezervasyon oluşturdum. Uçuş ekibi hazır mı?',
        timestamp: now.subtract(const Duration(hours: 3)),
        isRead: true,
      ),
      ChatMessage(
        id: 'm202',
        chatRoomId: 'room_2',
        senderId: 'comp_1',
        senderName: 'SkyJet Havacılık',
        content: 'Uçuş planı onaylandı, Atatürk HL Genel Havacılık Hangar 4 te bekliyoruz.',
        timestamp: now.subtract(const Duration(hours: 2)),
        isRead: true,
      ),
    ];
  }

  List<ChatRoom> getRoomsForUser(AppUser? user) {
    if (user == null) return _chatRoomsNotifier.value;
    final userId = user.id;

    return _chatRoomsNotifier.value.where((room) {
      return room.ownerId == userId || room.renterCivilianId == userId;
    }).toList();
  }

  List<ChatMessage> getMessagesForRoom(String roomId) {
    return _roomMessages[roomId] ?? [];
  }

  ChatRoom getOrCreateRoom({
    required VehicleModel vehicle,
    required AppUser currentUser,
    String? reservationId,
  }) {
    final existing = _chatRoomsNotifier.value.firstWhere(
      (r) =>
          r.vehicleId == vehicle.id &&
          (r.renterCivilianId == currentUser.id || r.ownerId == currentUser.id),
      orElse: () {
        final newRoom = ChatRoom(
          id: 'room_${DateTime.now().millisecondsSinceEpoch}',
          vehicleId: vehicle.id,
          vehicleTitle: vehicle.title,
          plateNumber: vehicle.plateNumber,
          vehicleType: vehicle.vehicleType,
          unitPrice: vehicle.unitPrice,
          reservationId: reservationId,
          ownerId: vehicle.ownerId,
          ownerName: vehicle.ownerName,
          ownerRole: vehicle.ownerRole,
          renterCivilianId: currentUser.id,
          renterName: currentUser.displayName,
          lastMessage: 'Sohbet başlatıldı.',
          lastMessageAt: DateTime.now(),
          unreadCount: 0,
        );
        _chatRoomsNotifier.value = [newRoom, ..._chatRoomsNotifier.value];
        _roomMessages[newRoom.id] = [];
        return newRoom;
      },
    );

    return existing;
  }

  void sendMessage({
    required String roomId,
    required String text,
    required String senderId,
    required String senderName,
  }) {
    if (text.trim().isEmpty) return;

    final msg = ChatMessage(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      chatRoomId: roomId,
      senderId: senderId,
      senderName: senderName,
      content: text.trim(),
      timestamp: DateTime.now(),
      isRead: false,
    );

    final currentList = _roomMessages[roomId] ?? [];
    _roomMessages[roomId] = [...currentList, msg];

    // Update room's last message
    _chatRoomsNotifier.value = _chatRoomsNotifier.value.map((room) {
      if (room.id == roomId) {
        return room.copyWith(
          lastMessage: text.trim(),
          lastMessageAt: DateTime.now(),
        );
      }
      return room;
    }).toList();

    notifyListeners();
  }

  void markAsRead(String roomId) {
    _chatRoomsNotifier.value = _chatRoomsNotifier.value.map((room) {
      if (room.id == roomId) {
        return room.copyWith(unreadCount: 0);
      }
      return room;
    }).toList();
    notifyListeners();
  }

  @override
  void dispose() {
    _chatRoomsNotifier.dispose();
    super.dispose();
  }
}
