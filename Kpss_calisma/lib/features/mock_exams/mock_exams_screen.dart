import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../providers/mock_exam_provider.dart';
import 'widgets/add_mock_exam_sheet.dart';

class MockExamsScreen extends StatelessWidget {
  const MockExamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final examProv = context.watch<MockExamProvider>();
    final exams = examProv.exams;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deneme Sınavları'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddMockExamSheet.show(context),
        icon: const Icon(Icons.add),
        label: const Text('Deneme Ekle'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: exams.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.assignment_outlined, size: 48, color: AppColors.accentGold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Henüz deneme kaydı eklenmedi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'İlk deneme sınavı sonucunu ekleyerek netlerini takip et!',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => AddMockExamSheet.show(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Deneme Sınavı Ekle'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryItem(
                          'Ortalama Net',
                          examProv.averageTotalNet.toStringAsFixed(2),
                        ),
                        Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.2)),
                        _buildSummaryItem(
                          'En Yüksek Net',
                          examProv.highestTotalNet.toStringAsFixed(2),
                        ),
                        Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.2)),
                        _buildSummaryItem(
                          'Toplam Deneme',
                          exams.length.toString(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Kayıtlı Denemeler',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: exams.length,
                    itemBuilder: (context, index) {
                      final exam = exams[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.cardTheme.color,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.brightness == Brightness.dark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        exam.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        AppDateUtils.formatDate(exam.date),
                                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${exam.totalNet.toStringAsFixed(2)} Net',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  onPressed: () => examProv.deleteExam(exam.id),
                                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                                  tooltip: 'Denemeyi Sil',
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text('Genel Yetenek (GY)', style: theme.textTheme.bodySmall),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${exam.gyCorrect} D • ${exam.gyWrong} Y',
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                    ),
                                    Text(
                                      'Net: ${exam.gyNet.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: AppColors.courseTurkce,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 1,
                                  height: 36,
                                  color: Colors.grey.withValues(alpha: 0.2),
                                ),
                                Column(
                                  children: [
                                    Text('Genel Kültür (GK)', style: theme.textTheme.bodySmall),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${exam.gkCorrect} D • ${exam.gkWrong} Y',
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                    ),
                                    Text(
                                      'Net: ${exam.gkNet.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: AppColors.courseTarih,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (exam.note != null && exam.note!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Not: ${exam.note}',
                                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
