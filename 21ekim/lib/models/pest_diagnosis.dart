import 'plant_species.dart';

class PestDiagnosis {
  final String id;
  final LocalizedText name;
  final String category; // 'pest' or 'disease'
  final String severity; // 'low', 'medium', 'high'
  final List<String> symptoms;
  final Map<String, List<String>> symptomLabels;
  final LocalizedText diagnosisSummary;
  final LocalizedText organicTreatment;
  final LocalizedText preventionTips;

  const PestDiagnosis({
    required this.id,
    required this.name,
    required this.category,
    required this.severity,
    required this.symptoms,
    required this.symptomLabels,
    required this.diagnosisSummary,
    required this.organicTreatment,
    required this.preventionTips,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name.toJson(),
        'category': category,
        'severity': severity,
        'symptoms': symptoms,
        'symptomLabels': symptomLabels,
        'diagnosisSummary': diagnosisSummary.toJson(),
        'organicTreatment': organicTreatment.toJson(),
        'preventionTips': preventionTips.toJson(),
      };

  factory PestDiagnosis.fromJson(Map<String, dynamic> json) {
    return PestDiagnosis(
      id: json['id'] ?? '',
      name: LocalizedText.fromJson(Map<String, dynamic>.from(json['name'] ?? {})),
      category: json['category'] ?? 'pest',
      severity: json['severity'] ?? 'medium',
      symptoms: List<String>.from(json['symptoms'] ?? []),
      symptomLabels: (json['symptomLabels'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, List<String>.from(v ?? [])),
          ) ??
          {},
      diagnosisSummary:
          LocalizedText.fromJson(Map<String, dynamic>.from(json['diagnosisSummary'] ?? {})),
      organicTreatment:
          LocalizedText.fromJson(Map<String, dynamic>.from(json['organicTreatment'] ?? {})),
      preventionTips:
          LocalizedText.fromJson(Map<String, dynamic>.from(json['preventionTips'] ?? {})),
    );
  }
}
