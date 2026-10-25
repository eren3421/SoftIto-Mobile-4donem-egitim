class MockExam {
  final String id;
  final String title;
  final DateTime date;
  final int gyCorrect;
  final int gyWrong;
  final int gkCorrect;
  final int gkWrong;
  final String? note;

  MockExam({
    required this.id,
    required this.title,
    required this.date,
    required this.gyCorrect,
    required this.gyWrong,
    required this.gkCorrect,
    required this.gkWrong,
    this.note,
  });

  double get gyNet => gyCorrect - (gyWrong / 4.0);
  double get gkNet => gkCorrect - (gkWrong / 4.0);
  double get totalNet => gyNet + gkNet;

  int get totalQuestions => gyCorrect + gyWrong + gkCorrect + gkWrong;
  int get totalCorrect => gyCorrect + gkCorrect;
  int get totalWrong => gyWrong + gkWrong;

  factory MockExam.fromMap(Map<dynamic, dynamic> map) {
    return MockExam(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'KPSS Denemesi',
      date: map['date'] != null
          ? DateTime.tryParse(map['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      gyCorrect: int.tryParse(map['gyCorrect']?.toString() ?? '0') ?? 0,
      gyWrong: int.tryParse(map['gyWrong']?.toString() ?? '0') ?? 0,
      gkCorrect: int.tryParse(map['gkCorrect']?.toString() ?? '0') ?? 0,
      gkWrong: int.tryParse(map['gkWrong']?.toString() ?? '0') ?? 0,
      note: map['note']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'gyCorrect': gyCorrect,
      'gyWrong': gyWrong,
      'gkCorrect': gkCorrect,
      'gkWrong': gkWrong,
      'note': note,
    };
  }
}
