import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/kpss_calculator.dart';
import '../../../providers/mock_exam_provider.dart';

class AddMockExamSheet extends StatefulWidget {
  const AddMockExamSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddMockExamSheet(),
    );
  }

  @override
  State<AddMockExamSheet> createState() => _AddMockExamSheetState();
}

class _AddMockExamSheetState extends State<AddMockExamSheet> {
  final _titleController = TextEditingController();
  final _gyCorrectController = TextEditingController();
  final _gyWrongController = TextEditingController();
  final _gkCorrectController = TextEditingController();
  final _gkWrongController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  double _gyNet = 0.0;
  double _gkNet = 0.0;
  double _totalNet = 0.0;

  @override
  void initState() {
    super.initState();
    _gyCorrectController.addListener(_recalc);
    _gyWrongController.addListener(_recalc);
    _gkCorrectController.addListener(_recalc);
    _gkWrongController.addListener(_recalc);
  }

  void _recalc() {
    final gyC = int.tryParse(_gyCorrectController.text) ?? 0;
    final gyW = int.tryParse(_gyWrongController.text) ?? 0;
    final gkC = int.tryParse(_gkCorrectController.text) ?? 0;
    final gkW = int.tryParse(_gkWrongController.text) ?? 0;

    setState(() {
      _gyNet = KpssCalculator.calculateNet(gyC, gyW);
      _gkNet = KpssCalculator.calculateNet(gkC, gkW);
      _totalNet = _gyNet + _gkNet;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _gyCorrectController.dispose();
    _gyWrongController.dispose();
    _gkCorrectController.dispose();
    _gkWrongController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                  'Deneme Sınavı Ekle',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
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

            // Exam Name / Publisher
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Deneme Adı / Yayın (Örn: Pegem TG-1, Yediiklim)',
                prefixIcon: Icon(Icons.assignment),
              ),
            ),
            const SizedBox(height: 16),

            // Genel Yetenek Section (Türkçe + Matematik = 60 Soru)
            _buildSectionHeader('Genel Yetenek (GY - 60 Soru)', AppColors.courseTurkce),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInput(
                    controller: _gyCorrectController,
                    label: 'GY Doğru',
                    color: AppColors.correct,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInput(
                    controller: _gyWrongController,
                    label: 'GY Yanlış',
                    color: AppColors.wrong,
                  ),
                ),
                const SizedBox(width: 12),
                _buildNetBadge('GY Net', _gyNet, AppColors.courseTurkce),
              ],
            ),
            const SizedBox(height: 16),

            // Genel Kültür Section (Tarih + Coğrafya + Vatandaşlık = 60 Soru)
            _buildSectionHeader('Genel Kültür (GK - 60 Soru)', AppColors.courseTarih),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInput(
                    controller: _gkCorrectController,
                    label: 'GK Doğru',
                    color: AppColors.correct,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInput(
                    controller: _gkWrongController,
                    label: 'GK Yanlış',
                    color: AppColors.wrong,
                  ),
                ),
                const SizedBox(width: 12),
                _buildNetBadge('GK Net', _gkNet, AppColors.courseTarih),
              ],
            ),
            const SizedBox(height: 16),

            // Total Net Preview
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Toplam Deneme Neti:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    _totalNet.toStringAsFixed(2),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
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

            // Note
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: 'Sınav hakkında notlar (opsiyonel)',
                prefixIcon: Icon(Icons.note_alt_outlined, size: 20),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveMockExam,
                child: const Text('Deneme Sonucunu Kaydet'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: color),
        ),
      ],
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: color),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          decoration: const InputDecoration(
            hintText: '0',
            contentPadding: EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildNetBadge(String title, double net, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(
            net.toStringAsFixed(2),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
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

  void _saveMockExam() {
    final title = _titleController.text.trim();
    final gyC = int.tryParse(_gyCorrectController.text) ?? 0;
    final gyW = int.tryParse(_gyWrongController.text) ?? 0;
    final gkC = int.tryParse(_gkCorrectController.text) ?? 0;
    final gkW = int.tryParse(_gkWrongController.text) ?? 0;

    context.read<MockExamProvider>().addExam(
          title: title.isEmpty ? 'KPSS Denemesi' : title,
          date: _selectedDate,
          gyCorrect: gyC,
          gyWrong: gyW,
          gkCorrect: gkC,
          gkWrong: gkW,
          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deneme başarıyla kaydedildi! Toplam Net: ${_totalNet.toStringAsFixed(2)}'),
        backgroundColor: AppColors.completed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
