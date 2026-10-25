import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/topic.dart';
import '../../providers/curriculum_provider.dart';
import 'widgets/topic_item_tile.dart';

class CurriculumScreen extends StatefulWidget {
  const CurriculumScreen({super.key});

  @override
  State<CurriculumScreen> createState() => _CurriculumScreenState();
}

class _CurriculumScreenState extends State<CurriculumScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedFilter = -1; // -1: Tümü, 0: Çalışılmadı, 1: Tekrar, 2: Bitirdim

  @override
  void initState() {
    super.initState();
    final courses = context.read<CurriculumProvider>().courses;
    _tabController = TabController(length: courses.isEmpty ? 5 : courses.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curriculumProv = context.watch<CurriculumProvider>();
    final courses = curriculumProv.courses;

    if (curriculumProv.isLoading || courses.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_tabController.length != courses.length) {
      _tabController.dispose();
      _tabController = TabController(length: courses.length, vsync: this);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Müfredat ve Konular'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelPadding: const EdgeInsets.symmetric(horizontal: 16),
          tabs: courses.map((course) {
            final color = AppColors.getCourseColor(course.id);
            return Tab(
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(course.title),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: courses.map((course) {
          return _buildCourseContent(context, course, curriculumProv);
        }).toList(),
      ),
    );
  }

  Widget _buildCourseContent(
    BuildContext context,
    Course course,
    CurriculumProvider prov,
  ) {
    final theme = Theme.of(context);
    final courseColor = AppColors.getCourseColor(course.id);
    final completedCount = prov.getCourseCompletedTopics(course.id);
    final totalCount = course.topics.length;
    final progress = prov.getCourseProgress(course.id);

    // Filter topics
    final filteredTopics = course.topics.where((t) {
      if (_selectedFilter == -1) return true;
      final status = prov.getTopicStatus(t.id);
      return status == _selectedFilter;
    }).toList();

    return Column(
      children: [
        // Course Header & Progress Bar
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${course.category} • ${course.questionCount} Soru',
                    style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '%${(progress * 100).toInt()} Tamamlandı',
                    style: TextStyle(
                      color: courseColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: courseColor.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(courseColor),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$completedCount / $totalCount konu bitti',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    '${totalCount - completedCount} konu kaldı',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildFilterChip(-1, 'Tümü (${course.topics.length})'),
              const SizedBox(width: 8),
              _buildFilterChip(
                AppConstants.statusCompleted,
                'Bitirdim ($completedCount)',
                color: AppColors.completed,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                AppConstants.statusNeedsReview,
                'Tekrar Edilecek (${course.topics.where((t) => prov.getTopicStatus(t.id) == AppConstants.statusNeedsReview).length})',
                color: AppColors.needsReview,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                AppConstants.statusNotStarted,
                'Çalışılmadı (${course.topics.where((t) => prov.getTopicStatus(t.id) == AppConstants.statusNotStarted).length})',
                color: AppColors.notStarted,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Topics List
        Expanded(
          child: filteredTopics.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.filter_list_off, size: 48, color: theme.disabledColor),
                      const SizedBox(height: 12),
                      Text(
                        'Bu filtrede konu bulunamadı',
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.disabledColor),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredTopics.length,
                  itemBuilder: (context, index) {
                    final topic = filteredTopics[index];
                    final status = prov.getTopicStatus(topic.id);
                    return TopicItemTile(
                      topic: topic,
                      status: status,
                      courseColor: courseColor,
                      onStatusChanged: (newStatus) {
                        prov.setTopicStatus(topic.id, newStatus);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(int value, String label, {Color? color}) {
    final isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? value : -1;
        });
      },
      selectedColor: (color ?? AppColors.primary).withValues(alpha: 0.2),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? (color ?? AppColors.primary) : null,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? (color ?? AppColors.primary) : Colors.transparent,
        ),
      ),
    );
  }
}
