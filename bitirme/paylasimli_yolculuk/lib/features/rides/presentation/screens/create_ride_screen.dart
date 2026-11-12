import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/storage/seed_data_service.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/geocoding_service.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/data/models/vehicle_model.dart';
import '../../../profile/domain/entities/vehicle_entity.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../domain/entities/ride_entity.dart';
import '../providers/ride_provider.dart';
import '../widgets/location_picker_sheet.dart';
import '../widgets/route_map_widget.dart';

/// Faz 3: Sürücülerin adım adım (Kalkış -> Varış -> Tarih/Saat -> Koltuk & Ücret)
/// ilan açabildiği Yolculuk Oluşturma Ekranı.
/// Klavyeden girilen her konum gerçek zamanlı olarak OpenStreetMap (Nominatim) ve
/// Türkiye gerçek koordinat veritabanı üzerinden çözümlenir ve harita kamerası
/// otomatik olarak gerçek koordinatlara odaklanır.
class CreateRideScreen extends ConsumerStatefulWidget {
  const CreateRideScreen({super.key});

  @override
  ConsumerState<CreateRideScreen> createState() => _CreateRideScreenState();
}

enum _MapPinTarget { origin, waypoint, destination }

class _CreateRideScreenState extends ConsumerState<CreateRideScreen> {
  int _currentStep = 0;

  RideLocationPoint _selectedOrigin = TurkeyLocations.popularPoints[0];
  RideLocationPoint _selectedDestination = TurkeyLocations.popularPoints[1];
  RideLocationPoint? _selectedWaypoint;

  late final TextEditingController _originController;
  late final TextEditingController _waypointController;
  late final TextEditingController _destinationController;

  _MapPinTarget _activeMapTarget = _MapPinTarget.origin;
  Timer? _originDebounce;
  Timer? _waypointDebounce;
  Timer? _destDebounce;
  bool _isGeocoding = false;
  List<RideLocationPoint> _activeSuggestions = [];

  DateTime _departureDate = DateTime.now().add(const Duration(hours: 4));
  TimeOfDay _departureTime = const TimeOfDay(hour: 9, minute: 0);

