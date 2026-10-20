import 'package:flutter/material.dart';

/// Yeni not, rapor veya fikir ekleme iletişim kutusu.
class AddNoteDialog extends StatefulWidget {
  final void Function({
    required String title,
    required String content,
    required String category,
  }) onAdd;

  const AddNoteDialog({super.key, required this.onAdd});

  @override
  State<AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<AddNoteDialog> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedCategory = 'Rapor';

  static const List<String> _categories = [
    'Rapor',
    'Yol Haritası',
    'Toplantı',
    'Fikir',
    'Genel',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yeni Defter Kaydı'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCategoryDropdown(),
            const SizedBox(height: 12),
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Başlık')),
            const SizedBox(height: 12),
            TextField(controller: _contentController, maxLines: 5, decoration: const InputDecoration(labelText: 'Not / Rapor İçeriği')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
        FilledButton(onPressed: _handleSubmit, child: const Text('Kaydet')),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      decoration: const InputDecoration(labelText: 'Kayıt Türü'),
      items: _categories
          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
          .toList(),
      onChanged: (val) => setState(() => _selectedCategory = val ?? 'Genel'),
    );
  }

  void _handleSubmit() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty || content.isEmpty) return;

    widget.onAdd(
      title: title,
      content: content,
      category: _selectedCategory,
    );
    Navigator.pop(context);
  }
}
