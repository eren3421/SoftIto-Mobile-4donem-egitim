import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/harvest_calculator.dart';
import '../services/i18n_service.dart';

class HarvestCountdownBar extends StatelessWidget {
  final DateTime plantedAt;
  final int expectedHarvestDays;
  final String lang;
  final VoidCallback onAddHarvestLog;

  const HarvestCountdownBar({
    super.key,
    required this.plantedAt,
    required this.expectedHarvestDays,
    required this.lang,
    required this.onAddHarvestLog,
  });

  @override
  Widget build(BuildContext context) {
    final info = HarvestCalculator.calculate(
      plantedAt: plantedAt,
      expectedHarvestDays: expectedHarvestDays,
    );

    final dateFormat = DateFormat('dd.MM.yyyy');
    final plantedDateStr = dateFormat.format(plantedAt);
    final harvestDateStr = dateFormat.format(info.estimatedHarvestDate);

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
          // Dates Header
          Wrap(
            spacing: 24,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              _buildDateBadge(
                label: AppStrings.get('planted_date', lang),
                value: plantedDateStr,
                icon: Icons.calendar_today_rounded,
                color: const Color(0xFF1B5E20),
              ),
              _buildDateBadge(
                label: AppStrings.get('estimated_harvest', lang),
                value: '$harvestDateStr (${expectedHarvestDays}G)',
                icon: Icons.eco_rounded,
                color: const Color(0xFFF59E0B),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF6EE7B7)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.psychology_rounded,
                        size: 16, color: Color(0xFF047857)),
                    const SizedBox(width: 6),
                    Text(
                      info.getStage(lang),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF047857),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Progress Bar with Percentage
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: info.progressPercent / 100.0,
                    minHeight: 14,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      info.isReadyForHarvest
                          ? const Color(0xFF10B981)
                          : const Color(0xFF4CAF50),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                '%${info.progressPercent.toInt()} ${AppStrings.get('completed_badge', lang)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Counters & Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildDayCounter(
                    title: AppStrings.get('elapsed_days', lang),
                    days: info.elapsedDays,
                    unit: AppStrings.get('days_unit', lang),
                    color: const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 24),
                  _buildDayCounter(
                    title: AppStrings.get('remaining_days', lang),
                    days: info.remainingDays,
                    unit: AppStrings.get('days_unit', lang),
                    color: info.isReadyForHarvest
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF59E0B),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: onAddHarvestLog,
                icon: const Icon(Icons.add_shopping_cart_rounded, size: 16),
                label: Text(
                  AppStrings.get('add_harvest_record_btn', lang),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateBadge({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildDayCounter({
    required String title,
    required int days,
    required String unit,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF94A3B8),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$days ',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              TextSpan(
                text: unit,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
