import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_pink_button.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/habit_repository.dart';
import '../../data/repositories/note_repository.dart';
import '../../data/repositories/report_repository.dart';
import '../auth/login_screen.dart';

enum LegalTab { privacy, faq, contact, account }

class LegalAndAccountDialog extends ConsumerStatefulWidget {
  final LegalTab initialTab;

  const LegalAndAccountDialog({super.key, this.initialTab = LegalTab.privacy});

  static void show(BuildContext context, {LegalTab initialTab = LegalTab.privacy}) {
    showDialog(
      context: context,
      builder: (_) => LegalAndAccountDialog(initialTab: initialTab),
    );
  }

  @override
  ConsumerState<LegalAndAccountDialog> createState() =>
      _LegalAndAccountDialogState();
}

class _LegalAndAccountDialogState extends ConsumerState<LegalAndAccountDialog> {
  late LegalTab _currentTab;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  Future<void> _handleLogout() async {
    await ref.read(authRepositoryProvider).logout();
    ref.read(currentUserProvider.notifier).state = null;

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.danger),
            SizedBox(width: 8),
            Text('Hesabı Kalıcı Olarak Sil', style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: const Text(
          'Hesabınızı ve cihazınızdaki tüm alışkanlıkları, notları, AI sohbetlerini ve oluşturulan PDF raporlarını kalıcı olarak silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Vazgeç', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Evet, Hesabımı Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        await ref.read(authRepositoryProvider).deleteAccount(user.id);
        ref.read(currentUserProvider.notifier).state = null;
        ref.read(habitsListProvider.notifier).refresh();
        ref.read(allNotesProvider.notifier).refresh();
        ref.read(userReportsProvider.notifier).refresh();

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.borderHighlight, width: 1.5),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
        child: Column(
          children: [
            // Üst Başlık ve [X] Kapatma Butonu
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bilgi & Hesap Yönetimi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Tab Başlıkları
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  _buildTabButton('Gizlilik Politikası', LegalTab.privacy),
                  _buildTabButton('S.S.S.', LegalTab.faq),
                  _buildTabButton('İletişim', LegalTab.contact),
                  _buildTabButton('Hesap & Çıkış', LegalTab.account),
                ],
              ),
            ),
            const Divider(height: 1),

            // Tab İçeriği
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildTabContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, LegalTab tab) {
    final isSelected = _currentTab == tab;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : AppColors.softPink,
          ),
        ),
        selected: isSelected,
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onSelected: (_) => setState(() => _currentTab = tab),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_currentTab) {
      case LegalTab.privacy:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gizlilik Politikası',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'MENTOR uygulaması, kullanıcı gizliliğine en yüksek önceliği vermektedir. '
              'Tüm verileriniz (alışkanlıklarınız, günlük kayıtlarınız, kişisel notlarınız ve şifre özetleriniz) '
              'cihazınızın yerel depolama alanında (Hive NoSQL LocalStorage) güvenli bir şekilde saklanır.\n\n'
              '• Çevrimdışı Öncelik (Offline-First): Verileriniz izniniz olmadan harici üçüncü taraf sunuculara aktarılmaz.\n'
              '• AI Koçluğu: Yapay zeka mentorluk istekleri yalnızca anonimleştirilmiş alışkanlık bağlamı ile Hugging Face API uç noktasına şifreli HTTPS kanalıyla iletilir.\n'
              '• Hesap Silme Hakkı: Dilediğiniz an "Hesabı Sil" seçeneğini kullanarak tüm verilerinizi geri getirilemeyecek şekilde cihazınızdan silebilirsiniz.',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 13.5, height: 1.5),
            ),
          ],
        );

      case LegalTab.faq:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sıkça Sorulan Sorular (S.S.S.)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 14),
            _buildFaqItem(
              'Zincir (Streak) nasıl hesaplanır?',
              'Her gün tamamladığınız alışkanlıklar aralıksız bir seri oluşturur. Bugün veya dün tamamlanmışsa seriniz aktif kalır; aksi takdirde sıfırlanır.',
            ),
            _buildFaqItem(
              'Yapay Zeka Uzman Görüşü nasıl çalışır?',
              'Hugging Face Inference API üzerinden Mistral/Qwen modelleri kullanılarak haftalık ve aylık tamamlama yüzdeleriniz analiz edilir ve davranışsal psikoloji odaklı bir rapor üretilir.',
            ),
            _buildFaqItem(
              'PDF raporları nereye kaydedilir?',
              'Cihazınızın belgeler dizinindeki /mentor_reports/ klasörüne kaydedilir ve istediğiniz an uygulama içindeki PDF Arşivi üzerinden açılabilir.',
            ),
            _buildFaqItem(
              'Çift katmanlı not sistemi nedir?',
              'Detay sayfasında sadece o alışkanlığa özel notlar ekleyebilir, ana sayfada ise tüm alışkanlıklarınıza ve genel hayatınıza ait tüm notları tek bir pencerede görebilirsiniz.',
            ),
          ],
        );

      case LegalTab.contact:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'İletişim & Geliştirici Bilgileri',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 14),
            _buildInfoRow(Icons.apps, 'Uygulama Adı', AppConfig.appName),
            _buildInfoRow(Icons.info_outline, 'Sürüm', AppConfig.appVersion),
            _buildInfoRow(Icons.email_outlined, 'Destek E-postası', 'destek@mentor-app.com'),
            _buildInfoRow(Icons.language, 'Web Sitesi', 'https://mentor-habit-tracker.dev'),
            const SizedBox(height: 16),
            const Text(
              'MENTOR, kullanıcıların mikro adımlarla makro başarılar elde etmesini sağlayan yeni nesil kişisel gelişim platformudur.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
            ),
          ],
        );

      case LegalTab.account:
        final user = ref.watch(currentUserProvider);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Hesap Ayarları & Oturum',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Giriş Yapılan Kullanıcı: ${user?.username ?? "-"}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'E-posta: ${user?.email ?? "-"}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CustomPinkButton(
              text: 'Oturumu Kapat (Çıkış Yap)',
              variant: PinkButtonVariant.secondary,
              icon: Icons.logout,
              onPressed: _handleLogout,
            ),
            const SizedBox(height: 16),
            CustomPinkButton(
              text: 'Hesabı ve Tüm Verileri Kalıcı Olarak Sil',
              variant: PinkButtonVariant.danger,
              icon: Icons.delete_forever,
              onPressed: _handleDeleteAccount,
            ),
          ],
        );
    }
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              color: AppColors.softPink,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            answer,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.softPink),
          const SizedBox(width: 10),
          Text('$label: ', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
