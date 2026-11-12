import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/storage/seed_data_service.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../bookings/domain/entities/booking_entity.dart';
import '../../../bookings/presentation/providers/booking_provider.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../../chat/presentation/widgets/review_modal_sheet.dart';
import '../../domain/entities/ride_entity.dart';
import '../providers/ride_provider.dart';
import '../widgets/location_picker_sheet.dart';
import '../widgets/route_map_widget.dart';

/// Faz 3 & Faz 4: Harita önizlemesi (`flutter_map`), güzergah özeti, sürücü puanı,
/// kurallar ve atomik koltuk rezervasyonu içeren Yolculuk Detay Ekranı.
class RideDetailScreen extends ConsumerStatefulWidget {
  final String rideId;

  const RideDetailScreen({
    super.key,
    required this.rideId,
  });

  @override
  ConsumerState<RideDetailScreen> createState() => _RideDetailScreenState();
}

class _RideDetailScreenState extends ConsumerState<RideDetailScreen> {
  int _seatsToBook = 1;
  final _pickupController = TextEditingController();
  RideLocationPoint? _customPickupPoint;
  final _noteController = TextEditingController(
    text: '1 adet sırt çantam var, tam saatinde durakta olacağım.',
  );
  bool _isSubmitting = false;

  @override
  void dispose() {
    _pickupController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleBookSeat(RideEntity ride) async {
    final user = ref.read(authNotifierProvider).valueOrNull;
    if (user == null) return;

    final resolvedPickup = _customPickupPoint ??
        (_pickupController.text.trim().isNotEmpty
            ? TurkeyLocations.findOrCreate(_pickupController.text.trim())
            : ride.origin);

    setState(() => _isSubmitting = true);
    final now = DateTime.now();
    final booking = BookingEntity(
      id: '',
      rideId: ride.id,
      driverId: ride.driverId,
      passengerId: user.id,
      passengerSummary: PassengerSummary(
        fullName: user.fullName,
        avatarUrl: user.avatarUrl,
        ratingAvg: user.ratingAvg,
      ),
      seatsBooked: _seatsToBook,
      totalPrice: ride.pricePerSeat * _seatsToBook,
      status: 'pending',
      pickupPoint: resolvedPickup,
      noteToDriver: _noteController.text.trim(),
      createdAt: now,
      updatedAt: now,
    );

    final errorMessage =
        await ref.read(passengerBookingsProvider.notifier).requestBooking(
              booking: booking,
              currentAvailableSeats: ride.availableSeats,
              instantApprove: ride.rules.instantApproval,
            );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(errorMessage),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.success,
            content: Text(
              ride.rules.instantApproval
                  ? 'Rezervasyonunuz anında onaylandı! Koltuk kontenjanı güncellendi.'
                  : 'Rezervasyon talebiniz sürücüye iletildi (Onay Bekliyor).',
            ),
          ),
        );
      }
    }
  }

  Future<void> _openChatWithDriver(RideEntity ride) async {
    final user = ref.read(authNotifierProvider).valueOrNull;
    if (user == null) return;

    final chat = await ref.read(chatsNotifierProvider.notifier).openOrCreateChat(
          rideId: ride.id,
          driverId: ride.driverId,
          driverName: ride.driverSummary.fullName,
          passengerId: user.id,
          passengerName: user.fullName,
          rideSummaryTitle: '${ride.origin.name} → ${ride.destination.name}',
        );
    if (chat != null && mounted) {
      context.push('/chat/${chat.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final rideAsync = ref.watch(rideDetailProvider(widget.rideId));
    final currentUser = ref.watch(authNotifierProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yolculuk Detayı'),
      ),
      body: rideAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Hata: $err')),
        data: (ride) {
          final isDriver = currentUser?.id == ride.driverId;
          final isCompleted = ride.status == 'completed';
          final isFull = ride.isFull || ride.availableSeats <= 0;
          final driverReviewsAsync =
              ref.watch(userReviewsProvider(ride.driverId));
          final driverReviews = driverReviewsAsync.valueOrNull ?? [];
          final effectiveDriverCount = driverReviews.length;
          final effectiveDriverAvg = effectiveDriverCount > 0
              ? (driverReviews.fold<double>(0.0, (s, r) => s + r.rating) /
                  effectiveDriverCount)
              : ride.driverSummary.ratingAvg;

          final String statusTitle;
          final String statusSubtitle;
          final Color statusColor;
          final IconData statusIcon;

          if (isCompleted) {
            statusTitle = 'Yolculuk Tamamlandı';
            statusSubtitle =
                'Bu seyahat tamamlandığı için yeni rezervasyon başvurusu alınmamaktadır.';
            statusColor = Colors.grey.shade700;
            statusIcon = Icons.done_all_rounded;
          } else if (isFull) {
            statusTitle = 'Kapasite Dolu (0 Boş Koltuk)';
            statusSubtitle =
                'Tüm koltuklar dolmuştur. Boş yer açılmadıkça başvuru yapılamaz.';
            statusColor = AppColors.error;
            statusIcon = Icons.block_rounded;
          } else {
            statusTitle = 'Başvuruya Açık (${ride.availableSeats} Boş Koltuk)';
            statusSubtitle =
                'Bu yolculuğa hemen rezervasyon talebi göndererek katılabilirsiniz.';
            statusColor = AppColors.success;
            statusIcon = Icons.check_circle_outline_rounded;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 0. Başvuru Uygunluk ve Koltuk Durum Bilgilendirme Kartı
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.35)),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 26),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            statusTitle,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            statusSubtitle,
                            style: TextStyle(
                              color: statusColor.withValues(alpha: 0.9),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 1. Harita ve Polyline Rota Önizlemesi (`flutter_map`)
              RouteMapWidget(
                origin: ride.origin,
                destination: ride.destination,
                waypoints: ride.waypoints,
                height: 240,
              ),
              const SizedBox(height: 16),

              // 2. Güzergah Özeti ve Durum Kartı
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _StatusBadge(status: ride.status),
                          Text(
                            '${DateFormatter.formatCurrency(ride.pricePerSeat)} / Koltuk',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _RouteStepRow(
                        icon: Icons.trip_origin_rounded,
                        color: AppColors.primary,
                        title: ride.origin.name,
                        subtitle:
                            '${ride.origin.address} • Kalkış: ${DateFormatter.formatDayAndTime(ride.departureTime)}',
                      ),
                      if (ride.waypoints.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        ...ride.waypoints.map(
                          (w) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _RouteStepRow(
                              icon: Icons.commit_rounded,
                              color: AppColors.accent,
                              title: 'Ara Durak: ${w.name}',
                              subtitle:
                                  'Koordinat: ${w.lat.toStringAsFixed(4)}, ${w.lng.toStringAsFixed(4)}',
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      _RouteStepRow(
                        icon: Icons.location_on_rounded,
                        color: AppColors.error,
                        title: ride.destination.name,
                        subtitle:
                            '${ride.destination.address} • Tahmini Varış: ${DateFormatter.formatTime(ride.estimatedArrivalTime)}',
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Boş Koltuk Kontenjanı:',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '${ride.availableSeats} / ${ride.totalSeatsOffered} Koltuk Müsait',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isFull ? AppColors.error : AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 3. Sürücü ve Araç Bilgisi Kartı
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sürücü ve Araç Bilgileri',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.15),
                            foregroundColor: AppColors.primary,
                            child: Text(
                              ride.driverSummary.fullName.isNotEmpty
                                  ? ride.driverSummary.fullName[0]
                                  : 'S',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ride.driverSummary.fullName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 18,
                                      color: AppColors.warning,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      effectiveDriverAvg > 0
                                          ? '${effectiveDriverAvg.toStringAsFixed(1)} Sürücü Puanı ($effectiveDriverCount değerlendirme)'
                                          : 'Henüz Değerlendirme Yok',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (!isDriver)
                            OutlinedButton.icon(
                              onPressed: () => _openChatWithDriver(ride),
                              icon: const Icon(Icons.chat_bubble_outline, size: 18),
                              label: const Text('Mesaj'),
                            ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        children: [
                          const Icon(
                            Icons.directions_car_filled_outlined,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${ride.vehicleSummary.brandModel} (${ride.vehicleSummary.color}) • Plaka: ${ride.vehicleSummary.licensePlate}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 3.1 Sürücü Değerlendirmeleri ve Yolcu Yorumları (FR-08)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sürücü Değerlendirmeleri ve Yorumları',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 18,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                effectiveDriverCount > 0
                                    ? '${effectiveDriverAvg.toStringAsFixed(1)} ($effectiveDriverCount yorum)'
                                    : 'Yeni Sürücü',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      driverReviewsAsync.when(
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        error: (_, __) =>
                            const Text('Yorumlar yüklenemedi.'),
                        data: (reviews) {
                          if (reviews.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 6),
                              child: Text(
                                'Bu sürücü için henüz yolcu yorumu bulunmuyor.',
                                style: TextStyle(
                                  color: AppColors.lightTextSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            );
                          }
                          return Column(
                            children: reviews.take(5).map((r) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.lightBorder,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: AppColors.warning
                                          .withValues(alpha: 0.2),
                                      child: Text(
                                        '${r.rating}★',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          color: AppColors.secondary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                r.reviewerName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              Text(
                                                DateFormatter.formatDate(
                                                  r.createdAt,
                                                ),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(fontSize: 11),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            r.comment,
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 4. Yolculuk Kuralları (`rules`)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Yolculuk Kuralları',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(
                            avatar: Icon(
                              ride.rules.instantApproval
                                  ? Icons.bolt_rounded
                                  : Icons.hourglass_top_rounded,
                              size: 16,
                            ),
                            label: Text(
                              ride.rules.instantApproval
                                  ? 'Anında Onay'
                                  : 'Sürücü Onaylı',
                            ),
                          ),
                          Chip(
                            avatar: const Icon(Icons.luggage_outlined, size: 16),
                            label: Text('Bagaj: ${ride.rules.luggageSize.toUpperCase()}'),
                          ),
                          Chip(
                            avatar: Icon(
                              ride.rules.smokingAllowed
                                  ? Icons.smoking_rooms
                                  : Icons.smoke_free,
                              size: 16,
                            ),
                            label: Text(
                              ride.rules.smokingAllowed
                                  ? 'Sigara Serbest'
                                  : 'Sigara İçilmez',
                            ),
                          ),
                          Chip(
                            avatar: const Icon(Icons.pets, size: 16),
                            label: Text(
                              ride.rules.petsAllowed
                                  ? 'Evcil Hayvan Uygun'
                                  : 'Evcil Hayvan Yok',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 5. Yolcu İçin Rezervasyon Kartı veya Sürücü İçin Durum Yönetimi
              if (!isDriver && ride.status != 'completed')
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Koltuk Rezervasyon Talebi',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        if (isFull)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Bu yolculukta boş koltuk kalmamıştır (Kapasite Dolu).',
                              style: TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        else ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Talep Edilen Koltuk Sayısı:'),
                              DropdownButton<int>(
                                value: _seatsToBook > ride.availableSeats
                                    ? 1
                                    : _seatsToBook,
                                items: List.generate(
                                  ride.availableSeats,
                                  (index) => DropdownMenuItem(
                                    value: index + 1,
                                    child: Text('${index + 1} Koltuk'),
                                  ),
                                ),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _seatsToBook = val);
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _pickupController,
                            onChanged: (val) {
                              setState(() {
                                _customPickupPoint = val.trim().isEmpty
                                    ? null
                                    : TurkeyLocations.findOrCreate(val);
                              });
                            },
                            decoration: InputDecoration(
                              labelText:
                                  'Biniş / Buluşma Noktanız (Yazın veya haritadan seçin)',
                              hintText: 'Varsayılan: ${ride.origin.name}',
                              prefixIcon: const Icon(
                                Icons.pin_drop_outlined,
                                color: AppColors.primary,
                              ),
                              suffixIcon: IconButton(
                                tooltip: 'Haritadan Biniş Noktası Seç',
                                icon: const Icon(
                                  Icons.map_rounded,
                                  color: AppColors.primary,
                                ),
                                onPressed: () async {
                                  final picked = await LocationPickerSheet.show(
                                    context,
                                    title: 'Biniş / Buluşma Noktanızı Seçin',
                                    initialLocation:
                                        _customPickupPoint ?? ride.origin,
                                    markerColor: AppColors.primary,
                                    markerIcon: Icons.pin_drop_rounded,
                                  );
                                  if (picked != null && mounted) {
                                    setState(() {
                                      _customPickupPoint = picked;
                                      _pickupController.text = picked.name;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _noteController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Sürücüye Notunuz',
                              prefixIcon: Icon(Icons.note_alt_outlined),
                            ),
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton.icon(
                            onPressed: _isSubmitting
                                ? null
                                : () => _handleBookSeat(ride),
                            icon: const Icon(Icons.event_seat_rounded),
                            label: Text(
                              _isSubmitting
                                  ? 'İşleniyor...'
                                  : 'Rezervasyon Yap (${DateFormatter.formatCurrency(ride.pricePerSeat * _seatsToBook)})',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

              // Sürücü Kontrol Paneli (Canlı Yolculuk Durumu FR-07)
              if (isDriver)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Sürücü Yolculuk Durum Yönetimi',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            if (ride.status == 'planned' ||
                                ride.status == 'full')
                              ElevatedButton.icon(
                                onPressed: () => ref
                                    .read(ridesNotifierProvider.notifier)
                                    .updateRideStatus(
                                      rideId: ride.id,
                                      status: 'ongoing',
                                    ),
                                icon: const Icon(Icons.play_arrow_rounded),
                                label: const Text('Yolculuğu Başlat (ONGOING)'),
                              ),
                            if (ride.status == 'ongoing')
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                ),
                                onPressed: () => ref
                                    .read(ridesNotifierProvider.notifier)
                                    .updateRideStatus(
                                      rideId: ride.id,
                                      status: 'completed',
                                    ),
                                icon: const Icon(Icons.flag_rounded),
                                label: const Text('Yolculuğu Tamamla (COMPLETED)'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              // Tamamlanan yolculuk için Bilgilendirme ve Değerlendirme (Review) butonu (FR-08)
              if (ride.status == 'completed' && !isDriver && currentUser != null)
                Card(
                  margin: const EdgeInsets.only(top: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: AppColors.secondary,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Bu yolculuk tamamlanmıştır. Yeni rezervasyon başvurusu alınmamaktadır.',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.warning,
                            foregroundColor: Colors.black87,
                          ),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (_) => ReviewModalSheet(
                                rideId: ride.id,
                                revieweeId: ride.driverId,
                                revieweeName: ride.driverSummary.fullName,
                              ),
                            );
                          },
                          icon: const Icon(Icons.star_rate_rounded),
                          label: const Text(
                            'Sürücüyü Puanla ve Yorum Yap (1-5 ★)',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _RouteStepRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _RouteStepRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case 'full':
        color = AppColors.error;
        label = 'DOLU (FULL)';
        break;
      case 'ongoing':
        color = AppColors.info;
        label = 'DEVAM EDİYOR (ONGOING)';
        break;
      case 'completed':
        color = AppColors.success;
        label = 'TAMAMLANDI (COMPLETED)';
        break;
      case 'cancelled':
        color = AppColors.error;
        label = 'İPTAL EDİLDİ';
        break;
      default:
        color = AppColors.primary;
        label = 'PLANLANDI (PLANNED)';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

