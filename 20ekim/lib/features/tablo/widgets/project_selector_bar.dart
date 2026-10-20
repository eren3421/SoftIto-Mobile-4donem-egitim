import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/tablo_model.dart';

/// Proje filtreleme çubuğu bileşeni.
class ProjectSelectorBar extends StatelessWidget {
  final List<ProjectModel> projects;
  final String? selectedProjectId;
  final ValueChanged<String?> onSelect;
  final VoidCallback onAddProject;

  const ProjectSelectorBar({
    super.key,
    required this.projects,
    required this.selectedProjectId,
    required this.onSelect,
    required this.onAddProject,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildChip(context, label: 'Tüm Projeler', isSelected: selectedProjectId == null, onTap: () => onSelect(null)),
          const SizedBox(width: 8),
          ...projects.map((p) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildChip(context, label: p.name, isSelected: selectedProjectId == p.id, onTap: () => onSelect(p.id)),
              )),
          IconButton.filledTonal(
            tooltip: 'Yeni Proje Ekle',
            icon: const Icon(Icons.add_business, size: 20),
            onPressed: onAddProject,
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primaryLeather,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
