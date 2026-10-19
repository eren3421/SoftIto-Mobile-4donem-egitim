import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CarPhoto extends StatelessWidget {
  const CarPhoto({super.key, required this.url, this.fit = BoxFit.cover});

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const ColoredBox(
          color: AppColors.paleGreen,
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => const ColoredBox(
        color: AppColors.paleGreen,
        child: Center(
          child: Icon(
            Icons.directions_car_filled_outlined,
            size: 52,
            color: AppColors.muted,
          ),
        ),
      ),
    );
  }
}
