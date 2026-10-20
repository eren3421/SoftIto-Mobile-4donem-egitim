import 'package:flutter/foundation.dart';
import '../models/kisi_model.dart';

/// Kişiler, paydaşlar, takvimli randevular, sohbetler ve video toplantı tutanaklarını yöneten kontrolcü.
/// Sadece flutter/foundation.dart ve ValueNotifier kullanır.
class KisilerController {
  final ValueNotifier<List<KisiModel>> kisiler =
      ValueNotifier<List<KisiModel>>(<KisiModel>[
    KisiModel(
      id: 'kisi_1',
      name: 'Dr. Selin Yılmaz',
      role: 'Melek Yatırımcı',
      company: 'Galata Business Angels',
      email: 'selin.yilmaz@angels.com',
      phone: '+90 532 111 2233',
    ),
    KisiModel(
      id: 'kisi_2',
      name: 'Emre Karaca',
      role: 'Kurucu Ortak & CTO',
      company: 'Asistan Labs',
      email: 'emre@asistan.co',
      phone: '+90 544 222 3344',
    ),
    KisiModel(
      id: 'kisi_3',
      name: 'Aylin Demir',
      role: 'Kurumsal Müşteri',
      company: 'TeknoLojistik A.Ş.',
      email: 'aylin.demir@teknolojistik.com',
      phone: '+90 555 333 4455',
    ),
    KisiModel(
      id: 'kisi_4',
      name: 'Prof. Dr. Kerem Aksoy',
      role: 'Strateji Danışmanı',
      company: 'İTÜ ARI Teknokent',
      email: 'kerem.aksoy@itu.edu.tr',
      phone: '+90 533 444 5566',
    ),
  ]);

  final ValueNotifier<List<RandevuModel>> randevular =
      ValueNotifier<List<RandevuModel>>(<RandevuModel>[
    RandevuModel(
      id: 'rand_1',
      kisiId: 'kisi_1',
      kisiName: 'Dr. Selin Yılmaz',
      title: 'Tohum Yatırım Değerleme Toplantısı',
      dateTime: DateTime.now().add(const Duration(hours: 3)),
      locationOrLink: 'https://meet.asistan.app/yatirim-selin',
      status: 'Onaylandı',
      note: 'Cap table ve runway projeksiyonu sunulacak.',
    ),
    RandevuModel(
      id: 'rand_2',
      kisiId: 'kisi_3',
      kisiName: 'Aylin Demir',
      title: 'Pilot Entegrasyon Demo Sunumu',
      dateTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
      locationOrLink: 'https://meet.asistan.app/demo-aylin',
      status: 'Onaylandı',
      note: '30 günlük deneme sürümü geri bildirimleri.',
    ),
    RandevuModel(
      id: 'rand_3',
      kisiId: 'kisi_4',
      kisiName: 'Prof. Dr. Kerem Aksoy',
      title: 'Akademik Danışma & Hibe Değerlendirmesi',
      dateTime: DateTime.now().add(const Duration(days: 3, hours: 5)),
      locationOrLink: 'İTÜ Teknokent Ofisi',
      status: 'Beklemede',
      note: 'TÜBİTAK 1507 ara rapor incelemesi.',
    ),
  ]);

