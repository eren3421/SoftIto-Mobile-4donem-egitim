import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/crimson_button.dart';
import '../../../core/widgets/vehicle_type_badge.dart';
import '../../auth/domain/models/app_user.dart';
import '../../auth/domain/models/user_role.dart';
import '../domain/models/vehicle_model.dart';

class VehicleDetailDialog extends StatelessWidget {
  final VehicleModel vehicle;
  final AppUser? currentUser;
  final VoidCallback onRent;
  final VoidCallback onTrack;
  final VoidCallback onChat;

  const VehicleDetailDialog({
    super.key,
    required this.vehicle,
    required this.currentUser,
    required this.onRent,
    required this.onTrack,
    required this.onChat,
  });

  static Future<void> show(
    BuildContext context, {
    required VehicleModel vehicle,
    required AppUser? currentUser,
    required VoidCallback onRent,
    required VoidCallback onTrack,
    required VoidCallback onChat,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => VehicleDetailDialog(
        vehicle: vehicle,
        currentUser: currentUser,
        onRent: onRent,
        onTrack: onTrack,
        onChat: onChat,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOwner = currentUser != null && currentUser!.id == vehicle.ownerId;
    final canRent = currentUser != null && currentUser!.canRent && !isOwner && vehicle.isAvailable;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: SingleChildScrollView(
          padding: AppSpacing.cardPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  VehicleTypeBadge(category: vehicle.vehicleType),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              Text(
                vehicle.title,
                style: AppTypography.displayHeader(
                  color: isDark ? AppColors.platinumText : AppColors.lightTextPrimary,
                ),
              ),

              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 15, color: AppColors.crimsonLight),
                  const SizedBox(width: 4),
                  Text(
                    '${vehicle.city}, ${vehicle.country}',
                    style: TextStyle(
                      color: isDark ? AppColors.silverText : AppColors.lightTextSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Plate and Tracking capsules
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.charcoalGrey,
                      borderRadius: AppSpacing.radiusSm,
                      border: Border.all(color: AppColors.steelBorderGrey),
                    ),
                    child: Text(
                      'Plaka / Tescil: ${vehicle.plateNumber}',
                      style: AppTypography.plateCode(),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      onTrack();
                    },
                    borderRadius: AppSpacing.radiusSm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.crimsonSurface,
                        borderRadius: AppSpacing.radiusSm,
                        border: Border.all(color: AppColors.crimsonPrimary),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.radar, size: 14, color: AppColors.crimsonLight),
                          const SizedBox(width: 6),
                          Text(
                            vehicle.trackingNumber,
                            style: AppTypography.telemetryCode(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),
              const Divider(),
              const SizedBox(height: AppSpacing.sm),

              // Description
              if (vehicle.description != null) ...[
                const Text('Araç Açıklaması', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 6),
                Text(
                  vehicle.description!,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: isDark ? AppColors.silverText : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // Specs Grid
              if (vehicle.specs.isNotEmpty) ...[
                const Text('Teknik Donanım & Özellikler', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: vehicle.specs.entries.map((entry) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.slateCardGrey : AppColors.lightInputBg,
                        borderRadius: AppSpacing.radiusSm,
                        border: Border.all(color: isDark ? AppColors.steelBorderGrey : AppColors.lightBorder),
                      ),
                      child: Text(
                        '${entry.key}: ${entry.value}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // Owner Card
              Container(
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.slateCardGrey : AppColors.lightInputBg,
                  borderRadius: AppSpacing.radiusMd,
                  border: Border.all(color: isDark ? AppColors.steelBorderGrey : AppColors.lightBorder),
                ),
                child: Row(
                  children: [
                    Icon(
                      vehicle.ownerRole == UserRole.company ? Icons.apartment : Icons.account_circle,
                      size: 32,
                      color: AppColors.crimsonLight,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicle.ownerName,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          Text(
                            vehicle.ownerRole.displayName,
                            style: const TextStyle(fontSize: 12, color: AppColors.silverText),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline, color: AppColors.crimsonLight),
                      tooltip: 'Mesaj Gönder',
                      onPressed: () {
                        Navigator.of(context).pop();
                        onChat();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Bottom Price & Action Container
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.gunmetalGrey : AppColors.lightInputBg,
                  borderRadius: AppSpacing.radiusMd,
                  border: Border.all(
                    color: isDark ? AppColors.steelBorderGrey : AppColors.lightBorder,
                    width: 0.8,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Kiralama Ücreti', style: TextStyle(fontSize: 11, color: AppColors.silverText)),
                            Text(
                              Formatters.currency(vehicle.unitPrice, '/ ${vehicle.pricingPeriod}'),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.platinumText : AppColors.crimsonPrimary,
                              ),
                            ),
                          ],
                        ),
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                          child: const Text('Kapat'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (canRent)
                      CrimsonButton(
                        label: 'Rezervasyon Yap',
                        icon: Icons.calendar_today,
                        height: 42,
                        onPressed: () {
                          Navigator.of(context).pop();
                          onRent();
                        },
                      )
                    else if (currentUser?.isCompany ?? false)
                      const ContainerNotice(text: 'Kurumsal hesaplar yalnızca kiraya verebilir.')
                    else if (isOwner)
                      CrimsonButton(
                        label: 'Canlı Takip',
                        icon: Icons.radar,
                        height: 42,
                        onPressed: () {
                          Navigator.of(context).pop();
                          onTrack();
                        },
                      )
                    else if (!vehicle.isAvailable)
                      const ContainerNotice(text: 'Araç şu an kirada.'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContainerNotice extends StatelessWidget {
  final String text;
  const ContainerNotice({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.crimsonSurface,
        borderRadius: AppSpacing.radiusSm,
        border: Border.all(color: AppColors.crimsonPrimary, width: 0.8),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: AppColors.crimsonLight),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: AppColors.crimsonLight, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
