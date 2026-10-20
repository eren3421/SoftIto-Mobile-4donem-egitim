import 'package:flutter/material.dart';
import '../models/tablo_model.dart';

/// Yeni finansal işlem (gelir/gider) ekleme iletişim kutusu.
class AddTransactionDialog extends StatefulWidget {
  final List<ProjectModel> projects;
  final String? defaultProjectId;
  final void Function({
    required String projectId,
    required String title,
    required double amount,
    required bool isIncome,
    required String category,
    required DateTime date,
    String note,
  }) onAdd;

  const AddTransactionDialog({
    super.key,
    required this.projects,
    required this.defaultProjectId,
    required this.onAdd,
  });

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController(text: 'Genel Gider');
  late String _selectedProjId;
  bool _isIncome = false;

  @override
  void initState() {
    super.initState();
    _selectedProjId = widget.defaultProjectId ??
        (widget.projects.isNotEmpty ? widget.projects.first.id : '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yeni İşlem Kaydı'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTypeToggle(),
            const SizedBox(height: 12),
            _buildProjectDropdown(),
            const SizedBox(height: 12),
            _buildTextFields(),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
        FilledButton(onPressed: _handleSubmit, child: const Text('Kaydet')),
      ],
    );
  }

  Widget _buildTypeToggle() {
    return SegmentedButton<bool>(
      segments: const [
        ButtonSegment(value: false, label: Text('Gider'), icon: Icon(Icons.arrow_downward)),
        ButtonSegment(value: true, label: Text('Gelir'), icon: Icon(Icons.arrow_upward)),
      ],
      selected: {_isIncome},
      onSelectionChanged: (set) => setState(() => _isIncome = set.first),
    );
  }

  Widget _buildProjectDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedProjId.isNotEmpty ? _selectedProjId : null,
      decoration: const InputDecoration(labelText: 'İlgili Proje'),
      items: widget.projects
          .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
          .toList(),
      onChanged: (val) => setState(() => _selectedProjId = val ?? ''),
    );
  }

  Widget _buildTextFields() {
    return Column(
      children: [
        TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Açıklama / Başlık')),
        const SizedBox(height: 12),
        TextField(controller: _amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Tutar (₺)')),
        const SizedBox(height: 12),
        TextField(controller: _categoryController, decoration: const InputDecoration(labelText: 'Kategori (Ar-Ge, Yatırım, Pazarlama vb.)')),
      ],
    );
  }

  void _handleSubmit() {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (title.isEmpty || amount <= 0 || _selectedProjId.isEmpty) return;

    widget.onAdd(
      projectId: _selectedProjId,
      title: title,
      amount: amount,
      isIncome: _isIncome,
      category: _categoryController.text.trim(),
      date: DateTime.now(),
    );
    Navigator.pop(context);
  }
}
