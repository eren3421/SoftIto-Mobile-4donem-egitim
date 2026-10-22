import '../../core/utils/date_utils.dart';

class HabitModel {
  final String id;
  final String userId;
  final String title;
  final List<String> completedDates;
  final String? reminderTime;
  final DateTime createdAt;

  HabitModel({
    required this.id,
    required this.userId,
    required this.title,
    List<String>? completedDates,
    this.reminderTime,
    DateTime? createdAt,
  })  : completedDates = completedDates ?? [],
        createdAt = createdAt ?? DateTime.now();

  int get currentStreak => HabitDateUtils.calculateCurrentStreak(completedDates);

  int get longestStreak => HabitDateUtils.calculateLongestStreak(completedDates);

  double get weeklyCompletionRate =>
      HabitDateUtils.calculateCompletionRate(completedDates, 7);

  double get monthlyCompletionRate =>
      HabitDateUtils.calculateCompletionRate(completedDates, 30);

  bool get isCompletedToday =>
      completedDates.contains(HabitDateUtils.todayString);

  bool isCompletedOn(String dateStr) => completedDates.contains(dateStr);

  HabitModel copyWith({
    String? id,
    String? userId,
    String? title,
    List<String>? completedDates,
    String? reminderTime,
    DateTime? createdAt,
  }) {
    return HabitModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      completedDates: completedDates ?? List.from(this.completedDates),
      reminderTime: reminderTime ?? this.reminderTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'completedDates': completedDates,
      'reminderTime': reminderTime,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory HabitModel.fromMap(Map<dynamic, dynamic> map) {
    return HabitModel(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      completedDates: (map['completedDates'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      reminderTime: map['reminderTime'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
