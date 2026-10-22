import 'package:flutter_test/flutter_test.dart';
import 'package:mentor_app/core/utils/date_utils.dart';
import 'package:mentor_app/core/utils/validators.dart';
import 'package:mentor_app/data/models/habit_model.dart';
import 'package:mentor_app/data/models/note_model.dart';

void main() {
  group('HabitDateUtils & Streak Tests', () {
    test('calculateCurrentStreak with empty dates returns 0', () {
      expect(HabitDateUtils.calculateCurrentStreak([]), 0);
    });

    test('calculateCurrentStreak with today completed returns 1 or more', () {
      final today = HabitDateUtils.todayString;
      final streak = HabitDateUtils.calculateCurrentStreak([today]);
      expect(streak, 1);
    });

    test('calculateLongestStreak calculates consecutive days correctly', () {
      final dates = [
        '2026-10-01',
        '2026-10-02',
        '2026-10-03',
        '2026-10-05',
        '2026-10-06',
      ];
      final longest = HabitDateUtils.calculateLongestStreak(dates);
      expect(longest, 3);
    });

    test('calculateCompletionRate calculates correct ratio for 7 days', () {
      final today = HabitDateUtils.todayString;
      final rate = HabitDateUtils.calculateCompletionRate([today], 7);
      expect(rate, closeTo(1 / 7, 0.01));
    });
  });

  group('Validators Tests', () {
    test('validateEmail validates valid and invalid emails', () {
      expect(Validators.validateEmail(''), isNotNull);
      expect(Validators.validateEmail('invalid-email'), isNotNull);
      expect(Validators.validateEmail('test@example.com'), isNull);
    });

    test('validatePassword validates minimum 6 chars', () {
      expect(Validators.validatePassword('123'), isNotNull);
      expect(Validators.validatePassword('123456'), isNull);
    });

    test('validateOtp validates 6 numeric digits', () {
      expect(Validators.validateOtp('123'), isNotNull);
      expect(Validators.validateOtp('abcdef'), isNotNull);
      expect(Validators.validateOtp('123456'), isNull);
    });
  });

  group('HabitModel & NoteModel Tests', () {
    test('HabitModel computed properties work as expected', () {
      final today = HabitDateUtils.todayString;
      final habit = HabitModel(
        id: 'h1',
        userId: 'u1',
        title: 'Kitap Okuma',
        completedDates: [today],
      );

      expect(habit.isCompletedToday, isTrue);
      expect(habit.isCompletedOn(today), isTrue);
      expect(habit.isCompletedOn('2025-01-01'), isFalse);
      expect(habit.currentStreak, 1);
      expect(habit.title, 'Kitap Okuma');

      final map = habit.toMap();
      final fromMap = HabitModel.fromMap(map);
      expect(fromMap.title, habit.title);
      expect(fromMap.completedDates, habit.completedDates);
    });

    test('NoteModel detects general vs habit-specific note', () {
      final generalNote = NoteModel(
        id: 'n1',
        userId: 'u1',
        content: 'Genel bir düşünce',
      );
      expect(generalNote.isGeneral, isTrue);

      final habitNote = NoteModel(
        id: 'n2',
        userId: 'u1',
        habitId: 'h1',
        habitName: 'Kitap Okuma',
        content: '50 sayfa okudum',
      );
      expect(habitNote.isGeneral, isFalse);
      expect(habitNote.habitName, 'Kitap Okuma');
    });
  });
}
