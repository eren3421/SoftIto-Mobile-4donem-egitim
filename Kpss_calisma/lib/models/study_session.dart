class StudySession {
  final String id;
  final String courseId;
  final int durationInMinutes;
  final DateTime date;
  final String type; // 'pomodoro' | 'stopwatch'
  final String? note;

  StudySession({
    required this.id,
    required this.courseId,
    required this.durationInMinutes,
    required this.date,
    required this.type,
    this.note,
  });

  factory StudySession.fromMap(Map<dynamic, dynamic> map) {
    return StudySession(
      id: map['id']?.toString() ?? '',
      courseId: map['courseId']?.toString() ?? '',
      durationInMinutes: int.tryParse(map['durationInMinutes']?.toString() ?? '0') ?? 0,
      date: map['date'] != null
          ? DateTime.tryParse(map['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      type: map['type']?.toString() ?? 'pomodoro',
      note: map['note']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseId': courseId,
      'durationInMinutes': durationInMinutes,
      'date': date.toIso8601String(),
      'type': type,
      'note': note,
    };
  }
}
