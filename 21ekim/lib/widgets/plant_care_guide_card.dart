import 'package:flutter/material.dart';
import '../models/plant_species.dart';
import '../services/i18n_service.dart';

class PlantCareGuideCard extends StatelessWidget {
  final PlantSpecies species;
  final String lang;

  const PlantCareGuideCard({
    super.key,
    required this.species,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
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
          // Header
          Row(
            children: [
              Text(species.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${species.name.get(lang)} (${species.scientificName})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      species.category.get(lang),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 4 Grid Guidance Boxes
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 500;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildGuidanceBox(
                    width: isWide ? (constraints.maxWidth - 16) / 2 : double.infinity,
                    icon: Icons.wb_sunny_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    title: AppStrings.get('sunlight_guide', lang),
                    value: '${species.sunlightHours} • ${species.sunlightType.get(lang)}',
                    description: '',
                  ),
                  _buildGuidanceBox(
                    width: isWide ? (constraints.maxWidth - 16) / 2 : double.infinity,
                    icon: Icons.water_drop_rounded,
                    iconColor: const Color(0xFF0EA5E9),
                    title: AppStrings.get('watering_guide', lang),
                    value:
                        '${species.wateringIntervalDays} ${AppStrings.get('days_interval', lang)} (${species.wateringAmountMl} ml)',
                    description: species.wateringTip.get(lang),
                  ),
                  _buildGuidanceBox(
                    width: isWide ? (constraints.maxWidth - 16) / 2 : double.infinity,
                    icon: Icons.thermostat_rounded,
                    iconColor: const Color(0xFFEF4444),
                    title: AppStrings.get('climate_guide', lang),
                    value: '${species.idealTempRange} • Nem: ${species.idealHumidity}',
                    description: species.fertilizingTip.get(lang),
                  ),
                  _buildGuidanceBox(
                    width: isWide ? (constraints.maxWidth - 16) / 2 : double.infinity,
                    icon: Icons.content_cut_rounded,
                    iconColor: const Color(0xFF10B981),
                    title: AppStrings.get('pruning_guide', lang),
                    value:
                        '${species.pruningIntervalDays} ${AppStrings.get('days_interval', lang)}',
                    description: species.pruningTip.get(lang),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGuidanceBox({
    required double width,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String description,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
