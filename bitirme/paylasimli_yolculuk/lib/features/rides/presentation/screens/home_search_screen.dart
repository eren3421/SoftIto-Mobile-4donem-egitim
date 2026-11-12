import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/storage/seed_data_service.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/repositories/ride_repository.dart';
import '../providers/ride_provider.dart';
import '../widgets/location_picker_sheet.dart';
import '../widgets/ride_card_widget.dart';

/// Faz 3: Kalkış/varış noktası, tarih, boş koltuk sayısı ve fiyata göre filtreleme yapan,
/// `box_search_history` üzerinden hızlı arama sunan Yolculuk Arama Ana Ekranı.
class HomeSearchScreen extends ConsumerStatefulWidget {
  const HomeSearchScreen({super.key});

  @override
  ConsumerState<HomeSearchScreen> createState() => _HomeSearchScreenState();
}

class _HomeSearchScreenState extends ConsumerState<HomeSearchScreen> {
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  DateTime? _selectedDate;
  int _minSeats = 1;
  String _statusFilter = 'all'; // 'all', 'available', 'full', 'completed'

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _triggerSearch() {
    final filter = RideSearchFilter(
      originQuery: _originController.text,
      destinationQuery: _destinationController.text,
      date: _selectedDate,
      minSeats: _minSeats,
      statusFilter: _statusFilter,
    );
    ref.read(ridesNotifierProvider.notifier).applyFilter(filter);
  }

