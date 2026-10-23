import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../local/hive_storage_service.dart';
import '../models/habit_model.dart';
import 'auth_repository.dart';

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepository(storage: HiveStorageService.instance);
});

final habitsListProvider =
    StateNotifierProvider<HabitsNotifier, List<HabitModel>>((ref) {
  final repo = ref.watch(habitRepositoryProvider);
  final currentUser = ref.watch(currentUserProvider);
  return HabitsNotifier(repo: repo, userId: currentUser?.id);
});

class HabitsNotifier extends StateNotifier<List<HabitModel>> {
  final HabitRepository _repo;
  final String? _userId;

  HabitsNotifier({
    required HabitRepository repo,
    required String? userId,
  })  : _repo = repo,
        _userId = userId,
        super([]) {
    refresh();
  }

  void refresh() {
    if (_userId == null) {
      state = [];
      return;
    }
    state = _repo.getHabitsForUser(_userId);
  }

  Future<void> addHabit(String title, {String? reminderTime}) async {
    if (_userId == null) return;
    await _repo.addHabit(
      userId: _userId,
      title: title,
      reminderTime: reminderTime,
    );
    refresh();
  }

  Future<void> toggleDate(String habitId, String dateStr) async {
    await _repo.toggleDate(habitId, dateStr);
    refresh();
  }

  Future<void> updateReminderTime(String habitId, String? reminderTime) async {
    await _repo.updateReminderTime(habitId, reminderTime);
    refresh();
  }

  Future<void> deleteHabit(String habitId) async {
    await _repo.deleteHabit(habitId);
    refresh();
  }
}

class HabitRepository {
  final HiveStorageService _storage;

  HabitRepository({required HiveStorageService storage}) : _storage = storage;

  List<HabitModel> getHabitsForUser(String userId) {
    return _storage.getHabitsForUser(userId);
  }

  HabitModel? getHabitById(String id) {
    return _storage.getHabitById(id);
  }

  Future<HabitModel> addHabit({
    required String userId,
    required String title,
    String? reminderTime,
  }) async {
    final habit = HabitModel(
      id: const Uuid().v4(),
      userId: userId,
      title: title.trim(),
      reminderTime: reminderTime,
      completedDates: [],
    );
    await _storage.saveHabit(habit);
    return habit;
  }

  Future<void> updateReminderTime(String habitId, String? reminderTime) async {
    await _storage.updateHabitReminder(habitId, reminderTime);
  }

  /// Belirli bir tarihi (Örn: Bugün veya takvimden seçilen bir gün) tamamlandı / tamamlanmadı yap
  Future<HabitModel?> toggleDate(String habitId, String dateStr) async {
    final habit = _storage.getHabitById(habitId);
    if (habit == null) return null;

    final List<String> updatedDates = List.from(habit.completedDates);
    if (updatedDates.contains(dateStr)) {
      updatedDates.remove(dateStr);
    } else {
      updatedDates.add(dateStr);
    }

    final updatedHabit = habit.copyWith(completedDates: updatedDates);
    await _storage.saveHabit(updatedHabit);
    return updatedHabit;
  }

  Future<void> deleteHabit(String habitId) async {
    await _storage.deleteHabit(habitId);
  }
}
