// Flutter Material Design bileşenlerini içe aktarıyoruz
import 'package:flutter/material.dart';
// Durum yönetimi için Provider paketini içe aktarıyoruz
import 'package:provider/provider.dart';
// Renk paleti sabitlerini içe aktarıyoruz
import '../../core/constants/app_colors.dart';
// Süre ve saat formatlama yardımcı sınıfını içe aktarıyoruz
import '../../core/utils/date_utils.dart';
// Çalışma oturumu verilerini okumak için QuestionProvider'ı içe aktarıyoruz
import '../../providers/question_provider.dart';
// Sayaç modlarını ve zamanlayıcı durumunu yöneten TimerProvider'ı içe aktarıyoruz
import '../../providers/timer_provider.dart';
// Oturum bittiğinde ders seçimi yaptırıp kaydeden diyalog bileşenini içe aktarıyoruz
import 'widgets/save_session_dialog.dart';

// Pomodoro, Mola ve Serbest Kronometre sayaç ekranı
class TimerScreen extends StatelessWidget {
  // TimerScreen kurucu fonksiyonu
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TimerProvider ve QuestionProvider durumlarını izliyoruz (watch)
    final timerProv = context.watch<TimerProvider>();
    final questionProv = context.watch<QuestionProvider>();
    final theme = Theme.of(context);

    // Pomodoro süresi bittiğinde otomatik olarak oturum kaydetme diyaloğunu tetikliyoruz
    if (timerProv.isFinished) {
      // Widget ağacı çizildikten hemen sonra diyaloğu açmak için addPostFrameCallback kullanıyoruz
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SaveSessionDialog.show(
          context,
          durationMinutes: timerProv.elapsedStudyMinutes,
          sessionType: 'pomodoro',
        );
        // Sayacı sıfırlıyoruz
        timerProv.resetTimer();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Çalışma Sayacı'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            // Mod Seçici Buton Grubu (Pomodoro, Kısa Mola, Kronometre)
            SegmentedButton<StudyTimerMode>(
              segments: const [
                ButtonSegment(
                  value: StudyTimerMode.pomodoro,
                  label: Text('Pomodoro (25dk)'),
                  icon: Icon(Icons.alarm),
                ),
                ButtonSegment(
                  value: StudyTimerMode.shortBreak,
                  label: Text('Mola (5dk)'),
                  icon: Icon(Icons.coffee),
                ),
                ButtonSegment(
                  value: StudyTimerMode.stopwatch,
                  label: Text('Kronometre'),
                  icon: Icon(Icons.timer),
                ),
              ],
              selected: {timerProv.mode},
              onSelectionChanged: (set) {
                // Seçilen yeni çalışma moduna geçiş yapıyoruz
                timerProv.switchMode(set.first);
              },
            ),
            const SizedBox(height: 36),

            // Büyük Dairesel Süre Göstergesi (Büyük Sayaç Kadranı)
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Dairesel ilerleme çubuğu
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: CircularProgressIndicator(
                      // Kronometre modunda belirsiz (sürekli dönen), Pomodoro'da kalan süreye göre yüzde
                      value: timerProv.mode == StudyTimerMode.stopwatch
                          ? (timerProv.isRunning ? null : 1.0)
                          : timerProv.progress,
                      strokeWidth: 12, // Kalın kadran çizgisi
                      backgroundColor: theme.brightness == Brightness.dark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                      // Molada yeşil, Pomodoro'da tema rengi
                      valueColor: AlwaysStoppedAnimation<Color>(
                        timerProv.mode == StudyTimerMode.shortBreak
                            ? AppColors.completed
                            : AppColors.primary,
                      ),
                      strokeCap: StrokeCap.round, // Yuvarlak uçlu kadran
                    ),
                  ),
                  // Dairenin tam ortasındaki sayaç metni (Örn: 24:59)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timerProv.formattedTime,
                        style: const TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Mevcut durum mesajı (Odaklanma Zamanı, Dinlenme Zamanı vb.)
                      Text(
                        timerProv.mode == StudyTimerMode.pomodoro
                            ? (timerProv.isRunning ? 'Odaklanma Zamanı' : 'Pomodoro Hazır')
                            : (timerProv.mode == StudyTimerMode.shortBreak
                                ? 'Dinlenme Zamanı'
                                : 'Serbest Sayaç'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Sayaç Kontrol Butonları (Sıfırla, Başlat/Duraklat, Kaydet)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Sayacı Baştan Başlatma / Sıfırlama Butonu
                IconButton.filledTonal(
                  onPressed: timerProv.resetTimer,
                  icon: const Icon(Icons.refresh),
                  iconSize: 28,
                  tooltip: 'Sıfırla',
                  style: IconButton.styleFrom(padding: const EdgeInsets.all(16)),
                ),
                const SizedBox(width: 20),

                // Ana Başlat / Duraklat Yuvarlak Butonu
                ElevatedButton(
                  onPressed: timerProv.isRunning ? timerProv.pauseTimer : timerProv.startTimer,
                  style: ElevatedButton.styleFrom(
                    // Çalışırken durdurma rengi (kırmızı), dururken başlatma rengi (ana tema)
                    backgroundColor: timerProv.isRunning ? AppColors.wrong : AppColors.primary,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(24),
                  ),
                  child: Icon(
                    timerProv.isRunning ? Icons.pause : Icons.play_arrow,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),

                // Oturumu Bitir ve Kaydet Butonu
                IconButton.filledTonal(
                  onPressed: () {
                    timerProv.pauseTimer();
                    final mins = timerProv.elapsedStudyMinutes;
                    SaveSessionDialog.show(
                      context,
                      durationMinutes: mins,
                      sessionType: timerProv.mode == StudyTimerMode.stopwatch
                          ? 'stopwatch'
                          : 'pomodoro',
                    );
                  },
                  icon: const Icon(Icons.bookmark_add_outlined),
                  iconSize: 28,
                  tooltip: 'Bitir ve Kaydet',
                  style: IconButton.styleFrom(padding: const EdgeInsets.all(16)),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Bugün Gerçekleştirilen Çalışma Oturumlarının Listesi
            if (questionProv.sessions.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Bugünkü Çalışma Oturumları',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                // Son 4 oturumu gösterir
                itemCount: questionProv.sessions.take(4).length,
                itemBuilder: (context, index) {
                  final session = questionProv.sessions[index];
                  final color = AppColors.getCourseColor(session.courseId);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.brightness == Brightness.dark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Ders rengi simgesi
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 10),
                        // Ders adı
                        Expanded(
                          child: Text(
                            session.courseId.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ),
                        // Çalışma süresi
                        Text(
                          AppDateUtils.formatDuration(session.durationInMinutes),
                          style: TextStyle(fontWeight: FontWeight.w700, color: color),
                        ),
                        const SizedBox(width: 10),
                        // Oturumun yapıldığı saat
                        Text(
                          AppDateUtils.formatTime(session.date),
                          style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
