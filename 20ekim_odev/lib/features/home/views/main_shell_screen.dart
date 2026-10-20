import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/views/profile_screen.dart';
import '../../messaging/controllers/messaging_controller.dart';
import '../../messaging/views/chat_list_screen.dart';
import '../../reservations/controllers/reservation_controller.dart';
import '../../reservations/views/reservation_panel_screen.dart';
import '../../tracking/controllers/tracking_controller.dart';
import '../../tracking/views/realtime_tracking_screen.dart';
import '../../vehicles/controllers/vehicle_controller.dart';
import '../../vehicles/views/vehicle_discovery_screen.dart';

class MainShellScreen extends StatefulWidget {
  final AuthController authController;
  final ThemeController themeController;
  final VehicleController vehicleController;
  final TrackingController trackingController;
  final ReservationController reservationController;
  final MessagingController messagingController;
  final VoidCallback onLogout;

  const MainShellScreen({
    super.key,
    required this.authController,
    required this.themeController,
    required this.vehicleController,
    required this.trackingController,
    required this.reservationController,
    required this.messagingController,
    required this.onLogout,
  });

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = widget.authController.currentUser.value;

    final screens = [
      VehicleDiscoveryScreen(
        currentUser: currentUser,
        vehicleController: widget.vehicleController,
        trackingController: widget.trackingController,
        reservationController: widget.reservationController,
        messagingController: widget.messagingController,
        onNavigateTab: _onTabChanged,
      ),
      ReservationPanelScreen(
        currentUser: currentUser,
        reservationController: widget.reservationController,
        trackingController: widget.trackingController,
        messagingController: widget.messagingController,
        vehicleController: widget.vehicleController,
        onNavigateTab: _onTabChanged,
      ),
      RealtimeTrackingScreen(
        currentUser: currentUser,
        trackingController: widget.trackingController,
        vehicleController: widget.vehicleController,
        messagingController: widget.messagingController,
      ),
      ChatListScreen(
        currentUser: currentUser,
        messagingController: widget.messagingController,
        vehicleController: widget.vehicleController,
      ),
      ProfileScreen(
        authController: widget.authController,
        themeController: widget.themeController,
        vehicleController: widget.vehicleController,
        onLogout: widget.onLogout,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;

        if (isDesktop) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: _onTabChanged,
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: AppColors.charcoalGrey,
                  indicatorColor: AppColors.crimsonPrimary,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.crimsonPrimary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.hub, color: Colors.white, size: 24),
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.explore_outlined),
                      selectedIcon: Icon(Icons.explore),
                      label: Text('Keşfet'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.calendar_month_outlined),
                      selectedIcon: Icon(Icons.calendar_month),
                      label: Text('Rezervasyon'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.radar_outlined),
                      selectedIcon: Icon(Icons.radar),
                      label: Text('Canlı Takip'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.chat_bubble_outline),
                      selectedIcon: Icon(Icons.chat_bubble),
                      label: Text('Mesajlar'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: Text('Profil'),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: screens[_currentIndex]),
              ],
            ),
          );
        }

        // Mobile layout with Material 3 NavigationBar
        return Scaffold(
          body: screens[_currentIndex],
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _onTabChanged,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore),
                label: 'Keşfet',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month),
                label: 'Rezervasyon',
              ),
              NavigationDestination(
                icon: Icon(Icons.radar_outlined),
                selectedIcon: Icon(Icons.radar),
                label: 'Canlı Takip',
              ),
              NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline),
                selectedIcon: Icon(Icons.chat_bubble),
                label: 'Mesajlar',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        );
      },
    );
  }
}
