import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../auth/domain/models/app_user.dart';
import '../../messaging/controllers/messaging_controller.dart';
import '../../messaging/views/chat_conversation_screen.dart';
import '../../tracking/controllers/tracking_controller.dart';
import '../../vehicles/controllers/vehicle_controller.dart';
import '../controllers/reservation_controller.dart';
import '../domain/models/reservation_status.dart';
import '../widgets/reservation_triad_card.dart';

class ReservationPanelScreen extends StatefulWidget {
  final AppUser? currentUser;
  final ReservationController reservationController;
  final TrackingController trackingController;
  final MessagingController messagingController;
  final VehicleController vehicleController;
  final void Function(int tabIndex)? onNavigateTab;

  const ReservationPanelScreen({
    super.key,
    required this.currentUser,
    required this.reservationController,
    required this.trackingController,
    required this.messagingController,
    required this.vehicleController,
    this.onNavigateTab,
  });

  @override
  State<ReservationPanelScreen> createState() => _ReservationPanelScreenState();
}

class _ReservationPanelScreenState extends State<ReservationPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Üç Taraflı Rezervasyon Paneli', style: TextStyle(fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.crimsonPrimary,
          labelColor: AppColors.crimsonLight,
          unselectedLabelColor: AppColors.silverText,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Tümü'),
            Tab(text: 'Onay Bekleyenler'),
            Tab(text: 'Aktif Kiralar'),
            Tab(text: 'Geçmiş / İptal'),
          ],
        ),
      ),
      body: AnimatedBuilder(
        animation: widget.reservationController,
        builder: (context, _) {
          final userReservations = widget.reservationController.getReservationsForUser(widget.currentUser);

          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(userReservations),
              _buildList(userReservations.where((r) => r.status == ReservationStatus.pending).toList()),
              _buildList(userReservations.where((r) => r.status == ReservationStatus.active).toList()),
              _buildList(userReservations.where((r) => r.status == ReservationStatus.completed || r.status == ReservationStatus.cancelled).toList()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(List userReservations) {
    if (userReservations.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today, size: 48, color: AppColors.mutedGreyText),
              SizedBox(height: AppSpacing.md),
              Text(
                'Bu filtrede rezervasyon kaydı bulunamadı.',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: AppSpacing.screenPadding,
      itemCount: userReservations.length,
      itemBuilder: (context, index) {
        final res = userReservations[index];
        return ReservationTriadCard(
          reservation: res,
          currentUser: widget.currentUser,
          onApprove: () => _confirmAction(
            title: 'Rezervasyonu Onayla',
            message: '${res.renterFullName} adlı kullanıcının ${res.vehicleSummary} kiralama talebini onaylamak istiyor musunuz?',
            onConfirm: () => widget.reservationController.updateStatus(res.id, ReservationStatus.approved),
          ),
          onReject: () => _confirmAction(
            title: 'Rezervasyonu Reddet / İptal Et',
            message: 'Bu rezervasyon talebini iptal etmek istediğinize emin misiniz?',
            isDestructive: true,
            onConfirm: () => widget.reservationController.updateStatus(res.id, ReservationStatus.cancelled),
          ),
          onStartRental: () => _confirmAction(
            title: 'Aracı Teslim Et (Kirayı Başlat)',
            message: 'Araç teslim edildi olarak işaretlenecek ve canlı takip panelinde aktif kiralama başlayacaktır.',
            onConfirm: () => widget.reservationController.updateStatus(res.id, ReservationStatus.active),
          ),
          onCompleteRental: () => _confirmAction(
            title: 'Aracı Teslim Al (Kiralama Tamamlandı)',
            message: 'Araç teslim alındı olarak envantere geri dönecek ve rezervasyon tamamlanacaktır.',
            onConfirm: () => widget.reservationController.updateStatus(res.id, ReservationStatus.completed),
          ),
          onTrack: () {
            widget.trackingController.selectTrackingNumber(res.trackingNumber);
            widget.onNavigateTab?.call(2); // Jump to tracking tab (index 2)
          },
          onChat: () {
            final vehicle = widget.vehicleController.getVehicleById(res.vehicleId);
            if (vehicle != null && widget.currentUser != null) {
              final room = widget.messagingController.getOrCreateRoom(
                vehicle: vehicle,
                currentUser: widget.currentUser!,
                reservationId: res.id,
              );
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChatConversationScreen(
                    room: room,
                    currentUser: widget.currentUser!,
                    messagingController: widget.messagingController,
                    vehicleController: widget.vehicleController,
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

  void _confirmAction({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    bool isDestructive = false,
  }) {
    ConfirmationDialog.show(
      context,
      title: title,
      message: message,
      isDestructive: isDestructive,
    ).then((confirmed) {
      if (confirmed == true) {
        onConfirm();
      }
    });
  }
}
