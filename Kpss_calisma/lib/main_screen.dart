// Flutter'ın temel Material Design arayüz kütüphanesini içe aktarıyoruz
import 'package:flutter/material.dart';
// Uygulama renk paletini içe aktarıyoruz
import 'core/constants/app_colors.dart';
// Müfredat ve konular ekranını içe aktarıyoruz
import 'features/curriculum/curriculum_screen.dart';
// Ana kontrol paneli (Dashboard) ekranını içe aktarıyoruz
import 'features/dashboard/dashboard_screen.dart';
// Deneme sınavları takip ekranını içe aktarıyoruz
import 'features/mock_exams/mock_exams_screen.dart';
// Hızlı soru ekleme açılır alt sayfasını (Bottom Sheet) içe aktarıyoruz
import 'features/question_tracker/widgets/add_question_sheet.dart';
// Grafikler ve istatistik ekranını içe aktarıyoruz
import 'features/statistics/statistics_screen.dart';
// Pomodoro ve çalışma sayacı ekranını içe aktarıyoruz
import 'features/timer/timer_screen.dart';

// Alt gezinti çubuğunu (BottomNavigationBar) ve ana ekranları yöneten durumlu (Stateful) ana ekran widget'ı
class MainScreen extends StatefulWidget {
  // MainScreen kurucu fonksiyonu
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

// MainScreen'in durum (State) mantığını içeren sınıf
class _MainScreenState extends State<MainScreen> {
  // Şu anda aktif olan alt sekmenin dizin (index) numarası (0: Dashboard, 1: Müfredat, 2: Sayaç, 3: İstatistik)
  int _currentIndex = 0;

  // Kullanıcı alt çubuktan yeni bir sekmeye tıkladığında çalışan fonksiyon
  void _onTabSelected(int index) {
    // Ekran durumunu güncelleyip seçili sekmenin arayüzünü açıyoruz
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sayfanın genel iskeletini (Scaffold) oluşturuyoruz
    return Scaffold(
      // Ekranlar arasında geçiş yaparken durumların (state) ve kaydırma konumlarının kaybolmaması için IndexedStack kullanıyoruz
      body: IndexedStack(
        // Görüntülenecek aktif ekranın dizin numarası
        index: _currentIndex,
        children: [
          // 0. Sekme: Ana Kontrol Paneli (Dashboard)
          DashboardScreen(
            // Konular sekmesine yönlendirme geri çağrımı (callback)
            onNavigateToCurriculum: () => _onTabSelected(1),
            // Sayaç sekmesine yönlendirme geri çağrımı
            onNavigateToTimer: () => _onTabSelected(2),
            // Hızlı soru ekleme penceresini açma geri çağrımı
            onOpenAddQuestion: () => AddQuestionSheet.show(context),
            // Deneme sınavları ekranına tam sayfa geçiş (Navigation)
            onOpenMockExams: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MockExamsScreen()),
            ),
          ),
          // 1. Sekme: KPSS Müfredatı ve Konu Takibi
          const CurriculumScreen(),
          // 2. Sekme: Pomodoro ve Çalışma Kronometresi
          const TimerScreen(),
          // 3. Sekme: İstatistikler ve fl_chart Grafikleri
          const StatisticsScreen(),
        ],
      ),
      // Sayfanın sağ alt köşesindeki hızlı işlem butonu (Floating Action Button)
      floatingActionButton: FloatingActionButton(
        // Butona tıklandığında soru ekleme modal sayfasını açar
        onPressed: () => AddQuestionSheet.show(context),
        // Buton arka plan rengi
        backgroundColor: AppColors.primary,
        // İkon rengi
        foregroundColor: Colors.white,
        // Uzun basıldığında görünen açıklama ipucu
        tooltip: 'Soru Ekle',
        // Artı (+) simgesi
        child: const Icon(Icons.add, size: 28),
      ),
      // Material 3 standart alt gezinti çubuğu (NavigationBar)
      bottomNavigationBar: NavigationBar(
        // Seçili sekmenin dizin numarası
        selectedIndex: _currentIndex,
        // Sekme tıklandığında dizini güncelleyen fonksiyon
        onDestinationSelected: _onTabSelected,
        // Alt çubuktaki 4 ana sekme hedefi
        destinations: const [
          // Ana Sayfa sekmesi
          NavigationDestination(
            icon: Icon(Icons.home_outlined), // Pasif ikon
            selectedIcon: Icon(Icons.home), // Seçili aktif ikon
            label: 'Ana Sayfa', // Sekme başlığı
          ),
          // Konular sekmesi
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Konular',
          ),
          // Sayaç sekmesi
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: 'Sayaç',
          ),
          // İstatistik sekmesi
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'İstatistik',
          ),
        ],
      ),
    );
  }
}
