import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../vehicles/domain/models/vehicle_type.dart';
import '../domain/models/tracking_telemetry.dart';

class TrackingController extends ChangeNotifier {
  static final TrackingController instance = TrackingController._();
  TrackingController._() {
    _startTelemetryGenerator();
  }

  final ValueNotifier<String?> selectedTrackingNumber = ValueNotifier<String?>('TRK-LAND-3401');
  final ValueNotifier<TrackingTelemetry?> currentTelemetry = ValueNotifier<TrackingTelemetry?>(null);
  final ValueNotifier<String?> accessError = ValueNotifier<String?>(null);

  final Map<String, TrackingTelemetry> _telemetryStore = {};
  Timer? _simulationTimer;
  final Random _rnd = Random();

  void _startTelemetryGenerator() {
    // Initial seeds
    _telemetryStore['TRK-LAND-3401'] = TrackingTelemetry(
      trackingNumber: 'TRK-LAND-3401',
      vehicleId: 'v_land_1',
      plateNumber: '34 VR 1923',
      vehicleType: VehicleCategory.land,
      latitude: 41.0082,
      longitude: 28.9784,
      speedKmh: 74,
      headingDegrees: 48,
      altitudeMeters: 45,
      isEngineRunning: true,
      lastUpdated: DateTime.now(),
      renterName: 'Selin Arslan',
      activeReservationId: 'res_101',
      routeHistory: [
        const GeoPoint(40.9920, 28.9500),
        const GeoPoint(40.9995, 28.9620),
        const GeoPoint(41.0040, 28.9710),
        const GeoPoint(41.0082, 28.9784),
      ],
    );

    _telemetryStore['TRK-HAVA-10492'] = TrackingTelemetry(
      trackingNumber: 'TRK-HAVA-10492',
      vehicleId: 'v_air_1',
      plateNumber: 'TC-SKY',
      vehicleType: VehicleCategory.air,
      latitude: 40.9769,
      longitude: 28.8146,
      speedKmh: 780,
      headingDegrees: 135,
      altitudeMeters: 9450,
      isEngineRunning: true,
      lastUpdated: DateTime.now(),
      renterName: 'Caner Aydın',
      activeReservationId: 'res_102',
      routeHistory: [
        const GeoPoint(41.1500, 28.6000),
        const GeoPoint(41.0800, 28.7200),
        const GeoPoint(40.9769, 28.8146),
      ],
    );

    _telemetryStore['TRK-DENIZ-55301'] = TrackingTelemetry(
      trackingNumber: 'TRK-DENIZ-55301',
      vehicleId: 'v_sea_1',
      plateNumber: 'BDR-DNZ-102',
      vehicleType: VehicleCategory.sea,
      latitude: 37.1067,
      longitude: 27.2917,
      speedKmh: 38, // ~20.5 knot
      headingDegrees: 220,
      altitudeMeters: 0,
      isEngineRunning: true,
      lastUpdated: DateTime.now(),
      renterName: null,
      routeHistory: [
        const GeoPoint(37.0850, 27.2500),
        const GeoPoint(37.0980, 27.2750),
        const GeoPoint(37.1067, 27.2917),
      ],
    );

    _telemetryStore['TRK-DENIZ-99014'] = TrackingTelemetry(
      trackingNumber: 'TRK-DENIZ-99014',
      vehicleId: 'v_sea_2',
      plateNumber: 'GCK-YAT-88',
      vehicleType: VehicleCategory.sea,
      latitude: 36.7533,
      longitude: 28.9417,
      speedKmh: 28, // ~15 knot
      headingDegrees: 180,
      altitudeMeters: 0,
      isEngineRunning: true,
      lastUpdated: DateTime.now(),
      renterName: 'Ali Koçak',
      routeHistory: [
        const GeoPoint(36.7200, 28.9100),
        const GeoPoint(36.7400, 28.9300),
        const GeoPoint(36.7533, 28.9417),
      ],
    );

    _telemetryStore['TRK-LAND-3502'] = TrackingTelemetry(
      trackingNumber: 'TRK-LAND-3502',
      vehicleId: 'v_land_2',
      plateNumber: '35 VIP 911',
      vehicleType: VehicleCategory.land,
      latitude: 38.4333,
      longitude: 27.1417,
      speedKmh: 92,
      headingDegrees: 90,
      altitudeMeters: 12,
      isEngineRunning: true,
      lastUpdated: DateTime.now(),
      routeHistory: [
        const GeoPoint(38.4100, 27.1000),
        const GeoPoint(38.4250, 27.1250),
        const GeoPoint(38.4333, 27.1417),
      ],
    );

    currentTelemetry.value = _telemetryStore[selectedTrackingNumber.value];

    // Every 2 seconds simulate incremental telemetry motion
    _simulationTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _updateSimulation();
    });
  }

  void _updateSimulation() {
    for (final key in _telemetryStore.keys) {
      final t = _telemetryStore[key]!;
      if (!t.isEngineRunning) continue;

      // Small jitter delta in coordinates
      final latDelta = (_rnd.nextDouble() - 0.48) * 0.0015;
      final lngDelta = (_rnd.nextDouble() - 0.48) * 0.0018;
      final newLat = t.latitude + latDelta;
      final newLng = t.longitude + lngDelta;

      // Small speed fluctuation
      double newSpeed = t.speedKmh + ((_rnd.nextDouble() - 0.5) * 4);
      if (t.vehicleType == VehicleCategory.air) {
        newSpeed = newSpeed.clamp(650.0, 850.0);
      } else if (t.vehicleType == VehicleCategory.sea) {
        newSpeed = newSpeed.clamp(12.0, 55.0);
      } else {
        newSpeed = newSpeed.clamp(30.0, 120.0);
      }

      final newHeading = (t.headingDegrees + ((_rnd.nextDouble() - 0.5) * 8)) % 360;

      final updatedHistory = List<GeoPoint>.from(t.routeHistory);
      if (updatedHistory.length > 25) {
        updatedHistory.removeAt(0);
      }
      updatedHistory.add(GeoPoint(newLat, newLng));

      _telemetryStore[key] = t.copyWith(
        latitude: newLat,
        longitude: newLng,
        speedKmh: newSpeed,
        headingDegrees: newHeading,
        lastUpdated: DateTime.now(),
        routeHistory: updatedHistory,
      );
    }

    // Refresh currently watched telemetry
    final activeKey = selectedTrackingNumber.value;
    if (activeKey != null && _telemetryStore.containsKey(activeKey)) {
      currentTelemetry.value = _telemetryStore[activeKey];
    }
  }

  void selectTrackingNumber(String trackingNumber, {String? ownerId, String? currentUserId}) {
    final clean = trackingNumber.toUpperCase().trim();
    selectedTrackingNumber.value = clean;
    accessError.value = null;

    if (_telemetryStore.containsKey(clean)) {
      currentTelemetry.value = _telemetryStore[clean];
    } else {
      // Auto-generate seed telemetry for any newly added vehicle
      final newTel = TrackingTelemetry(
        trackingNumber: clean,
        vehicleId: 'v_custom',
        plateNumber: clean,
        vehicleType: clean.contains('HAVA')
            ? VehicleCategory.air
            : clean.contains('DENIZ')
                ? VehicleCategory.sea
                : VehicleCategory.land,
        latitude: 41.0082,
        longitude: 28.9784,
        speedKmh: 45,
        headingDegrees: 90,
        isEngineRunning: true,
        lastUpdated: DateTime.now(),
        routeHistory: [const GeoPoint(41.0082, 28.9784)],
      );
      _telemetryStore[clean] = newTel;
      currentTelemetry.value = newTel;
    }
    notifyListeners();
  }

  void toggleEngine(String trackingNumber) {
    if (_telemetryStore.containsKey(trackingNumber)) {
      final t = _telemetryStore[trackingNumber]!;
      _telemetryStore[trackingNumber] = t.copyWith(
        isEngineRunning: !t.isEngineRunning,
        speedKmh: !t.isEngineRunning ? 35 : 0,
      );
      if (selectedTrackingNumber.value == trackingNumber) {
        currentTelemetry.value = _telemetryStore[trackingNumber];
      }
      notifyListeners();
    }
  }

  void stopSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
  }

  @override
  void dispose() {
    stopSimulation();
    selectedTrackingNumber.dispose();
    currentTelemetry.dispose();
    accessError.dispose();
    super.dispose();
  }
}
