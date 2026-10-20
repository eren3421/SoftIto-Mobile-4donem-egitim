/// Girişimcinin paydaş, müşteri veya ekip üyesi bağlantı modeli.
class KisiModel {
  final String id;
  final String name;
  final String role; // Yatırımcı, Müşteri, Ortak, Danışman, Ekip
  final String company;
  final String email;
  final String phone;

  const KisiModel({
    required this.id,
    required this.name,
    required this.role,
    required this.company,
    required this.email,
    required this.phone,
  });

  KisiModel copyWith({
    String? id,
    String? name,
    String? role,
    String? company,
    String? email,
    String? phone,
  }) {
    return KisiModel(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      company: company ?? this.company,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }

  factory KisiModel.fromJson(Map<String, dynamic> json) {
    return KisiModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? 'Paydaş',
      company: json['company'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'company': company,
      'email': email,
      'phone': phone,
    };
  }
}

/// Takvimli ve saatli randevu / görüşme modeli.
class RandevuModel {
  final String id;
  final String kisiId;
  final String kisiName;
  final String title;
  final DateTime dateTime;
  final String locationOrLink;
  final String status; // Onaylandı, Beklemede, Tamamlandı, İptal
  final String note;

  const RandevuModel({
    required this.id,
    required this.kisiId,
    required this.kisiName,
    required this.title,
    required this.dateTime,
    required this.locationOrLink,
    this.status = 'Onaylandı',
    this.note = '',
  });

  RandevuModel copyWith({
    String? id,
    String? kisiId,
    String? kisiName,
    String? title,
    DateTime? dateTime,
    String? locationOrLink,
    String? status,
    String? note,
  }) {
    return RandevuModel(
      id: id ?? this.id,
      kisiId: kisiId ?? this.kisiId,
      kisiName: kisiName ?? this.kisiName,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      locationOrLink: locationOrLink ?? this.locationOrLink,
      status: status ?? this.status,
      note: note ?? this.note,
    );
  }

  factory RandevuModel.fromJson(Map<String, dynamic> json) {
    return RandevuModel(
      id: json['id'] as String? ?? '',
      kisiId: json['kisi_id'] as String? ?? '',
      kisiName: json['kisi_name'] as String? ?? '',
      title: json['title'] as String? ?? '',
      dateTime: json['date_time'] != null
          ? DateTime.parse(json['date_time'] as String)
          : DateTime.now(),
      locationOrLink: json['location_link'] as String? ?? 'Online',
      status: json['status'] as String? ?? 'Onaylandı',
      note: json['note'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kisi_id': kisiId,
      'kisi_name': kisiName,
      'title': title,
      'date_time': dateTime.toIso8601String(),
      'location_link': locationOrLink,
      'status': status,
      'note': note,
    };
  }
}

/// Birebir veya genel sohbet mesajı modeli.
class ChatMessageModel {
  final String id;
  final String kisiId;
  final String text;
  final bool isMe;
  final DateTime timestamp;

  const ChatMessageModel({
    required this.id,
    required this.kisiId,
    required this.text,
    required this.isMe,
    required this.timestamp,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String? ?? '',
      kisiId: json['kisi_id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      isMe: json['is_me'] as bool? ?? false,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kisi_id': kisiId,
      'text': text,
      'is_me': isMe,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Depolanan ve inceleme için özelleştirilebilen video toplantı tutanak modeli.
class MeetingRecordModel {
  final String id;
  final String title;
  final String participants;
  final DateTime date;
  final int durationMinutes;
  final String summaryNotes;
  final String decisions;

  const MeetingRecordModel({
    required this.id,
    required this.title,
    required this.participants,
    required this.date,
    required this.durationMinutes,
    required this.summaryNotes,
    required this.decisions,
  });

  MeetingRecordModel copyWith({
    String? id,
    String? title,
    String? participants,
    DateTime? date,
    int? durationMinutes,
    String? summaryNotes,
    String? decisions,
  }) {
    return MeetingRecordModel(
      id: id ?? this.id,
      title: title ?? this.title,
      participants: participants ?? this.participants,
      date: date ?? this.date,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      summaryNotes: summaryNotes ?? this.summaryNotes,
      decisions: decisions ?? this.decisions,
    );
  }

  factory MeetingRecordModel.fromJson(Map<String, dynamic> json) {
    return MeetingRecordModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      participants: json['participants'] as String? ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      durationMinutes: json['duration_minutes'] as int? ?? 30,
      summaryNotes: json['summary_notes'] as String? ?? '',
      decisions: json['decisions'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'participants': participants,
      'date': date.toIso8601String(),
      'duration_minutes': durationMinutes,
      'summary_notes': summaryNotes,
      'decisions': decisions,
    };
  }
}
