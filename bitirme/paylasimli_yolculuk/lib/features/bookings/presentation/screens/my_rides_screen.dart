import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/storage/seed_data_service.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../chat/presentation/widgets/review_modal_sheet.dart';
import '../../../rides/presentation/widgets/ride_card_widget.dart';
import '../../domain/entities/booking_entity.dart';
import '../providers/booking_provider.dart';

/// Faz 4: 'Yolculuklarım' ekranında kullanıcının rolüne (`passenger`, `driver`, `both`)
/// göre 'Yolcu Olarak Katıldıklarım' ve/veya 'Sürücü Olarak Açtıklarım' görünümlerini sunar.
class MyRidesScreen extends ConsumerWidget {
  const MyRidesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(isOfflineModeProvider);

    final offlineBanner = isOffline
        ? Container(
            width: double.infinity,
            color: AppColors.warning.withValues(alpha: 0.2),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Row(
              children: [
                Icon(
                  Icons.offline_pin_rounded,
                  size: 18,
                  color: AppColors.warning,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Çevrimdışı Önbellek (Hive box_my_rides & box_bookings) üzerinden görüntüleniyor.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          )
        : const SizedBox.shrink();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          offlineBanner,
          const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.airline_seat_recline_normal_rounded),
                text: 'Yolcu Olarak Katıldıklarım',
              ),
              Tab(
                icon: Icon(Icons.drive_eta_rounded),
                text: 'Sürücü Olarak Açtıklarım',
              ),
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [
                _PassengerBookingsTab(),
                _DriverRidesAndRequestsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PassengerBookingsTab extends ConsumerWidget {
  const _PassengerBookingsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(passengerBookingsProvider);

    return bookingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Hata: $e')),
      data: (bookings) {
        if (bookings.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Henüz yolcu olarak katıldığınız bir rezervasyon bulunmuyor.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final b = bookings[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _BookingStatusChip(status: b.status),
                        Text(
                          '${b.seatsBooked} Koltuk • ${DateFormatter.formatCurrency(b.totalPrice)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.place_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Biniş Noktası: ${b.pickupPoint.name}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    if (b.noteToDriver.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Notunuz: "${b.noteToDriver}"',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => context.push('/ride/${b.rideId}'),
                          icon: const Icon(Icons.map_outlined, size: 18),
                          label: const Text('Rotayı Gör'),
                        ),
                        if (b.status == 'pending' || b.status == 'approved')
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.error,
                            ),
                            onPressed: () async {
                              final err = await ref
                                  .read(passengerBookingsProvider.notifier)
                                  .cancelBooking(
                                    bookingId: b.id,
                                    byDriver: false,
                                  );
                              if (err != null && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColors.error,
                                    content: Text(err),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.cancel_outlined, size: 18),
                            label: const Text('İptal Et'),
                          ),
                        if (b.status == 'completed')
                          ElevatedButton.icon(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (_) => ReviewModalSheet(
                                  rideId: b.rideId,
                                  revieweeId: b.driverId,
                                  revieweeName: 'Sürücü',
                                ),
                              );
                            },
                            icon: const Icon(Icons.star_rate_rounded, size: 18),
                            label: const Text('Değerlendir'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _DriverRidesAndRequestsTab extends ConsumerWidget {
  const _DriverRidesAndRequestsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myRidesAsync = ref.watch(myDriverRidesProvider);
    final driverBookingsAsync = ref.watch(driverBookingsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Gelen Koltuk Rezervasyon Talepleri',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            FilledButton.tonalIcon(
              onPressed: () => context.push('/create-ride'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Yeni İlan'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        driverBookingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Hata: $e'),
          data: (requests) {
            if (requests.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('İlanlarınıza gelen rezervasyon talebi bulunmuyor.'),
                ),
              );
            }
            return Column(
              children: requests
                  .map((req) => _DriverBookingRequestCard(booking: req))
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 20),
        Text(
          'Sürücü Olarak Açtığım İlanlar',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        myRidesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Hata: $e'),
          data: (rides) {
            if (rides.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Henüz sürücü olarak açtığınız bir ilan yok.'),
                ),
              );
            }
            return Column(
              children: rides
                  .map(
                    (r) => RideCardWidget(
                      ride: r,
                      onTap: () => context.push('/ride/${r.id}'),
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

class _DriverBookingRequestCard extends ConsumerWidget {
  final BookingEntity booking;

  const _DriverBookingRequestCard({required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPending = booking.status == 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  foregroundColor: AppColors.primary,
                  child: Text(booking.passengerSummary.fullName[0]),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${booking.passengerSummary.fullName} (${booking.passengerSummary.ratingAvg} ★)',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Biniş: ${booking.pickupPoint.name} • ${booking.seatsBooked} Koltuk',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                _BookingStatusChip(status: booking.status),
              ],
            ),
            if (booking.noteToDriver.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Yolcu Notu: "${booking.noteToDriver}"',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (isPending) ...[
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    onPressed: () async {
                      final err = await ref
                          .read(passengerBookingsProvider.notifier)
                          .rejectBooking(booking.id);
                      if (err != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(err)),
                        );
                      }
                    },
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Reddet'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final err = await ref
                          .read(passengerBookingsProvider.notifier)
                          .approveBooking(
                            rideId: booking.rideId,
                            bookingId: booking.id,
                          );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor:
                                err == null ? AppColors.success : AppColors.error,
                            content: Text(
                              err ??
                                  'Rezervasyon Atomik Transaction ile onaylandı ve boş koltuk düşürüldü!',
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Onayla (Transaction)'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BookingStatusChip extends StatelessWidget {
  final String status;

  const _BookingStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    switch (status) {
      case 'approved':
        color = AppColors.success;
        text = 'Onaylandı';
        break;
      case 'rejected':
        color = AppColors.error;
        text = 'Reddedildi';
        break;
      case 'cancelled_by_passenger':
        color = AppColors.error;
        text = 'Yolcu İptal Etti';
        break;
      case 'cancelled_by_driver':
        color = AppColors.error;
        text = 'Sürücü İptal Etti';
        break;
      case 'completed':
        color = AppColors.info;
        text = 'Tamamlandı';
        break;
      default:
        color = AppColors.warning;
        text = 'Onay Bekliyor';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