  final ValueNotifier<Map<String, List<ChatMessageModel>>> chatMessages =
      ValueNotifier<Map<String, List<ChatMessageModel>>>({
    'kisi_1': [
      ChatMessageModel(
        id: 'c1',
        kisiId: 'kisi_1',
        text: 'Merhaba! Sunum dosyanızı inceledim, metrikler çok ümit verici görünüyor.',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      ChatMessageModel(
        id: 'c2',
        kisiId: 'kisi_1',
        text: 'Teşekkürler Selin Hanım! Bugünkü randevumuzda detaylı finansal projeksiyonu aktaracağım.',
        isMe: true,
        timestamp: DateTime.now().subtract(const Duration(hours: 3, minutes: 40)),
      ),
    ],
    'kisi_2': [
      ChatMessageModel(
        id: 'c3',
        kisiId: 'kisi_2',
        text: 'Backend API deploy edildi. Test sunucusu hazır.',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      ChatMessageModel(
        id: 'c4',
        kisiId: 'kisi_2',
        text: 'Harika eline sağlık Emre, video toplantıda gözden geçirelim.',
        isMe: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ],
  });

  final ValueNotifier<List<MeetingRecordModel>> meetingRecords =
      ValueNotifier<List<MeetingRecordModel>>(<MeetingRecordModel>[
    MeetingRecordModel(
      id: 'rec_1',
      title: 'Haftalık Sprint & Kaynak Değerlendirme',
      participants: 'Emre Karaca, Kurucu Ortaklar',
      date: DateTime.now().subtract(const Duration(days: 2)),
      durationMinutes: 45,
      summaryNotes:
          'Mobil arayüz defter teması tasarımı onaylandı. Bütçe harcamalarında sunucu maliyeti optimizasyonu kararlaştırıldı.',
      decisions: 'GPU sunucu rezervasyonu 1 yıllık indirimli plana geçirilecek.',
    ),
    MeetingRecordModel(
      id: 'rec_2',
      title: 'Yatırımcı Ön Tanışma Görüşmesi',
      participants: 'Dr. Selin Yılmaz',
      date: DateTime.now().subtract(const Duration(days: 6)),
      durationMinutes: 30,
      summaryNotes:
          'Girişimin büyüme potansiyeli ve müşteri edinme maliyeti (CAC) incelendi. İkinci görüşme takvime eklendi.',
      decisions: 'Sözleşme taslağı hukuk danışmanına iletilecek.',
    ),
  ]);

  final ValueNotifier<int> selectedSubTab = ValueNotifier<int>(0);

  void setSubTab(int index) {
    selectedSubTab.value = index;
  }

  void addKisi({
    required String name,
    required String role,
    required String company,
    required String email,
    required String phone,
  }) {
    final newKisi = KisiModel(
      id: 'kisi_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      role: role,
      company: company,
      email: email,
      phone: phone,
    );
    kisiler.value = <KisiModel>[...kisiler.value, newKisi];
  }

  void deleteKisi(String id) {
    kisiler.value = kisiler.value.where((k) => k.id != id).toList();
  }

  void addRandevu({
    required String kisiId,
    required String kisiName,
    required String title,
    required DateTime dateTime,
    required String locationOrLink,
    String note = '',
  }) {
    final newRand = RandevuModel(
      id: 'rand_${DateTime.now().millisecondsSinceEpoch}',
      kisiId: kisiId,
      kisiName: kisiName,
      title: title,
      dateTime: dateTime,
      locationOrLink: locationOrLink,
      status: 'Onaylandı',
      note: note,
    );
    randevular.value = <RandevuModel>[newRand, ...randevular.value]
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  void cancelRandevu(String id) {
    randevular.value = randevular.value.map((r) {
      if (r.id == id) {
        return r.copyWith(status: 'İptal');
      }
      return r;
    }).toList();
  }

  void sendMessage(String kisiId, String text) {
    if (text.trim().isEmpty) return;
    final currentMap = Map<String, List<ChatMessageModel>>.from(chatMessages.value);
    final msgList = List<ChatMessageModel>.from(currentMap[kisiId] ?? []);

    final newMsg = ChatMessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      kisiId: kisiId,
      text: text.trim(),
      isMe: true,
      timestamp: DateTime.now(),
    );

    msgList.add(newMsg);
    currentMap[kisiId] = msgList;
    chatMessages.value = currentMap;
  }

  void addMeetingRecord({
    required String title,
    required String participants,
    required DateTime date,
    required int durationMinutes,
    required String summaryNotes,
    required String decisions,
  }) {
    final record = MeetingRecordModel(
      id: 'rec_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      participants: participants,
      date: date,
      durationMinutes: durationMinutes,
      summaryNotes: summaryNotes,
      decisions: decisions,
    );
    meetingRecords.value = <MeetingRecordModel>[record, ...meetingRecords.value];
  }

  void deleteMeetingRecord(String id) {
    meetingRecords.value =
        meetingRecords.value.where((r) => r.id != id).toList();
  }

  void dispose() {
    kisiler.dispose();
    randevular.dispose();
    chatMessages.dispose();
    meetingRecords.dispose();
    selectedSubTab.dispose();
  }
}
