import 'package:flutter/material.dart';

import '../models/car.dart';
import '../theme/app_theme.dart';
import 'car_photo.dart';

class CarCard extends StatelessWidget {
  const CarCard({
    super.key,
    required this.car,
    required this.onTap,
    this.isFavorite = false,
    this.onFavorite,
  });

  final Car car;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback? onFavorite;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 184,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CarPhoto(url: car.imageUrl),
                  if (car.badge != null)
                    Positioned(
                      left: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .94),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          car.badge!,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: .5,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                  if (onFavorite != null)
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Material(
                        color: Colors.white.withValues(alpha: .95),
                        shape: const CircleBorder(),
                        child: IconButton(
                          tooltip: isFavorite
                              ? 'Favorilerden çıkar'
                              : 'Favorilere ekle',
                          visualDensity: VisualDensity.compact,
                          onPressed: onFavorite,
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isFavorite
                                ? AppColors.accent
                                : AppColors.ink,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${car.year}  ·  ${car.transmission}  ·  ${car.fuel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          formatTry(car.price),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.accent,
                        size: 20,
                      ),
                    ],
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
