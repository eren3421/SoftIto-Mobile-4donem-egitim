class QuestionLog {
  final String id;
  final String courseId;
  final int correct;
  final int wrong;
  final int empty;
  final DateTime date;
  final String? note;

  QuestionLog({
    required this.id,
    required this.courseId,
    required this.correct,
    required this.wrong,
    required this.empty,
    required this.date,
    this.note,
  });

  int get totalQuestions => correct + wrong + empty;

  double get netScore => correct - (wrong / 4.0);

  double get accuracyRate {
    if (totalQuestions == 0) return 0.0;
    return (correct / totalQuestions) * 100.0;
  }

  factory QuestionLog.fromMap(Map<dynamic, dynamic> map) {
    return QuestionLog(
      id: map['id']?.toString() ?? '',
      courseId: map['courseId']?.toString() ?? '',
      correct: int.tryParse(map['correct']?.toString() ?? '0') ?? 0,
      wrong: int.tryParse(map['wrong']?.toString() ?? '0') ?? 0,
      empty: int.tryParse(map['empty']?.toString() ?? '0') ?? 0,
      date: map['date'] != null
          ? DateTime.tryParse(map['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      note: map['note']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseId': courseId,
      'correct': correct,
      'wrong': wrong,
      'empty': empty,
      'date': date.toIso8601String(),
      'note': note,
    };
  }
}
