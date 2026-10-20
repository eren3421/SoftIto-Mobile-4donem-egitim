import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/crimson_button.dart';
import '../../auth/domain/models/app_user.dart';
import '../../vehicles/domain/models/vehicle_model.dart';
import '../controllers/reservation_controller.dart';

class CreateReservationDialog extends StatefulWidget {
  final VehicleModel vehicle;
  final AppUser currentUser;
  final ReservationController controller;

  const CreateReservationDialog({
    super.key,
    required this.vehicle,
    required this.currentUser,
    required this.controller,
  });

  static Future<void> show(
    BuildContext context, {
    required VehicleModel vehicle,
    required AppUser currentUser,
    required ReservationController controller,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => CreateReservationDialog(
        vehicle: vehicle,
        currentUser: currentUser,
        controller: controller,
      ),
    );
  }

  @override
  State<CreateReservationDialog> createState() => _CreateReservationDialogState();
}

class _CreateReservationDialogState extends State<CreateReservationDialog> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now().add(const Duration(days: 1));
    _endDate = DateTime.now().add(const Duration(days: 4));
  }

  int get _daysCount {
    final diff = _endDate.difference(_startDate).inDays;
    return diff <= 0 ? 1 : diff;
  }

  double get _totalPrice => widget.vehicle.unitPrice * _daysCount;

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.crimsonPrimary,
                  onPrimary: Colors.white,
                  surface: AppColors.charcoalGrey,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _confirmReservation() {
    widget.controller.createReservation(
      vehicle: widget.vehicle,
      renterUser: widget.currentUser,
      startDate: _startDate,
      endDate: _endDate,
    );

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.vehicle.title} için rezervasyon talebiniz (${Formatters.currency(_totalPrice)}) araç sahibine iletildi!',
        ),
        backgroundColor: AppColors.statusEmerald,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: AppSpacing.cardPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Rezervasyon Oluştur', style: AppTypography.sectionTitle()),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: AppSpacing.sm),

              // Vehicle summary banner
              Container(
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.slateCardGrey : AppColors.lightInputBg,
                  borderRadius: AppSpacing.radiusMd,
                  border: Border.all(color: isDark ? AppColors.steelBorderGrey : AppColors.lightBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.directions_car, color: AppColors.crimsonLight, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.vehicle.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                          Text(
                            '${widget.vehicle.plateNumber} • ${widget.vehicle.ownerName}',
                            style: const TextStyle(fontSize: 12, color: AppColors.silverText),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      Formatters.currency(widget.vehicle.unitPrice, '/ ${widget.vehicle.pricingPeriod}'),
                      style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.crimsonLight),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Date Range Picker Box
              const Text('Kiralama Tarih Aralığı', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              InkWell(
                onTap: _selectDateRange,
                borderRadius: AppSpacing.radiusMd,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.gunmetalGrey : AppColors.lightInputBg,
                    borderRadius: AppSpacing.radiusMd,
                    border: Border.all(color: AppColors.crimsonAccent, width: 1.2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_month, color: AppColors.crimsonLight, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            Formatters.dateRange(_startDate, _endDate),
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.crimsonSurface,
                          borderRadius: AppSpacing.radiusSm,
                        ),
                        child: Text(
                          '$_daysCount Gün',
                          style: const TextStyle(color: AppColors.crimsonLight, fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Renter civilian summary
              const Text('Kiralayan Sivil Kullanıcı', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              Container(
                padding: AppSpacing.compactCardPadding,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.slateCardGrey : AppColors.lightInputBg,
                  borderRadius: AppSpacing.radiusMd,
                  border: Border.all(color: isDark ? AppColors.steelBorderGrey : AppColors.lightBorder),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Ad Soyad:', widget.currentUser.displayName),
                    _buildInfoRow('T.C. Kimlik No:', widget.currentUser.civilian?.tcIdentityNumber ?? '-'),
                    _buildInfoRow('İletişim No:', widget.currentUser.contactPhone),
                    _buildInfoRow('Adres:', widget.currentUser.addressSummary),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Total Calculation
              Container(
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: AppColors.crimsonSurface,
                  borderRadius: AppSpacing.radiusMd,
                  border: Border.all(color: AppColors.crimsonPrimary),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Toplam Tutar', style: TextStyle(fontSize: 12, color: AppColors.silverText)),
                        Text(
                          '${Formatters.currency(widget.vehicle.unitPrice)} x $_daysCount Gün',
                          style: const TextStyle(fontSize: 11, color: AppColors.silverText),
                        ),
                      ],
                    ),
                    Text(
                      Formatters.currency(_totalPrice, ''),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.platinumText,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Vazgeç'),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  CrimsonButton(
                    label: 'Talebi Onayla ve Gönder',
                    icon: Icons.check,
                    onPressed: _confirmReservation,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.silverText)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
