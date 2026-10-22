import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../data/local/hive_storage_service.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/models/habit_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/habit_repository.dart';
import '../../data/repositories/note_repository.dart';
import '../../data/services/huggingface_service.dart';

class MentorChatScreen extends ConsumerStatefulWidget {
  final HabitModel? specificHabit;

  const MentorChatScreen({super.key, this.specificHabit});

  static void show(BuildContext context, {HabitModel? specificHabit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MentorChatScreen(specificHabit: specificHabit),
    );
  }

  @override
  ConsumerState<MentorChatScreen> createState() => _MentorChatScreenState();
}

class _MentorChatScreenState extends ConsumerState<MentorChatScreen> {
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessageModel> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadChatHistory() {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final history = HiveStorageService.instance.getChatHistory(
      user.id,
      habitId: widget.specificHabit?.id,
    );

    setState(() {
      _messages.addAll(history);
      if (_messages.isEmpty) {
        // Hoş geldin mesajı ekle
        final welcomeMsg = widget.specificHabit != null
            ? 'Merhaba! Ben senin MENTOR koçunum. "${widget.specificHabit!.title}" alışkanlığında ${widget.specificHabit!.currentStreak} günlük bir serin var. Bugün bu alışkanlığı sürdürmek için nasıl hissediyorsun? Sana nasıl destek olabilirim?'
            : 'Merhaba! Ben MENTOR yapay zeka koçun. Günlük alışkanlıkların, motivasyon serilerin veya hedeflerin hakkında konuşmaya hazırım. Bugün ne üzerine odaklanmak istersin?';

        final initialModel = ChatMessageModel(
          id: const Uuid().v4(),
          userId: user.id,
          habitId: widget.specificHabit?.id,
          isUser: false,
          message: welcomeMsg,
        );
        _messages.add(initialModel);
        HiveStorageService.instance.saveChatMessage(initialModel);
      }
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isTyping) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final userMessage = ChatMessageModel(
      id: const Uuid().v4(),
      userId: user.id,
      habitId: widget.specificHabit?.id,
      isUser: true,
      message: text,
    );

    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
    });
    _messageController.clear();
    await HiveStorageService.instance.saveChatMessage(userMessage);
    _scrollToBottom();

    // Alışkanlık ve Not Bağlamını Hazırla
    String habitContext;
    if (widget.specificHabit != null) {
      final h = widget.specificHabit!;
      habitContext =
          'Seçili Alışkanlık: ${h.title}, Aktif Zincir: ${h.currentStreak} gün, En Uzun Zincir: ${h.longestStreak} gün, Haftalık Başarı: %${(h.weeklyCompletionRate * 100).toStringAsFixed(0)}.';
    } else {
      final habits = ref.read(habitsListProvider);
      habitContext = habits.isEmpty
          ? 'Henüz aktif alışkanlık eklenmemiş.'
          : habits
              .map((h) => '${h.title} (${h.currentStreak} gün streak)')
              .join(', ');
    }

    final notes = ref.read(allNotesProvider);
    final notesContext = notes.isEmpty
        ? 'Henüz not eklenmemiş.'
        : notes.take(3).map((n) => n.content).join('; ');

    // Önceki konuşma geçmişi (Son 4 mesaj)
    final historyPayload = _messages
        .take(_messages.length - 1)
        .map((m) => {
              'role': m.isUser ? 'user' : 'assistant',
              'content': m.message,
            })
        .toList();

    final aiReplyText = await HuggingFaceService.instance.sendMessage(
      userMessage: text,
      habitContext: habitContext,
      notesContext: notesContext,
      previousMessages: historyPayload,
    );

    final aiMessage = ChatMessageModel(
      id: const Uuid().v4(),
      userId: user.id,
      habitId: widget.specificHabit?.id,
      isUser: false,
      message: aiReplyText,
    );

    if (mounted) {
      setState(() {
        _messages.add(aiMessage);
        _isTyping = false;
      });
      await HiveStorageService.instance.saveChatMessage(aiMessage);
      _scrollToBottom();
    }
  }

  void _showTokenConfigDialog() {
    final tokenController =
        TextEditingController(text: AppConfig.huggingFaceToken);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.primary),
          ),
          title: Text(
            'Hugging Face API Ayarı',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Kendi Hugging Face User Access Token bilginizi girebilirsiniz. Boş bırakırsanız yüksek kaliteli yerel uzman koçluk algoritması devrede kalır.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tokenController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'hf_xxxxxxxxxxxxxxxxxxxxxx',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('İptal', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                AppConfig.huggingFaceToken = tokenController.text.trim();
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Hugging Face Token kaydedildi.'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: AppColors.borderHighlight, width: 2),
        ),
      ),
      child: Column(
        children: [
          // Başlık Çubuğu
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryVariant,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.psychology,
                        color: AppColors.accent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Mentor / Koç',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          widget.specificHabit != null
                              ? widget.specificHabit!.title
                              : 'Genel Yaşam & Alışkanlık Koçluğu',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.softPink,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.key, color: AppColors.softPink, size: 20),
                      tooltip: 'HF API Token Ayarı',
                      onPressed: _showTokenConfigDialog,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textMuted),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Mesajlar Alanı
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Yazıyor Göstergesi
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Mentor düşünüyor ve yanıt hazırlıyor...',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

          // Mesaj Yazma Çubuğu
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceVariant,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Mentor koçuna bir şey sor...',
                        fillColor: AppColors.surface,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _handleSendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.buttonGradient,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: _handleSendMessage,
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

  Widget _buildMessageBubble(ChatMessageModel message) {
    final isMe = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primaryVariant,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.psychology, size: 16, color: AppColors.accent),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : AppColors.surfaceVariant,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                border: Border.all(
                  color: isMe ? AppColors.accent : AppColors.border,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(
                      color: isMe ? Colors.white : AppColors.textPrimary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('HH:mm').format(message.timestamp),
                    style: TextStyle(
                      color: isMe
                          ? Colors.white.withOpacity(0.7)
                          : AppColors.textMuted,
                      fontSize: 10,
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