  void _resetSearch() {
    _originController.clear();
    _destinationController.clear();
    setState(() {
      _selectedDate = null;
      _minSeats = 1;
      _statusFilter = 'all';
    });
    ref
        .read(ridesNotifierProvider.notifier)
        .applyFilter(const RideSearchFilter());
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now.subtract(const Duration(days: 7)),
      lastDate: now.add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _triggerSearch();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ridesAsync = ref.watch(ridesNotifierProvider);
    final searchHistory = ref.watch(searchHistoryProvider);
    final isOffline = ref.watch(isOfflineModeProvider);
    final currentUser = ref.watch(authNotifierProvider).valueOrNull;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (isOffline)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warning),
            ),
            child: const Row(
              children: [
                Icon(Icons.wifi_off_rounded, color: AppColors.warning),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Çevrimdışı Mod Aktif: Veriler yerel Hive önbelleğinden (box_my_rides) yükleniyor.',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

        // Arama Kartı
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Yolculuk Ara',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _originController,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _triggerSearch(),
                  decoration: InputDecoration(
                    labelText:
                        'Kalkış Noktası (Klavyeden yazın veya haritadan seçin)',
                    prefixIcon: const Icon(
                      Icons.trip_origin_rounded,
                      color: AppColors.primary,
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_originController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _originController.clear();
                              setState(() {});
                              _triggerSearch();
                            },
                          ),
                        IconButton(
                          tooltip: 'Haritadan Kalkış Noktası Seç',
                          icon: const Icon(
                            Icons.map_rounded,
                            color: AppColors.primary,
                          ),
                          onPressed: () async {
                            final picked = await LocationPickerSheet.show(
                              context,
                              title: 'Arama İçin Kalkış Noktası Seçin',
                              initialLocation: _originController.text.isNotEmpty
                                  ? TurkeyLocations.findOrCreate(
                                      _originController.text,
                                    )
                                  : null,
                              markerColor: AppColors.primary,
                              markerIcon: Icons.trip_origin_rounded,
                            );
                            if (picked != null && mounted) {
                              setState(() {
                                _originController.text = picked.name;
                              });
                              _triggerSearch();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _destinationController,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _triggerSearch(),
                  decoration: InputDecoration(
                    labelText:
                        'Varış Noktası (Klavyeden yazın veya haritadan seçin)',
                    prefixIcon: const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.error,
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_destinationController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _destinationController.clear();
                              setState(() {});
                              _triggerSearch();
                            },
                          ),
                        IconButton(
                          tooltip: 'Haritadan Varış Noktası Seç',
                          icon: const Icon(
                            Icons.map_rounded,
                            color: AppColors.error,
                          ),
                          onPressed: () async {
                            final picked = await LocationPickerSheet.show(
                              context,
                              title: 'Arama İçin Varış Noktası Seçin',
                              initialLocation:
                                  _destinationController.text.isNotEmpty
                                      ? TurkeyLocations.findOrCreate(
                                          _destinationController.text,
                                        )
                                      : null,
                              markerColor: AppColors.error,
                              markerIcon: Icons.location_on_rounded,
                            );
                            if (picked != null && mounted) {
                              setState(() {
                                _destinationController.text = picked.name;
                              });
                              _triggerSearch();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_month_rounded, size: 18),
                        label: Text(
                          _selectedDate == null
                              ? 'Tüm Tarihler'
                              : DateFormatter.formatDate(_selectedDate!),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.lightBorder),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _minSeats,
                          items: [1, 2, 3, 4]
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text('$s+ Koltuk'),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _minSeats = val);
                              _triggerSearch();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _triggerSearch,
                        icon: const Icon(Icons.search_rounded),
                        label: const Text('Yolculuk Bul'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Filtreleri Sıfırla',
                      onPressed: _resetSearch,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Son Aramalar (`box_search_history`)
        if (searchHistory.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Son Aramalar (Yerel Önbellek)',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              TextButton(
                onPressed: () =>
                    ref.read(searchHistoryProvider.notifier).clear(),
                child: const Text('Temizle'),
              ),
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: searchHistory.map((item) {
                final origin = item['origin']?.toString() ?? '';
                final dest = item['destination']?.toString() ?? '';
                final label = [
                  if (origin.isNotEmpty) origin,
                  if (dest.isNotEmpty) dest,
                ].join(' → ');
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    avatar: const Icon(Icons.history_rounded, size: 16),
                    label: Text(label),
                    onPressed: () {
                      setState(() {
                        _originController.text = origin;
                        _destinationController.text = dest;
                      });
                      _triggerSearch();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],

        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aktif Yolculuk İlanları',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () => context.push('/create-ride'),
              icon: const Icon(Icons.add_road_rounded, size: 18),
              label: const Text('İlan Aç'),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Durum ve Başvuru Uygunluk Filtreleri
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: const Text('Tüm İlanlar'),
                selected: _statusFilter == 'all',
                onSelected: (_) {
                  setState(() => _statusFilter = 'all');
                  _triggerSearch();
                },
              ),
              const SizedBox(width: 8),
              FilterChip(
                avatar: const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 16,
                  color: AppColors.success,
                ),
                label: const Text('Başvurulabilir (Boş Yer Var)'),
                selected: _statusFilter == 'available',
                onSelected: (_) {
                  setState(() => _statusFilter = 'available');
                  _triggerSearch();
                },
              ),
              const SizedBox(width: 8),
              FilterChip(
                avatar: const Icon(
                  Icons.block_flipped,
                  size: 16,
                  color: AppColors.error,
                ),
                label: const Text('Kapasitesi Dolu'),
                selected: _statusFilter == 'full',
                onSelected: (_) {
                  setState(() => _statusFilter = 'full');
                  _triggerSearch();
                },
              ),
              const SizedBox(width: 8),
              FilterChip(
                avatar: const Icon(
                  Icons.done_all_rounded,
                  size: 16,
                ),
                label: const Text('Tamamlananlar'),
                selected: _statusFilter == 'completed',
                onSelected: (_) {
                  setState(() => _statusFilter = 'completed');
                  _triggerSearch();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Yolculuk Listesi (AsyncValue.when)
        ridesAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.error,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text('Hata oluştu: $error'),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => ref.invalidate(ridesNotifierProvider),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            ),
          ),
          data: (rides) {
            if (rides.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.search_off_rounded,
                        size: 48,
                        color: AppColors.lightTextSecondary,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Aradığınız kriterlere uygun yolculuk bulunamadı.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Filtreleri temizleyebilir veya aynı güzergah için yeni bir sürücü ilanı açabilirsiniz.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _resetSearch,
                        icon: const Icon(Icons.filter_alt_off_rounded),
                        label: const Text('Tüm İlanları Göster'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: rides
                  .map(
                    (ride) => RideCardWidget(
                      ride: ride,
                      onTap: () => context.push('/ride/${ride.id}'),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

