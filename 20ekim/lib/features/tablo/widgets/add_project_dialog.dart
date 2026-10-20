import 'package:flutter/material.dart';

/// Yeni girişim projesi ekleme iletişim kutusu.
class AddProjectDialog extends StatefulWidget {
  final void Function({
    required String name,
    required String description,
    required String category,
    required double totalBudget,
  }) onAdd;

  const AddProjectDialog({super.key, required this.onAdd});

  @override
  State<AddProjectDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<AddProjectDialog> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _categoryController = TextEditingController(text: 'Yazılım');
  final _budgetController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _categoryController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yeni Girişim Projesi'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Proje Adı')),
            const SizedBox(height: 12),
            TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Proje Özeti / Hedefi')),
            const SizedBox(height: 12),
            TextField(controller: _categoryController, decoration: const InputDecoration(labelText: 'Sektör / Kategori')),
            const SizedBox(height: 12),
            TextField(controller: _budgetController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Ayrılan Bütçe (₺)')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
        FilledButton(onPressed: _handleSubmit, child: const Text('Oluştur')),
      ],
    );
  }

  void _handleSubmit() {
    final name = _nameController.text.trim();
    final budget = double.tryParse(_budgetController.text.trim()) ?? 0.0;
    if (name.isEmpty) return;

    widget.onAdd(
      name: name,
      description: _descController.text.trim(),
      category: _categoryController.text.trim(),
      totalBudget: budget,
    );
    Navigator.pop(context);
  }
}
