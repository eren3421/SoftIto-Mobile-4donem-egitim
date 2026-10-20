import 'package:flutter/material.dart';
import '../controllers/kisiler_controller.dart';
import '../models/kisi_model.dart';
import '../widgets/chat_bubble.dart';

/// Belirli bir kişi veya paydaş ile birebir sohbet ekranı.
class ChatView extends StatefulWidget {
  final KisiModel kisi;
  final KisilerController controller;

  const ChatView({
    super.key,
    required this.kisi,
    required this.controller,
  });

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.kisi.name, style: const TextStyle(fontSize: 16)),
            Text('${widget.kisi.role} • ${widget.kisi.company}', style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessagesList()),
          _buildMessageInputField(context),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ValueListenableBuilder<Map<String, List<ChatMessageModel>>>(
      valueListenable: widget.controller.chatMessages,
      builder: (context, map, _) {
        final messages = map[widget.kisi.id] ?? [];
        if (messages.isEmpty) {
          return const Center(child: Text('Henüz bir mesajlaşma bulunmuyor.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: messages.length,
          itemBuilder: (context, index) => ChatBubble(message: messages[index]),
        );
      },
    );
  }

  Widget _buildMessageInputField(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: 'Bir mesaj yazın...',
                  isDense: true,
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _handleSend,
            ),
          ],
        ),
      ),
    );
  }

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    widget.controller.sendMessage(widget.kisi.id, text);
    _textController.clear();
  }
}
