import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/slate_card.dart';
import '../../../core/widgets/vehicle_type_badge.dart';
import '../../auth/domain/models/app_user.dart';
import '../../vehicles/controllers/vehicle_controller.dart';
import '../controllers/messaging_controller.dart';
import '../domain/models/chat_room.dart';
import 'chat_conversation_screen.dart';

class ChatListScreen extends StatelessWidget {
  final AppUser? currentUser;
  final MessagingController messagingController;
  final VehicleController vehicleController;

  const ChatListScreen({
    super.key,
    required this.currentUser,
    required this.messagingController,
    required this.vehicleController,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesajlaşma Paneli', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: AnimatedBuilder(
        animation: messagingController,
        builder: (context, _) {
          final rooms = messagingController.getRoomsForUser(currentUser);

          if (rooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.chat_bubble_outline, size: 48, color: AppColors.mutedGreyText),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Aktif mesajlaşma bulunmuyor.',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Araç kartları veya rezervasyonlarınız üzerinden araç sahipleri ve kiracılarla mesajlaşabilirsiniz.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: isDark ? AppColors.silverText : AppColors.lightTextSecondary, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: AppSpacing.screenPadding,
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              return _buildRoomCard(context, room, isDark);
            },
          );
        },
      ),
    );
  }

  Widget _buildRoomCard(BuildContext context, ChatRoom room, bool isDark) {
    final isMeOwner = currentUser?.id == room.ownerId;
    final otherPartyName = isMeOwner ? room.renterName : room.ownerName;

    return SlateCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatConversationScreen(
              room: room,
              currentUser: currentUser!,
              messagingController: messagingController,
              vehicleController: vehicleController,
            ),
          ),
        );
      },
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.crimsonSurface,
            radius: 24,
            child: Icon(
              isMeOwner ? Icons.person : Icons.apartment,
              color: AppColors.crimsonLight,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      otherPartyName,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    Text(
                      Formatters.time(room.lastMessageAt),
                      style: const TextStyle(fontSize: 11, color: AppColors.mutedGreyText),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    VehicleTypeBadge(category: room.vehicleType, compact: true),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${room.vehicleTitle} (${room.plateNumber})',
                        style: const TextStyle(fontSize: 12, color: AppColors.silverText),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  room.lastMessage,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.platinumText : AppColors.lightTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (room.unreadCount > 0) ...[
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: const BoxDecoration(
                color: AppColors.crimsonAccent,
                shape: BoxShape.circle,
              ),
              child: Text(
                room.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
