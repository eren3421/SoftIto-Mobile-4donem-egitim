// Flutter Material Design bileşenlerini içe aktarıyoruz
import 'package:flutter/material.dart';
// Sayısal metin girişlerini filtrelemek için Services kütüphanesini içe aktarıyoruz
import 'package:flutter/services.dart';
// Durum yönetimi için Provider paketini içe aktarıyoruz
import 'package:provider/provider.dart';
// Renk paleti sabitlerini içe aktarıyoruz
import '../../../core/constants/app_colors.dart';
// Tarih formatlama yardımcı sınıfını içe aktarıyoruz
import '../../../core/utils/date_utils.dart';
// KPSS 4 yanlış 1 doğru kuralı net hesaplayıcısını içe aktarıyoruz
import '../../../core/utils/kpss_calculator.dart';
// Ders listesini okumak için CurriculumProvider'ı içe aktarıyoruz
import '../../../providers/curriculum_provider.dart';
// Soru kaydını eklemek için QuestionProvider'ı içe aktarıyoruz
import '../../../providers/question_provider.dart';

// Kullanıcının çözdüğü soru sayılarını (Doğru, Yanlış, Boş) girmesini sağlayan modal alt pencere (BottomSheet)
class AddQuestionSheet extends StatefulWidget {
  // AddQuestionSheet kurucu fonksiyonu
  const AddQuestionSheet({super.key});

  // Bu modal sayfayı alttan yukarı doğru açan statik yardımcı metot
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Klavyenin içeriği kapatmasını önlemek için tam kaydırma modu
      backgroundColor: Colors.transparent, // Köşe yuvarlaklıklarının görünmesi için şeffaf zemin
      builder: (context) => const AddQuestionSheet(),
    );
  }

  @override
  State<AddQuestionSheet> createState() => _AddQuestionSheetState();
}

// AddQuestionSheet'in durum yönetim ve form mantığı sınıfı
class _AddQuestionSheetState extends State<AddQuestionSheet> {
  // Seçilen dersin kimliği (Örn: 'turkce')
  String? _selectedCourseId;

  // Doğru sayısı metin kontrolcüsü
  final _correctController = TextEditingController();

  // Yanlış sayısı metin kontrolcüsü
  final _wrongController = TextEditingController();

  // Boş sayısı metin kontrolcüsü
  final _emptyController = TextEditingController();

  // Not veya konu adı metin kontrolcüsü
  final _noteController = TextEditingController();

  // Soruların çözüldüğü tarih (Varsayılan: Bugün)
  DateTime _selectedDate = DateTime.now();

  // Kullanıcı sayı girdikçe anlık olarak hesaplanan net puan
  double _calculatedNet = 0.0;

  // Anlık toplam soru sayısı (D + Y + B)
  int _totalQuestions = 0;

  @override
  void initState() {
    super.initState();
    // İlk açılışta dersler listesinden ilk dersi varsayılan olarak seçiyoruz
    final courses = context.read<CurriculumProvider>().courses;
    if (courses.isNotEmpty) {
      _selectedCourseId = courses.first.id;
    }
    // Kullanıcı giriş yaptıkça net puanın anında yeniden hesaplanması için dinleyiciler ekliyoruz
    _correctController.addListener(_recalculate);
    _wrongController.addListener(_recalculate);
    _emptyController.addListener(_recalculate);
  }

  // Doğru, yanlış ve boş kutularındaki değerleri toplayıp anlık neti hesaplayan metot
  void _recalculate() {
    final d = int.tryParse(_correctController.text) ?? 0;
    final y = int.tryParse(_wrongController.text) ?? 0;
    final b = int.tryParse(_emptyController.text) ?? 0;
    setState(() {
      _totalQuestions = d + y + b;
      _calculatedNet = KpssCalculator.calculateNet(d, y);
    });
  }

