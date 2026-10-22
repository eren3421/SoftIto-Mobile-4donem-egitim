import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../models/user_model.dart';
import '../models/habit_model.dart';
import '../models/note_model.dart';
import '../models/pdf_report_model.dart';
import '../models/chat_message_model.dart';

class HiveStorageService {
  static final HiveStorageService instance = HiveStorageService._internal();
  HiveStorageService._internal();

  static const String usersBoxName = 'users_box';
  static const String sessionBoxName = 'session_box';
  static const String habitsBoxName = 'habits_box';
  static const String notesBoxName = 'notes_box';
  static const String reportsBoxName = 'reports_box';
  static const String chatBoxName = 'chat_box';

  late Box _usersBox;
  late Box _sessionBox;
  late Box _habitsBox;
  late Box _notesBox;
  late Box _reportsBox;
  late Box _chatBox;

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    await Hive.initFlutter();

    _usersBox = await Hive.openBox(usersBoxName);
    _sessionBox = await Hive.openBox(sessionBoxName);
    _habitsBox = await Hive.openBox(habitsBoxName);
    _notesBox = await Hive.openBox(notesBoxName);
    _reportsBox = await Hive.openBox(reportsBoxName);
    _chatBox = await Hive.openBox(chatBoxName);

    _isInitialized = true;
    debugPrint('HiveStorageService initialized successfully.');
  }

  // ===================== SESSION OPERATIONS =====================

  String? getCurrentUserId() {
    if (!_isInitialized) return null;
    return _sessionBox.get('currentUserId') as String?;
  }

  Future<void> setCurrentUserId(String? userId) async {
    if (!_isInitialized) return;
    if (userId == null) {
      await _sessionBox.delete('currentUserId');
    } else {
      await _sessionBox.put('currentUserId', userId);
    }
  }

  Future<void> savePendingOtp(String email, String otp) async {
    if (!_isInitialized) return;
    await _sessionBox.put('pending_otp_${email.toLowerCase().trim()}', {
      'otp': otp,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  String? getPendingOtp(String email) {
    if (!_isInitialized) return null;
    final data = _sessionBox.get('pending_otp_${email.toLowerCase().trim()}');
    if (data is Map) {
      return data['otp'] as String?;
    }
    return null;
  }

  Future<void> clearPendingOtp(String email) async {
    if (!_isInitialized) return;
    await _sessionBox.delete('pending_otp_${email.toLowerCase().trim()}');
  }

  // ===================== USER OPERATIONS =====================

  Future<void> saveUser(UserModel user) async {
    if (!_isInitialized) return;
    await _usersBox.put(user.id, user.toMap());
  }

  UserModel? getUserById(String id) {
    if (!_isInitialized) return null;
    final map = _usersBox.get(id);
    if (map != null && map is Map) {
      return UserModel.fromMap(map);
    }
    return null;
  }

  UserModel? getUserByUsername(String username) {
    if (!_isInitialized) return null;
    final lower = username.trim().toLowerCase();
    for (final key in _usersBox.keys) {
      final map = _usersBox.get(key);
      if (map is Map &&
          (map['username'] as String? ?? '').trim().toLowerCase() == lower) {
        return UserModel.fromMap(map);
      }
    }
    return null;
  }

  UserModel? getUserByEmail(String email) {
    if (!_isInitialized) return null;
    final lower = email.trim().toLowerCase();
    for (final key in _usersBox.keys) {
      final map = _usersBox.get(key);
      if (map is Map &&
          (map['email'] as String? ?? '').trim().toLowerCase() == lower) {
        return UserModel.fromMap(map);
      }
    }
    return null;
  }

  // ===================== HABIT OPERATIONS =====================

  Future<void> saveHabit(HabitModel habit) async {
    if (!_isInitialized) return;
    await _habitsBox.put(habit.id, habit.toMap());
  }

  List<HabitModel> getHabitsForUser(String userId) {
    if (!_isInitialized) return [];
    final List<HabitModel> habits = [];
    for (final key in _habitsBox.keys) {
      final map = _habitsBox.get(key);
      if (map is Map && map['userId'] == userId) {
        habits.add(HabitModel.fromMap(map));
      }
    }
    habits.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return habits;
  }

  HabitModel? getHabitById(String id) {
    if (!_isInitialized) return null;
    final map = _habitsBox.get(id);
    if (map is Map) {
      return HabitModel.fromMap(map);
    }
    return null;
  }

  Future<void> deleteHabit(String id) async {
    if (!_isInitialized) return;
    await _habitsBox.delete(id);
    final noteKeysToDelete = <dynamic>[];
    for (final key in _notesBox.keys) {
      final map = _notesBox.get(key);
      if (map is Map && map['habitId'] == id) {
        noteKeysToDelete.add(key);
      }
    }
    await _notesBox.deleteAll(noteKeysToDelete);
  }

  // ===================== NOTE OPERATIONS =====================

  Future<void> saveNote(NoteModel note) async {
    if (!_isInitialized) return;
    await _notesBox.put(note.id, note.toMap());
  }

  List<NoteModel> getAllNotesForUser(String userId) {
    if (!_isInitialized) return [];
    final List<NoteModel> notes = [];
    for (final key in _notesBox.keys) {
      final map = _notesBox.get(key);
      if (map is Map && map['userId'] == userId) {
        notes.add(NoteModel.fromMap(map));
      }
    }
    notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notes;
  }

  List<NoteModel> getNotesByHabit(String userId, String habitId) {
    if (!_isInitialized) return [];
    final List<NoteModel> notes = [];
    for (final key in _notesBox.keys) {
      final map = _notesBox.get(key);
      if (map is Map && map['userId'] == userId && map['habitId'] == habitId) {
        notes.add(NoteModel.fromMap(map));
      }
    }
    notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notes;
  }

  Future<void> deleteNote(String noteId) async {
    if (!_isInitialized) return;
    await _notesBox.delete(noteId);
  }

  // ===================== REPORT OPERATIONS =====================

  Future<void> saveReport(PdfReportModel report) async {
    if (!_isInitialized) return;
    await _reportsBox.put(report.id, report.toMap());
  }

  List<PdfReportModel> getReportsForUser(String userId) {
    if (!_isInitialized) return [];
    final List<PdfReportModel> list = [];
    for (final key in _reportsBox.keys) {
      final map = _reportsBox.get(key);
      if (map is Map && map['userId'] == userId) {
        list.add(PdfReportModel.fromMap(map));
      }
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  List<PdfReportModel> getReportsForHabit(String userId, String habitId) {
    if (!_isInitialized) return [];
    final List<PdfReportModel> list = [];
    for (final key in _reportsBox.keys) {
      final map = _reportsBox.get(key);
      if (map is Map && map['userId'] == userId && map['habitId'] == habitId) {
        list.add(PdfReportModel.fromMap(map));
      }
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> deleteReport(String reportId) async {
    if (!_isInitialized) return;
    final map = _reportsBox.get(reportId);
    if (map is Map) {
      final filePath = map['filePath'] as String?;
      if (filePath != null && filePath.isNotEmpty) {
        try {
          final file = File(filePath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          debugPrint('Error deleting report file: $e');
        }
      }
    }
    await _reportsBox.delete(reportId);
  }

  // ===================== CHAT OPERATIONS =====================

  Future<void> saveChatMessage(ChatMessageModel message) async {
    if (!_isInitialized) return;
    await _chatBox.put(message.id, message.toMap());
  }

  List<ChatMessageModel> getChatHistory(String userId, {String? habitId}) {
    if (!_isInitialized) return [];
    final List<ChatMessageModel> list = [];
    for (final key in _chatBox.keys) {
      final map = _chatBox.get(key);
      if (map is Map && map['userId'] == userId) {
        if (habitId == null || map['habitId'] == habitId) {
          list.add(ChatMessageModel.fromMap(map));
        }
      }
    }
    list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return list;
  }

  // ===================== ACCOUNT DELETION (WIPEOUT) =====================

  Future<void> deleteUserAccountCompletely(String userId) async {
    if (!_isInitialized) return;
    // 1. Delete all reports files from disk
    final userReports = getReportsForUser(userId);
    for (final report in userReports) {
      try {
        final f = File(report.filePath);
        if (await f.exists()) {
          await f.delete();
        }
      } catch (_) {}
    }

    // 2. Clear boxes entries for this user
    final habitsToDelete = _habitsBox.keys
        .where((k) => (_habitsBox.get(k) as Map?)?['userId'] == userId)
        .toList();
    await _habitsBox.deleteAll(habitsToDelete);

    final notesToDelete = _notesBox.keys
        .where((k) => (_notesBox.get(k) as Map?)?['userId'] == userId)
        .toList();
    await _notesBox.deleteAll(notesToDelete);

    final reportsToDelete = _reportsBox.keys
        .where((k) => (_reportsBox.get(k) as Map?)?['userId'] == userId)
        .toList();
    await _reportsBox.deleteAll(reportsToDelete);

    final chatToDelete = _chatBox.keys
        .where((k) => (_chatBox.get(k) as Map?)?['userId'] == userId)
        .toList();
    await _chatBox.deleteAll(chatToDelete);

    // 3. Delete user record & session
    await _usersBox.delete(userId);
    if (getCurrentUserId() == userId) {
      await setCurrentUserId(null);
    }
  }

  /// App documents directory for reports
  Future<String> getReportsDirectoryPath() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final reportsDir = Directory('${appDocDir.path}/mentor_reports');
    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }
    return reportsDir.path;
  }
}
