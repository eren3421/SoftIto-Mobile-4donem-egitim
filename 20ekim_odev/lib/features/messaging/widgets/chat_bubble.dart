import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../domain/models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isMe
        ? AppColors.crimsonPrimary
        : (isDark ? AppColors.slateCardGrey : AppColors.lightInputBg);

    final textColor = isMe
        ? AppColors.platinumText
        : (isDark ? AppColors.platinumText : AppColors.lightTextPrimary);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(14),
              topRight: const Radius.circular(14),
              bottomLeft: Radius.circular(isMe ? 14 : 2),
              bottomRight: Radius.circular(isMe ? 2 : 14),
            ),
            border: isMe
                ? null
                : Border.all(
                    color: isDark ? AppColors.steelBorderGrey : AppColors.lightBorder,
                    width: 0.8,
                  ),
          ),
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isMe) ...[
                Text(
                  message.senderName,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.crimsonLight,
                  ),
                ),
                const SizedBox(height: 2),
              ],
              Text(
                message.content,
                style: TextStyle(
                  fontSize: 13.5,
                  color: textColor,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    Formatters.time(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe ? Colors.white70 : AppColors.mutedGreyText,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.done_all, size: 12, color: Colors.white70),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
