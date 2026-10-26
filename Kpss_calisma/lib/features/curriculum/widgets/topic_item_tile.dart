// Flutter'ın temel Material Design widget kütüphanesini içe aktarıyoruz
import 'package:flutter/material.dart';
// Uygulama renk paletini içe aktarıyoruz
import '../../../core/constants/app_colors.dart';
// Konu durum kodlarını (Çalışılmadı, Tekrar, Bitirildi) içe aktarıyoruz
import '../../../core/constants/app_constants.dart';
// Konu modelini içe aktarıyoruz
import '../../../models/topic.dart';

// Müfredat listesindeki her bir konuyu ve durum değiştirme menüsünü gösteren kart bileşeni
class TopicItemTile extends StatelessWidget {
  // Görüntülenecek alt konu nesnesi
  final Topic topic;

  // Konunun geçerli tamamlanma durumu (0: Çalışılmadı, 1: Tekrar, 2: Bitti)
  final int status;

  // Konunun ait olduğu dersin tema rengi
  final Color courseColor;

  // Kullanıcı durumu değiştirdiğinde tetiklenen geri çağrım (callback)
  final ValueChanged<int> onStatusChanged;

  // TopicItemTile kurucu fonksiyonu
  const TopicItemTile({
    super.key,
    required this.topic,
    required this.status,
    required this.courseColor,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Mevcut tema verilerini alıyoruz
    final theme = Theme.of(context);
    // Konunun durumuna göre renk belirliyoruz
    final statusColor = _getStatusColor(status);
    // Konunun durumuna göre metin etiketi alıyoruz
    final statusLabel = _getStatusLabel(status);
    // Konunun durumuna göre ikon alıyoruz
    final statusIcon = _getStatusIcon(status);

    return Container(
      // Kartlar arası dikey boşluk
      margin: const EdgeInsets.only(bottom: 10),
      // Kart içi boşluğu (padding)
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      // Kart kutu süslemesi (arkaplan rengi, yuvarlak köşeler ve kenarlık)
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          // Konu bittiyse yeşilimsi ince kenarlık, değilse tema kenarlık rengini uygula
          color: status == AppConstants.statusCompleted
              ? AppColors.completed.withValues(alpha: 0.3)
              : (theme.brightness == Brightness.dark
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0)),
        ),
      ),
      child: Row(
        children: [
          // Sol tarafta durum rengini gösteren dikey şerit çubuk
          Container(
            width: 8,
            height: 38,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          // Konu başlığı ve durum metninin yer aldığı alan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Konu adı
                Text(
                  topic.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: status == AppConstants.statusCompleted
                        ? TextDecoration.none
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                // Konu durum etiketi (Bitirildi / Tekrar Edilecek / Çalışılmadı)
                Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          // Durumu hızlıca değiştirmeyi sağlayan açılır menü (PopupMenuButton)
          PopupMenuButton<int>(
            initialValue: status, // Mevcut seçili durum
            onSelected: onStatusChanged, // Yeni durum seçildiğinde çalışır
            tooltip: 'Durumu Değiştir',
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            // Açılır menüdeki 3 farklı durum seçeneği
            itemBuilder: (context) => [
              _buildMenuItem(
                value: AppConstants.statusNotStarted,
                title: 'Çalışılmadı',
                icon: Icons.circle_outlined,
                color: AppColors.notStarted,
              ),
              _buildMenuItem(
                value: AppConstants.statusNeedsReview,
                title: 'Tekrar Edilecek',
                icon: Icons.sync,
                color: AppColors.needsReview,
              ),
              _buildMenuItem(
                value: AppConstants.statusCompleted,
                title: 'Bitirdim',
                icon: Icons.check_circle,
                color: AppColors.completed,
              ),
            ],
            // Menüyü açan şık buton tasarımı
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, color: statusColor, size: 16),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Açılır menü (PopupMenuItem) elemanı oluşturan yardımcı metot
  PopupMenuItem<int> _buildMenuItem({
    required int value,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return PopupMenuItem<int>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Durum koduna göre uygun rengi döndüren metot
  Color _getStatusColor(int status) {
    switch (status) {
      case AppConstants.statusCompleted:
        return AppColors.completed;
      case AppConstants.statusNeedsReview:
        return AppColors.needsReview;
      default:
        return AppColors.notStarted;
    }
  }

  // Durum koduna göre Türkçe durum açıklamasını döndüren metot
  String _getStatusLabel(int status) {
    switch (status) {
      case AppConstants.statusCompleted:
        return 'Bitirildi';
      case AppConstants.statusNeedsReview:
        return 'Tekrar Edilecek';
      default:
        return 'Çalışılmadı';
    }
  }

  // Durum koduna göre uygun Material ikonunu döndüren metot
  IconData _getStatusIcon(int status) {
    switch (status) {
      case AppConstants.statusCompleted:
        return Icons.check_circle;
      case AppConstants.statusNeedsReview:
        return Icons.sync;
      default:
        return Icons.radio_button_unchecked;
    }
  }
}
