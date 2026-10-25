import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../providers/curriculum_provider.dart';
import '../../../providers/question_provider.dart';

class SaveSessionDialog extends StatefulWidget {
  final int durationMinutes;
  final String sessionType;

  const SaveSessionDialog({
    super.key,
    required this.durationMinutes,
    required this.sessionType,
  });

  static Future<void> show(
    BuildContext context, {
    required int durationMinutes,
    required String sessionType,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SaveSessionDialog(
        durationMinutes: durationMinutes,
        sessionType: sessionType,
      ),
    );
  }

  @override
  State<SaveSessionDialog> createState() => _SaveSessionDialogState();
}

class _SaveSessionDialogState extends State<SaveSessionDialog> {
  String? _selectedCourseId;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final courses = context.read<CurriculumProvider>().courses;
    if (courses.isNotEmpty) {
      _selectedCourseId = courses.first.id;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courses = context.watch<CurriculumProvider>().courses;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.check_circle, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Oturumu Kaydet',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer, color: AppColors.secondary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Tamamlanan Süre: ${AppDateUtils.formatDuration(widget.durationMinutes)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Hangi derse çalıştın?',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: courses.map((c) {
                final isSelected = _selectedCourseId == c.id;
                final color = AppColors.getCourseColor(c.id);
                return ChoiceChip(
                  selected: isSelected,
                  label: Text(c.title),
                  selectedColor: color.withValues(alpha: 0.2),
                  side: BorderSide(color: isSelected ? color : Colors.transparent),
                  labelStyle: TextStyle(
                    color: isSelected ? color : null,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _selectedCourseId = c.id);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: 'Oturum notu (opsiyonel)',
                prefixIcon: Icon(Icons.edit_note, size: 20),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _saveSession,
          child: const Text('Kaydet'),
        ),
      ],
    );
  }

  void _saveSession() {
    if (_selectedCourseId == null) return;
    context.read<QuestionProvider>().addStudySession(
          courseId: _selectedCourseId!,
          durationInMinutes: widget.durationMinutes,
          date: DateTime.now(),
          type: widget.sessionType,
          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Çalışma süresi başarıyla kaydedildi!'),
        backgroundColor: AppColors.completed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
