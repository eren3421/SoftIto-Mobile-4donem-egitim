import 'package:flutter/material.dart';

/// Yeni kişi / paydaş ekleme iletişim kutusu.
class AddKisiDialog extends StatefulWidget {
  final void Function({
    required String name,
    required String role,
    required String company,
    required String email,
    required String phone,
  }) onAdd;

  const AddKisiDialog({super.key, required this.onAdd});

  @override
  State<AddKisiDialog> createState() => _AddKisiDialogState();
}

class _AddKisiDialogState extends State<AddKisiDialog> {
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedRole = 'Yatırımcı';

  static const List<String> _roles = [
    'Yatırımcı',
    'Müşteri',
    'Kurucu Ortak',
    'Danışman',
    'Ekip Üyesi',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yeni Paydaş / Kişi Ekle'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRoleDropdown(),
            const SizedBox(height: 12),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Ad Soyad')),
            const SizedBox(height: 12),
            TextField(controller: _companyController, decoration: const InputDecoration(labelText: 'Kurum / Şirket')),
            const SizedBox(height: 12),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'E-posta')),
            const SizedBox(height: 12),
            TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Telefon')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
        FilledButton(onPressed: _handleSubmit, child: const Text('Kaydet')),
      ],
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedRole,
      decoration: const InputDecoration(labelText: 'Rol'),
      items: _roles
          .map((role) => DropdownMenuItem(value: role, child: Text(role)))
          .toList(),
      onChanged: (val) => setState(() => _selectedRole = val ?? 'Paydaş'),
    );
  }

  void _handleSubmit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    widget.onAdd(
      name: name,
      role: _selectedRole,
      company: _companyController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
    );
    Navigator.pop(context);
  }
}
