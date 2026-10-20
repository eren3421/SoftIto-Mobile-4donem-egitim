import 'package:flutter/foundation.dart';
import '../models/tablo_model.dart';

/// Finansal tablolar, bütçeler ve kaynak yönetimini yöneten kontrolcü.
/// Sadece flutter/foundation.dart kullanır ve ValueNotifier tabanlıdır.
class TabloController {
  final ValueNotifier<List<ProjectModel>> projects =
      ValueNotifier<List<ProjectModel>>(<ProjectModel>[
    ProjectModel(
      id: 'proj_1',
      name: 'Yapay Zeka SaaS',
      description: 'Girişimciler için otomatik müşteri analitiği platformu',
      category: 'Yazılım',
      totalBudget: 450000.0,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
    ProjectModel(
      id: 'proj_2',
      name: 'Mobil Pazar Yeri',
      description: 'Zanaatkar ürünleri için B2C mobil uygulama',
      category: 'E-Ticaret',
      totalBudget: 280000.0,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
  ]);

  final ValueNotifier<String?> selectedProjectId =
      ValueNotifier<String?>(null); // null: Tüm Projeler

  final ValueNotifier<List<TransactionModel>> transactions =
      ValueNotifier<List<TransactionModel>>(<TransactionModel>[
    TransactionModel(
      id: 'tx_1',
      projectId: 'proj_1',
      title: 'TÜBİTAK 1507 Ar-Ge Hibesi',
      amount: 150000.0,
      isIncome: true,
      category: 'Hibe / Teşvik',
      date: DateTime.now().subtract(const Duration(days: 30)),
      note: '1. Aşama kabul ödemesi',
    ),
    TransactionModel(
      id: 'tx_2',
      projectId: 'proj_1',
      title: 'Bulut Sunucu & GPU Kiralama',
      amount: 18500.0,
      isIncome: false,
      category: 'Altyapı',
      date: DateTime.now().subtract(const Duration(days: 18)),
      note: 'Model eğitimi için GPU kümesi',
    ),
    TransactionModel(
      id: 'tx_3',
      projectId: 'proj_1',
      title: 'Melek Yatırımcı Girişi',
      amount: 300000.0,
      isIncome: true,
      category: 'Yatırım',
      date: DateTime.now().subtract(const Duration(days: 12)),
      note: '%5 hisse karşılığı tohum yatırım',
    ),
    TransactionModel(
      id: 'tx_4',
      projectId: 'proj_1',
      title: 'Kıdemli Geliştirici Sözleşmesi',
      amount: 45000.0,
      isIncome: false,
      category: 'Personel',
      date: DateTime.now().subtract(const Duration(days: 5)),
      note: 'Backend mimari kurulumu',
    ),
    TransactionModel(
      id: 'tx_5',
      projectId: 'proj_2',
      title: 'UI/UX Tasarım Sprinti',
      amount: 22000.0,
      isIncome: false,
      category: 'Tasarım',
      date: DateTime.now().subtract(const Duration(days: 3)),
      note: 'Mobil ekran prototipleri',
    ),
  ]);

  final ValueNotifier<String> filterType = ValueNotifier<String>('Tümü');

  List<TransactionModel> get filteredTransactions {
    final projId = selectedProjectId.value;
    final fType = filterType.value;

    return transactions.value.where((tx) {
      final matchesProject = projId == null || tx.projectId == projId;
      if (!matchesProject) return false;

      if (fType == 'Gelir') return tx.isIncome;
      if (fType == 'Gider') return !tx.isIncome;
      return true;
    }).toList();
  }

  double get totalIncome {
    final projId = selectedProjectId.value;
    return transactions.value
        .where((tx) =>
            (projId == null || tx.projectId == projId) && tx.isIncome)
        .fold(0.0, (acc, tx) => acc + tx.amount);
  }

  double get totalExpense {
    final projId = selectedProjectId.value;
    return transactions.value
        .where((tx) =>
            (projId == null || tx.projectId == projId) && !tx.isIncome)
        .fold(0.0, (acc, tx) => acc + tx.amount);
  }

  double get netBalance => totalIncome - totalExpense;

  double get totalAllocatedBudget {
    final projId = selectedProjectId.value;
    if (projId == null) {
      return projects.value.fold(0.0, (acc, p) => acc + p.totalBudget);
    }
    final proj = projects.value.firstWhere(
      (p) => p.id == projId,
      orElse: () => ProjectModel(
        id: '',
        name: '',
        description: '',
        category: '',
        totalBudget: 0.0,
        createdAt: DateTime.now(),
      ),
    );
    return proj.totalBudget;
  }

  double get budgetUsageRatio {
    final total = totalAllocatedBudget;
    if (total <= 0) return 0.0;
    final ratio = totalExpense / total;
    return ratio > 1.0 ? 1.0 : (ratio < 0.0 ? 0.0 : ratio);
  }

  Map<String, double> get categoryExpenseMap {
    final projId = selectedProjectId.value;
    final map = <String, double>{};
    for (final tx in transactions.value) {
      if ((projId == null || tx.projectId == projId) && !tx.isIncome) {
        map[tx.category] = (map[tx.category] ?? 0.0) + tx.amount;
      }
    }
    return map;
  }

  void addProject({
    required String name,
    required String description,
    required String category,
    required double totalBudget,
  }) {
    final newProject = ProjectModel(
      id: 'proj_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      category: category,
      totalBudget: totalBudget,
      createdAt: DateTime.now(),
    );
    projects.value = <ProjectModel>[...projects.value, newProject];
  }

  void selectProject(String? id) {
    selectedProjectId.value = id;
  }

  void setFilterType(String type) {
    filterType.value = type;
  }

  void addTransaction({
    required String projectId,
    required String title,
    required double amount,
    required bool isIncome,
    required String category,
    required DateTime date,
    String note = '',
  }) {
    final newTx = TransactionModel(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      projectId: projectId,
      title: title,
      amount: amount,
      isIncome: isIncome,
      category: category,
      date: date,
      note: note,
    );
    transactions.value = <TransactionModel>[newTx, ...transactions.value];
  }

  void deleteTransaction(String id) {
    transactions.value =
        transactions.value.where((tx) => tx.id != id).toList();
  }

  void dispose() {
    projects.dispose();
    selectedProjectId.dispose();
    transactions.dispose();
    filterType.dispose();
  }
}
