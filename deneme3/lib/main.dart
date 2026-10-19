import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/cars.dart';
import 'screens/appointment_screen.dart';
import 'screens/cars_screen.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() => runApp(const ArabaGalerisiApp());

class ArabaGalerisiApp extends StatelessWidget {
  const ArabaGalerisiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vites Select | Araba Galerisi',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [Locale('tr', 'TR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const GalleryShell(),
    );
  }
}

class GalleryShell extends StatefulWidget {
  const GalleryShell({super.key});

  @override
  State<GalleryShell> createState() => _GalleryShellState();
}

class _GalleryShellState extends State<GalleryShell> {
  int _selectedIndex = 0;
  String? _selectedCarId;

  void _openAppointment([String? carId]) {
    setState(() {
      _selectedCarId = carId;
      _selectedIndex = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _BrandBar(onAppointmentTap: () => _openAppointment()),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: [
                      HomeScreen(
                        onBrowseTap: () => setState(() => _selectedIndex = 1),
                      ),
                      CarsScreen(onSchedule: _openAppointment),
                      AppointmentScreen(
                        key: ValueKey(_selectedCarId),
                        initialCarId: _selectedCarId,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(Icons.directions_car_filled_rounded),
            label: 'Araçlar',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Randevu',
          ),
        ],
      ),
    );
  }
}

class _BrandBar extends StatelessWidget {
  const _BrandBar({required this.onAppointmentTap});

  final VoidCallback onAppointmentTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1136),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.directions_car_filled_rounded,
                  color: Colors.white,
                  size: 23,
                ),
              ),
              const SizedBox(width: 11),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VİTES',
                    style: TextStyle(
                      fontSize: 17,
                      height: 1.05,
                      letterSpacing: 1.6,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'SELECT',
                    style: TextStyle(
                      fontSize: 9,
                      letterSpacing: 2.4,
                      fontWeight: FontWeight.w700,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: onAppointmentTap,
                icon: const Icon(Icons.calendar_month_outlined, size: 18),
                label: const Text('Test sürüşü'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.ink,
                  side: const BorderSide(color: AppColors.line),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
