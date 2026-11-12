import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/ride_entity.dart';

/// `flutter_map` (OpenStreetMap) tabanlı, kalkış/ara durak/varış işaretçilerini (Marker)
/// ve güzergah çizgisini (Polyline) gösteren, koordinatlar değiştiğinde kamerayı
/// otomatik olarak gerçek rotaya odaklayan (`CameraFit.bounds`) harita bileşeni.
class RouteMapWidget extends StatefulWidget {
  final RideLocationPoint origin;
  final RideLocationPoint destination;
  final List<RideLocationPoint> waypoints;
  final double height;
  final void Function(LatLng point)? onMapTap;
  final String? interactiveHint;

  const RouteMapWidget({
    super.key,
    required this.origin,
    required this.destination,
    this.waypoints = const [],
    this.height = 230,
    this.onMapTap,
    this.interactiveHint,
  });

  @override
  State<RouteMapWidget> createState() => _RouteMapWidgetState();
}

class _RouteMapWidgetState extends State<RouteMapWidget> {
  final MapController _mapController = MapController();
  bool _isMapReady = false;

  List<LatLng> get _routePoints => <LatLng>[
        LatLng(widget.origin.lat, widget.origin.lng),
        ...widget.waypoints.map((w) => LatLng(w.lat, w.lng)),
        LatLng(widget.destination.lat, widget.destination.lng),
      ];

  @override
  void didUpdateWidget(covariant RouteMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final originChanged = oldWidget.origin.lat != widget.origin.lat ||
        oldWidget.origin.lng != widget.origin.lng;
    final destChanged = oldWidget.destination.lat != widget.destination.lat ||
        oldWidget.destination.lng != widget.destination.lng;
    final waypointsChanged =
        oldWidget.waypoints.length != widget.waypoints.length ||
            _hasWaypointCoordChange(oldWidget.waypoints, widget.waypoints);

    if (_isMapReady && (originChanged || destChanged || waypointsChanged)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fitRouteBounds();
      });
    }
  }

  bool _hasWaypointCoordChange(
    List<RideLocationPoint> oldList,
    List<RideLocationPoint> newList,
  ) {
    for (int i = 0; i < oldList.length; i++) {
      if (oldList[i].lat != newList[i].lat ||
          oldList[i].lng != newList[i].lng) {
        return true;
      }
    }
    return false;
  }

  void _fitRouteBounds() {
    if (!_isMapReady) return;
    final points = _routePoints;
    if (points.isEmpty) return;

    final allSame = points.every(
      (p) =>
          (p.latitude - points.first.latitude).abs() < 0.0005 &&
          (p.longitude - points.first.longitude).abs() < 0.0005,
    );

    try {
      if (allSame) {
        _mapController.move(points.first, 13.5);
      } else {
        final bounds = LatLngBounds.fromPoints(points);
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 44),
            maxZoom: 14.2,
          ),
        );
      }
    } catch (_) {}
  }

  void _zoomIn() {
    if (!_isMapReady) return;
    final currentZoom = _mapController.camera.zoom;
    final targetZoom = (currentZoom + 1.0).clamp(3.0, 18.5);
    _mapController.move(_mapController.camera.center, targetZoom);
  }

  void _zoomOut() {
    if (!_isMapReady) return;
    final currentZoom = _mapController.camera.zoom;
    final targetZoom = (currentZoom - 1.0).clamp(3.0, 18.5);
    _mapController.move(_mapController.camera.center, targetZoom);
  }

  @override
  Widget build(BuildContext context) {
    final originLatLng = LatLng(widget.origin.lat, widget.origin.lng);
    final destLatLng = LatLng(widget.destination.lat, widget.destination.lng);
    final routePoints = _routePoints;

    final centerLat = (widget.origin.lat + widget.destination.lat) / 2;
    final centerLng = (widget.origin.lng + widget.destination.lng) / 2;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(centerLat, centerLng),
                initialZoom: 10.8,
                onMapReady: () {
                  _isMapReady = true;
                  _fitRouteBounds();
                },
                onTap: widget.onMapTap != null
                    ? (_, latLng) => widget.onMapTap!(latLng)
                    : null,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.bitirme.paylasimli_yolculuk',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 4.5,
                      color: AppColors.primary,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    // Kalkış Noktası İşaretçisi
                    Marker(
                      point: originLatLng,
                      width: 135,
                      height: 62,
                      child: _MapPin(
                        label: widget.origin.name,
                        color: AppColors.primary,
                        icon: Icons.trip_origin_rounded,
                      ),
                    ),
                    // Ara Durak İşaretçileri
                    ...widget.waypoints.map(
                      (wp) => Marker(
                        point: LatLng(wp.lat, wp.lng),
                        width: 120,
                        height: 56,
                        child: _MapPin(
                          label: wp.name,
                          color: AppColors.accent,
                          icon: Icons.commit_rounded,
                        ),
                      ),
                    ),
                    // Varış Noktası İşaretçisi
                    Marker(
                      point: destLatLng,
                      width: 135,
                      height: 62,
                      child: _MapPin(
                        label: widget.destination.name,
                        color: AppColors.error,
                        icon: Icons.location_on_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (widget.interactiveHint != null)
              Positioned(
                left: 10,
                top: 10,
                right: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.touch_app_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.interactiveHint!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
              left: 10,
              bottom: 10,
              child: Material(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: _fitRouteBounds,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.fit_screen_rounded,
                          size: 15,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Rotaya Odakla',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Sağ Taraf Zoom In (+) ve Zoom Out (-) Kontrol Butonları
            Positioned(
              right: 10,
              bottom: 44,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Yakınlaştır (Zoom In +)',
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.add_rounded,
                        color: Colors.black87,
                        size: 20,
                      ),
                      onPressed: _zoomIn,
                    ),
                    Container(
                      width: 24,
                      height: 1,
                      color: Colors.black12,
                    ),
                    IconButton(
                      tooltip: 'Uzaklaştır (Zoom Out -)',
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.remove_rounded,
                        color: Colors.black87,
                        size: 20,
                      ),
                      onPressed: _zoomOut,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'OpenStreetMap • Gerçek Konum',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _MapPin({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 4),
            ],
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Icon(icon, color: color, size: 26),
      ],
    );
  }
}
