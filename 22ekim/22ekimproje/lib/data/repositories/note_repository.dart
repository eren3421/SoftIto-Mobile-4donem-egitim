import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../local/hive_storage_service.dart';
import '../models/note_model.dart';
import 'auth_repository.dart';

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepository(storage: HiveStorageService.instance);
});

// Tüm Notlar (Genel + Alışkanlık Özel) Provider'ı
final allNotesProvider = StateNotifierProvider<AllNotesNotifier, List<NoteModel>>((ref) {
  final repo = ref.watch(noteRepositoryProvider);
  final currentUser = ref.watch(currentUserProvider);
  return AllNotesNotifier(repo: repo, userId: currentUser?.id);
});

class AllNotesNotifier extends StateNotifier<List<NoteModel>> {
  final NoteRepository _repo;
  final String? _userId;

  AllNotesNotifier({
    required NoteRepository repo,
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
    state = _repo.getAllNotesForUser(_userId);
  }

  Future<void> addNote({
    String? habitId,
    String? habitName,
    String title = '',
    required String content,
  }) async {
    if (_userId == null) return;
    await _repo.addNote(
      userId: _userId,
      habitId: habitId,
      habitName: habitName,
      title: title,
      content: content,
    );
    refresh();
  }

  Future<void> deleteNote(String noteId) async {
    await _repo.deleteNote(noteId);
    refresh();
  }
}

class NoteRepository {
  final HiveStorageService _storage;

  NoteRepository({required HiveStorageService storage}) : _storage = storage;

  List<NoteModel> getAllNotesForUser(String userId) {
    return _storage.getAllNotesForUser(userId);
  }

  List<NoteModel> getNotesByHabit(String userId, String habitId) {
    return _storage.getNotesByHabit(userId, habitId);
  }

  Future<NoteModel> addNote({
    required String userId,
    String? habitId,
    String? habitName,
    String title = '',
    required String content,
  }) async {
    final note = NoteModel(
      id: const Uuid().v4(),
      userId: userId,
      habitId: habitId,
      habitName: habitName,
      title: title.trim(),
      content: content.trim(),
    );
    await _storage.saveNote(note);
    return note;
  }

  Future<void> deleteNote(String noteId) async {
    await _storage.deleteNote(noteId);
  }
}
