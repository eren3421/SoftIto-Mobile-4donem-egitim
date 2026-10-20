import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/crimson_button.dart';
import '../../../core/widgets/slate_card.dart';
import '../../../core/widgets/vehicle_type_badge.dart';
import '../../auth/domain/models/app_user.dart';
import '../../auth/domain/models/user_role.dart';
import '../domain/models/vehicle_model.dart';

class VehicleCard extends StatelessWidget {
  final VehicleModel vehicle;
  final AppUser? currentUser;
  final VoidCallback onDetailsTap;
  final VoidCallback onRentTap;
  final VoidCallback onTrackTap;
  final VoidCallback onChatTap;

  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.currentUser,
    required this.onDetailsTap,
    required this.onRentTap,
    required this.onTrackTap,
    required this.onChatTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOwner = currentUser != null && currentUser!.id == vehicle.ownerId;
    final canRent = currentUser != null && currentUser!.canRent && !isOwner && vehicle.isAvailable;

    return SlateCard(
      onTap: onDetailsTap,
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar: Type badge, Location, and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              VehicleTypeBadge(category: vehicle.vehicleType),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: AppColors.crimsonLight),
                  const SizedBox(width: 4),
                  Text(
                    vehicle.locationSummary,
                    style: AppTypography.caption(
                      color: isDark ? AppColors.silverText : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: vehicle.isAvailable
                          ? AppColors.statusEmerald.withValues(alpha: 0.15)
                          : AppColors.statusRed.withValues(alpha: 0.15),
                      borderRadius: AppSpacing.radiusSm,
                      border: Border.all(
                        color: vehicle.isAvailable ? AppColors.statusEmerald : AppColors.statusRed,
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      vehicle.isAvailable ? 'Müsait' : 'Dolu',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: vehicle.isAvailable ? AppColors.statusEmerald : AppColors.statusRed,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Title: Brand & Model
          Text(
            vehicle.title,
            style: AppTypography.cardTitle(
              color: isDark ? AppColors.platinumText : AppColors.lightTextPrimary,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Plate Box & Tracking Badge
          Row(
            children: [
              _buildPlateCapsule(context),
              const SizedBox(width: AppSpacing.sm),
              _buildTrackingBadge(context),
            ],
          ),

          if (vehicle.description != null && vehicle.description!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              vehicle.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyRegular(
                color: isDark ? AppColors.silverText : AppColors.lightTextSecondary,
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),

          // Bottom Bar: Owner & Price & Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Owner
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      vehicle.ownerRole == UserRole.company ? Icons.business : Icons.person_outline,
                      size: 15,
                      color: AppColors.crimsonLight,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        vehicle.ownerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.silverText : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),

              // Price & Button
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    Formatters.currency(vehicle.unitPrice, '/ ${vehicle.pricingPeriod}'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.platinumText : AppColors.crimsonPrimary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  if (isOwner)
                    CrimsonButton(
                      label: 'Takip',
                      icon: Icons.radar,
                      height: 34,
                      onPressed: onTrackTap,
                    )
                  else if (canRent)
                    CrimsonButton(
                      label: 'Kirala',
                      height: 34,
                      onPressed: onRentTap,
                    )
                  else
                    OutlinedButton(
                      onPressed: onDetailsTap,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: AppSpacing.radiusMd),
                      ),
                      child: const Text('İncele', style: TextStyle(fontSize: 12)),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlateCapsule(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.charcoalGrey,
        borderRadius: AppSpacing.radiusSm,
        border: Border.all(color: AppColors.steelBorderGrey, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 3,
            height: 12,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: AppColors.crimsonPrimary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            vehicle.plateNumber,
            style: AppTypography.plateCode(color: AppColors.platinumText),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingBadge(BuildContext context) {
    return InkWell(
      onTap: onTrackTap,
      borderRadius: AppSpacing.radiusSm,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.crimsonSurface,
          borderRadius: AppSpacing.radiusSm,
          border: Border.all(color: AppColors.crimsonPrimary, width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 6),
              decoration: const BoxDecoration(
                color: AppColors.crimsonLight,
                shape: BoxShape.circle,
              ),
            ),
            Text(
              vehicle.trackingNumber,
              style: AppTypography.telemetryCode(
                color: AppColors.crimsonLight,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
