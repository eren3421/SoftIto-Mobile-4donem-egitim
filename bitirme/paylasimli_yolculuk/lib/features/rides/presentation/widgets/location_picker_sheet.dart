import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/storage/seed_data_service.dart';
import '../../../../core/utils/geocoding_service.dart';
import '../../domain/entities/ride_entity.dart';

/// Kullanıcının hem harita üzerinde istediği herhangi bir noktaya dokunarak (`FlutterMap`)
/// hem de klavyeden serbestçe konum adı / adres yazarak gerçek OpenStreetMap (Nominatim)
/// koordinatlarıyla kalkış, varış veya ara durak seçebilmesini sağlayan bileşen.
class LocationPickerSheet extends StatefulWidget {
  final String title;
  final RideLocationPoint? initialLocation;
  final Color markerColor;
  final IconData markerIcon;

  const LocationPickerSheet({
    super.key,
    required this.title,
    this.initialLocation,
    this.markerColor = AppColors.primary,
    this.markerIcon = Icons.location_on_rounded,
  });

  static Future<RideLocationPoint?> show(
    BuildContext context, {
    required String title,
    RideLocationPoint? initialLocation,
    Color markerColor = AppColors.primary,
    IconData markerIcon = Icons.location_on_rounded,
  }) {
    return showModalBottomSheet<RideLocationPoint>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => LocationPickerSheet(
        title: title,
        initialLocation: initialLocation,
        markerColor: markerColor,
        markerIcon: markerIcon,
      ),
    );
  }

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  final MapController _mapController = MapController();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;

  late double _selectedLat;
  late double _selectedLng;
  bool _isLoadingGps = false;
  bool _isSearchingOsm = false;
  Timer? _debounceTimer;
  List<RideLocationPoint> _liveSuggestions = [];

  @override
  void initState() {
    super.initState();
    final initLoc = widget.initialLocation ??
        const RideLocationPoint(
          name: 'Kadıköy Rıhtım',
          address: 'Caferağa, Kadıköy/İstanbul',
          lat: 40.9901,
          lng: 29.0234,
        );
    _selectedLat = initLoc.lat;
    _selectedLng = initLoc.lng;
    _nameController = TextEditingController(text: initLoc.name);
    _addressController = TextEditingController(text: initLoc.address);
    _liveSuggestions = TurkeyLocations.popularPoints.take(8).toList();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  /// Harita üzerinde herhangi bir noktaya dokunulduğunda gerçek Reverse Geocoding yapar.
  Future<void> _onMapTapped(LatLng latLng) async {
    final quickLocal = TurkeyLocations.fromCoordinates(
      latLng.latitude,
      latLng.longitude,
    );

    setState(() {
      _selectedLat = latLng.latitude;
      _selectedLng = latLng.longitude;
      _nameController.text = quickLocal.name;
      _addressController.text = quickLocal.address;
      _isSearchingOsm = true;
    });

    final realPlace = await GeocodingService.reverseGeocode(
      latLng.latitude,
      latLng.longitude,
    );
    if (mounted) {
      setState(() {
        _isSearchingOsm = false;
        _nameController.text = realPlace.name;
        _addressController.text = realPlace.address;
      });
    }
  }

  /// Kullanıcı klavyeden konum adı yazdığında hem yerel hem de canlı OpenStreetMap araması yapar.
  void _onNameTyped(String value) {
    _debounceTimer?.cancel();
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _isSearchingOsm = false;
        _liveSuggestions = TurkeyLocations.popularPoints.take(8).toList();
      });
      return;
    }

    // 1. Anlık yerel gerçek koordinat eşleşmesi varsa hemen haritayı oraya taşı
    final localMatches = GeocodingService.searchLocalRealPlaces(trimmed);
    if (localMatches.isNotEmpty) {
      final first = localMatches.first;
      setState(() {
        _selectedLat = first.lat;
        _selectedLng = first.lng;
        _addressController.text = first.address;
        _liveSuggestions = localMatches.take(8).toList();
      });
      _mapController.move(LatLng(_selectedLat, _selectedLng), 13.5);
    } else {
      setState(() {});
    }

    // 2. Canlı OpenStreetMap Nominatim araması (350 ms debounce)
    _debounceTimer = Timer(const Duration(milliseconds: 350), () async {
      if (!mounted) return;
      setState(() => _isSearchingOsm = true);
      final results = await GeocodingService.searchPlaces(trimmed);
      if (!mounted) return;
      setState(() {
        _isSearchingOsm = false;
        if (results.isNotEmpty) {
          _liveSuggestions = results.take(8).toList();
          final best = results.first;
          _selectedLat = best.lat;
          _selectedLng = best.lng;
          _addressController.text = best.address;
        }
      });
      if (results.isNotEmpty) {
        _mapController.move(LatLng(_selectedLat, _selectedLng), 13.8);
      }
    });
  }

  /// Cihazın gerçek GPS konumunu alır ve haritayı oraya taşır.
  Future<void> _useCurrentGpsLocation() async {
    setState(() => _isLoadingGps = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          final pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 5),
            ),
          );
          final realPlace = await GeocodingService.reverseGeocode(
            pos.latitude,
            pos.longitude,
          );
          if (mounted) {
            setState(() {
              _selectedLat = pos.latitude;
              _selectedLng = pos.longitude;
              _nameController.text = realPlace.name;
              _addressController.text = realPlace.address;
            });
            _mapController.move(LatLng(_selectedLat, _selectedLng), 14.5);
          }
          return;
        }
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _isLoadingGps = false);
      }
    }
  }

  void _zoomIn() {
    try {
      final currentZoom = _mapController.camera.zoom;
      final targetZoom = (currentZoom + 1.0).clamp(3.0, 18.5);
      _mapController.move(_mapController.camera.center, targetZoom);
    } catch (_) {}
  }

  void _zoomOut() {
    try {
      final currentZoom = _mapController.camera.zoom;
      final targetZoom = (currentZoom - 1.0).clamp(3.0, 18.5);
      _mapController.move(_mapController.camera.center, targetZoom);
    } catch (_) {}
  }

  void _confirmSelection() {
    final nameText = _nameController.text.trim();
    final addressText = _addressController.text.trim();

    final result = RideLocationPoint(
      name: nameText.isEmpty
          ? 'Konum (${_selectedLat.toStringAsFixed(4)}, ${_selectedLng.toStringAsFixed(4)})'
          : nameText,
      address: addressText.isEmpty
          ? '${_selectedLat.toStringAsFixed(4)}, ${_selectedLng.toStringAsFixed(4)}'
          : addressText,
      lat: _selectedLat,
      lng: _selectedLng,
      geohash: 'osm',
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.90,
      minChildSize: 0.65,
      maxChildSize: 0.96,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              // Üst Başlık Çubuğu
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
                child: Row(
                  children: [
                    Icon(widget.markerIcon, color: widget.markerColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Klavyeden arayın (Gerçek OpenStreetMap) veya haritaya dokunun',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (_isSearchingOsm)
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // 1. Klavyeden Gerçek Konum Arama & Giriş
                    TextField(
                      controller: _nameController,
                      onChanged: _onNameTyped,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        labelText:
                            'Konum Ara / Yaz (Örn: Esenboğa, Ankara YHT, Kadıköy...)',
                        hintText:
                            'Sokak, ilçe, havalimanı, gar veya bina adı yazın...',
                        prefixIcon: Icon(
                          widget.markerIcon,
                          color: widget.markerColor,
                        ),
                        suffixIcon: _nameController.text.isNotEmpty
                            ? IconButton(
                                tooltip: 'Temizle',
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _nameController.clear();
                                  _onNameTyped('');
                                },
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 2. Gerçek Adres Bilgisi
                    TextField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Gerçek Adres & Koordinat Bilgisi',
                        helperText:
                            'Gerçek GPS Koordinatı: ${_selectedLat.toStringAsFixed(5)}, ${_selectedLng.toStringAsFixed(5)}',
                        prefixIcon: const Icon(Icons.place_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 3. Canlı OpenStreetMap & Türkiye Sonuç Önerileri
                    if (_liveSuggestions.isNotEmpty) ...[
                      Text(
                        'Bulunan Gerçek Konumlar (Seçmek için dokunun):',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 6),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _liveSuggestions.map((loc) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ActionChip(
                                visualDensity: VisualDensity.compact,
                                avatar: Icon(
                                  Icons.location_on_outlined,
                                  size: 14,
                                  color: widget.markerColor,
                                ),
                                label: Text(
                                  loc.name,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _selectedLat = loc.lat;
                                    _selectedLng = loc.lng;
                                    _nameController.text = loc.name;
                                    _addressController.text = loc.address;
                                  });
                                  _mapController.move(
                                    LatLng(loc.lat, loc.lng),
                                    14.0,
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],

                    // 4. İnteraktif Harita
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: 300,
                        child: Stack(
                          children: [
                            FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                initialCenter:
                                    LatLng(_selectedLat, _selectedLng),
                                initialZoom: 13.0,
                                onTap: (_, latLng) => _onMapTapped(latLng),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName:
                                      'com.bitirme.paylasimli_yolculuk',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point:
                                          LatLng(_selectedLat, _selectedLng),
                                      width: 170,
                                      height: 75,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: widget.markerColor,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              _nameController.text
                                                      .trim()
                                                      .isEmpty
                                                  ? 'Seçilen Nokta'
                                                  : _nameController.text.trim(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Icon(
                                            widget.markerIcon,
                                            color: widget.markerColor,
                                            size: 36,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Positioned(
                              top: 10,
                              left: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.72),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.touch_app_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Haritada dokunduğunuz noktanın gerçek adresi bulunur (${_selectedLat.toStringAsFixed(4)}, ${_selectedLng.toStringAsFixed(4)})',
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
                            // Sağ Taraf Zoom In (+) ve Zoom Out (-) Butonları
                            Positioned(
                              right: 10,
                              bottom: 62,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.95),
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
                                        minWidth: 38,
                                        minHeight: 38,
                                      ),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.add_rounded,
                                        color: Colors.black87,
                                        size: 22,
                                      ),
                                      onPressed: _zoomIn,
                                    ),
                                    Container(
                                      width: 26,
                                      height: 1,
                                      color: Colors.black12,
                                    ),
                                    IconButton(
                                      tooltip: 'Uzaklaştır (Zoom Out -)',
                                      visualDensity: VisualDensity.compact,
                                      constraints: const BoxConstraints(
                                        minWidth: 38,
                                        minHeight: 38,
                                      ),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.remove_rounded,
                                        color: Colors.black87,
                                        size: 22,
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
                              child: FloatingActionButton.small(
                                heroTag: 'gps_btn_${widget.title}',
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primary,
                                tooltip: 'Mevcut GPS Konumumu Kullan',
                                onPressed: _isLoadingGps
                                    ? null
                                    : _useCurrentGpsLocation,
                                child: _isLoadingGps
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.my_location_rounded),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Alt Onay Butonu
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _confirmSelection,
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: Text(
                      'Konumu Onayla: ${_nameController.text.trim().isEmpty ? "Seçilen Nokta" : _nameController.text.trim()}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
