import 'package:flutter/material.dart';

/// 1. EKRAN: Tekli ve Kademeli Sayaç Ekranı
/// Stajyer Notu:
/// StatefulWidget kullandık çünkü sayaç değeri kullanıcı etkileşimiyle değişir.
/// Bu sınıfta iki farklı ekleme butonu (+1 ve +5) bulunmaktadır.
class ClassicCounterScreen extends StatefulWidget {
  const ClassicCounterScreen({super.key});

  @override
  State<ClassicCounterScreen> createState() => _ClassicCounterScreenState();
}

class _ClassicCounterScreenState extends State<ClassicCounterScreen> {
  int _counter = 0;
  int _lastAdded = 0;

  @override
  void initState() {
    super.initState();
    // Stajyer Notu: initState(), widget ağaca ilk eklendiğinde sadece 1 kez çalışır.
    // Başlangıç değerleri veya dinleyiciler burada kurulabilir.
  }

  void _increment(int amount) {
    setState(() {
      // Stajyer Notu: setState() çağrısı Flutter'a UI'ın yeniden çizilmesi (rebuild)
      // gerektiğini bildirir. Flutter Element Tree üzerinden sadece değişen kısmı günceller.
      _counter += amount;
      _lastAdded = amount;
    });

    // Kullanıcıya Material 3 SnackBar ile geri bildirim verelim
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sayaç +$amount artırıldı!'),
        duration: const Duration(milliseconds: 700),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _decrement() {
    if (_counter > 0) {
      setState(() {
        _counter--;
      });
    }
  }

  void _reset() {
    setState(() {
      _counter = 0;
      _lastAdded = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bilgi Rozeti
            Chip(
              avatar: const Icon(Icons.touch_app, size: 18),
              label: const Text('1. Sayaç Modu: İki Farklı Ekleme Seçeneği'),
              backgroundColor: colorScheme.secondaryContainer,
            ),
            const SizedBox(height: 24),

            // Sayaç Kartı (Material 3 Card)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primaryContainer.withValues(alpha: 0.5),
                      colorScheme.surface,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Mevcut Değer',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$_counter',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    if (_lastAdded > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Son eklenen: +$_lastAdded',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 2 Farklı Ekleme Butonu Grubu
            Text(
              'Ekleme Seçenekleri',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. Ekleme Yöntemi: +1 Standart Ekle
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => _increment(1),
                    icon: const Icon(Icons.add),
                    label: const Text(
                      '+1 Ekle',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 2. Ekleme Yöntemi: +5 Hızlı / Çoklu Ekle
                Expanded(
                  child: FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => _increment(5),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text(
                      '+5 Ekle',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Ekstra İşlemler (Azalt ve Sıfırla)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _counter > 0 ? _decrement : null,
                  icon: const Icon(Icons.remove),
                  label: const Text('1 Azalt'),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: _counter > 0 ? _reset : null,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Sıfırla'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
