import 'package:flutter/material.dart';
import 'package:susadim/core/constants/app_colors.dart';

/// Örnek Modüler ve Çift Tema Uyumlu Kart Bileşeni (Susadım Standartı)
class SampleCardWidget extends StatelessWidget {
  final int current;
  final int goal;
  final VoidCallback onAdd;

  const SampleCardWidget({
    super.key,
    required this.current,
    required this.goal,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.neonCyanBright : AppColors.neonCyan;
    final progress = (current / goal).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, accentColor),
            const SizedBox(height: 12),
            _buildProgressBar(progress, accentColor, isDark),
            const SizedBox(height: 14),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color accentColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Aktivite İlerlemesi',
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '$current / $goal',
          style: TextStyle(
            color: accentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(double progress, Color accentColor, bool isDark) {
    final trackColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 10,
        backgroundColor: trackColor,
        valueColor: AlwaysStoppedAnimation<Color>(accentColor),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: FilledButton.tonalIcon(
        onPressed: onAdd,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('250 Ekle'),
      ),
    );
  }
}
