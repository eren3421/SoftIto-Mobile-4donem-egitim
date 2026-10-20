import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../auth/domain/models/app_user.dart';
import '../../vehicles/controllers/vehicle_controller.dart';
import '../../vehicles/views/vehicle_detail_dialog.dart';
import '../controllers/messaging_controller.dart';
import '../domain/models/chat_room.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/pinned_vehicle_header.dart';
import '../widgets/quick_reply_bar.dart';

class ChatConversationScreen extends StatefulWidget {
  final ChatRoom room;
  final AppUser currentUser;
  final MessagingController messagingController;
  final VehicleController vehicleController;

  const ChatConversationScreen({
    super.key,
    required this.room,
    required this.currentUser,
    required this.messagingController,
    required this.vehicleController,
  });

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.messagingController.markAsRead(widget.room.id);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage([String? quickText]) {
    final text = quickText ?? _textController.text.trim();
    if (text.isEmpty) return;

    widget.messagingController.sendMessage(
      roomId: widget.room.id,
      text: text,
      senderId: widget.currentUser.id,
      senderName: widget.currentUser.displayName,
    );

    if (quickText == null) {
      _textController.clear();
    }

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _openVehicleDetails() {
    final vehicle = widget.vehicleController.getVehicleById(widget.room.vehicleId);
    if (vehicle != null) {
      VehicleDetailDialog.show(
        context,
        vehicle: vehicle,
        currentUser: widget.currentUser,
        onRent: () {},
        onTrack: () {},
        onChat: () {},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMeOwner = widget.currentUser.id == widget.room.ownerId;
    final otherPartyName = isMeOwner ? widget.room.renterName : widget.room.ownerName;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(otherPartyName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text(
              isMeOwner ? 'Kiracı (Sivil Kullanıcı)' : 'Araç Sahibi',
              style: const TextStyle(fontSize: 11, color: AppColors.silverText),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Fixed Vehicle Header
          PinnedVehicleHeader(
            room: widget.room,
            onDetailsTap: _openVehicleDetails,
          ),

          // Messages list
          Expanded(
            child: AnimatedBuilder(
              animation: widget.messagingController,
              builder: (context, _) {
                final messages = widget.messagingController.getMessagesForRoom(widget.room.id);

                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'Henüz mesaj yok.\nHızlı hazır şablonlardan birini seçebilirsiniz.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.silverText),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == widget.currentUser.id;
                    return ChatBubble(message: msg, isMe: isMe);
                  },
                );
              },
            ),
          ),

          // Quick Replies
          QuickReplyBar(
            replies: MessagingController.quickReplies,
            onSelect: (reply) => _sendMessage(reply),
          ),
          const SizedBox(height: 6),

          // Message Input Field
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: const Border(
                  top: BorderSide(color: AppColors.steelBorderGrey, width: 0.8),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'Mesajınızı yazın...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton.filled(
                    onPressed: () => _sendMessage(),
                    icon: const Icon(Icons.send, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.crimsonPrimary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
