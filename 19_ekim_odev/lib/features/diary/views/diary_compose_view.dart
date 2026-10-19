import 'package:flutter/material.dart';
import '../controllers/diary_controller.dart';
import '../widgets/lined_paper_background.dart';
import '../widgets/mood_selector_bar.dart';

/// Yeni günlük sayfası yazma ekranı.
/// project.md kurallarına uygun olarak 40 satır altı build metotları ve defter kağıdı dokusu ile tasarlanmıştır.
class DiaryComposeView extends StatefulWidget {
  final DiaryController controller;

  const DiaryComposeView({
    super.key,
    required this.controller,
  });

  @override
  State<DiaryComposeView> createState() => _DiaryComposeViewState();
}

class _DiaryComposeViewState extends State<DiaryComposeView> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  String _selectedMood = 'Huzurlu';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _selectedMood = widget.controller.selectedMood.value;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveEntry() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir başlık veya içerik yazın.'),
        ),
      );
      return;
    }

    widget.controller.addEntry(
      title: title.isEmpty ? 'İsimsiz Sayfa' : title,
      content: content,
      mood: _selectedMood,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sayfa defterinize eklendi.'),
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Defter Sayfası'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded),
            tooltip: 'Sayfayı Kaydet',
            onPressed: _saveEntry,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              children: [
                _ComposeHeaderPanel(
                  selectedMood: _selectedMood,
                  onMoodChanged: (mood) => setState(() => _selectedMood = mood),
                ),
                Expanded(
                  child: _ComposePaperSheet(
                    titleController: _titleController,
                    contentController: _contentController,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ComposeHeaderPanel extends StatelessWidget {
  final String selectedMood;
  final ValueChanged<String> onMoodChanged;

  const _ComposeHeaderPanel({
    required this.selectedMood,
    required this.onMoodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final dateText =
        '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}';

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(
                  Icons.edit_calendar_rounded,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text('Tarih: $dateText', style: theme.textTheme.labelMedium),
                const Spacer(),
                Text(
                  'Ruh Hali: $selectedMood',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          MoodSelectorBar(
            selectedMood: selectedMood,
            onMoodSelected: onMoodChanged,
          ),
        ],
      ),
    );
  }
}

class _ComposePaperSheet extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController contentController;

  const _ComposePaperSheet({
    required this.titleController,
    required this.contentController,
  });

  @override
  Widget build(BuildContext context) {
    return LinedPaperBackground(
      marginOffset: 52.0,
      lineSpacing: 36.0,
      child: Column(
        children: [
          _ComposeTitleField(controller: titleController),
          Expanded(
            child: _ComposeContentField(controller: contentController),
          ),
        ],
      ),
    );
  }
}

class _ComposeTitleField extends StatelessWidget {
  final TextEditingController controller;

  const _ComposeTitleField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 36.0,
      child: Padding(
        padding: const EdgeInsets.only(left: 68, right: 24),
        child: TextField(
          controller: controller,
          cursorHeight: 18.0,
          cursorWidth: 1.5,
          cursorColor: theme.colorScheme.primary,
          style: theme.textTheme.titleSmall?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: 'Sayfa Başlığı...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            hintStyle: theme.textTheme.titleSmall?.copyWith(
              fontSize: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _ComposeContentField extends StatelessWidget {
  final TextEditingController controller;

  const _ComposeContentField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 68, right: 24, top: 2, bottom: 16),
      child: TextField(
        controller: controller,
        cursorHeight: 16.0,
        cursorWidth: 1.5,
        cursorColor: theme.colorScheme.primary,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontSize: 15,
          height: 2.4,
        ),
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        decoration: InputDecoration(
          hintText: 'Sevgili Günlük, bugün aklımdan geçenler...',
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          isDense: true,
          contentPadding: const EdgeInsets.only(top: 4),
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 15,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            height: 2.4,
          ),
        ),
      ),
    );
  }
}
