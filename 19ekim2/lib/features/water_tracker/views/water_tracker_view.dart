import 'package:flutter/material.dart';
import '../controllers/water_tracker_controller.dart';
import '../models/water_log_model.dart';
import '../widgets/quick_water_buttons.dart';
import '../widgets/water_gauge_card.dart';
import '../widgets/water_history_list.dart';

class WaterTrackerView extends StatefulWidget {
  final WaterTrackerController controller;

  const WaterTrackerView({
    super.key,
    required this.controller,
  });

  @override
  State<WaterTrackerView> createState() => _WaterTrackerViewState();
}

class _WaterTrackerViewState extends State<WaterTrackerView> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildGaugeSection(),
          const SizedBox(height: 20),
          QuickWaterButtons(onAddWater: widget.controller.addWater),
          const SizedBox(height: 24),
          _buildHistorySection(),
        ],
      ),
    );
  }

  Widget _buildGaugeSection() {
    return ValueListenableBuilder<int>(
      valueListenable: widget.controller.currentWater,
      builder: (context, current, _) {
        return WaterGaugeCard(
          currentMl: current,
          goalMl: widget.controller.dailyGoalMl,
        );
      },
    );
  }

  Widget _buildHistorySection() {
    return ValueListenableBuilder<List<WaterLog>>(
      valueListenable: widget.controller.logs,
      builder: (context, logs, _) {
        return WaterHistoryList(logs: logs);
      },
    );
  }
}