  @override
  void dispose() {
    // Bellek sızıntılarını önlemek için tüm kontrolcüleri serbest bırakıyoruz
    _correctController.dispose();
    _wrongController.dispose();
    _emptyController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final courses = context.watch<CurriculumProvider>().courses;
    // Klavye açıldığında formun yukarı ötelenmesini sağlayan alt boşluk (insets)
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sayfanın en üstündeki küçük gri tutamaç çizgisi
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Başlık ve Kapatma Çarpı Butonu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Soru Girişi Ekle',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Ders Seçimi Başlığı ve Yatay Ders Çipleri (ChoiceChips)
            const Text(
              'Ders Seçimi',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: courses.map((course) {
                  final isSelected = _selectedCourseId == course.id;
                  final color = AppColors.getCourseColor(course.id);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      selected: isSelected,
                      label: Text(course.title),
                      selectedColor: color.withValues(alpha: 0.2),
                      side: BorderSide(
                        color: isSelected ? color : Colors.transparent,
                        width: 1.5,
                      ),
                      labelStyle: TextStyle(
                        color: isSelected ? color : null,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      onSelected: (val) {
                        if (val) {
                          setState(() => _selectedCourseId = course.id);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Sayısal Giriş Alanları: Doğru, Yanlış, Boş
            Row(
              children: [
                Expanded(
                  child: _buildNumberInput(
                    controller: _correctController,
                    label: 'Doğru',
                    color: AppColors.correct,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNumberInput(
                    controller: _wrongController,
                    label: 'Yanlış',
                    color: AppColors.wrong,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNumberInput(
                    controller: _emptyController,
                    label: 'Boş',
                    color: AppColors.empty,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Anlık Hesaplanan Net Önizleme Kartı
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hesaplanan Net',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Toplam Soru: $_totalQuestions (4 Yanlış = 1 Doğru)',
                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                  // Anlık net değeri metni
                  Text(
                    _calculatedNet.toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tarih Seçici Satırı
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Tarih: ${AppDateUtils.formatDate(_selectedDate)}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const Spacer(),
                // Tarihi değiştirmek için takvim modalini açan buton
                TextButton(
                  onPressed: _pickDate,
                  child: const Text('Değiştir'),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // İsteğe Bağlı Not Giriş Kutusu
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: 'Not veya konu bilgisi (opsiyonel)',
                prefixIcon: Icon(Icons.note_alt_outlined, size: 20),
              ),
            ),
            const SizedBox(height: 24),

            // Kaydetme Butonu (En az 1 soru girildiğinde aktifleşir)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _totalQuestions > 0 ? _saveQuestionLog : null,
                child: const Text('Kaydı Ekle'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Doğru, Yanlış ve Boş sayı giriş kutularını oluşturan yardımcı metot
  Widget _buildNumberInput({
    required TextEditingController controller,
    required String label,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          // Sadece rakam girilmesine izin verir (harf veya sembol yazılamaz)
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            hintText: '0',
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // Tarih seçiciyi (DatePicker) açan asenkron fonksiyon
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // Form verilerini toplayıp veritabanına kaydeden fonksiyon
  void _saveQuestionLog() {
    if (_selectedCourseId == null) return;
    final d = int.tryParse(_correctController.text) ?? 0;
    final y = int.tryParse(_wrongController.text) ?? 0;
    final b = int.tryParse(_emptyController.text) ?? 0;

    // QuestionProvider üzerinden veritabanına yeni soru kaydı ekliyoruz
    context.read<QuestionProvider>().addQuestionLog(
          courseId: _selectedCourseId!,
          correct: d,
          wrong: y,
          empty: b,
          date: _selectedDate,
          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        );

    // Modal alt sayfayı kapatıyoruz
    Navigator.pop(context);

    // Kullanıcıya işlemin başarılı olduğuna dair bilgilendirme bildirimi (SnackBar) gösteriyoruz
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Soru kaydı başarıyla eklendi! Net: ${_calculatedNet.toStringAsFixed(2)}'),
        backgroundColor: AppColors.completed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
