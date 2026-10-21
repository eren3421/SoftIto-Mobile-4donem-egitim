import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/greenhouse.dart';
import '../models/plant.dart';
import '../models/note_and_harvest.dart';
import '../data/seed_data.dart';

class StorageService {
  static const String _keyGreenhouses = 'bahcivan_greenhouses_v1';
  static const String _keyPlants = 'bahcivan_plants_v1';
  static const String _keyNotes = 'bahcivan_notes_v1';
  static const String _keyLang = 'bahcivan_lang_v1';
  static const String _keyUser = 'bahcivan_user_v1';

  static Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  static Future<String> loadLanguage() async {
    final prefs = await _getPrefs();
    return prefs.getString(_keyLang) ?? 'tr';
  }

  static Future<void> saveLanguage(String lang) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyLang, lang);
  }

  static Future<Map<String, String>?> loadAuthUser() async {
    final prefs = await _getPrefs();
    final data = prefs.getString(_keyUser);
    if (data == null) return null;
    try {
      final map = jsonDecode(data) as Map<String, dynamic>;
      return {'email': map['email'] ?? '', 'password': map['password'] ?? ''};
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveAuthUser(String email, String password) async {
    final prefs = await _getPrefs();
    await prefs.setString(
        _keyUser, jsonEncode({'email': email, 'password': password}));
  }

  static Future<void> clearAuthUser() async {
    final prefs = await _getPrefs();
    await prefs.remove(_keyUser);
  }

  static Future<List<Greenhouse>> loadGreenhouses() async {
    final prefs = await _getPrefs();
    final jsonStr = prefs.getString(_keyGreenhouses);
    if (jsonStr == null) {
      final initial = SeedData.getInitialGreenhouses();
      await saveGreenhouses(initial);
      return initial;
    }
    try {
      final list = jsonDecode(jsonStr) as List;
      return list.map((e) => Greenhouse.fromJson(e)).toList();
    } catch (_) {
      return SeedData.getInitialGreenhouses();
    }
  }

  static Future<void> saveGreenhouses(List<Greenhouse> list) async {
    final prefs = await _getPrefs();
    final jsonStr = jsonEncode(list.map((e) => e.toJson()).toList());
    await prefs.setString(_keyGreenhouses, jsonStr);
  }

  static Future<List<Plant>> loadPlants() async {
    final prefs = await _getPrefs();
    final jsonStr = prefs.getString(_keyPlants);
    if (jsonStr == null) {
      final initial = SeedData.getInitialPlants();
      await savePlants(initial);
      return initial;
    }
    try {
      final list = jsonDecode(jsonStr) as List;
      return list.map((e) => Plant.fromJson(e)).toList();
    } catch (_) {
      return SeedData.getInitialPlants();
    }
  }

  static Future<void> savePlants(List<Plant> list) async {
    final prefs = await _getPrefs();
    final jsonStr = jsonEncode(list.map((e) => e.toJson()).toList());
    await prefs.setString(_keyPlants, jsonStr);
  }

  static Future<List<NoteAndHarvest>> loadNotes() async {
    final prefs = await _getPrefs();
    final jsonStr = prefs.getString(_keyNotes);
    if (jsonStr == null) {
      final initial = SeedData.getInitialNotes();
      await saveNotes(initial);
      return initial;
    }
    try {
      final list = jsonDecode(jsonStr) as List;
      return list.map((e) => NoteAndHarvest.fromJson(e)).toList();
    } catch (_) {
      return SeedData.getInitialNotes();
    }
  }

  static Future<void> saveNotes(List<NoteAndHarvest> list) async {
    final prefs = await _getPrefs();
    final jsonStr = jsonEncode(list.map((e) => e.toJson()).toList());
    await prefs.setString(_keyNotes, jsonStr);
  }
}
