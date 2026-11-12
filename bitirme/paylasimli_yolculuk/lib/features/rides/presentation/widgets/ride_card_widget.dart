import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/ride_entity.dart';

class RideCardWidget extends StatelessWidget {
  final RideEntity ride;
  final VoidCallback onTap;

  const RideCardWidget({
    super.key,
    required this.ride,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = ride.status == 'completed';
    final isFull = ride.isFull || ride.availableSeats <= 0;

    final String badgeText;
    final Color badgeColor;
    final IconData badgeIcon;

    if (isCompleted) {
      badgeText = 'Tamamlandı • Başvuruya Kapalı';
      badgeColor = Colors.grey.shade700;
      badgeIcon = Icons.done_all_rounded;
    } else if (isFull) {
      badgeText = 'Kapasite Dolu (0 Boş Koltuk)';
      badgeColor = AppColors.error;
      badgeIcon = Icons.cancel_outlined;
    } else {
      badgeText = 'Başvuruya Açık • ${ride.availableSeats} Koltuk Boş';
      badgeColor = AppColors.success;
      badgeIcon = Icons.check_circle_outline_rounded;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst Satır: Tarih/Saat + Durum & Fiyat
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormatter.formatDayAndTime(ride.departureTime),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      DateFormatter.formatCurrency(
                        ride.pricePerSeat,
                        currency: ride.currency,
                      ),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Başvuru Uygunluk ve Koltuk Durum Rozeti
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(badgeIcon, size: 15, color: badgeColor),
                    const SizedBox(width: 6),
                    Text(
                      badgeText,
                      style: TextStyle(
                        color: badgeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Rota Zaman Çizelgesi (Kalkış -> Ara Durak -> Varış)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      const Icon(
                        Icons.radio_button_checked_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      Container(
                        width: 2,
                        height: ride.waypoints.isNotEmpty ? 36 : 24,
                        color: AppColors.primary.withValues(alpha: 0.4),
                      ),
                      const Icon(
                        Icons.location_on_rounded,
                        size: 18,
                        color: AppColors.error,
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ride.origin.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        if (ride.waypoints.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Ara durak: ${ride.waypoints.map((w) => w.name).join(', ')}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.accent,
                                    ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Text(
                          ride.destination.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Alt Satır: Sürücü Özeti, Araç ve Boş Koltuk
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                    child: Text(
                      ride.driverSummary.fullName.isNotEmpty
                          ? ride.driverSummary.fullName[0].toUpperCase()
                          : 'S',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                ride.driverSummary.fullName,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: AppColors.warning,
                            ),
                            Text(
                              ride.driverSummary.ratingAvg > 0
                                  ? ride.driverSummary.ratingAvg.toStringAsFixed(1)
                                  : 'Yeni',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${ride.vehicleSummary.brandModel} • ${ride.vehicleSummary.color}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (ride.rules.instantApproval)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Tooltip(
                        message: 'Anında Onay',
                        child: Icon(
                          Icons.bolt_rounded,
                          color: AppColors.warning,
                          size: 20,
                        ),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isCompleted
                          ? 'TAMAMLANDI'
                          : (isFull
                              ? 'DOLU'
                              : '${ride.availableSeats}/${ride.totalSeatsOffered} Koltuk'),
                      style: TextStyle(
                        color: badgeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

