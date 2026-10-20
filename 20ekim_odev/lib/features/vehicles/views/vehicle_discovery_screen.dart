import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/crimson_button.dart';
import '../../auth/domain/models/app_user.dart';
import '../../messaging/controllers/messaging_controller.dart';
import '../../messaging/views/chat_conversation_screen.dart';
import '../../reservations/controllers/reservation_controller.dart';
import '../../reservations/views/create_reservation_dialog.dart';
import '../../tracking/controllers/tracking_controller.dart';
import '../controllers/vehicle_controller.dart';
import '../domain/models/vehicle_model.dart';
import '../widgets/vehicle_card.dart';
import '../widgets/vehicle_category_bar.dart';
import '../widgets/vehicle_filter_panel.dart';
import 'add_vehicle_dialog.dart';
import 'vehicle_detail_dialog.dart';

class VehicleDiscoveryScreen extends StatelessWidget {
  final AppUser? currentUser;
  final VehicleController vehicleController;
  final TrackingController trackingController;
  final ReservationController reservationController;
  final MessagingController messagingController;
  final void Function(int tabIndex)? onNavigateTab;

  const VehicleDiscoveryScreen({
    super.key,
    required this.currentUser,
    required this.vehicleController,
    required this.trackingController,
    required this.reservationController,
    required this.messagingController,
    this.onNavigateTab,
  });

  void _openFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return VehicleFilterPanel(
              controller: vehicleController,
              onFilterApplied: () => Navigator.of(context).pop(),
            );
          },
        );
      },
    );
  }

  void _openAddVehicleDialog(BuildContext context) {
    if (currentUser == null) return;
    AddVehicleDialog.show(
      context,
      currentUser: currentUser!,
      controller: vehicleController,
    );
  }

  void _openDetails(BuildContext context, VehicleModel vehicle) {
    VehicleDetailDialog.show(
      context,
      vehicle: vehicle,
      currentUser: currentUser,
      onRent: () => _openRentDialog(context, vehicle),
      onTrack: () => _trackVehicle(vehicle),
      onChat: () => _openChat(context, vehicle),
    );
  }

  void _openRentDialog(BuildContext context, VehicleModel vehicle) {
    if (currentUser == null) return;
    CreateReservationDialog.show(
      context,
      vehicle: vehicle,
      currentUser: currentUser!,
      controller: reservationController,
    );
  }

  void _trackVehicle(VehicleModel vehicle) {
    trackingController.selectTrackingNumber(vehicle.trackingNumber);
    onNavigateTab?.call(2); // Tracking tab
  }

  void _openChat(BuildContext context, VehicleModel vehicle) {
    if (currentUser == null) return;
    final room = messagingController.getOrCreateRoom(
      vehicle: vehicle,
      currentUser: currentUser!,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatConversationScreen(
          room: room,
          currentUser: currentUser!,
          messagingController: messagingController,
          vehicleController: vehicleController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Çok Modlu Araç Kiralama', style: AppTypography.cardTitle()),
            Text(
              'Kara, Hava ve Deniz Taşıtları Portalı',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.silverText : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
        actions: [
          // Filter button with active counter badge
          ValueListenableBuilder(
            valueListenable: vehicleController.filterState,
            builder: (context, filter, _) {
              final count = filter.activeFilterCount;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    tooltip: '7 Kriterli Filtreleme',
                    onPressed: () => _openFilterBottomSheet(context),
                  ),
                  if (count > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.crimsonAccent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CrimsonButton(
              label: '+ Kiraya Ver',
              height: 34,
              onPressed: () => _openAddVehicleDialog(context),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;

          return Column(
            children: [
              // Horizontal Category Bar
              ValueListenableBuilder(
                valueListenable: vehicleController.filterState,
                builder: (context, filter, _) {
                  return VehicleCategoryBar(
                    selectedCategory: filter.vehicleType,
                    onCategorySelected: (cat) => vehicleController.updateCategoryFilter(cat),
                  );
                },
              ),

              // Main Content Area (Wide: side-by-side; Narrow: single column)
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isWide)
                      SizedBox(
                        width: 320,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.charcoalGrey : AppColors.lightSurface,
                            border: Border(
                              right: BorderSide(
                                color: isDark ? AppColors.steelBorderGrey : AppColors.lightBorder,
                                width: 0.8,
                              ),
                            ),
                          ),
                          child: VehicleFilterPanel(controller: vehicleController),
                        ),
                      ),

                    // Vehicle Cards Grid / List
                    Expanded(
                      child: AnimatedBuilder(
                        animation: vehicleController,
                        builder: (context, _) {
                          final list = vehicleController.filteredVehicles;

                          if (list.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.search_off, size: 54, color: AppColors.mutedGreyText),
                                  const SizedBox(height: AppSpacing.md),
                                  const Text(
                                    'Kriterlerinize uygun araç bulunamadı.',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  OutlinedButton(
                                    onPressed: () => vehicleController.resetFilters(),
                                    child: const Text('Filtreleri Sıfırla'),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: AppSpacing.screenPadding,
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              final vehicle = list[index];
                              return VehicleCard(
                                vehicle: vehicle,
                                currentUser: currentUser,
                                onDetailsTap: () => _openDetails(context, vehicle),
                                onRentTap: () => _openRentDialog(context, vehicle),
                                onTrackTap: () => _trackVehicle(vehicle),
                                onChatTap: () => _openChat(context, vehicle),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
