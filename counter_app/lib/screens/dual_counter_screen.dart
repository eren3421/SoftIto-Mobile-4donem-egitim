import 'package:flutter/material.dart';

/// 2. EKRAN: Çift Sayaç (Dual Counter) Ekranı
/// Stajyer Notu:
/// Bu ekranda bağımsız çalışan iki farklı sayaç (_counterA ve _counterB)
/// yönetilmektedir. Takım skoru, karşılaştırma veya iki ayrı hedef takibi için idealdir.
class DualCounterScreen extends StatefulWidget {
  const DualCounterScreen({super.key});

  @override
  State<DualCounterScreen> createState() => _DualCounterScreenState();
}

class _DualCounterScreenState extends State<DualCounterScreen> {
  int _counterA = 0;
  int _counterB = 0;

  void _incrementA([int step = 1]) {
    setState(() {
      _counterA += step;
    });
  }

  void _incrementB([int step = 1]) {
    setState(() {
      _counterB += step;
    });
  }

  void _resetAll() {
    setState(() {
      _counterA = 0;
      _counterB = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Her iki sayaç da sıfırlandı!'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final total = _counterA + _counterB;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Bilgi Rozeti
            Chip(
              avatar: const Icon(Icons.compare_arrows, size: 18),
              label: const Text('2. Sayaç Modu: İki Bağımsız Sayaç'),
              backgroundColor: colorScheme.tertiaryContainer,
            ),
            const SizedBox(height: 20),

            // Toplam Sayaç Kartı
            Card(
              color: colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Toplam Skor / Toplam Ekleme',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '$total',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    IconButton.filledTonal(
                      onPressed: total > 0 ? _resetAll : null,
                      icon: const Icon(Icons.restart_alt),
                      tooltip: 'Tümünü Sıfırla',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // İki Farklı Sayaç Kartı Yan Yana (Responsive Row)
            Row(
              children: [
                // 1. SAYAÇ (Sayaç A - Birincil Renk)
                Expanded(
                  child: _buildCounterCard(
                    title: '1. Sayaç (A)',
                    count: _counterA,
                    accentColor: colorScheme.primary,
                    bgColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
                    onAddOne: () => _incrementA(1),
                    onAddTen: () => _incrementA(10),
                    onDecrement: () {
                      if (_counterA > 0) {
                        setState(() => _counterA--);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 14),

                // 2. SAYAÇ (Sayaç B - Üçüncül Renk)
                Expanded(
                  child: _buildCounterCard(
                    title: '2. Sayaç (B)',
                    count: _counterB,
                    accentColor: colorScheme.tertiary,
                    bgColor: colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                    onAddOne: () => _incrementB(1),
                    onAddTen: () => _incrementB(10),
                    onDecrement: () {
                      if (_counterB > 0) {
                        setState(() => _counterB--);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterCard({
    required String title,
    required int count,
    required Color accentColor,
    required Color bgColor,
    required VoidCallback onAddOne,
    required VoidCallback onAddTen,
    required VoidCallback onDecrement,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: accentColor.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: bgColor,
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        child: Column(
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$count',
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 20),

            // Ekle butonları
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: accentColor,
                minimumSize: const Size.fromHeight(40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onAddOne,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('+1 Ekle'),
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(38),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onAddTen,
              child: const Text('+10 Ekle'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: count > 0 ? onDecrement : null,
              child: const Text('-1 Azalt'),
            ),
          ],
        ),
      ),
    );
  }
}
