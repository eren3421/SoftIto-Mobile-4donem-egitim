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
          title: Row(
            children: [
              const Icon(Icons.psychology, color: AppColors.accent, size: 22),
              const SizedBox(width: 8),
              Text(
                'Hugging Face Canlı Model',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Arka plandaki yapay zeka modelinin (Qwen 2.5 72B / Mistral 7B) canlı olarak cevap üretmesi için Hugging Face "Read" tokeninizi buraya yapıştırın.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ücretsiz token almak için: huggingface.co/settings/tokens',
                style: TextStyle(color: AppColors.softPink, fontSize: 11, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: tokenController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'hf_xxxxxxxxxxxxxxxxxxxxxx',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
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
              onPressed: () async {
                final nav = Navigator.of(ctx);
                final messenger = ScaffoldMessenger.of(context);
                final input = tokenController.text.trim();
                AppConfig.huggingFaceToken = input;
                await HiveStorageService.instance.setHfToken(input);
                if (!mounted) return;
                setState(() {});
                nav.pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      AppConfig.hasValidHfToken
                          ? '✅ Hugging Face Token kaydedildi. Canlı model devrede!'
                          : '⚠️ Token formatı kontrol edilmeli (hf_ ile başlamalı).',
                    ),
                    backgroundColor: AppConfig.hasValidHfToken
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                );
              },
              child: const Text('Kaydet ve Bağlan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isHfConnected = AppConfig.hasValidHfToken;

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
                    // Model Bağlantı Durumu Rozeti
                    InkWell(
                      onTap: _showTokenConfigDialog,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isHfConnected
                              ? AppColors.success.withValues(alpha: 0.15)
                              : AppColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isHfConnected ? AppColors.success : AppColors.warning,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isHfConnected ? Icons.circle : Icons.warning_amber_rounded,
                              size: 10,
                              color: isHfConnected ? AppColors.success : AppColors.warning,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isHfConnected ? 'HF Canlı Model' : 'Token Girin',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isHfConnected ? AppColors.success : AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
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

          // Token Girilmemişse Bilgilendirme ve Hızlı Ayar Şeridi
          if (!isHfConnected)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.primaryVariant.withValues(alpha: 0.9),
              child: Row(
                children: [
                  const Icon(Icons.flash_on, size: 16, color: AppColors.accent),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Canlı Hugging Face modeli için token tanımlayınız.',
                      style: TextStyle(fontSize: 11, color: AppColors.textPrimary),
                    ),
                  ),
                  InkWell(
                    onTap: _showTokenConfigDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Token Ayarla',
                        style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
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

          // Hızlı Soru Önerileri (Quick Prompts)
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildQuickChip('⚡ Bugün enerjim yok'),
                _buildQuickChip('🎯 2 Dakika Kuralı nedir?'),
                _buildQuickChip('🔄 Dün zinciri bozdum'),
                _buildQuickChip('📚 Kitap okuma taktiği'),
                _buildQuickChip('⏰ Sabah erken kalkma tüyosu'),
                _buildQuickChip('📋 Günlük rutin öner'),
                _buildQuickChip('💧 Su içmeyi unutuyorum'),
                _buildQuickChip('⏳ 21 gün kuralı doğru mu?'),
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
                    color: Colors.black.withValues(alpha: 0.15),
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
                          ? Colors.white.withValues(alpha: 0.7)
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

  Widget _buildQuickChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        backgroundColor: AppColors.surfaceVariant,
        side: const BorderSide(color: AppColors.borderHighlight, width: 0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        label: Text(
          text,
          style: const TextStyle(
            color: AppColors.softPink,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: () {
          _messageController.text = text;
          _handleSendMessage();
        },
      ),
    );
  }
}
