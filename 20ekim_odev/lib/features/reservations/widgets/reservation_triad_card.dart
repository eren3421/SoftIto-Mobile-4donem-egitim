import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/slate_card.dart';
import '../../../core/widgets/vehicle_type_badge.dart';
import '../../auth/domain/models/app_user.dart';
import '../../auth/domain/models/user_role.dart';
import '../domain/models/reservation_model.dart';
import '../domain/models/reservation_status.dart';

class ReservationTriadCard extends StatelessWidget {
  final ReservationModel reservation;
  final AppUser? currentUser;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onStartRental;
  final VoidCallback onCompleteRental;
  final VoidCallback onTrack;
  final VoidCallback onChat;

  const ReservationTriadCard({
    super.key,
    required this.reservation,
    required this.currentUser,
    required this.onApprove,
    required this.onReject,
    required this.onStartRental,
    required this.onCompleteRental,
    required this.onTrack,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOwner = currentUser != null && currentUser!.id == reservation.ownerId;

    return SlateCard(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header: Dates & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_month, size: 16, color: AppColors.crimsonLight),
                  const SizedBox(width: 6),
                  Text(
                    Formatters.dateRange(reservation.startDate, reservation.endDate),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${reservation.dayCount} Gün)',
                    style: const TextStyle(fontSize: 12, color: AppColors.silverText),
                  ),
                ],
              ),
              _buildStatusBadge(context, reservation.status),
            ],
          ),

          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),

          // The 3 TRIAD Sections: Araç | Kiralayan | Araç Sahibi
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 650) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildVehicleSection(context, isDark)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _buildRenterSection(context, isDark)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _buildOwnerSection(context, isDark)),
                  ],
                );
              }
              // Stacked on narrow screens
              return Column(
                children: [
                  _buildVehicleSection(context, isDark),
                  const SizedBox(height: AppSpacing.sm),
                  _buildRenterSection(context, isDark),
                  const SizedBox(height: AppSpacing.sm),
                  _buildOwnerSection(context, isDark),
                ],
              );
            },
          ),

          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),

          // Bottom Action Bar: Price and Primary Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Toplam Tutar', style: TextStyle(fontSize: 11, color: AppColors.silverText)),
                  Text(
                    Formatters.currency(reservation.totalPrice, ''),
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.crimsonLight : AppColors.crimsonPrimary,
                    ),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: onChat,
                icon: const Icon(Icons.chat_bubble_outline, size: 14),
                label: Text(isOwner ? 'Kiracıya Yaz' : 'Sahibine Yaz'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Action Buttons Row
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 6,
            children: [
              // Tracking button
              if (isOwner || reservation.status == ReservationStatus.active)
                OutlinedButton.icon(
                  onPressed: onTrack,
                  icon: const Icon(Icons.radar, size: 14, color: AppColors.crimsonLight),
                  label: const Text('Canlı Takip', style: TextStyle(color: AppColors.crimsonLight)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.crimsonPrimary),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),

              // Owner Approval / Transition actions
              if (isOwner && reservation.status == ReservationStatus.pending) ...[
                OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.statusRed,
                    side: const BorderSide(color: AppColors.statusRed),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  child: const Text('Reddet', style: TextStyle(fontSize: 12)),
                ),
                ElevatedButton(
                  onPressed: onApprove,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.statusEmerald,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: const Text('Onayla', style: TextStyle(fontSize: 12)),
                ),
              ],

              if (isOwner && reservation.status == ReservationStatus.approved) ...[
                ElevatedButton.icon(
                  onPressed: onStartRental,
                  icon: const Icon(Icons.key, size: 14),
                  label: const Text('Teslim Et (Kirayı Başlat)', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.crimsonPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
              ],

              if (isOwner && reservation.status == ReservationStatus.active) ...[
                ElevatedButton(
                  onPressed: onCompleteRental,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.statusEmerald,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: const Text('Teslim Al (Tamamla)', style: TextStyle(fontSize: 12)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // --- BÖLÜM 1: ARAÇ BİLGİSİ ---
  Widget _buildVehicleSection(BuildContext context, bool isDark) {
    return _buildTriadBox(
      context,
      isDark,
      title: '1. ARAÇ DETAYI',
      icon: Icons.directions_car,
      iconColor: AppColors.crimsonLight,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              VehicleTypeBadge(category: reservation.vehicleType, compact: true),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  reservation.vehicleSummary,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Plaka: ${reservation.plateNumber}',
            style: AppTypography.plateCode(color: isDark ? AppColors.platinumText : AppColors.lightTextPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Takip: ${reservation.trackingNumber}',
            style: AppTypography.telemetryCode(fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            Formatters.currency(reservation.unitPrice, '/ Gün'),
            style: const TextStyle(fontSize: 12, color: AppColors.silverText),
          ),
        ],
      ),
    );
  }

  // --- BÖLÜM 2: KİRALAYAN (SİVİL) ---
  Widget _buildRenterSection(BuildContext context, bool isDark) {
    return _buildTriadBox(
      context,
      isDark,
      title: '2. KİRALAYAN (SİVİL)',
      icon: Icons.person_outline,
      iconColor: AppColors.statusEmerald,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reservation.renterFullName,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            'TC: ${reservation.maskedTcNumber}',
            style: const TextStyle(fontSize: 12, color: AppColors.silverText),
          ),
          const SizedBox(height: 4),
          Text(
            reservation.renterPhone,
            style: const TextStyle(fontSize: 12, color: AppColors.silverText),
          ),
          const SizedBox(height: 4),
          Text(
            reservation.renterAddressSummary,
            style: const TextStyle(fontSize: 11, color: AppColors.mutedGreyText),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // --- BÖLÜM 3: ARAÇ SAHİBİ ---
  Widget _buildOwnerSection(BuildContext context, bool isDark) {
    return _buildTriadBox(
      context,
      isDark,
      title: '3. ARAÇ SAHİBİ',
      icon: reservation.ownerRole == UserRole.company ? Icons.business : Icons.person_pin,
      iconColor: AppColors.crimsonAccent,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reservation.ownerDisplayName,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            reservation.ownerRole.displayName,
            style: const TextStyle(fontSize: 11, color: AppColors.crimsonLight, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            reservation.ownerContactPhone,
            style: const TextStyle(fontSize: 12, color: AppColors.silverText),
          ),
          const SizedBox(height: 4),
          Text(
            reservation.ownerAddressSummary,
            style: const TextStyle(fontSize: 11, color: AppColors.mutedGreyText),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTriadBox(
    BuildContext context,
    bool isDark, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget content,
  }) {
    return Container(
      padding: AppSpacing.compactCardPadding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.charcoalGrey : AppColors.lightInputBg,
        borderRadius: AppSpacing.radiusMd,
        border: Border.all(color: isDark ? AppColors.steelBorderGrey : AppColors.lightBorder, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.silverText : AppColors.lightTextSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, ReservationStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.15),
        borderRadius: AppSpacing.radiusSm,
        border: Border.all(color: status.color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 13, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }
}
