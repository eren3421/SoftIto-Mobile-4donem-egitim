import 'package:flutter/material.dart';

import '../data/cars.dart';
import '../models/car.dart';
import '../theme/app_theme.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key, this.initialCarId});

  final String? initialCarId;

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  late String? _selectedCarId;
  late DateTime _selectedDate;
  String _selectedTime = '11:00';
  final List<_VisitRequest> _requests = [];

  static const _times = [
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCarId = widget.initialCarId ?? galleryCars.first.id;
    _selectedDate = DateUtils.dateOnly(
      DateTime.now().add(const Duration(days: 1)),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(today)
          ? today.add(const Duration(days: 1))
          : _selectedDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      helpText: 'Test sürüşü tarihini seçin',
      cancelText: 'Vazgeç',
      confirmText: 'Seç',
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final car = galleryCars.firstWhere((item) => item.id == _selectedCarId);
    setState(() {
      _requests.insert(
        0,
        _VisitRequest(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          car: car,
          date: _selectedDate,
          time: _selectedTime,
        ),
      );
      _nameController.clear();
      _phoneController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Test sürüşü randevunuz oluşturuldu.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Test sürüşü randevusu',
            style: TextStyle(
              fontSize: 26,
              letterSpacing: -.6,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Aracınızı seçin, size uygun zamanı birlikte planlayalım.',
            style: TextStyle(fontSize: 14, color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FormHeading(
                      icon: Icons.drive_eta_outlined,
                      title: 'Randevu bilgileri',
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Ad soyad',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: (value) =>
                          value == null || value.trim().length < 3
                          ? 'Lütfen adınızı ve soyadınızı girin.'
                          : null,
                    ),
                    const SizedBox(height: 13),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Telefon numarası',
                        hintText: '05XX XXX XX XX',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (value) {
                        final digits = (value ?? '').replaceAll(
                          RegExp(r'\D'),
                          '',
                        );
                        if (digits.length < 10) {
                          return 'Geçerli bir telefon numarası girin.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 13),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCarId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'İlgilendiğiniz araç',
                        prefixIcon: Icon(Icons.directions_car_outlined),
                      ),
                      items: galleryCars
                          .map(
                            (car) => DropdownMenuItem(
                              value: car.id,
                              child: Text(
                                '${car.brand} ${car.model}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedCarId = value),
                      validator: (value) =>
                          value == null ? 'Bir araç seçin.' : null,
                    ),
                    const SizedBox(height: 13),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final stacked = constraints.maxWidth < 460;
                        final dateButton = OutlinedButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                          ),
                          label: Text(_formatDate(_selectedDate)),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                            foregroundColor: AppColors.ink,
                            side: const BorderSide(color: AppColors.line),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        );
                        final timeField = DropdownButtonFormField<String>(
                          initialValue: _selectedTime,
                          decoration: const InputDecoration(
                            labelText: 'Saat',
                            prefixIcon: Icon(Icons.schedule_rounded),
                          ),
                          items: _times
                              .map(
                                (time) => DropdownMenuItem(
                                  value: time,
                                  child: Text(time),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null)
                              setState(() => _selectedTime = value);
                          },
                        );
                        if (stacked) {
                          return Column(
                            children: [
                              dateButton,
                              const SizedBox(height: 12),
                              timeField,
                            ],
                          );
                        }
                        return Row(
                          children: [
                            Expanded(child: dateButton),
                            const SizedBox(width: 12),
                            Expanded(child: timeField),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.event_available_outlined),
                        label: const Text('Randevu oluştur'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.ink,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Bu form örnek amaçlıdır. Bilgileriniz kaydedilmez veya gönderilmez.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Randevularım',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ),
              if (_requests.isNotEmpty)
                Text(
                  '${_requests.length} randevu',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_requests.isEmpty)
            const _EmptyAppointments()
          else
            for (final request in _requests) ...[
              _RequestCard(request: request),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _VisitRequest {
  const _VisitRequest({
    required this.name,
    required this.phone,
    required this.car,
    required this.date,
    required this.time,
  });

  final String name;
  final String phone;
  final Car car;
  final DateTime date;
  final String time;
}

class _FormHeading extends StatelessWidget {
  const _FormHeading({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.paleGreen,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.ink, size: 21),
        ),
        const SizedBox(width: 11),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}

class _EmptyAppointments extends StatelessWidget {
  const _EmptyAppointments();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.event_note_outlined, color: AppColors.muted),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Henüz randevu oluşturmadınız.',
              style: TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});

  final _VisitRequest request;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.paleGreen,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.directions_car_filled_outlined,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.car.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${request.name}  ·  ${request.phone}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatDate(request.date)}  ·  ${request.time}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentDark,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.accent,
              size: 21,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
}
