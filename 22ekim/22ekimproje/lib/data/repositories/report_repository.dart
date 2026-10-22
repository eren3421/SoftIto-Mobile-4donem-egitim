import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../local/hive_storage_service.dart';
import '../models/pdf_report_model.dart';
import 'auth_repository.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository(storage: HiveStorageService.instance);
});

final userReportsProvider =
    StateNotifierProvider<ReportsNotifier, List<PdfReportModel>>((ref) {
  final repo = ref.watch(reportRepositoryProvider);
  final currentUser = ref.watch(currentUserProvider);
  return ReportsNotifier(repo: repo, userId: currentUser?.id);
});

class ReportsNotifier extends StateNotifier<List<PdfReportModel>> {
  final ReportRepository _repo;
  final String? _userId;

  ReportsNotifier({
    required ReportRepository repo,
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
    state = _repo.getReportsForUser(_userId);
  }

  Future<void> deleteReport(String reportId) async {
    await _repo.deleteReport(reportId);
    refresh();
  }
}

class ReportRepository {
  final HiveStorageService _storage;

  ReportRepository({required HiveStorageService storage}) : _storage = storage;

  List<PdfReportModel> getReportsForUser(String userId) {
    return _storage.getReportsForUser(userId);
  }

  List<PdfReportModel> getReportsForHabit(String userId, String habitId) {
    return _storage.getReportsForHabit(userId, habitId);
  }

  Future<void> deleteReport(String reportId) async {
    await _storage.deleteReport(reportId);
  }
}
