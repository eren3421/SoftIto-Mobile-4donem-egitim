import '../../../auth/domain/models/user_role.dart';
import '../../../vehicles/domain/models/vehicle_type.dart';

class ChatRoom {
  final String id;
  final String vehicleId;
  final String vehicleTitle;         // Örn: "Mercedes-Benz G63 AMG"
  final String plateNumber;
  final VehicleCategory vehicleType;
  final double unitPrice;
  final String? reservationId;
  final String ownerId;
  final String ownerName;
  final UserRole ownerRole;
  final String renterCivilianId;
  final String renterName;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;

  const ChatRoom({
    required this.id,
    required this.vehicleId,
    required this.vehicleTitle,
    required this.plateNumber,
    required this.vehicleType,
    required this.unitPrice,
    this.reservationId,
    required this.ownerId,
    required this.ownerName,
    required this.ownerRole,
    required this.renterCivilianId,
    required this.renterName,
    required this.lastMessage,
    required this.lastMessageAt,
    this.unreadCount = 0,
  });

  ChatRoom copyWith({
    String? id,
    String? vehicleId,
    String? vehicleTitle,
    String? plateNumber,
    VehicleCategory? vehicleType,
    double? unitPrice,
    String? reservationId,
    String? ownerId,
    String? ownerName,
    UserRole? ownerRole,
    String? renterCivilianId,
    String? renterName,
    String? lastMessage,
    DateTime? lastMessageAt,
    int? unreadCount,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleTitle: vehicleTitle ?? this.vehicleTitle,
      plateNumber: plateNumber ?? this.plateNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      unitPrice: unitPrice ?? this.unitPrice,
      reservationId: reservationId ?? this.reservationId,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerRole: ownerRole ?? this.ownerRole,
      renterCivilianId: renterCivilianId ?? this.renterCivilianId,
      renterName: renterName ?? this.renterName,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
