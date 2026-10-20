import 'package:flutter/material.dart';
import '../models/kisi_model.dart';

/// Takvim ve saat ayrıntılı randevu planlama iletişim kutusu.
class AddRandevuDialog extends StatefulWidget {
  final List<KisiModel> kisiler;
  final String? defaultKisiId;
  final void Function({
    required String kisiId,
    required String kisiName,
    required String title,
    required DateTime dateTime,
    required String locationOrLink,
    String note,
  }) onAdd;

  const AddRandevuDialog({
    super.key,
    required this.kisiler,
    required this.defaultKisiId,
    required this.onAdd,
  });

  @override
  State<AddRandevuDialog> createState() => _AddRandevuDialogState();
}

class _AddRandevuDialogState extends State<AddRandevuDialog> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController(text: 'https://meet.asistan.app');
  final _noteController = TextEditingController();
  late String _selectedKisiId;
  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _selectedKisiId = widget.defaultKisiId ??
        (widget.kisiler.isNotEmpty ? widget.kisiler.first.id : '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yeni Randevu Planla'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildKisiDropdown(),
            const SizedBox(height: 12),
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Görüşme Konusu / Başlık')),
            const SizedBox(height: 12),
            _buildDateTimePickers(context),
            const SizedBox(height: 12),
            TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'Toplantı Linki / Konum')),
            const SizedBox(height: 12),
            TextField(controller: _noteController, decoration: const InputDecoration(labelText: 'Gündem Notu')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
        FilledButton(onPressed: _handleSubmit, child: const Text('Planla')),
      ],
    );
  }

  Widget _buildKisiDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedKisiId.isNotEmpty ? _selectedKisiId : null,
      decoration: const InputDecoration(labelText: 'Kişi / Paydaş'),
      items: widget.kisiler
          .map((k) => DropdownMenuItem(value: k.id, child: Text('${k.name} (${k.role})')))
          .toList(),
      onChanged: (val) => setState(() => _selectedKisiId = val ?? ''),
    );
  }

  Widget _buildDateTimePickers(BuildContext context) {
    final dateStr =
        '${_selectedDate.day.toString().padLeft(2, '0')}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.year}';
    final timeStr =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today, size: 16),
            label: Text(dateStr, style: const TextStyle(fontSize: 12)),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) setState(() => _selectedDate = picked);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.access_time, size: 16),
            label: Text(timeStr, style: const TextStyle(fontSize: 12)),
            onPressed: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _selectedTime,
              );
              if (picked != null) setState(() => _selectedTime = picked);
            },
          ),
        ),
      ],
    );
  }

  void _handleSubmit() {
    final title = _titleController.text.trim();
    if (title.isEmpty || _selectedKisiId.isEmpty) return;

    final kisi = widget.kisiler.firstWhere(
      (k) => k.id == _selectedKisiId,
      orElse: () => const KisiModel(id: '', name: '', role: '', company: '', email: '', phone: ''),
    );

    final finalDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    widget.onAdd(
      kisiId: _selectedKisiId,
      kisiName: kisi.name,
      title: title,
      dateTime: finalDateTime,
      locationOrLink: _locationController.text.trim(),
      note: _noteController.text.trim(),
    );
    Navigator.pop(context);
  }
}
