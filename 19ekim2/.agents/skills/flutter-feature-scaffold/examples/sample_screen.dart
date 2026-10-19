import 'package:flutter/material.dart';
import 'sample_card_widget.dart';
import 'sample_controller.dart';
import 'sample_model.dart';

/// Örnek Modüler Ekran Görünümü (Susadım Clean UI & ValueNotifier Standartı)
class SampleScreen extends StatefulWidget {
  final SampleActivityController? controller;

  const SampleScreen({
    super.key,
    this.controller,
  });

  @override
  State<SampleScreen> createState() => _SampleScreenState();
}

class _SampleScreenState extends State<SampleScreen> {
  late final SampleActivityController _controller;
  late final bool _isInternalController;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
      _isInternalController = false;
    } else {
      _controller = SampleActivityController();
      _isInternalController = true;
    }
  }

  @override
  void dispose() {
    if (_isInternalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Örnek Aktivite Takibi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Sıfırla',
            onPressed: _controller.reset,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProgressSection(),
            const SizedBox(height: 20),
            _buildHistorySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return ValueListenableBuilder<int>(
      valueListenable: _controller.currentCount,
      builder: (context, current, _) {
        return SampleCardWidget(
          current: current,
          goal: _controller.targetGoal,
          onAdd: () => _controller.addActivity('Hızlı Ekleme', 250),
        );
      },
    );
  }

  Widget _buildHistorySection() {
    return ValueListenableBuilder<List<SampleActivityModel>>(
      valueListenable: _controller.activities,
      builder: (context, activities, _) {
        if (activities.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Text('Henüz aktivite kaydı bulunmuyor.'),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activities.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = activities[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.check_circle_outline),
              title: Text(item.title),
              trailing: Text(
                '+${item.value}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          },
        );
      },
    );
  }
}
