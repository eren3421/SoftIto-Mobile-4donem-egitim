import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/chat_provider.dart';

/// Faz 5: Onaylanmış rezervasyona sahip yolcu ve sürücünün mesajlaşabileceği,
/// okunmamış mesaj sayaçlarını (1, 2...) ve bildirim rozetlerini gösteren Sohbet Listesi Ekranı.
class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(chatsNotifierProvider);
    final currentUser = ref.watch(authNotifierProvider).valueOrNull;
    final totalUnread = ref.watch(totalUnreadMessagesCountProvider);

    return chatsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Hata: $e')),
      data: (chats) {
        if (chats.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.forum_outlined,
                    size: 52,
                    color: AppColors.lightTextSecondary,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Henüz aktif sohbet odanız bulunmuyor.',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Onaylanan yolculuk rezervasyonlarınız için otomatik sohbet odası açılır.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final userId = currentUser?.id ?? '';

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (totalUnread > 0)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Badge(
                      label: Text('$totalUnread'),
                      backgroundColor: AppColors.error,
                      child: const Icon(
                        Icons.mark_email_unread_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Toplam $totalUnread okunmamış mesajınız var.',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        for (final c in chats) {
                          if (c.unreadCountFor(userId) > 0) {
                            await ref
                                .read(chatsNotifierProvider.notifier)
                                .markChatAsRead(c.id);
                          }
                        }
                      },
                      child: const Text('Tümünü Okundu İşaretle'),
                    ),
                  ],
                ),
              ),
            ...chats.map((chat) {
              final otherName = chat.otherParticipantName(userId);
              final unread = chat.unreadCountFor(userId);
              final otherId = chat.otherParticipantId(userId);
              final otherUnread = chat.unreadCountFor(otherId);

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: unread > 0
                        ? AppColors.primary
                        : AppColors.lightBorder,
                    width: unread > 0 ? 1.8 : 1.0,
                  ),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Badge(
                    isLabelVisible: unread > 0,
                    label: Text(
                      '$unread',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: AppColors.error,
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: unread > 0
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.15),
                      foregroundColor:
                          unread > 0 ? Colors.white : AppColors.primary,
                      child: Text(
                        otherName.isNotEmpty ? otherName[0].toUpperCase() : 'K',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          otherName,
                          style: TextStyle(
                            fontWeight: unread > 0
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                      if (unread > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$unread Yeni Mesaj',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else if (otherUnread > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Karşıda $otherUnread okunmamış',
                            style: const TextStyle(
                              color: AppColors.info,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (chat.rideSummaryTitle.isNotEmpty)
                          Text(
                            chat.rideSummaryTitle,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        const SizedBox(height: 2),
                        Text(
                          chat.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: unread > 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: unread > 0
                                ? Theme.of(context).colorScheme.onSurface
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        DateFormatter.formatTime(chat.lastMessageTime),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              unread > 0 ? FontWeight.bold : FontWeight.normal,
                          color: unread > 0
                              ? AppColors.primary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      if (unread > 0) ...[
                        const SizedBox(height: 6),
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColors.error,
                          child: Text(
                            '$unread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  onTap: () => context.push('/chat/${chat.id}'),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
