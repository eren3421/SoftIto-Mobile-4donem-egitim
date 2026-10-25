import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'features/curriculum/curriculum_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/mock_exams/mock_exams_screen.dart';
import 'features/question_tracker/widgets/add_question_sheet.dart';
import 'features/statistics/statistics_screen.dart';
import 'features/timer/timer_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardScreen(
            onNavigateToCurriculum: () => _onTabSelected(1),
            onNavigateToTimer: () => _onTabSelected(2),
            onOpenAddQuestion: () => AddQuestionSheet.show(context),
            onOpenMockExams: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MockExamsScreen()),
            ),
          ),
          const CurriculumScreen(),
          const TimerScreen(),
          const StatisticsScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddQuestionSheet.show(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        tooltip: 'Soru Ekle',
        child: const Icon(Icons.add, size: 28),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Konular',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: 'Sayaç',
          ),
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
