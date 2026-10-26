// Flutter Material Design bileşenlerini içe aktarıyoruz
import 'package:flutter/material.dart';
// Durum yönetimi için Provider paketini içe aktarıyoruz
import 'package:provider/provider.dart';
// Soru verilerini okumak için QuestionProvider'ı içe aktarıyoruz
import '../../../providers/question_provider.dart';
// Günlük hedef ayarını okumak ve güncellemek için SettingsProvider'ı içe aktarıyoruz
import '../../../providers/settings_provider.dart';

// Ana sayfada kullanıcının günlük soru hedefini ve tamamlanma oranını gradyan arkaplanla gösteren kart
class DailyGoalCard extends StatelessWidget {
  // DailyGoalCard kurucu fonksiyonu
  const DailyGoalCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Soru ve ayar sağlayıcılarını watch ederek değişiklikleri dinliyoruz
    final questionProv = context.watch<QuestionProvider>();
    final settingsProv = context.watch<SettingsProvider>();

    // Belirlenen günlük hedef soru sayısı
    final goal = settingsProv.dailyGoal;
    // Bugün çözülen toplam soru sayısı
    final solved = questionProv.todayTotalQuestions;
    // Hedefin tamamlanma oranını 0.0 ile 1.0 arasına sıkıştırıyoruz
    final progress = (goal == 0 ? 0.0 : (solved / goal)).clamp(0.0, 1.0);
    // Hedefe ulaşılıp ulaşılmadığını kontrol ediyoruz
    final isGoalReached = solved >= goal;
    // Hedefe ulaşmak için kalan soru sayısı
    final remaining = (goal - solved) > 0 ? (goal - solved) : 0;

    return Container(
      // Kart içi boşluğu
      padding: const EdgeInsets.all(20),
      // Kart kutu süslemesi (gradyan ve gölge)
      decoration: BoxDecoration(
        // Hedefe ulaşıldıysa yeşil, ulaşılmadıysa mor/mavi gradyan renk geçişi
        gradient: LinearGradient(
          colors: isGoalReached
              ? [const Color(0xFF10B981), const Color(0xFF059669)]
              : [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        // Kartın altına modern yumuşak bir renkli gölge ekliyoruz
        boxShadow: [
          BoxShadow(
            color: (isGoalReached ? const Color(0xFF10B981) : const Color(0xFF6366F1))
                .withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kart Üst Başlık Satırı ve "Hedef" Düzenleme Butonu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Dairesel ikon kutucuğu
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isGoalReached ? Icons.workspace_premium : Icons.track_changes,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Duruma göre başlık metni
                  Text(
                    isGoalReached ? 'Hedef Tamamlandı! 🎉' : 'Günlük Soru Hedefi',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              // Hedef soru sayısını değiştiren modal pencereyi açan tıklanabilir alan
              InkWell(
                onTap: () => _showGoalEditDialog(context, goal, settingsProv),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.edit, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Hedef',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Soru Sayısı Metinleri ve Dairesel İlerleme Göstergesi
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Çözülen ve hedef soru sayısını yan yana farklı boyutlarda yazdırıyoruz
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$solved',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                          ),
                          TextSpan(
                            text: ' / $goal soru',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Kalan soru bilgisi veya motivasyon mesajı
                    Text(
                      isGoalReached
                          ? 'Harika! Bugün hedefini aştın.'
                          : 'Hedefe ulaşmak için son $remaining soru kaldı.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Sağ tarafta dairesel yüzde göstergesi (CircularProgressIndicator)
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  // Halkanın ortasındaki yüzde metni (Örn: %75)
                  Text(
                    '%${(progress * 100).toInt()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Kullanıcının günlük soru hedefini değiştirebileceği açılır iletişim kutusu (Dialog)
  void _showGoalEditDialog(
    BuildContext context,
    int currentGoal,
    SettingsProvider settingsProv,
  ) {
    // Giriş kutusu için mevcut hedefi barındıran metin kontrolcüsü
    final controller = TextEditingController(text: currentGoal.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Günlük Hedefi Değiştir'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number, // Sadece sayısal klavye açar
          autofocus: true, // Açıldığında doğrudan klavyeyi odaklar
          decoration: const InputDecoration(
            labelText: 'Günlük Hedef Soru Sayısı',
            suffixText: 'soru',
          ),
        ),
        actions: [
          // İptal butonu
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          // Kaydet butonu
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val > 0) {
                // Yeni hedefi ayarlar sağlayıcısına kaydeder
                settingsProv.setDailyGoal(val);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}
