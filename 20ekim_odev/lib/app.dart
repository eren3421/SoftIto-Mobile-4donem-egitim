import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/views/auth_portal_screen.dart';
import 'features/home/views/main_shell_screen.dart';
import 'features/messaging/controllers/messaging_controller.dart';
import 'features/reservations/controllers/reservation_controller.dart';
import 'features/tracking/controllers/tracking_controller.dart';
import 'features/vehicles/controllers/vehicle_controller.dart';

class MultiModalRentalApp extends StatelessWidget {
  const MultiModalRentalApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = ThemeController.instance;
    final authController = AuthController.instance;
    final vehicleController = VehicleController.instance;
    final trackingController = TrackingController.instance;
    final reservationController = ReservationController.instance;
    final messagingController = MessagingController.instance;

    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'Çok Modlu Araç Kiralama Sistemi',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          home: AnimatedBuilder(
            animation: authController,
            builder: (context, _) {
              final user = authController.currentUser.value;
              if (user == null) {
                return AuthPortalScreen(
                  authController: authController,
                  onLoginSuccess: () {},
                );
              }

              return MainShellScreen(
                authController: authController,
                themeController: themeController,
                vehicleController: vehicleController,
                trackingController: trackingController,
                reservationController: reservationController,
                messagingController: messagingController,
                onLogout: () {},
              );
            },
          ),
        );
      },
    );
  }
}
