import 'package:flutter/material.dart';
import '../../../core/theme/theme_controller.dart';
import '../../tablo/controllers/tablo_controller.dart';
import '../../tablo/views/tablo_view.dart';
import '../../notlar/controllers/notlar_controller.dart';
import '../../notlar/views/notlar_view.dart';
import '../../kisiler/controllers/kisiler_controller.dart';
import '../../kisiler/views/kisiler_view.dart';

/// Asistan uygulamasının ana kabuğu ve sekme yönlendiricisi.
class HomeView extends StatefulWidget {
  final ThemeController themeController;

  const HomeView({super.key, required this.themeController});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;
  late final TabloController _tabloController;
  late final NotlarController _notlarController;
  late final KisilerController _kisilerController;

  @override
  void initState() {
    super.initState();
    _tabloController = TabloController();
    _notlarController = NotlarController();
    _kisilerController = KisilerController();
  }

  @override
  void dispose() {
    _tabloController.dispose();
    _notlarController.dispose();
    _kisilerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          TabloView(controller: _tabloController),
          NotlarView(controller: _notlarController),
          KisilerView(controller: _kisilerController),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final titles = ['Finans & Kaynak Tablosu', 'Defterim & Raporlar', 'Paydaşlar & Takvim'];
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Asistan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          Text(titles[_currentIndex], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Tema Değiştir (Defter / Gece Deri)',
          icon: Icon(
            widget.themeController.isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_round_outlined,
          ),
          onPressed: widget.themeController.toggleTheme,
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) => setState(() => _currentIndex = index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.table_chart_outlined),
          selectedIcon: Icon(Icons.table_chart),
          label: 'Tablo & Bütçe',
        ),
        NavigationDestination(
          icon: Icon(Icons.auto_stories_outlined),
          selectedIcon: Icon(Icons.auto_stories),
          label: 'Notlar',
        ),
        NavigationDestination(
          icon: Icon(Icons.groups_outlined),
          selectedIcon: Icon(Icons.groups),
          label: 'Kişiler & Takvim',
        ),
      ],
    );
  }
}
