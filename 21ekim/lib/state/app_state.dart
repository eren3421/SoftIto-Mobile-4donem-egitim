import 'package:flutter/foundation.dart';
import '../models/greenhouse.dart';
import '../models/plant.dart';
import '../models/plant_species.dart';
import '../models/pest_diagnosis.dart';
import '../models/note_and_harvest.dart';
import '../data/seed_data.dart';
import '../services/storage_service.dart';
import '../utils/care_calculator.dart';

class AppState extends ChangeNotifier {
  String _lang = 'tr';
  String? _currentUserEmail;
  bool _isLoading = true;

  List<Greenhouse> _greenhouses = [];
  List<Plant> _plants = [];
  List<NoteAndHarvest> _notes = [];

  final List<PlantSpecies> speciesCatalog = SeedData.plantSpeciesList;
  final List<PestDiagnosis> pestCatalog = SeedData.pestDiagnosisList;

  String get lang => _lang;
  String? get currentUserEmail => _currentUserEmail;
  bool get isLoggedIn => _currentUserEmail != null;
  bool get isLoading => _isLoading;

  List<Greenhouse> get greenhouses => List.unmodifiable(_greenhouses);
  List<Plant> get plants => List.unmodifiable(_plants);
  List<NoteAndHarvest> get notes => List.unmodifiable(_notes);

  AppState() {
    _initialize();
  }

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    _lang = await StorageService.loadLanguage();
    final savedUser = await StorageService.loadAuthUser();
    if (savedUser != null) {
      _currentUserEmail = savedUser['email'];
    }

