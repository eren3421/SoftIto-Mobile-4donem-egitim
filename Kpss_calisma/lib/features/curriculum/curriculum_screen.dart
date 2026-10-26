// Flutter Material Design bileşenlerini içe aktarıyoruz
import 'package:flutter/material.dart';
// Durum yönetimi için Provider paketini içe aktarıyoruz
import 'package:provider/provider.dart';
// Uygulama renk paletini içe aktarıyoruz
import '../../core/constants/app_colors.dart';
// Konu durum sabitlerini (Bitirildi, Tekrar, Çalışılmadı) içe aktarıyoruz
import '../../core/constants/app_constants.dart';
// Ders ve Konu modellerini içe aktarıyoruz
import '../../models/topic.dart';
// Müfredat durum sağlayıcısını içe aktarıyoruz
import '../../providers/curriculum_provider.dart';
// Konu liste kartı bileşenini içe aktarıyoruz
import 'widgets/topic_item_tile.dart';

// KPSS ders müfredatını, sekmeli (TabBar) ders görünümünü ve filtrelemeyi sunan ekran
class CurriculumScreen extends StatefulWidget {
  // CurriculumScreen kurucu fonksiyonu
  const CurriculumScreen({super.key});

  @override
  State<CurriculumScreen> createState() => _CurriculumScreenState();
}

// Sekme animasyonlarını yönetmek için SingleTickerProviderStateMixin ekliyoruz
class _CurriculumScreenState extends State<CurriculumScreen> with SingleTickerProviderStateMixin {
  // Dersler arası yatay geçişi yöneten TabController nesnesi
  late TabController _tabController;

  // Seçili durum filtresi (-1: Tümü, 0: Çalışılmadı, 1: Tekrar Edilecek, 2: Bitirdim)
  int _selectedFilter = -1;

  @override
  void initState() {
    super.initState();
    // CurriculumProvider'daki mevcut ders listesini okuyoruz
    final courses = context.read<CurriculumProvider>().courses;
    // Ders sayısına göre sekmeleri yöneten kontrolcüyü başlatıyoruz
    _tabController = TabController(length: courses.isEmpty ? 5 : courses.length, vsync: this);
  }

  @override
  void dispose() {
    // Bellek sızıntısını önlemek için kontrolcüyü bellekten temizliyoruz
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // CurriculumProvider'daki değişiklikleri dinliyoruz
    final curriculumProv = context.watch<CurriculumProvider>();
    final courses = curriculumProv.courses;

    // Müfredat verisi henüz yükleniyorsa veya boşsa dönen yükleme göstergesi (loader) göster
    if (curriculumProv.isLoading || courses.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Ders sayısı değişmişse TabController uzunluğunu güvenli şekilde yeniliyoruz
    if (_tabController.length != courses.length) {
      _tabController.dispose();
      _tabController = TabController(length: courses.length, vsync: this);
    }

    return Scaffold(
      appBar: AppBar(
        // Ekran başlığı
        title: const Text('Müfredat ve Konular'),
        // Dersler için yatay kaydırılabilir sekme çubuğu (TabBar)
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true, // Çok sayıda ders olduğu için yatay kaydırma açık
          tabAlignment: TabAlignment.start,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelPadding: const EdgeInsets.symmetric(horizontal: 16),
          // Her ders için renkli nokta ve ders adından oluşan bir sekme oluşturuyoruz
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
      // Seçilen derse göre alt konu listesini gösteren görünüm
      body: TabBarView(
        controller: _tabController,
        children: courses.map((course) {
          return _buildCourseContent(context, course, curriculumProv);
        }).toList(),
      ),
    );
  }

  // Belirli bir dersin ilerleme kartını, filtre butonlarını ve konu listesini oluşturan metot
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

    // Seçili filtreye göre konuları filtreliyoruz
    final filteredTopics = course.topics.where((t) {
      if (_selectedFilter == -1) return true; // Tümü seçiliyse hepsini göster
      final status = prov.getTopicStatus(t.id);
      return status == _selectedFilter;
    }).toList();

    return Column(
      children: [
        // Ders Özeti ve İlerleme Yüzdesi Kartı
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
              // Kategori ve tamamlanma yüzdesi metinleri
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
              // Çizgisel ilerleme çubuğu (LinearProgressIndicator)
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
              // Biten ve kalan konu sayısı açıklaması
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

        // Konu Durum Filtre Butonları (Filter Chips)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Tüm konuları göster butonu
              _buildFilterChip(-1, 'Tümü (${course.topics.length})'),
              const SizedBox(width: 8),
              // Sadece biten konuları göster butonu
              _buildFilterChip(
                AppConstants.statusCompleted,
                'Bitirdim ($completedCount)',
                color: AppColors.completed,
              ),
              const SizedBox(width: 8),
              // Sadece tekrar edilecek konuları göster butonu
              _buildFilterChip(
                AppConstants.statusNeedsReview,
                'Tekrar Edilecek (${course.topics.where((t) => prov.getTopicStatus(t.id) == AppConstants.statusNeedsReview).length})',
                color: AppColors.needsReview,
              ),
              const SizedBox(width: 8),
              // Henüz başlanmayan konuları göster butonu
              _buildFilterChip(
                AppConstants.statusNotStarted,
                'Çalışılmadı (${course.topics.where((t) => prov.getTopicStatus(t.id) == AppConstants.statusNotStarted).length})',
                color: AppColors.notStarted,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Filtrelenmiş Konuların Listesi
        Expanded(
          child: filteredTopics.isEmpty
              // Filtreye uygun konu yoksa boş durum uyarısı göster
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
              // Konuları dikey liste olarak render et
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
                      // Kullanıcı konunun durumunu değiştirdiğinde veritabanına kaydet
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

  // Durum filtreleme çipi (ChoiceChip) oluşturan yardımcı metot
  Widget _buildFilterChip(int value, String label, {Color? color}) {
    final isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      // Seçildiğinde filtre durumunu günceller
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? value : -1;
        });
      },
      // Seçili arka plan rengi
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
