/// Girişimcinin takip ettiği proje modeli.
class ProjectModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final double totalBudget;
  final DateTime createdAt;

  const ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.totalBudget,
    required this.createdAt,
  });

  ProjectModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? totalBudget,
    DateTime? createdAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      totalBudget: totalBudget ?? this.totalBudget,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'Genel',
      totalBudget: (json['total_budget'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'total_budget': totalBudget,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Gelir ve gider finansal işlem kaydı modeli.
class TransactionModel {
  final String id;
  final String projectId;
  final String title;
  final double amount;
  final bool isIncome; // true: Gelir, false: Gider
  final String category; // örn. Ar-Ge, Pazarlama, Operasyon, Satış vb.
  final DateTime date;
  final String note;

  const TransactionModel({
    required this.id,
    required this.projectId,
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.category,
    required this.date,
    this.note = '',
  });

  TransactionModel copyWith({
    String? id,
    String? projectId,
    String? title,
    double? amount,
    bool? isIncome,
    String? category,
    DateTime? date,
    String? note,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      isIncome: isIncome ?? this.isIncome,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String? ?? '',
      projectId: json['project_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      isIncome: json['is_income'] as bool? ?? false,
      category: json['category'] as String? ?? 'Genel',
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      note: json['note'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'title': title,
      'amount': amount,
      'is_income': isIncome,
      'category': category,
      'date': date.toIso8601String(),
      'note': note,
    };
  }
}
