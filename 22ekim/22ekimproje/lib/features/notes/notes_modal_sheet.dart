import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_pink_button.dart';
import '../../data/models/habit_model.dart';
import '../../data/repositories/habit_repository.dart';
import '../../data/repositories/note_repository.dart';

class NotesModalSheet extends ConsumerStatefulWidget {
  final HabitModel? specificHabit; // null ise Tüm Notlar (Genel)

  const NotesModalSheet({super.key, this.specificHabit});

  static Future<void> show(BuildContext context, {HabitModel? specificHabit}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NotesModalSheet(specificHabit: specificHabit),
    );
  }

  @override
  ConsumerState<NotesModalSheet> createState() => _NotesModalSheetState();
}

class _NotesModalSheetState extends ConsumerState<NotesModalSheet> {
  final _contentController = TextEditingController();
  final _titleController = TextEditingController();
  bool _isAdding = false;
  HabitModel? _selectedHabitForNote;

  @override
  void initState() {
    super.initState();
    _selectedHabitForNote = widget.specificHabit;
  }

  @override
  void dispose() {
    _contentController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen not içeriğini yazınız.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final habit = widget.specificHabit ?? _selectedHabitForNote;

    await ref.read(allNotesProvider.notifier).addNote(
          habitId: habit?.id,
          habitName: habit?.title,
          title: _titleController.text.trim(),
          content: content,
        );

    _contentController.clear();
    _titleController.clear();
    setState(() => _isAdding = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not başarıyla kaydedildi!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final allNotes = ref.watch(allNotesProvider);
    final allHabits = ref.watch(habitsListProvider);

    // Filtreleme: Eğer spesifik bir alışkanlık modundaysa sadece onun notları, değilse tüm notlar
    final filteredNotes = widget.specificHabit != null
        ? allNotes
            .where((n) => n.habitId == widget.specificHabit!.id)
            .toList()
        : allNotes;

    final sheetTitle = widget.specificHabit != null
        ? '${widget.specificHabit!.title} - Notları'
        : 'Tüm Notlar & Düşünceler';

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: AppColors.borderHighlight, width: 2),
        ),
      ),
      child: Column(
        children: [
          // Üst Tutamaç ve Kapatma Butonu
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
                    const Icon(Icons.note_alt_outlined, color: AppColors.accent, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      sheetTitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Yeni Not Ekleme Butonu / Formu
          if (!_isAdding)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: CustomPinkButton(
                text: widget.specificHabit != null
                    ? 'Bu Alışkanlığa Not Ekle'
                    : 'Yeni Not Ekle',
                icon: Icons.add,
                width: double.infinity,
                height: 44,
                onPressed: () => setState(() => _isAdding = true),
              ),
            )
          else
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary, width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Yeni Not Yaz',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Alışkanlık Seçici (Genel Notlar ekranındaysa)
                  if (widget.specificHabit == null && allHabits.isNotEmpty) ...[
                    DropdownButtonFormField<HabitModel?>(
                      value: _selectedHabitForNote,
                      dropdownColor: AppColors.surfaceVariant,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Alışkanlık Bağla (İsteğe Bağlı)',
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Genel Not (Bağlantısız)'),
                        ),
                        ...allHabits.map(
                          (h) => DropdownMenuItem(
                            value: h,
                            child: Text(h.title),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() => _selectedHabitForNote = val);
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Başlık (İsteğe Bağlı)',
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _contentController,
                    maxLines: 3,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Notunuzu veya hislerinizi buraya yazın...',
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => setState(() => _isAdding = false),
                        child: const Text('Vazgeç', style: TextStyle(color: AppColors.textMuted)),
                      ),
                      const SizedBox(width: 8),
                      CustomPinkButton(
                        text: 'Kaydet',
                        height: 38,
                        onPressed: _saveNote,
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Notlar Listesi
          Expanded(
            child: filteredNotes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.speaker_notes_off_outlined,
                          size: 48,
                          color: AppColors.textMuted.withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Henüz kaydedilmiş bir not bulunmuyor.',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      final note = filteredNotes[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (note.habitName != null && note.habitName!.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryVariant,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      note.habitName!,
                                      style: const TextStyle(
                                        color: AppColors.softPink,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.border,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Genel',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                Text(
                                  DateFormat('dd.MM.yyyy HH:mm').format(note.createdAt),
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            if (note.title.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                note.title,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                            const SizedBox(height: 6),
                            Text(
                              note.content,
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: AppColors.textPrimary,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: InkWell(
                                onTap: () async {
                                  await ref
                                      .read(allNotesProvider.notifier)
                                      .deleteNote(note.id);
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.delete_outline, size: 16, color: AppColors.danger),
                                      SizedBox(width: 4),
                                      Text(
                                        'Sil',
                                        style: TextStyle(
                                          color: AppColors.danger,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
