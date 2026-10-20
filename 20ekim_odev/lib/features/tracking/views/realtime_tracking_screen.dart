import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../auth/domain/models/app_user.dart';
import '../../messaging/controllers/messaging_controller.dart';
import '../../messaging/views/chat_conversation_screen.dart';
import '../../vehicles/controllers/vehicle_controller.dart';
import '../controllers/tracking_controller.dart';
import '../widgets/telemetry_status_card.dart';
import '../widgets/tracking_map_view.dart';
import '../widgets/tracking_number_bar.dart';

class RealtimeTrackingScreen extends StatelessWidget {
  final AppUser? currentUser;
  final TrackingController trackingController;
  final VehicleController vehicleController;
  final MessagingController messagingController;

  const RealtimeTrackingScreen({
    super.key,
    required this.currentUser,
    required this.trackingController,
    required this.vehicleController,
    required this.messagingController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerçek Zamanlı Araç Takip Paneli', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Tracking Number Search & Quick Chips
            TrackingNumberBar(
              trackingController: trackingController,
              vehicleController: vehicleController,
              currentUser: currentUser,
            ),

            // Live Telemetry Stream / Map Canvas
            ValueListenableBuilder(
              valueListenable: trackingController.currentTelemetry,
              builder: (context, telemetry, _) {
                return Column(
                  children: [
                    TrackingMapView(telemetry: telemetry),
                    Padding(
                      padding: AppSpacing.screenPadding,
                      child: TelemetryStatusCard(
                        telemetry: telemetry,
                        controller: trackingController,
                        onOpenChat: () {
                          if (telemetry != null && currentUser != null) {
                            final vehicle = vehicleController.getVehicleByTrackingNumber(telemetry.trackingNumber);
                            if (vehicle != null) {
                              final room = messagingController.getOrCreateRoom(
                                vehicle: vehicle,
                                currentUser: currentUser!,
                                reservationId: telemetry.activeReservationId,
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
                          }
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
