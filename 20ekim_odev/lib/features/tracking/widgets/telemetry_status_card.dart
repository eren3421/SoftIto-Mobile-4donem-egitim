import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/slate_card.dart';
import '../controllers/tracking_controller.dart';
import '../domain/models/tracking_telemetry.dart';

class TelemetryStatusCard extends StatelessWidget {
  final TrackingTelemetry? telemetry;
  final TrackingController controller;
  final VoidCallback onOpenChat;

  const TelemetryStatusCard({
    super.key,
    required this.telemetry,
    required this.controller,
    required this.onOpenChat,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (telemetry == null) {
      return SlateCard(
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'Aktif telemetri sinyali bulunamadı.\nLütfen geçerli bir takip numarası girin.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.silverText),
            ),
          ),
        ),
      );
    }

    final t = telemetry!;

    return SlateCard(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.speed, color: AppColors.crimsonLight, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Kokpit Telemetri Durumu',
                    style: AppTypography.cardTitle(
                      color: isDark ? AppColors.platinumText : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  t.isEngineRunning ? Icons.power_settings_new : Icons.play_circle_outline,
                  color: t.isEngineRunning ? AppColors.statusEmerald : AppColors.mutedGreyText,
                ),
                tooltip: t.isEngineRunning ? 'Motoru Kapat' : 'Motoru Çalıştır (Simülasyon)',
                onPressed: () => controller.toggleEngine(t.trackingNumber),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),

          // 4-Quadrant Grid
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 550) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildQuad1(t, isDark)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _buildQuad2(t, isDark)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _buildQuad3(t, isDark)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _buildQuad4(t, isDark)),
                  ],
                );
              }
              // 2x2 grid for mobile/compact
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildQuad1(t, isDark)),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: _buildQuad2(t, isDark)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(child: _buildQuad3(t, isDark)),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: _buildQuad4(t, isDark)),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // 1. Takip No & Plaka
  Widget _buildQuad1(TrackingTelemetry t, bool isDark) {
    return _buildBlock(
      isDark,
      label: 'TAKİP NO & PLAKA',
      value: t.trackingNumber,
      subValue: t.plateNumber,
      icon: Icons.tag,
      isMonospace: true,
    );
  }

  // 2. Anlık Hız & Motor Durumu
  Widget _buildQuad2(TrackingTelemetry t, bool isDark) {
    return _buildBlock(
      isDark,
      label: 'ANLIK HIZ & DURUM',
      value: t.speedDisplay,
      subValue: t.statusDisplay,
      icon: Icons.electric_meter,
      statusColor: t.isEngineRunning ? AppColors.statusEmerald : AppColors.statusRed,
    );
  }

  // 3. Konum & İrtifa
  Widget _buildQuad3(TrackingTelemetry t, bool isDark) {
    return _buildBlock(
      isDark,
      label: 'KOORDİNAT & İRTİFA',
      value: Formatters.coordinates(t.latitude, t.longitude),
      subValue: 'İrtifa: ${t.altitudeDisplay}',
      icon: Icons.map,
      isMonospace: true,
    );
  }

  // 4. Aktif Kiralama Durumu
  Widget _buildQuad4(TrackingTelemetry t, bool isDark) {
    final isRented = t.activeReservationId != null;

    return Container(
      padding: AppSpacing.compactCardPadding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.gunmetalGrey : AppColors.lightInputBg,
        borderRadius: AppSpacing.radiusMd,
        border: Border.all(
          color: isRented ? AppColors.crimsonAccent : (isDark ? AppColors.steelBorderGrey : AppColors.lightBorder),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'KİRALAMA DURUMU',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.silverText : AppColors.lightTextSecondary,
                ),
              ),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isRented ? AppColors.crimsonLight : AppColors.statusEmerald,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isRented ? 'Kirada: ${t.renterName ?? 'Sivil Kullanıcı'}' : 'Envanterde Bekliyor',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          if (isRented)
            InkWell(
              onTap: onOpenChat,
              child: const Text(
                'Kiralayana Mesaj Gönder →',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.crimsonLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            const Text(
              'Rezervasyona Müsait',
              style: TextStyle(fontSize: 11, color: AppColors.statusEmerald),
            ),
        ],
      ),
    );
  }

  Widget _buildBlock(
    bool isDark, {
    required String label,
    required String value,
    required String subValue,
    required IconData icon,
    Color? statusColor,
    bool isMonospace = false,
  }) {
    return Container(
      padding: AppSpacing.compactCardPadding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.gunmetalGrey : AppColors.lightInputBg,
        borderRadius: AppSpacing.radiusMd,
        border: Border.all(color: isDark ? AppColors.steelBorderGrey : AppColors.lightBorder, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.silverText : AppColors.lightTextSecondary,
                ),
              ),
              Icon(icon, size: 12, color: statusColor ?? AppColors.silverText),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: isMonospace
                ? AppTypography.telemetryCode(
                    fontSize: 12,
                    color: isDark ? AppColors.platinumText : AppColors.lightTextPrimary,
                  )
                : const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subValue,
            style: TextStyle(
              fontSize: 11,
              color: statusColor ?? (isDark ? AppColors.silverText : AppColors.lightTextSecondary),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
