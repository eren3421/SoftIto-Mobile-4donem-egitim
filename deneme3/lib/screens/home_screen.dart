import 'package:flutter/material.dart';

import '../data/cars.dart';
import '../theme/app_theme.dart';
import '../widgets/car_card.dart';
import '../widgets/car_photo.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onBrowseTap});

  final VoidCallback onBrowseTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroBanner(onBrowseTap: onBrowseTap),
          const SizedBox(height: 25),
          const _ServiceHighlights(),
          const SizedBox(height: 35),
          _SectionHeading(
            title: 'Öne çıkan otomobiller',
            subtitle: 'Galerimizden sizin için seçtiklerimiz',
            trailing: TextButton.icon(
              onPressed: onBrowseTap,
              icon: const Icon(Icons.arrow_forward_rounded, size: 17),
              label: const Text('Tüm araçlar'),
            ),
          ),
          const SizedBox(height: 15),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 760 ? 3 : 1;
              final width =
                  (constraints.maxWidth - (columns - 1) * 14) / columns;
              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: galleryCars.take(3).map((car) {
                  return SizedBox(
                    width: width,
                    child: CarCard(car: car, onTap: onBrowseTap),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 32),
          const _TrustStrip(),
        ],
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.onBrowseTap});

  final VoidCallback onBrowseTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 520;
        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: compact ? 330 : 365,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const CarPhoto(
                  url: 'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?auto=format&fit=crop&w=1800&q=90',
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        Color(0x00152126),
                        Color(0x8C152126),
                        Color(0xF2152126),
                      ],
                      stops: [0, .42, 1],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(compact ? 22 : 38),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .15),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: .24),
                              ),
                            ),
                            child: const Text(
                              'SEÇKİN OTOMOBİL DENEYİMİ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Hayalindeki otomobil,\nbir adım uzağında.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: compact ? 29 : 39,
                              height: 1.08,
                              letterSpacing: -.8,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Özenle seçilmiş araçları keşfet, yolculuğuna güvenle başla.',
                            style: TextStyle(
                              color: Color(0xFFD8DFDC),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 23),
                          FilledButton.icon(
                            onPressed: onBrowseTap,
                            icon: const Icon(Icons.directions_car_outlined),
                            label: const Text('Araçları keşfet'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ServiceHighlights extends StatelessWidget {
  const _ServiceHighlights();

  @override
  Widget build(BuildContext context) {
    const items = [
      (
        Icons.verified_user_outlined,
        'Ekspertiz kontrolü',
        'Her araç özenle incelenir',
      ),
      (Icons.price_check_outlined, 'Şeffaf fiyat', 'Açık ve anlaşılır süreç'),
      (
        Icons.support_agent_outlined,
        'Size özel destek',
        'Satış öncesi ve sonrası',
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 680 ? 3 : 1;
        final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items.map((item) {
            return SizedBox(
              width: width,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.paleGreen,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(item.$1, color: AppColors.ink, size: 21),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.$2,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.$3,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.3,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 13, color: AppColors.muted),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _TrustStrip extends StatelessWidget {
  const _TrustStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(17),
      ),
      child: const Row(
        children: [
          Icon(Icons.handshake_outlined, color: Color(0xFFE8B999), size: 25),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Size uygun aracı birlikte bulalım.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
        ],
      ),
    );
  }
}
