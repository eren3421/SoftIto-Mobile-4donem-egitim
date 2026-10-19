import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../controller/water_tracker_controller.dart';
import '../widget/water_history_tile.dart';
import '../widget/water_progress_card.dart';
import '../widget/water_quick_add_buttons.dart';

class WaterTrackerView extends StatelessWidget {
  const WaterTrackerView({
    required this.controller,
    super.key,
  });

  final WaterTrackerController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WaterProgressCard(
                currentMl: controller.currentAmountMl,
                targetMl: controller.dailyTargetMl,
                progress: controller.progressRatio,
              ),
              const SizedBox(height: 24),
              Text('Hızlı Ekle', style: context.textTheme.titleMedium),
              const SizedBox(height: 12),
              WaterQuickAddButtons(onAdd: controller.addWater),
              const SizedBox(height: 28),
              _WaterHistoryHeader(onReset: controller.reset),
              const SizedBox(height: 12),
              _WaterHistoryList(controller: controller),
            ],
          ),
        );
      },
    );
  }
}

class _WaterHistoryHeader extends StatelessWidget {
  const _WaterHistoryHeader({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Bugünkü Kayıtlar', style: context.textTheme.titleMedium),
        TextButton(
          onPressed: onReset,
          child: Text(
            'Sıfırla',
            style: context.textTheme.bodySmall?.copyWith(color: AppColors.error),
          ),
        ),
      ],
    );
  }
}

class _WaterHistoryList extends StatelessWidget {
  const _WaterHistoryList({required this.controller});

  final WaterTrackerController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.logs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'Henüz su kaydı bulunmuyor.',
            style: context.textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
          ),
        ),
      );
    }

    return Column(
      children: controller.logs.map((log) {
        return WaterHistoryTile(
          log: log,
          onDelete: () => controller.removeLog(log.id),
        );
      }).toList(),
    );
  }
}
