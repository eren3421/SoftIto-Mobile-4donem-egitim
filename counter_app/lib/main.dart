import 'package:flutter/material.dart';
import 'screens/classic_counter_screen.dart';
import 'screens/dual_counter_screen.dart';

void main() {
  runApp(const CounterApp());
}

class CounterApp extends StatefulWidget {
  const CounterApp({super.key});

  @override
  State<CounterApp> createState() => _CounterAppState();
}

class _CounterAppState extends State<CounterApp> {
  // Tema modu kontrolü (Material 3 Açık / Koyu Tema)
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Sayaç Uygulaması',
      debugShowCheckedModeBanner: false,
      // Material 3 Açık Tema
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      // Material 3 Koyu Tema
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      themeMode: _themeMode,
      home: MainNavigationScreen(
        onToggleTheme: _toggleTheme,
        currentThemeMode: _themeMode,
      ),
    );
  }
}

/// Ana Navigasyon Ekranı (Material 3 NavigationBar)
/// İki farklı sayaç ekranı arasında geçiş sağlar.
class MainNavigationScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode currentThemeMode;

  const MainNavigationScreen({
    super.key,
    required this.onToggleTheme,
    required this.currentThemeMode,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // 2 Farklı Sayaç Ekranı
  final List<Widget> _screens = const [
    ClassicCounterScreen(),
    DualCounterScreen(),
  ];

  final List<String> _titles = const [
    '1. Ekran: Kademeli Sayaç',
    '2. Ekran: Çift Sayaç',
  ];

  void _showInternInfoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.school, size: 36),
          title: const Text('Flutter Stajyer Notu 🚀'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Bu proje Material 3 standartlarında ve iki farklı sayaç modu içerecek şekilde geliştirilmiştir:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text('• 1. Ekran: Tek sayaç üzerinde +1 ve +5 olmak üzere iki farklı ekleme butonu.'),
                SizedBox(height: 8),
                Text('• 2. Ekran: İki bağımsız sayaç (A ve B) ve toplam skor takibi.'),
                SizedBox(height: 12),
                Text(
                  'State & Lifecycle Mimarisi:\n'
                  '- StatefulWidget: Immutable yapıdadır.\n'
                  '- State: Mutable omurgadır, rebuild sırasında durumu saklar.\n'
                  '- setState(): UI güncellemesini tetikler ve Element Tree koordinasyonu sağlar.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anladım'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.currentThemeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          // Bilgi Dialog Butonu
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Hakkında & Stajyer Notları',
            onPressed: _showInternInfoDialog,
          ),
          // Tema Değiştirme Butonu (Light / Dark)
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Temayı Değiştir',
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      // Seçili ekrana göre gövde değişir
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _screens[_selectedIndex],
      ),
      // Material 3 NavigationBar
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.exposure_plus_1_outlined),
            selectedIcon: Icon(Icons.exposure_plus_1),
            label: 'Kademeli Sayaç',
          ),
          NavigationDestination(
            icon: Icon(Icons.compare_arrows_outlined),
            selectedIcon: Icon(Icons.compare_arrows),
            label: 'Çift Sayaç',
          ),
        ],
      ),
    );
  }
}
