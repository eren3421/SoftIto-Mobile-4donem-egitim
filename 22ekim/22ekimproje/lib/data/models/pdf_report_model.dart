class PdfReportModel {
  final String id;
  final String userId;
  final String? habitId;
  final String? habitTitle;
  final String title;
  final String filePath;
  final String expertOpinion;
  final double completionRate;
  final DateTime createdAt;

  PdfReportModel({
    required this.id,
    required this.userId,
    this.habitId,
    this.habitTitle,
    required this.title,
    required this.filePath,
    required this.expertOpinion,
    required this.completionRate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isGeneral => habitId == null || habitId!.isEmpty;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'habitId': habitId,
      'habitTitle': habitTitle,
      'title': title,
      'filePath': filePath,
      'expertOpinion': expertOpinion,
      'completionRate': completionRate,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PdfReportModel.fromMap(Map<dynamic, dynamic> map) {
    return PdfReportModel(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      habitId: map['habitId'] as String?,
      habitTitle: map['habitTitle'] as String?,
      title: map['title'] as String? ?? 'Rapor',
      filePath: map['filePath'] as String? ?? '',
      expertOpinion: map['expertOpinion'] as String? ?? '',
      completionRate: (map['completionRate'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