  int _totalSeats = 3;
  final _priceController = TextEditingController(text: '85');
  String? _selectedVehicleId;
  bool _instantApproval = false;
  String _luggageSize = 'medium';
  bool _smokingAllowed = false;
  bool _petsAllowed = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _originController = TextEditingController(text: _selectedOrigin.name);
    _waypointController = TextEditingController();
    _destinationController =
        TextEditingController(text: _selectedDestination.name);
  }

  @override
  void dispose() {
    _originDebounce?.cancel();
    _waypointDebounce?.cancel();
    _destDebounce?.cancel();
    _originController.dispose();
    _waypointController.dispose();
    _destinationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  /// Klavyeden Kalkış Noktası yazıldığında anlık yerel + canlı OpenStreetMap Nominatim çözümlemesi yapar.
  void _onOriginTextChanged(String text) {
    _originDebounce?.cancel();
    final trimmed = text.trim();
    setState(() {
      _activeMapTarget = _MapPinTarget.origin;
      if (trimmed.isNotEmpty) {
        final localMatches = GeocodingService.searchLocalRealPlaces(trimmed);
        if (localMatches.isNotEmpty) {
          final best = localMatches.first;
          _selectedOrigin = best.copyWith(name: trimmed);
          _activeSuggestions = localMatches.take(6).toList();
        }
      } else {
        _activeSuggestions = [];
      }
    });

    if (trimmed.length < 2) return;

    _originDebounce = Timer(const Duration(milliseconds: 350), () async {
      if (!mounted) return;
      setState(() => _isGeocoding = true);
      final results = await GeocodingService.searchPlaces(trimmed);
      if (!mounted) return;
      setState(() {
        _isGeocoding = false;
        if (results.isNotEmpty) {
          final best = results.first;
          _selectedOrigin = RideLocationPoint(
            name: trimmed,
            address: best.address,
            lat: best.lat,
            lng: best.lng,
            geohash: best.geohash,
          );
          _activeSuggestions = results.take(6).toList();
        }
      });
    });
  }

  /// Klavyeden Ara Durak yazıldığında anlık yerel + canlı OpenStreetMap Nominatim çözümlemesi yapar.
  void _onWaypointTextChanged(String text) {
    _waypointDebounce?.cancel();
    final trimmed = text.trim();
    setState(() {
      _activeMapTarget = _MapPinTarget.waypoint;
      if (trimmed.isEmpty) {
        _selectedWaypoint = null;
        _activeSuggestions = [];
      } else {
        final localMatches = GeocodingService.searchLocalRealPlaces(trimmed);
        if (localMatches.isNotEmpty) {
          final best = localMatches.first;
          _selectedWaypoint = best.copyWith(name: trimmed);
          _activeSuggestions = localMatches.take(6).toList();
        }
      }
    });

    if (trimmed.length < 2) return;

    _waypointDebounce = Timer(const Duration(milliseconds: 350), () async {
      if (!mounted) return;
      setState(() => _isGeocoding = true);
      final results = await GeocodingService.searchPlaces(trimmed);
      if (!mounted) return;
      setState(() {
        _isGeocoding = false;
        if (results.isNotEmpty && _waypointController.text.trim().isNotEmpty) {
          final best = results.first;
          _selectedWaypoint = RideLocationPoint(
            name: _waypointController.text.trim(),
            address: best.address,
            lat: best.lat,
            lng: best.lng,
            geohash: best.geohash,
          );
          _activeSuggestions = results.take(6).toList();
        }
      });
    });
  }

  /// Klavyeden Varış Noktası yazıldığında anlık yerel + canlı OpenStreetMap Nominatim çözümlemesi yapar.
  void _onDestinationTextChanged(String text) {
    _destDebounce?.cancel();
    final trimmed = text.trim();
    setState(() {
      _activeMapTarget = _MapPinTarget.destination;
      if (trimmed.isNotEmpty) {
        final localMatches = GeocodingService.searchLocalRealPlaces(trimmed);
        if (localMatches.isNotEmpty) {
          final best = localMatches.first;
          _selectedDestination = best.copyWith(name: trimmed);
          _activeSuggestions = localMatches.take(6).toList();
        }
      } else {
        _activeSuggestions = [];
      }
    });

    if (trimmed.length < 2) return;

    _destDebounce = Timer(const Duration(milliseconds: 350), () async {
      if (!mounted) return;
      setState(() => _isGeocoding = true);
      final results = await GeocodingService.searchPlaces(trimmed);
      if (!mounted) return;
      setState(() {
        _isGeocoding = false;
        if (results.isNotEmpty) {
          final best = results.first;
          _selectedDestination = RideLocationPoint(
            name: trimmed,
            address: best.address,
            lat: best.lat,
            lng: best.lng,
            geohash: best.geohash,
          );
          _activeSuggestions = results.take(6).toList();
        }
      });
    });
  }

  /// Öneri listesinden bir gerçek konum seçildiğinde ilgili hedefe uygular.
  void _applySuggestion(RideLocationPoint loc) {
    setState(() {
      switch (_activeMapTarget) {
        case _MapPinTarget.origin:
          _selectedOrigin = loc;
          _originController.text = loc.name;
          break;
        case _MapPinTarget.waypoint:
          _selectedWaypoint = loc;
          _waypointController.text = loc.name;
          break;
        case _MapPinTarget.destination:
          _selectedDestination = loc;
          _destinationController.text = loc.name;
          break;
      }
      _activeSuggestions = [];
    });
  }

  /// Adım 1'deki önizleme haritasına doğrudan dokunulduğunda gerçek Reverse Geocoding ile konumu günceller.
  Future<void> _onInlineMapTapped(LatLng latLng) async {
    final quickPicked = TurkeyLocations.fromCoordinates(
      latLng.latitude,
      latLng.longitude,
    );
    setState(() {
      _isGeocoding = true;
      switch (_activeMapTarget) {
        case _MapPinTarget.origin:
          _selectedOrigin = quickPicked;
          _originController.text = quickPicked.name;
          break;
        case _MapPinTarget.waypoint:
          _selectedWaypoint = quickPicked;
          _waypointController.text = quickPicked.name;
          break;
        case _MapPinTarget.destination:
          _selectedDestination = quickPicked;
          _destinationController.text = quickPicked.name;
          break;
      }
    });

    final realPlace = await GeocodingService.reverseGeocode(
      latLng.latitude,
      latLng.longitude,
    );
    if (!mounted) return;
    setState(() {
      _isGeocoding = false;
      switch (_activeMapTarget) {
        case _MapPinTarget.origin:
          _selectedOrigin = realPlace;
          _originController.text = realPlace.name;
          break;
        case _MapPinTarget.waypoint:
          _selectedWaypoint = realPlace;
          _waypointController.text = realPlace.name;
          break;
        case _MapPinTarget.destination:
          _selectedDestination = realPlace;
          _destinationController.text = realPlace.name;
          break;
      }
    });
  }

  /// Tam ekran Harita Konum Seçici modalını açar.
  Future<void> _openMapPickerFor(_MapPinTarget target) async {
    setState(() => _activeMapTarget = target);

    final String title;
    final RideLocationPoint? initial;
    final Color color;
    final IconData icon;

    switch (target) {
      case _MapPinTarget.origin:
        title = 'Kalkış Noktasını Seçin';
        initial = _selectedOrigin;
        color = AppColors.primary;
        icon = Icons.trip_origin_rounded;
        break;
      case _MapPinTarget.waypoint:
        title = 'Ara Durak Noktasını Seçin';
        initial = _selectedWaypoint ?? _selectedOrigin;
        color = AppColors.accent;
        icon = Icons.commit_rounded;
        break;
      case _MapPinTarget.destination:
        title = 'Varış Noktasını Seçin';
        initial = _selectedDestination;
        color = AppColors.error;
        icon = Icons.location_on_rounded;
        break;
    }

    final result = await LocationPickerSheet.show(
      context,
      title: title,
      initialLocation: initial,
      markerColor: color,
      markerIcon: icon,
    );

    if (result != null && mounted) {
      setState(() {
        switch (target) {
          case _MapPinTarget.origin:
            _selectedOrigin = result;
            _originController.text = result.name;
            break;
          case _MapPinTarget.waypoint:
            _selectedWaypoint = result;
            _waypointController.text = result.name;
            break;
          case _MapPinTarget.destination:
            _selectedDestination = result;
            _destinationController.text = result.name;
            break;
        }
        _activeSuggestions = [];
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _departureDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _departureDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _departureTime,
    );
    if (picked != null) {
      setState(() => _departureTime = picked);
    }
  }

  Future<void> _submitRide() async {
    try {
      final authState = ref.read(authNotifierProvider);
      var user = authState.valueOrNull;
      if (user == null) {
        final cached = ref.read(localCacheServiceProvider).getUserSession();
        if (cached != null) {
          user = UserModel.fromJson(cached);
        }
      }
      if (user == null) {
        final currentRes = await ref.read(getCurrentUserUseCaseProvider)();
        user = currentRes.fold((_) => null, (u) => u);
      }

      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.error,
            content: Text('Lütfen önce oturum açın.'),
          ),
        );
        return;
      }

      final originText = _originController.text.trim();
      final destText = _destinationController.text.trim();
      final originName =
          originText.isNotEmpty ? originText : _selectedOrigin.name;
      final destName =
          destText.isNotEmpty ? destText : _selectedDestination.name;

      if (originName.isEmpty || destName.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.error,
            content: Text(
              'Lütfen kalkış ve varış noktalarını girin veya haritadan seçin.',
            ),
          ),
        );
        setState(() => _currentStep = 0);
        return;
      }

      List<VehicleEntity> vehicles =
          ref.read(userVehiclesProvider).valueOrNull ?? [];
      if (vehicles.isEmpty) {
        final repo = ref.read(profileRepositoryProvider);
        final res = await repo.getUserVehicles(user.id);
        vehicles = res.fold((_) => [], (vList) => vList);
      }
      if (vehicles.isEmpty) {
        final cachedVehicles =
            ref.read(localCacheServiceProvider).getCachedVehicles();
        if (cachedVehicles.isNotEmpty) {
          vehicles = cachedVehicles.map<VehicleEntity>(VehicleModel.fromJson).toList();
        }
      }

      VehicleEntity? chosenVehicle;
      if (vehicles.isNotEmpty) {
        for (final v in vehicles) {
          if (v.id == _selectedVehicleId) {
            chosenVehicle = v;
            break;
          }
        }
        chosenVehicle ??= vehicles.first;
      }

      final vehicleSummary = chosenVehicle != null
          ? VehicleSummary(
              brandModel: '${chosenVehicle.brand} ${chosenVehicle.model}'.trim(),
              color: chosenVehicle.color,
              licensePlate: chosenVehicle.licensePlate,
            )
          : const VehicleSummary(
              brandModel: 'Kişisel Araç',
              color: 'Beyaz',
              licensePlate: '34 ABC 123',
            );

      final vehicleId =
          chosenVehicle?.id ?? 'veh_${DateTime.now().millisecondsSinceEpoch}';

      final departureDateTime = DateTime(
        _departureDate.year,
        _departureDate.month,
        _departureDate.day,
        _departureTime.hour,
        _departureTime.minute,
      );

      final price = double.tryParse(
            _priceController.text.trim().replaceAll(',', '.'),
          ) ??
          75.0;

      final origin = _selectedOrigin.copyWith(name: originName);
      final destination = _selectedDestination.copyWith(name: destName);

      setState(() => _isSubmitting = true);

      final newRide = RideEntity(
        id: '',
        driverId: user.id,
        driverSummary: DriverSummary(
          fullName: user.fullName,
          avatarUrl: user.avatarUrl,
          ratingAvg: user.ratingAvg,
        ),
        vehicleId: vehicleId,
        vehicleSummary: vehicleSummary,
        origin: origin,
        destination: destination,
        waypoints: _selectedWaypoint != null ? [_selectedWaypoint!] : [],
        routePolyline: 'custom_route_polyline',
        departureTime: departureDateTime,
        estimatedArrivalTime:
            departureDateTime.add(const Duration(minutes: 50)),
        totalSeatsOffered: _totalSeats,
        availableSeats: _totalSeats,
        pricePerSeat: price,
        currency: 'TRY',
        status: 'planned',
        rules: RideRules(
          instantApproval: _instantApproval,
          luggageSize: _luggageSize,
          smokingAllowed: _smokingAllowed,
          petsAllowed: _petsAllowed,
        ),
        createdAt: DateTime.now(),
      );

      final ok =
          await ref.read(ridesNotifierProvider.notifier).createRide(newRide);

      if (mounted) {
        setState(() => _isSubmitting = false);
        if (ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.success,
              content: Text('Yolculuk ilanınız başarıyla yayınlandı!'),
            ),
          );
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.error,
              content: Text(
                'İlan yayınlanırken bir sorun oluştu. Lütfen tekrar deneyin.',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text('Hata oluştu: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicles = ref.watch(userVehiclesProvider).valueOrNull ?? [];
    final targetLabel = switch (_activeMapTarget) {
      _MapPinTarget.origin => 'Kalkış Noktası',
      _MapPinTarget.waypoint => 'Ara Durak',
      _MapPinTarget.destination => 'Varış Noktası',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Yolculuk İlanı Oluştur'),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepTapped: (step) => setState(() => _currentStep = step),
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() => _currentStep += 1);
          } else {
            _submitRide();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          } else {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          if (_currentStep == 2) {
                            _submitRide();
                          } else {
                            details.onStepContinue?.call();
                          }
                        },
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _currentStep == 2 ? 'İlanı Yayınla' : 'Devam Et',
                        ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: _isSubmitting ? null : details.onStepCancel,
                  child: Text(_currentStep == 0 ? 'Vazgeç' : 'Geri'),
                ),
              ],
            ),
          );
        },
        steps: [
          // Adım 1: Kalkış -> Varış -> Gerçek Zamanlı Geocoding ve Harita Seçimi
          Step(
            title: const Text('1. Güzergah ve Harita Seçimi'),
            subtitle: Text(
              '${_selectedOrigin.name} → ${_selectedDestination.name}',
            ),
            isActive: _currentStep >= 0,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Kalkış Noktası
                TextField(
                  controller: _originController,
                  onTap: () =>
                      setState(() => _activeMapTarget = _MapPinTarget.origin),
                  onChanged: _onOriginTextChanged,
                  decoration: InputDecoration(
                    labelText:
                        'Kalkış Noktası (Yazın veya haritadan seçin)',
                    hintText: 'Örn: Ankara YHT, Kadıköy, İzmir Konak...',
                    helperText:
                        'Gerçek Konum: ${_selectedOrigin.address} (${_selectedOrigin.lat.toStringAsFixed(4)}, ${_selectedOrigin.lng.toStringAsFixed(4)})',
                    helperMaxLines: 2,
                    prefixIcon: const Icon(
                      Icons.trip_origin_rounded,
                      color: AppColors.primary,
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_originController.text.isNotEmpty)
                          IconButton(
                            tooltip: 'Temizle',
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _originController.clear();
                              _onOriginTextChanged('');
                            },
                          ),
                        IconButton(
                          tooltip: 'Haritadan Kalkış Noktası Seç',
                          icon: const Icon(
                            Icons.map_rounded,
                            color: AppColors.primary,
                          ),
                          onPressed: () =>
                              _openMapPickerFor(_MapPinTarget.origin),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Ara Durak (Opsiyonel)
                TextField(
                  controller: _waypointController,
                  onTap: () =>
                      setState(() => _activeMapTarget = _MapPinTarget.waypoint),
                  onChanged: _onWaypointTextChanged,
                  decoration: InputDecoration(
                    labelText:
                        'Ara Durak (Opsiyonel - Yazın veya haritadan seçin)',
                    hintText: 'Ara durak yoksa boş bırakın',
                    helperText: _selectedWaypoint != null
                        ? 'Gerçek Konum: ${_selectedWaypoint!.address} (${_selectedWaypoint!.lat.toStringAsFixed(4)}, ${_selectedWaypoint!.lng.toStringAsFixed(4)})'
                        : 'Ara durak eklemek isterseniz yazın veya haritadan seçin',
                    helperMaxLines: 2,
                    prefixIcon: const Icon(
                      Icons.commit_rounded,
                      color: AppColors.accent,
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_waypointController.text.isNotEmpty)
                          IconButton(
                            tooltip: 'Ara Durağı Kaldır',
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _waypointController.clear();
                              _onWaypointTextChanged('');
                            },
                          ),
                        IconButton(
                          tooltip: 'Haritadan Ara Durak Seç',
                          icon: const Icon(
                            Icons.map_rounded,
                            color: AppColors.accent,
                          ),
                          onPressed: () =>
                              _openMapPickerFor(_MapPinTarget.waypoint),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Varış Noktası
                TextField(
                  controller: _destinationController,
                  onTap: () => setState(
                    () => _activeMapTarget = _MapPinTarget.destination,
                  ),
                  onChanged: _onDestinationTextChanged,
                  decoration: InputDecoration(
                    labelText:
                        'Varış Noktası (Yazın veya haritadan seçin)',
                    hintText: 'Örn: Esenboğa, Sabiha Gökçen, ODTÜ...',
                    helperText:
                        'Gerçek Konum: ${_selectedDestination.address} (${_selectedDestination.lat.toStringAsFixed(4)}, ${_selectedDestination.lng.toStringAsFixed(4)})',
                    helperMaxLines: 2,
                    prefixIcon: const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.error,
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_destinationController.text.isNotEmpty)
                          IconButton(
                            tooltip: 'Temizle',
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _destinationController.clear();
                              _onDestinationTextChanged('');
                            },
                          ),
                        IconButton(
                          tooltip: 'Haritadan Varış Noktası Seç',
                          icon: const Icon(
                            Icons.map_rounded,
                            color: AppColors.error,
                          ),
                          onPressed: () =>
                              _openMapPickerFor(_MapPinTarget.destination),
                        ),
                      ],
                    ),
                  ),
                ),

                // Canlı OpenStreetMap Eşleşme Önerileri
                if (_isGeocoding)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
                if (_activeSuggestions.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Eşleşen Gerçek Konumlar ($targetLabel için seçebilirsiniz):',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _activeSuggestions.map((loc) {
                      return ActionChip(
                        visualDensity: VisualDensity.compact,
                        avatar: const Icon(
                          Icons.place_rounded,
                          size: 15,
                          color: AppColors.primary,
                        ),
                        label: Text(
                          '${loc.name} (${loc.address.split(',').take(2).join(',')})',
                          style: const TextStyle(fontSize: 11.5),
                        ),
                        onPressed: () => _applySuggestion(loc),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 14),

                // Harita üzerinde hangi pinin dokunarak taşınacağını seçen bar
                Text(
                  'Aşağıdaki haritaya dokunarak da doğrudan konum işaretleyebilirsiniz:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 6),
                SegmentedButton<_MapPinTarget>(
                  segments: const [
                    ButtonSegment(
                      value: _MapPinTarget.origin,
                      label: Text('Kalkış', style: TextStyle(fontSize: 12)),
                      icon: Icon(Icons.trip_origin_rounded, size: 16),
                    ),
                    ButtonSegment(
                      value: _MapPinTarget.waypoint,
                      label: Text('Ara Durak', style: TextStyle(fontSize: 12)),
                      icon: Icon(Icons.commit_rounded, size: 16),
                    ),
                    ButtonSegment(
                      value: _MapPinTarget.destination,
                      label: Text('Varış', style: TextStyle(fontSize: 12)),
                      icon: Icon(Icons.location_on_rounded, size: 16),
                    ),
                  ],
                  selected: {_activeMapTarget},
                  onSelectionChanged: (selection) {
                    setState(() => _activeMapTarget = selection.first);
                  },
                ),
                const SizedBox(height: 10),

                // İnteraktif Rota Haritası (Otomatik kamera odaklı + dokunmaya duyarlı)
                RouteMapWidget(
                  origin: _selectedOrigin,
                  destination: _selectedDestination,
                  waypoints:
                      _selectedWaypoint != null ? [_selectedWaypoint!] : [],
                  height: 240,
                  onMapTap: _onInlineMapTapped,
                  interactiveHint:
                      'Haritaya dokunarak "$targetLabel" konumunu taşıyabilirsiniz',
                ),
              ],
            ),
          ),

          // Adım 2: Tarih ve Saat
          Step(
            title: const Text('2. Kalkış Tarihi ve Saati'),
            subtitle: Text(
              '${DateFormatter.formatDate(_departureDate)} • ${_departureTime.format(context)}',
            ),
            isActive: _currentStep >= 1,
            content: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_rounded),
                  title: const Text('Yolculuk Tarihi'),
                  subtitle: Text(DateFormatter.formatDate(_departureDate)),
                  trailing: OutlinedButton(
                    onPressed: _pickDate,
                    child: const Text('Tarih Seç'),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.access_time_rounded),
                  title: const Text('Kalkış Saati'),
                  subtitle: Text(_departureTime.format(context)),
                  trailing: OutlinedButton(
                    onPressed: _pickTime,
                    child: const Text('Saat Seç'),
                  ),
                ),
              ],
            ),
          ),

          // Adım 3: Sürücü Aracı, Koltuk Sayısı, Katkı Payı Ücreti ve Kurallar
          Step(
            title: const Text('3. Araç, Koltuk ve Ücret Bilgileri'),
            isActive: _currentStep >= 2,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Sürücünün Kayıtlı Kendi Aracı Seçimi (Varsayılan/Sahte Araç Kullanılmaz)
                Text(
                  'Yolculuk Yapılacak Araç',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (vehicles.isEmpty)
                  Card(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    margin: const EdgeInsets.only(bottom: 14),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: AppColors.warning,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Kayıtlı aracınız bulunmuyor.',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'İlan oluşturabilmek için önce sisteme kendi aracınızı eklemelisiniz.',
                            style: TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: () => context.push('/add-vehicle'),
                            icon: const Icon(Icons.add_circle_outline, size: 18),
                            label: const Text('Şimdi Araç Ekle'),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  DropdownButtonFormField<String>(
                    value: (_selectedVehicleId != null &&
                            vehicles.any((v) => v.id == _selectedVehicleId))
                        ? _selectedVehicleId
                        : vehicles.first.id,
                    decoration: const InputDecoration(
                      labelText: 'Kayıtlı Aracınızı Seçin',
                      prefixIcon: Icon(
                        Icons.directions_car_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    items: vehicles
                        .map(
                          (v) => DropdownMenuItem(
                            value: v.id,
                            child: Text(
                              '${v.brand} ${v.model} (${v.licensePlate}) • ${v.color}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedVehicleId = val);
                    },
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => context.push('/add-vehicle'),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Yeni Araç Ekle'),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _totalSeats,
                  decoration: const InputDecoration(
                    labelText: 'Sunulan Boş Koltuk Sayısı',
                    prefixIcon: Icon(Icons.event_seat_rounded),
                  ),
                  items: [1, 2, 3, 4]
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text('$s Boş Koltuk'),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _totalSeats = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Koltuk Başı Katkı Payı (₺ TRY)',
                    prefixIcon: Icon(Icons.payments_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _luggageSize,
                  decoration: const InputDecoration(
                    labelText: 'Bagaj Boyutu',
                    prefixIcon: Icon(Icons.luggage_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'small',
                      child: Text('Küçük (Sırt Çantası)'),
                    ),
                    DropdownMenuItem(
                      value: 'medium',
                      child: Text('Orta (Kabin Boy Valiz)'),
                    ),
                    DropdownMenuItem(
                      value: 'large',
                      child: Text('Büyük Bagaj Uygun'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _luggageSize = v);
                  },
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Anında Rezervasyon Onayı'),
                  subtitle: const Text(
                    'Açık olduğunda yolcu talepleri beklemeden otomatik onaylanır',
                  ),
                  value: _instantApproval,
                  onChanged: (v) => setState(() => _instantApproval = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Evcil Hayvan Kabul Edilir'),
                  value: _petsAllowed,
                  onChanged: (v) => setState(() => _petsAllowed = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Sigara İçilebilir'),
                  value: _smokingAllowed,
                  onChanged: (v) => setState(() => _smokingAllowed = v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
