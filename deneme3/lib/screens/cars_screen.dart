import 'package:flutter/material.dart';

import '../data/cars.dart';
import '../models/car.dart';
import '../theme/app_theme.dart';
import '../widgets/car_card.dart';
import '../widgets/car_photo.dart';

class CarsScreen extends StatefulWidget {
  const CarsScreen({super.key, required this.onSchedule});

  final ValueChanged<String> onSchedule;

  @override
  State<CarsScreen> createState() => _CarsScreenState();
}

class _CarsScreenState extends State<CarsScreen> {
  final _searchController = TextEditingController();
  final Set<String> _favorites = {};
  String _selectedBodyType = 'Tümü';

  static const _bodyTypes = ['Tümü', 'Sedan', 'SUV', 'Hatchback'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Car> get _filteredCars {
    final query = _searchController.text.trim().toLowerCase();
    return galleryCars.where((car) {
      final matchesType =
          _selectedBodyType == 'Tümü' || car.bodyType == _selectedBodyType;
      final matchesQuery =
          query.isEmpty ||
          '${car.brand} ${car.model} ${car.year} ${car.fuel}'
              .toLowerCase()
              .contains(query);
      return matchesType && matchesQuery;
    }).toList();
  }

  void _showDetails(Car car) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _CarDetailsSheet(
        car: car,
        onSchedule: () {
          Navigator.of(sheetContext).pop();
          widget.onSchedule(car.id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cars = _filteredCars;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Araç koleksiyonu',
            style: TextStyle(
              fontSize: 26,
              letterSpacing: -.6,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Size uygun otomobili bulun ve detaylarını inceleyin.',
            style: TextStyle(fontSize: 14, color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Marka veya model ara',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Aramayı temizle',
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final type in _bodyTypes) ...[
                  ChoiceChip(
                    label: Text(type),
                    selected: _selectedBodyType == type,
                    onSelected: (_) => setState(() => _selectedBodyType = type),
                    selectedColor: AppColors.paleGreen,
                    side: BorderSide(
                      color: _selectedBodyType == type
                          ? AppColors.paleGreen
                          : AppColors.line,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (_favorites.isNotEmpty)
                  ActionChip(
                    avatar: const Icon(
                      Icons.favorite_rounded,
                      color: AppColors.accent,
                      size: 17,
                    ),
                    label: Text('Favorilerim (${_favorites.length})'),
                    onPressed: () => showModalBottomSheet<void>(
                      context: context,
                      useSafeArea: true,
                      builder: (context) => _FavoritesSheet(
                        cars: galleryCars
                            .where((car) => _favorites.contains(car.id))
                            .toList(),
                        onCarTap: (car) {
                          Navigator.pop(context);
                          _showDetails(car);
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              Text(
                '${cars.length} araç',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const Spacer(),
              const Icon(Icons.tune_rounded, size: 17, color: AppColors.muted),
              const SizedBox(width: 5),
              Text(
                _selectedBodyType == 'Tümü'
                    ? 'Tüm gövde tipleri'
                    : _selectedBodyType,
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (cars.isEmpty)
            _EmptyResults(
              onReset: () {
                _searchController.clear();
                setState(() => _selectedBodyType = 'Tümü');
              },
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 900
                    ? 3
                    : constraints.maxWidth >= 570
                    ? 2
                    : 1;
                final cardWidth =
                    (constraints.maxWidth - (columns - 1) * 14) / columns;
                return Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: cars.map((car) {
                    return SizedBox(
                      width: cardWidth,
                      child: CarCard(
                        car: car,
                        onTap: () => _showDetails(car),
                        isFavorite: _favorites.contains(car.id),
                        onFavorite: () => setState(() {
                          if (!_favorites.add(car.id))
                            _favorites.remove(car.id);
                        }),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 36,
            color: AppColors.muted,
          ),
          const SizedBox(height: 10),
          const Text(
            'Aradığınız kriterlerde araç bulunamadı.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink),
          ),
          TextButton(
            onPressed: onReset,
            child: const Text('Filtreleri temizle'),
          ),
        ],
      ),
    );
  }
}

class _CarDetailsSheet extends StatelessWidget {
  const _CarDetailsSheet({required this.car, required this.onSchedule});

  final Car car;
  final VoidCallback onSchedule;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Container(
      height: MediaQuery.sizeOf(context).height * .9,
      decoration: const BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: width < 560 ? 225 : 320,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: CarPhoto(url: car.imageUrl),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (car.badge != null)
                    Text(
                      car.badge!,
                      style: const TextStyle(
                        fontSize: 10,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    car.title,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatTry(car.price),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accentDark,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 9,
                    runSpacing: 9,
                    children: [
                      _SpecPill(Icons.calendar_today_outlined, '${car.year}'),
                      _SpecPill(
                        Icons.speed_rounded,
                        formatKilometers(car.mileage),
                      ),
                      _SpecPill(Icons.local_gas_station_outlined, car.fuel),
                      _SpecPill(Icons.settings_outlined, car.transmission),
                      _SpecPill(Icons.directions_car_outlined, car.bodyType),
                      _SpecPill(Icons.palette_outlined, car.color),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Araç hakkında',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    car.description,
                    style: const TextStyle(height: 1.5, color: AppColors.muted),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onSchedule,
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: const Text('Bu araç için test sürüşü planla'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.ink,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecPill extends StatelessWidget {
  const _SpecPill(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.muted),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoritesSheet extends StatelessWidget {
  const _FavoritesSheet({required this.cars, required this.onCarTap});

  final List<Car> cars;
  final ValueChanged<Car> onCarTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Favori araçlarım',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 12),
            for (final car in cars)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 64,
                    height: 48,
                    child: CarPhoto(url: car.imageUrl),
                  ),
                ),
                title: Text(
                  car.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(formatTry(car.price)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => onCarTap(car),
              ),
          ],
        ),
      ),
    );
  }
}
