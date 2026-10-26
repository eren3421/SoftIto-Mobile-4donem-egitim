// Flutter Material Design arayüz kütüphanesini içe aktarıyoruz
import 'package:flutter/material.dart';
// Durum yönetimi için Provider paketini içe aktarıyoruz
import 'package:provider/provider.dart';
// Renk paleti sabitlerini içe aktarıyoruz
import '../../../core/constants/app_colors.dart';
// Çalışma süresi formatlama yardımcı sınıfını içe aktarıyoruz
import '../../../core/utils/date_utils.dart';
// Ders listesini okumak için CurriculumProvider'ı içe aktarıyoruz
import '../../../providers/curriculum_provider.dart';
// Çalışma oturumunu kaydetmek için QuestionProvider'ı içe aktarıyoruz
import '../../../providers/question_provider.dart';

// Pomodoro veya kronometre süresi tamamlandığında çalışılan dersi seçip süreyi kaydetmeyi sağlayan diyalog penceresi
class SaveSessionDialog extends StatefulWidget {
  // Tamamlanan çalışma süresi (dakika)
  final int durationMinutes;

  // Oturum türü ('pomodoro' veya 'stopwatch')
  final String sessionType;

  // SaveSessionDialog kurucu fonksiyonu
  const SaveSessionDialog({
    super.key,
    required this.durationMinutes,
    required this.sessionType,
  });

  // Diyaloğu ekranda gösteren statik yardımcı fonksiyon
  static Future<void> show(
    BuildContext context, {
    required int durationMinutes,
    required String sessionType,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false, // Kullanıcı dışarı tıklayarak yanlışlıkla kapatmasın
      builder: (context) => SaveSessionDialog(
        durationMinutes: durationMinutes,
        sessionType: sessionType,
      ),
    );
  }

  @override
  State<SaveSessionDialog> createState() => _SaveSessionDialogState();
}

// Diyaloğun durum ve form mantığı sınıfı
class _SaveSessionDialogState extends State<SaveSessionDialog> {
  // Seçilen dersin kimliği
  String? _selectedCourseId;

  // İsteğe bağlı oturum notu metin kontrolcüsü
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // İlk açılışta mevcut ders listesinden ilkini varsayılan olarak seçiyoruz
    final courses = context.read<CurriculumProvider>().courses;
    if (courses.isNotEmpty) {
      _selectedCourseId = courses.first.id;
    }
  }

  @override
  void dispose() {
    // Kontrolcüyü bellekten serbest bırakıyoruz
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ders listesini Provider üzerinden izliyoruz
    final courses = context.watch<CurriculumProvider>().courses;

    return AlertDialog(
      // Köşeleri yuvarlatılmış modern diyalog penceresi
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      // Diyalog Başlık Alanı
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.check_circle, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Oturumu Kaydet',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ),
        ],
      ),
      // Diyalog İçerik Alanı
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tamamlanan süreyi vurgulayan bilgi kutusu
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer, color: AppColors.secondary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Tamamlanan Süre: ${AppDateUtils.formatDuration(widget.durationMinutes)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Ders seçimi başlığı
            const Text(
              'Hangi derse çalıştın?',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            // Dersleri yan yana sığacak şekilde dizen Wrap bileşeni
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: courses.map((c) {
                final isSelected = _selectedCourseId == c.id;
                final color = AppColors.getCourseColor(c.id);
                return ChoiceChip(
                  selected: isSelected,
                  label: Text(c.title),
                  selectedColor: color.withValues(alpha: 0.2),
                  side: BorderSide(color: isSelected ? color : Colors.transparent),
                  labelStyle: TextStyle(
                    color: isSelected ? color : null,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _selectedCourseId = c.id);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // İsteğe bağlı not giriş kutusu
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: 'Oturum notu (opsiyonel)',
                prefixIcon: Icon(Icons.edit_note, size: 20),
              ),
            ),
          ],
        ),
      ),
      // Diyalog Aksiyon Butonları (İptal ve Kaydet)
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _saveSession,
          child: const Text('Kaydet'),
        ),
      ],
    );
  }

  // Çalışma oturumunu veritabanına ekleyen fonksiyon
  void _saveSession() {
    if (_selectedCourseId == null) return;
    // QuestionProvider üzerinden çalışma oturumunu kalıcı olarak ekliyoruz
    context.read<QuestionProvider>().addStudySession(
          courseId: _selectedCourseId!,
          durationInMinutes: widget.durationMinutes,
          date: DateTime.now(),
          type: widget.sessionType,
          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        );

    // Diyaloğu kapatıyoruz
    Navigator.pop(context);

    // Başarılı kaydı bildiren yeşil SnackBar gösteriyoruz
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Çalışma süresi başarıyla kaydedildi!'),
        backgroundColor: AppColors.completed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
