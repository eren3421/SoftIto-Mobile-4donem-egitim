import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../models/workout_item.dart';

class WorkoutAddSheet extends StatefulWidget {
  const WorkoutAddSheet({
    required this.onAdd,
    super.key,
  });

  final void Function(WorkoutType type, int duration) onAdd;

  @override
  State<WorkoutAddSheet> createState() => _WorkoutAddSheetState();
}

class _WorkoutAddSheetState extends State<WorkoutAddSheet> {
  WorkoutType _selectedType = WorkoutType.gym;
  int _duration = 30;

  void _submit() {
    widget.onAdd(_selectedType, _duration);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Yeni Egzersiz Ekle', style: context.textTheme.titleLarge),
          const SizedBox(height: 18),
          _TypeDropdown(
            selected: _selectedType,
            onChanged: (val) => setState(() => _selectedType = val),
          ),
          const SizedBox(height: 16),
          _DurationSlider(
            duration: _duration,
            onChanged: (val) => setState(() => _duration = val.toInt()),
          ),
          const SizedBox(height: 20),
          _SaveButton(onPressed: _submit),
        ],
      ),
    );
  }
}

class _TypeDropdown extends StatelessWidget {
  const _TypeDropdown({required this.selected, required this.onChanged});

  final WorkoutType selected;
  final ValueChanged<WorkoutType> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<WorkoutType>(
      initialValue: selected,
      decoration: InputDecoration(
        labelText: 'Egzersiz Türü',
        labelStyle: context.textTheme.bodyMedium,
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dropdownColor: AppColors.surfaceLight,
      items: WorkoutType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text('${type.label} (~${type.caloriesPerMinute} kcal/dk)'),
        );
      }).toList(),
      onChanged: (val) {
        if (val != null) onChanged(val);
      },
    );
  }
}

class _DurationSlider extends StatelessWidget {
  const _DurationSlider({required this.duration, required this.onChanged});

  final int duration;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Süre: $duration dakika', style: context.textTheme.bodyMedium),
        Slider(
          value: duration.toDouble(),
          min: 5,
          max: 120,
          divisions: 23,
          activeColor: AppColors.neonOrange,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.neonOrange,
        foregroundColor: AppColors.background,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: onPressed,
      child: const Text('Kaydet ve Ekle', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
