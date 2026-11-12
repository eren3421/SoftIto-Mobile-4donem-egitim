import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../providers/profile_provider.dart';

class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController(text: '2023');
  final _colorController = TextEditingController(text: 'Beyaz');
  final _plateController = TextEditingController();
  int _totalSeats = 4;
  bool _isSaving = false;

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(authNotifierProvider).valueOrNull;
    if (user == null) return;

    setState(() => _isSaving = true);
    final vehicle = VehicleEntity(
      id: '',
      ownerId: user.id,
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      year: int.tryParse(_yearController.text.trim()) ?? 2023,
      color: _colorController.text.trim(),
      licensePlate: _plateController.text.trim().toUpperCase(),
      totalSeats: _totalSeats,
      isVerified: true,
      createdAt: DateTime.now(),
    );

    final ok =
        await ref.read(userVehiclesProvider.notifier).addVehicle(vehicle);
    if (mounted) {
      setState(() => _isSaving = false);
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Araç başarıyla eklendi!')),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sürücü Araç Kaydı'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _brandController,
                validator: (v) =>
                    Validators.validateRequired(v, 'Marka (Örn: Renault)'),
                decoration: const InputDecoration(
                  labelText: 'Araç Markası (Örn: Renault, Toyota)',
                  prefixIcon: Icon(Icons.directions_car_outlined),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _modelController,
                validator: (v) =>
                    Validators.validateRequired(v, 'Model (Örn: Clio)'),
                decoration: const InputDecoration(
                  labelText: 'Araç Modeli (Örn: Clio, Corolla)',
                  prefixIcon: Icon(Icons.car_rental_outlined),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _yearController,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          Validators.validateRequired(v, 'Model Yılı'),
                      decoration: const InputDecoration(
                        labelText: 'Model Yılı',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _colorController,
                      validator: (v) => Validators.validateRequired(v, 'Renk'),
                      decoration: const InputDecoration(
                        labelText: 'Renk',
                        prefixIcon: Icon(Icons.palette_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _plateController,
                textCapitalization: TextCapitalization.characters,
                validator: Validators.validateLicensePlate,
                decoration: const InputDecoration(
                  labelText: 'Plaka (Örn: 34 ABC 123)',
                  prefixIcon: Icon(Icons.pin_outlined),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _totalSeats,
                decoration: const InputDecoration(
                  labelText: 'Yolcu Koltuk Kapasitesi',
                  prefixIcon: Icon(Icons.event_seat_outlined),
                ),
                items: [1, 2, 3, 4, 5, 6]
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text('$s Koltuk'),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _totalSeats = val);
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveVehicle,
                icon: const Icon(Icons.check_circle_outline),
                label: Text(_isSaving ? 'Kaydediliyor...' : 'Aracı Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

