import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../auth/domain/models/app_user.dart';
import '../../vehicles/controllers/vehicle_controller.dart';
import '../controllers/tracking_controller.dart';

class TrackingNumberBar extends StatefulWidget {
  final TrackingController trackingController;
  final VehicleController vehicleController;
  final AppUser? currentUser;

  const TrackingNumberBar({
    super.key,
    required this.trackingController,
    required this.vehicleController,
    required this.currentUser,
  });

  @override
  State<TrackingNumberBar> createState() => _TrackingNumberBarState();
}

class _TrackingNumberBarState extends State<TrackingNumberBar> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: widget.trackingController.selectedTrackingNumber.value ?? '',
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      widget.trackingController.selectTrackingNumber(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter vehicles belonging to the current user (or all if not logged in)
    final userVehicles = widget.vehicleController.allVehicles.where((v) {
      if (widget.currentUser == null) return true;
      return v.ownerId == widget.currentUser!.id;
    }).toList();

    return ValueListenableBuilder<String?>(
      valueListenable: widget.trackingController.selectedTrackingNumber,
      builder: (context, activeNumber, _) {
        return Container(
          padding: AppSpacing.screenPadding,
          decoration: BoxDecoration(
            color: isDark ? AppColors.charcoalGrey : AppColors.lightSurface,
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppColors.steelBorderGrey : AppColors.lightBorder,
                width: 0.8,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: AppTypography.telemetryCode(
                        color: isDark ? AppColors.platinumText : AppColors.lightTextPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Takip Numarası Girin (Örn: TRK-LAND-3401, TRK-HAVA-10492)',
                        hintStyle: const TextStyle(fontSize: 12),
                        prefixIcon: const Icon(Icons.radar, color: AppColors.crimsonLight, size: 20),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.arrow_forward, color: AppColors.crimsonLight),
                          onPressed: _onSearch,
                        ),
                      ),
                      onSubmitted: (_) => _onSearch(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ElevatedButton(
                    onPressed: _onSearch,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text('Sorgula'),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              // Quick selector chips for user vehicles
              if (userVehicles.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.bookmark_border, size: 13, color: AppColors.silverText),
                    const SizedBox(width: 4),
                    Text(
                      'Araçlarım (${userVehicles.length}):',
                      style: const TextStyle(fontSize: 11, color: AppColors.silverText, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: userVehicles.map((v) {
                      final isSelected = activeNumber == v.trackingNumber;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          avatar: Icon(
                            v.vehicleType.name == 'land'
                                ? Icons.directions_car
                                : v.vehicleType.name == 'air'
                                    ? Icons.flight
                                    : Icons.sailing,
                            size: 14,
                            color: isSelected ? Colors.white : AppColors.crimsonLight,
                          ),
                          label: Text('${v.brand} (${v.trackingNumber})'),
                          selected: isSelected,
                          onSelected: (_) {
                            _searchController.text = v.trackingNumber;
                            widget.trackingController.selectTrackingNumber(v.trackingNumber);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
