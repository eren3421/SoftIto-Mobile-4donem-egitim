import 'package:flutter/material.dart';
import '../models/pest_diagnosis.dart';
import '../services/i18n_service.dart';

class PestDiagnosisPanel extends StatefulWidget {
  final List<PestDiagnosis> catalog;
  final String lang;
  final Function(String title, String treatment) onApplyTreatment;

  const PestDiagnosisPanel({
    super.key,
    required this.catalog,
    required this.lang,
    required this.onApplyTreatment,
  });

  @override
  State<PestDiagnosisPanel> createState() => _PestDiagnosisPanelState();
}

class _PestDiagnosisPanelState extends State<PestDiagnosisPanel> {
  final Set<String> _selectedSymptoms = {};

  // All distinct symptoms and display labels
  final Map<String, Map<String, String>> _symptomDefinitions = {
    'yaprak_sararmasi': {
      'tr': 'Yaprak Sararması',
      'en': 'Yellowing Leaves',
    },
    'yaprak_alti_beyaz_bocek': {
      'tr': 'Yaprak Altı Beyaz Sinekler',
      'en': 'White Insects Under Leaves',
    },
    'yapiskan_yuzey': {
      'tr': 'Yapışkan Yüzey (Balımsı)',
      'en': 'Sticky Honeydew Residue',
    },
    'beyaz_leke': {
      'tr': 'Beyaz Pudra/Unsu Leke',
      'en': 'White Powdery Spots',
    },
    'unsu_tabaka': {
      'tr': 'Yaprakta Unsu Tabaka',
      'en': 'Flour-like Coating',
    },
    'yaprak_delik': {
      'tr': 'Yapraklarda Delikler',
      'en': 'Holes in Leaves',
    },
    'kemirilmis_kenar': {
      'tr': 'Kemirilmiş Kenarlar',
      'en': 'Chewed Leaf Edges',
    },
    'orumcek_agi': {
      'tr': 'İnce Örümcek Ağı',
      'en': 'Fine Webbing Under Leaves',
    },
    'nokta_sararma': {
      'tr': 'Noktasal Bronzlaşma',
      'en': 'Speckled Bronzing',
    },
    'kok_kararmasi': {
      'tr': 'Kök / Gövde Kararması',
      'en': 'Darkening Stem / Roots',
    },
    'yaprak_kivrilmasi': {
      'tr': 'Yaprak Kıvrılması',
      'en': 'Leaf Curling',
    },
  };

  @override
  Widget build(BuildContext context) {
    final matches = _filterMatches();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.get('select_symptoms_instruction', widget.lang),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),

          // Symptom Filter Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _symptomDefinitions.entries.map((entry) {
              final symptomKey = entry.key;
              final isSelected = _selectedSymptoms.contains(symptomKey);
              final label = entry.value[widget.lang] ?? entry.value['tr']!;

              return FilterChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedSymptoms.add(symptomKey);
                    } else {
                      _selectedSymptoms.remove(symptomKey);
                    }
                  });
                },
                selectedColor: const Color(0xFF1B5E20).withOpacity(0.15),
                checkmarkColor: const Color(0xFF1B5E20),
                backgroundColor: const Color(0xFFF1F5F9),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF1B5E20)
                      : const Color(0xFF475569),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF1B5E20)
                        : Colors.transparent,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Matched Diagnoses
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppStrings.get('matched_diagnoses', widget.lang)} (${matches.length})',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              if (_selectedSymptoms.isNotEmpty)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedSymptoms.clear();
                    });
                  },
                  child: Text(
                    widget.lang == 'en' ? 'Clear Filters' : 'Filtreleri Temizle',
                    style: const TextStyle(fontSize: 12, color: Color(0xFFEF4444)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          if (matches.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  widget.lang == 'en'
                      ? 'No exact matches found for selected symptoms. Try selecting different symptoms.'
                      : 'Seçili belirtilere tam uyan teşhis bulunamadı. Lütfen başka belirtileri işaretleyin.',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: matches.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = matches[index];
                return _buildDiagnosisCard(item);
              },
            ),
        ],
      ),
    );
  }

  List<PestDiagnosis> _filterMatches() {
    if (_selectedSymptoms.isEmpty) {
      return widget.catalog;
    }
    final scored = widget.catalog.map((item) {
      final matchedCount =
          item.symptoms.where((s) => _selectedSymptoms.contains(s)).length;
      return MapEntry(item, matchedCount);
    }).where((entry) => entry.value > 0).toList();

    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.map((e) => e.key).toList();
  }

  Widget _buildDiagnosisCard(PestDiagnosis item) {
    Color severityColor;
    String severityLabel;

    switch (item.severity) {
      case 'high':
        severityColor = const Color(0xFFEF4444);
        severityLabel = AppStrings.get('severity_high', widget.lang);
        break;
      case 'low':
        severityColor = const Color(0xFF10B981);
        severityLabel = AppStrings.get('severity_low', widget.lang);
        break;
      default:
        severityColor = const Color(0xFFF59E0B);
        severityLabel = AppStrings.get('severity_medium', widget.lang);
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      item.category == 'disease' ? '🍄' : '🐛',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        item.name.get(widget.lang),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: severityColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: severityColor.withOpacity(0.4)),
                ),
                child: Text(
                  severityLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: severityColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            item.diagnosisSummary.get(widget.lang),
            style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
          ),
          const SizedBox(height: 12),

          // Organic Treatment Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.eco_rounded,
                        size: 16, color: Color(0xFF047857)),
                    const SizedBox(width: 6),
                    Text(
                      AppStrings.get('organic_solution', widget.lang),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF047857),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.organicTreatment.get(widget.lang),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF065F46)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Prevention Tips
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.shield_outlined,
                  size: 15, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${AppStrings.get('prevention_advice', widget.lang)} ${item.preventionTips.get(widget.lang)}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Save Treatment Note Action
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () {
                widget.onApplyTreatment(
                  item.name.get(widget.lang),
                  item.organicTreatment.get(widget.lang),
                );
              },
              icon: const Icon(Icons.note_add_rounded, size: 15),
              label: Text(
                AppStrings.get('apply_treatment_note', widget.lang),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