    _greenhouses = await StorageService.loadGreenhouses();
    _plants = await StorageService.loadPlants();
    _notes = await StorageService.loadNotes();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    _lang = _lang == 'tr' ? 'en' : 'tr';
    await StorageService.saveLanguage(_lang);
    notifyListeners();
  }

  Future<void> setLanguage(String newLang) async {
    _lang = newLang;
    await StorageService.saveLanguage(_lang);
    notifyListeners();
  }

  // --- Auth Actions ---
  Future<bool> login(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) return false;
    // Default allowed credentials or any non-empty demo password
    _currentUserEmail = email.trim();
    await StorageService.saveAuthUser(_currentUserEmail!, password);
    notifyListeners();
    return true;
  }

  Future<bool> register(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) return false;
    _currentUserEmail = email.trim();
    await StorageService.saveAuthUser(_currentUserEmail!, password);
    notifyListeners();
    return true;
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    if (email.trim().isEmpty || newPassword.trim().isEmpty) return false;
    _currentUserEmail = email.trim();
    await StorageService.saveAuthUser(_currentUserEmail!, newPassword);
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _currentUserEmail = null;
    await StorageService.clearAuthUser();
    notifyListeners();
  }

  // --- Greenhouse Actions ---
  Future<void> addGreenhouse({
    required String name,
    String icon = '🏡',
    String photoUrl = '',
  }) async {
    final newGh = Greenhouse(
      id: 'gh_${DateTime.now().millisecondsSinceEpoch}',
      userId: _currentUserEmail ?? 'user_default',
      name: name.trim(),
      icon: icon,
      photoUrl: photoUrl.trim(),
    );
    _greenhouses.insert(0, newGh);
    await StorageService.saveGreenhouses(_greenhouses);
    notifyListeners();
  }

  Future<void> deleteGreenhouse(String greenhouseId) async {
    // Cascade delete: Greenhouse + all related plants + all related notes
    _greenhouses.removeWhere((g) => g.id == greenhouseId);
    _plants.removeWhere((p) => p.greenhouseId == greenhouseId);
    _notes.removeWhere((n) => n.greenhouseId == greenhouseId);

    await StorageService.saveGreenhouses(_greenhouses);
    await StorageService.savePlants(_plants);
    await StorageService.saveNotes(_notes);
    notifyListeners();
  }

  // --- Plant Actions ---
  Future<void> addPlant({
    required String greenhouseId,
    required String speciesId,
    required String customName,
    required DateTime plantedAt,
    String locationNote = '',
    int? customWateringDays,
    int? customFertilizingDays,
    int? customPruningDays,
    int? customHarvestDays,
  }) async {
    final now = DateTime.now();
    final newPlant = Plant(
      id: 'plt_${now.millisecondsSinceEpoch}',
      greenhouseId: greenhouseId,
      speciesId: speciesId,
      customName: customName.trim(),
      plantedAt: plantedAt,
      lastWateredAt: now,
      lastFertilizedAt: now,
      lastPrunedAt: now,
      locationNote: locationNote.trim(),
      customWateringDays: customWateringDays,
      customFertilizingDays: customFertilizingDays,
      customPruningDays: customPruningDays,
      customHarvestDays: customHarvestDays,
    );
    _plants.insert(0, newPlant);
    await StorageService.savePlants(_plants);
    notifyListeners();
  }

  Future<void> deletePlant(String plantId) async {
    _plants.removeWhere((p) => p.id == plantId);
    _notes.removeWhere((n) => n.plantId == plantId);
    await StorageService.savePlants(_plants);
    await StorageService.saveNotes(_notes);
    notifyListeners();
  }

  Future<void> waterPlant(String plantId) async {
    final index = _plants.indexWhere((p) => p.id == plantId);
    if (index != -1) {
      _plants[index].lastWateredAt = DateTime.now();
      await StorageService.savePlants(_plants);
      notifyListeners();
    }
  }

  Future<void> fertilizePlant(String plantId) async {
    final index = _plants.indexWhere((p) => p.id == plantId);
    if (index != -1) {
      _plants[index].lastFertilizedAt = DateTime.now();
      await StorageService.savePlants(_plants);
      notifyListeners();
    }
  }

  Future<void> prunePlant(String plantId) async {
    final index = _plants.indexWhere((p) => p.id == plantId);
    if (index != -1) {
      _plants[index].lastPrunedAt = DateTime.now();
      await StorageService.savePlants(_plants);
      notifyListeners();
    }
  }

  // --- Notes & Harvest Actions ---
  Future<void> addNote({
    required String greenhouseId,
    String? plantId,
    required String title,
    required String content,
  }) async {
    final note = NoteAndHarvest(
      id: 'note_${DateTime.now().millisecondsSinceEpoch}',
      greenhouseId: greenhouseId,
      plantId: plantId,
      type: 'note',
      title: title.trim(),
      content: content.trim(),
    );
    _notes.insert(0, note);
    await StorageService.saveNotes(_notes);
    notifyListeners();
  }

  Future<void> addHarvestRecord({
    required String greenhouseId,
    required String plantId,
    required String title,
    required String content,
    required int harvestAmountGrams,
    required int qualityRating,
  }) async {
    final harvest = NoteAndHarvest(
      id: 'harvest_${DateTime.now().millisecondsSinceEpoch}',
      greenhouseId: greenhouseId,
      plantId: plantId,
      type: 'harvest',
      title: title.trim(),
      content: content.trim(),
      harvestAmountGrams: harvestAmountGrams,
      qualityRating: qualityRating,
    );
    _notes.insert(0, harvest);
    await StorageService.saveNotes(_notes);
    notifyListeners();
  }

  Future<void> addTreatmentRecord({
    required String greenhouseId,
    required String plantId,
    required String diagnosisTitle,
    required String treatmentContent,
  }) async {
    final treatment = NoteAndHarvest(
      id: 'treat_${DateTime.now().millisecondsSinceEpoch}',
      greenhouseId: greenhouseId,
      plantId: plantId,
      type: 'treatment',
      title: diagnosisTitle,
      content: treatmentContent,
    );
    _notes.insert(0, treatment);
    await StorageService.saveNotes(_notes);
    notifyListeners();
  }

  Future<void> deleteNote(String noteId) async {
    _notes.removeWhere((n) => n.id == noteId);
    await StorageService.saveNotes(_notes);
    notifyListeners();
  }

  // --- Helper Queries ---
  PlantSpecies? getSpeciesById(String speciesId) {
    try {
      return speciesCatalog.firstWhere((s) => s.speciesId == speciesId);
    } catch (_) {
      return null;
    }
  }

  List<Plant> getPlantsForGreenhouse(String greenhouseId) {
    return _plants.where((p) => p.greenhouseId == greenhouseId).toList();
  }

  List<NoteAndHarvest> getNotesForGreenhouse(String greenhouseId) {
    return _notes.where((n) => n.greenhouseId == greenhouseId).toList();
  }

  List<NoteAndHarvest> getNotesForPlant(String plantId) {
    return _notes.where((n) => n.plantId == plantId).toList();
  }

  Greenhouse? getGreenhouseById(String id) {
    try {
      return _greenhouses.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  Plant? getPlantById(String id) {
    try {
      return _plants.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  bool hasUrgentCareInGreenhouse(String greenhouseId) {
    final ghPlants = getPlantsForGreenhouse(greenhouseId);
    for (final plant in ghPlants) {
      final species = getSpeciesById(plant.speciesId);
      final waterInterval =
          plant.customWateringDays ?? species?.wateringIntervalDays ?? 3;
      final fertInterval =
          plant.customFertilizingDays ?? species?.fertilizingIntervalDays ?? 14;

      final waterStatus = CareCalculator.evaluate(
          lastActionDate: plant.lastWateredAt, intervalDays: waterInterval);
      final fertStatus = CareCalculator.evaluate(
          lastActionDate: plant.lastFertilizedAt, intervalDays: fertInterval);

      if (waterStatus.level == CareAlertLevel.overdue ||
          fertStatus.level == CareAlertLevel.overdue) {
        return true;
      }
    }
    return false;
  }
}
