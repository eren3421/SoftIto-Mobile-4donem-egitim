import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../lib/core/constants/app_colors.dart';
import '../../lib/providers/question_provider.dart';

/// Örnek KPSS Modüler Ekran Şablonu
class SampleFeatureScreen extends StatelessWidget {
  const SampleFeatureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final questionProv = context.watch<QuestionProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Örnek Özellik Ekranı'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
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
              child: Row(
                children: [
                  const Icon(Icons.school, color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Bugünkü Net: ${questionProv.todayNetScore.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
