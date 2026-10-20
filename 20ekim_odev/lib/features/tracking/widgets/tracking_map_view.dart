import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../vehicles/domain/models/vehicle_type.dart';
import '../domain/models/tracking_telemetry.dart';

class TrackingMapView extends StatefulWidget {
  final TrackingTelemetry? telemetry;

  const TrackingMapView({super.key, required this.telemetry});

  @override
  State<TrackingMapView> createState() => _TrackingMapViewState();
}

class _TrackingMapViewState extends State<TrackingMapView>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.telemetry;

    return Container(
      width: double.infinity,
      height: 380,
      decoration: const BoxDecoration(
        color: AppColors.obsidianGrey,
      ),
      child: Stack(
        children: [
          // Custom Radar / Map Painter
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              return CustomPaint(
                size: Size.infinite,
                painter: _RadarMapPainter(
                  telemetry: t,
                  pulseValue: _pulseController.value,
                ),
              );
            },
          ),

          // Top Left Overlay: Live Telemetry HUD
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.charcoalGrey.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.steelBorderGrey, width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: (t?.isEngineRunning ?? false)
                          ? AppColors.statusEmerald
                          : AppColors.statusAmber,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t != null
                        ? '${t.trackingNumber} • ${Formatters.coordinates(t.latitude, t.longitude)}'
                        : 'Sinyal Aranıyor...',
                    style: AppTypography.telemetryCode(
                      color: AppColors.platinumText,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Top Right Overlay: Compass Heading
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.charcoalGrey.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.steelBorderGrey, width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.navigation, size: 13, color: AppColors.crimsonLight),
                  const SizedBox(width: 6),
                  Text(
                    'YÖN: ${t?.headingDegrees.toStringAsFixed(0) ?? '0'}°',
                    style: AppTypography.telemetryCode(
                      color: AppColors.crimsonLight,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Center Center-Target Badge
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.crimsonSurface.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.crimsonPrimary, width: 0.8),
              ),
              child: Text(
                'RADAR MENZİLİ: 25 KM (GERÇEK ZAMANLI TELEMETRİ)',
                style: AppTypography.telemetryCode(fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarMapPainter extends CustomPainter {
  final TrackingTelemetry? telemetry;
  final double pulseValue;

  _RadarMapPainter({required this.telemetry, required this.pulseValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) * 0.45;

    // Background Grid
    final gridPaint = Paint()
      ..color = AppColors.charcoalGrey.withValues(alpha: 0.6)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Concentric Range Rings
    final ringPaint = Paint()
      ..color = AppColors.steelBorderGrey.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 1; i <= 3; i++) {
      final r = maxRadius * (i / 3);
      canvas.drawCircle(center, r, ringPaint);
    }

    // Crosshairs
    final crossHairPaint = Paint()
      ..color = AppColors.steelBorderGrey.withValues(alpha: 0.4)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(center.dx - maxRadius, center.dy), Offset(center.dx + maxRadius, center.dy), crossHairPaint);
    canvas.drawLine(Offset(center.dx, center.dy - maxRadius), Offset(center.dx, center.dy + maxRadius), crossHairPaint);

    // Pulse Wave Animation
    final pulseRadius = maxRadius * pulseValue;
    final pulsePaint = Paint()
      ..color = AppColors.crimsonAccent.withValues(alpha: (1.0 - pulseValue) * 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, pulseRadius, pulsePaint);

    if (telemetry == null) return;

    // Draw route trail
    final route = telemetry!.routeHistory;
    if (route.isNotEmpty) {
      final trailPaint = Paint()
        ..color = AppColors.crimsonLight.withValues(alpha: 0.8)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;

      final path = Path();
      for (int i = 0; i < route.length; i++) {
        // Map relative deltas from latest point to center
        final pt = route[i];
        final dx = (pt.longitude - telemetry!.longitude) * 12000;
        final dy = -(pt.latitude - telemetry!.latitude) * 12000;
        final screenPos = Offset(center.dx + dx, center.dy + dy);

        if (i == 0) {
          path.moveTo(screenPos.dx, screenPos.dy);
        } else {
          path.lineTo(screenPos.dx, screenPos.dy);
        }
      }
      canvas.drawPath(path, trailPaint);
    }

    // Draw Vehicle Target Marker at center
    final targetGlowPaint = Paint()
      ..color = AppColors.crimsonPrimary.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 18, targetGlowPaint);

    final targetPaint = Paint()
      ..color = AppColors.crimsonLight
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 8, targetPaint);

    // Heading Arrow Vector
    final angleRad = (telemetry!.headingDegrees - 90) * (math.pi / 180);
    final arrowLength = 28.0;
    final arrowEnd = Offset(
      center.dx + math.cos(angleRad) * arrowLength,
      center.dy + math.sin(angleRad) * arrowLength,
    );

    final arrowPaint = Paint()
      ..color = AppColors.platinumText
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, arrowEnd, arrowPaint);

    // Vehicle Category Symbol Hint
    final iconSpan = TextSpan(
      text: telemetry!.vehicleType == VehicleCategory.air
          ? '✈'
          : telemetry!.vehicleType == VehicleCategory.sea
              ? '⚓'
              : '▲',
      style: const TextStyle(
        fontSize: 16,
        color: AppColors.platinumText,
        fontWeight: FontWeight.bold,
      ),
    );
    final textPainter = TextPainter(
      text: iconSpan,
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - (textPainter.width / 2), center.dy - 32),
    );
  }

  @override
  bool shouldRepaint(covariant _RadarMapPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue || oldDelegate.telemetry != telemetry;
  }
}
