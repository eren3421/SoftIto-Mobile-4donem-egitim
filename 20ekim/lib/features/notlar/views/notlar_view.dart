import 'package:flutter/material.dart';
import '../controllers/notlar_controller.dart';
import '../models/not_model.dart';
import '../widgets/note_card.dart';
import '../widgets/note_filter_bar.dart';
import '../widgets/note_search_bar.dart';
import '../widgets/add_note_dialog.dart';

/// Girişimcinin not defteri, raporları ve fikirleri ana ekranı.
class NotlarView extends StatelessWidget {
  final NotlarController controller;

  const NotlarView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          NoteSearchBar(onChanged: controller.setSearchQuery),
          ValueListenableBuilder<String>(
            valueListenable: controller.selectedCategory,
            builder: (context, cat, _) => NoteFilterBar(
              selectedCategory: cat,
              onSelect: controller.setCategory,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildNotesList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddNoteDialog(context),
        icon: const Icon(Icons.edit_note),
        label: const Text('Not Yaz'),
      ),
    );
  }

  Widget _buildNotesList() {
    return ValueListenableBuilder<List<NotModel>>(
      valueListenable: controller.notes,
      builder: (context, _, _) => ValueListenableBuilder<String>(
        valueListenable: controller.searchQuery,
        builder: (context, _, _) => ValueListenableBuilder<String>(
          valueListenable: controller.selectedCategory,
          builder: (context, _, _) {
            final items = controller.filteredNotes;
            if (items.isEmpty) return _buildEmptyPlaceholder(context);

            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final note = items[index];
                return NoteCard(
                  note: note,
                  onToggleFavorite: () => controller.toggleFavorite(note.id),
                  onTogglePin: () => controller.togglePin(note.id),
                  onDelete: () => controller.deleteNote(note.id),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyPlaceholder(BuildContext context) {
    return const Center(
      child: Text('Kriterlere uygun kayıtlı bir not bulunamadı.'),
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AddNoteDialog(onAdd: controller.addNote),
    );
  }
}
