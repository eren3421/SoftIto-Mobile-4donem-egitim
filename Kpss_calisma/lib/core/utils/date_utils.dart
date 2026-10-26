// Tarih ve saat formatlama işlemleri için intl paketini içe aktarıyoruz
import 'package:intl/intl.dart';

// Tarih ve süreleri kullanıcı dostu metinlere dönüştüren yardımcı sınıf
class AppDateUtils {
  // Gün.Ay.Yıl biçiminde tarih formatlayıcı (Örn: 24.10.2026)
  static final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');

  // Gün ve Ay biçiminde kısa tarih formatlayıcı (Örn: 24 Eki)
  static final DateFormat _dayMonthFormat = DateFormat('d MMM');

  // Günün tam adı biçiminde formatlayıcı (Örn: Cumartesi)
  static final DateFormat _dayNameFormat = DateFormat('EEEE');

  // Saat:Dakika biçiminde zaman formatlayıcı (Örn: 14:30)
  static final DateFormat _timeFormat = DateFormat('HH:mm');

  // DateTime nesnesini 'dd.MM.yyyy' şeklinde metne dönüştürür
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  // DateTime nesnesini 'd MMM' (gün ve ay adı) şeklinde metne dönüştürür
  static String formatDayMonth(DateTime date) {
    return _dayMonthFormat.format(date);
  }

  // Tarihin hangi güne denk geldiğini (Pazartesi, Salı vb.) metin olarak döndürür
  static String formatDayName(DateTime date) {
    return _dayNameFormat.format(date);
  }

  // DateTime nesnesinin saat ve dakikasını (HH:mm) metin olarak döndürür
  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  // Dakika cinsinden verilen çalışma süresini saat ve dakika metnine çevirir
  static String formatDuration(int minutes) {
    // 60 dakikadan az ise sadece dakika olarak göster (Örn: 45 dk)
    if (minutes < 60) {
      return '$minutes dk';
    }
    // Tam saat kısmını hesaplar (tamsayı bölme ~/ operatörü ile)
    final hours = minutes ~/ 60;
    // Kalan dakika kısmını mod (%) operatörü ile hesaplar
    final remainingMinutes = minutes % 60;
    // Artan dakika yoksa sadece saati gösterir (Örn: 2 sa)
    if (remainingMinutes == 0) {
      return '$hours sa';
    }
    // Hem saat hem de dakika varsa birleştirerek gösterir (Örn: 1 sa 30 dk)
    return '$hours sa $remainingMinutes dk';
  }

  // Verilen tarihin bugüne göre bağıl konumunu (Bugün, Dün, vb.) döndürür
  static String getRelativeDay(DateTime date) {
    // Şu anki anlık zamanı alırız
    final now = DateTime.now();
    // Saat kısmını sıfırlayarak bugünün saf tarihini elde ederiz
    final today = DateTime(now.year, now.month, now.day);
    // Karşılaştırılacak tarihin saf gününü elde ederiz
    final target = DateTime(date.year, date.month, date.day);
    // İki gün arasındaki gün farkını hesaplarız
    final difference = today.difference(target).inDays;

    // Fark 0 ise bugündür
    if (difference == 0) return 'Bugün';
    // Fark 1 ise dündür
    if (difference == 1) return 'Dün';
    // Fark -1 ise gelecekteki yarındır
    if (difference == -1) return 'Yarın';
    // Diğer tüm durumlarda standart tarih formatında gösteririz
    return formatDate(date);
  }
}
