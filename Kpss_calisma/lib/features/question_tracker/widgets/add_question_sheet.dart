import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/kpss_calculator.dart';
import '../../../providers/curriculum_provider.dart';
import '../../../providers/question_provider.dart';

class AddQuestionSheet extends StatefulWidget {
  const AddQuestionSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddQuestionSheet(),
    );
  }

  @override
  State<AddQuestionSheet> createState() => _AddQuestionSheetState();
}

class _AddQuestionSheetState extends State<AddQuestionSheet> {
  String? _selectedCourseId;
  final _correctController = TextEditingController();
  final _wrongController = TextEditingController();
  final _emptyController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  double _calculatedNet = 0.0;
  int _totalQuestions = 0;

  @override
  void initState() {
    super.initState();
    final courses = context.read<CurriculumProvider>().courses;
    if (courses.isNotEmpty) {
      _selectedCourseId = courses.first.id;
    }
    _correctController.addListener(_recalculate);
    _wrongController.addListener(_recalculate);
    _emptyController.addListener(_recalculate);
  }

  void _recalculate() {
    final d = int.tryParse(_correctController.text) ?? 0;
    final y = int.tryParse(_wrongController.text) ?? 0;
    final b = int.tryParse(_emptyController.text) ?? 0;
    setState(() {
      _totalQuestions = d + y + b;
      _calculatedNet = KpssCalculator.calculateNet(d, y);
    });
  }

  @override
  void dispose() {
    _correctController.dispose();
    _wrongController.dispose();
    _emptyController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final courses = context.watch<CurriculumProvider>().courses;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Soru Girişi Ekle',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Course Selection
            const Text(
              'Ders Seçimi',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: courses.map((course) {
                  final isSelected = _selectedCourseId == course.id;
                  final color = AppColors.getCourseColor(course.id);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      selected: isSelected,
                      label: Text(course.title),
                      selectedColor: color.withValues(alpha: 0.2),
                      side: BorderSide(
                        color: isSelected ? color : Colors.transparent,
                        width: 1.5,
                      ),
                      labelStyle: TextStyle(
                        color: isSelected ? color : null,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      onSelected: (val) {
                        if (val) {
                          setState(() => _selectedCourseId = course.id);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Number Inputs: Doğru, Yanlış, Boş
            Row(
              children: [
                Expanded(
                  child: _buildNumberInput(
                    controller: _correctController,
                    label: 'Doğru',
                    color: AppColors.correct,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNumberInput(
                    controller: _wrongController,
                    label: 'Yanlış',
                    color: AppColors.wrong,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNumberInput(
                    controller: _emptyController,
                    label: 'Boş',
                    color: AppColors.empty,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Real-Time Net Preview Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hesaplanan Net',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Toplam Soru: $_totalQuestions (4 Yanlış = 1 Doğru)',
                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                  Text(
                    _calculatedNet.toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Date Picker Row
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Tarih: ${AppDateUtils.formatDate(_selectedDate)}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _pickDate,
                  child: const Text('Değiştir'),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Note Input
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: 'Not veya konu bilgisi (opsiyonel)',
                prefixIcon: Icon(Icons.note_alt_outlined, size: 20),
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _totalQuestions > 0 ? _saveQuestionLog : null,
                child: const Text('Kaydı Ekle'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberInput({
    required TextEditingController controller,
    required String label,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            hintText: '0',
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveQuestionLog() {
    if (_selectedCourseId == null) return;
    final d = int.tryParse(_correctController.text) ?? 0;
    final y = int.tryParse(_wrongController.text) ?? 0;
    final b = int.tryParse(_emptyController.text) ?? 0;

    context.read<QuestionProvider>().addQuestionLog(
          courseId: _selectedCourseId!,
          correct: d,
          wrong: y,
          empty: b,
          date: _selectedDate,
          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        );

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Soru kaydı başarıyla eklendi! Net: ${_calculatedNet.toStringAsFixed(2)}'),
        backgroundColor: AppColors.completed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
