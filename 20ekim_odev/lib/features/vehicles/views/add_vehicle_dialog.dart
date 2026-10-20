import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/crimson_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../auth/domain/models/app_user.dart';
import '../controllers/vehicle_controller.dart';
import '../domain/models/vehicle_model.dart';
import '../domain/models/vehicle_type.dart';

class AddVehicleDialog extends StatefulWidget {
  final AppUser currentUser;
  final VehicleController controller;

  const AddVehicleDialog({
    super.key,
    required this.currentUser,
    required this.controller,
  });

  static Future<void> show(
    BuildContext context, {
    required AppUser currentUser,
    required VehicleController controller,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddVehicleDialog(
        currentUser: currentUser,
        controller: controller,
      ),
    );
  }

  @override
  State<AddVehicleDialog> createState() => _AddVehicleDialogState();
}

class _AddVehicleDialogState extends State<AddVehicleDialog> {
  final _formKey = GlobalKey<FormState>();

  VehicleCategory _selectedType = VehicleCategory.land;
  String _pricingPeriod = 'Günlük';

  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _plateController = TextEditingController();
  final _priceController = TextEditingController();
  final _trackingController = TextEditingController();
  final _countryController = TextEditingController(text: 'Türkiye');
  final _cityController = TextEditingController(text: 'İstanbul');
  final _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _generateTrackingNumber();
  }

  void _generateTrackingNumber() {
    final prefix = _selectedType == VehicleCategory.land
        ? 'TRK-LAND'
        : _selectedType == VehicleCategory.air
            ? 'TRK-HAVA'
            : 'TRK-DENIZ';
    final randomDigits = (1000 + (DateTime.now().millisecondsSinceEpoch % 8999));
    _trackingController.text = '$prefix-$randomDigits';
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _plateController.dispose();
    _priceController.dispose();
    _trackingController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 1000;

    final newVehicle = VehicleModel(
      id: 'v_${DateTime.now().millisecondsSinceEpoch}',
      ownerId: widget.currentUser.id,
      ownerName: widget.currentUser.displayName,
      ownerRole: widget.currentUser.role,
      vehicleType: _selectedType,
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      plateNumber: _plateController.text.trim().toUpperCase(),
      unitPrice: price,
      pricingPeriod: _pricingPeriod,
      trackingNumber: _trackingController.text.trim().toUpperCase(),
      country: _countryController.text.trim(),
      city: _cityController.text.trim(),
      isAvailable: true,
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
    );

    widget.controller.addVehicle(newVehicle);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${newVehicle.title} envantere eklendi ve kiraya sunuldu!'),
        backgroundColor: AppColors.statusEmerald,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: SingleChildScrollView(
          padding: AppSpacing.cardPadding,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Yeni Araç Kiraya Ver', style: AppTypography.sectionTitle()),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Text(
                  'Sahip: ${widget.currentUser.displayName} (${widget.currentUser.role.displayName})',
                  style: const TextStyle(color: AppColors.silverText, fontSize: 13),
                ),
                const SizedBox(height: AppSpacing.md),
                const Divider(),
                const SizedBox(height: AppSpacing.sm),

                // Taşıt Türü
                const Text('Taşıt Türü', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                SegmentedButton<VehicleCategory>(
                  segments: const [
                    ButtonSegment(
                      value: VehicleCategory.land,
                      label: Text('Kara'),
                      icon: Icon(Icons.directions_car),
                    ),
                    ButtonSegment(
                      value: VehicleCategory.air,
                      label: Text('Hava'),
                      icon: Icon(Icons.flight),
                    ),
                    ButtonSegment(
                      value: VehicleCategory.sea,
                      label: Text('Deniz'),
                      icon: Icon(Icons.sailing),
                    ),
                  ],
                  selected: {_selectedType},
                  onSelectionChanged: (set) {
                    setState(() {
                      _selectedType = set.first;
                      _generateTrackingNumber();
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.sm),

                // Marka & Model
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _brandController,
                        label: 'Marka *',
                        hint: 'Örn: Mercedes-Benz, Cessna, Azimut',
                        validator: (v) => Validators.requiredField(v, 'Marka'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: CustomTextField(
                        controller: _modelController,
                        label: 'Model *',
                        hint: 'Örn: G63 AMG, CJ4, Grande',
                        validator: (v) => Validators.requiredField(v, 'Model'),
                      ),
                    ),
                  ],
                ),

                // Plaka & Fiyat
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _plateController,
                        label: _selectedType == VehicleCategory.land
                            ? 'Plaka No *'
                            : _selectedType == VehicleCategory.air
                                ? 'Kuyruk Tescil No *'
                                : 'Deniz Sicil Plaka No *',
                        hint: _selectedType == VehicleCategory.land ? '34 VR 1923' : 'TC-ABC',
                        validator: Validators.plateNumber,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: CustomTextField(
                        controller: _priceController,
                        label: 'Birim Fiyat (₺) *',
                        hint: 'Örn: 8500',
                        keyboardType: TextInputType.number,
                        validator: Validators.price,
                      ),
                    ),
                  ],
                ),

                // Fiyat Periyodu & Takip No
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Fiyat Periyodu',
                              style: TextStyle(fontSize: 13, color: AppColors.silverText),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: _pricingPeriod,
                              decoration: const InputDecoration(isDense: true),
                              items: const [
                                DropdownMenuItem(value: 'Günlük', child: Text('Günlük')),
                                DropdownMenuItem(value: 'Saatlik', child: Text('Saatlik')),
                              ],
                              onChanged: (val) => setState(() => _pricingPeriod = val ?? 'Günlük'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: CustomTextField(
                        controller: _trackingController,
                        label: 'Takip Numarası *',
                        hint: 'TRK-...',
                        validator: Validators.trackingNumber,
                      ),
                    ),
                  ],
                ),

                // Ülke & Şehir
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _countryController,
                        label: 'Bulunduğu Ülke *',
                        hint: 'Türkiye',
                        validator: (v) => Validators.requiredField(v, 'Ülke'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: CustomTextField(
                        controller: _cityController,
                        label: 'Bulunduğu Şehir *',
                        hint: 'İstanbul',
                        validator: (v) => Validators.requiredField(v, 'Şehir'),
                      ),
                    ),
                  ],
                ),

                // Açıklama
                CustomTextField(
                  controller: _descController,
                  label: 'Açıklama ve Donanım Detayları',
                  hint: 'Örn: Şoförlü teslimat seçeneği, sigorta durumu...',
                  maxLines: 2,
                ),

                const SizedBox(height: AppSpacing.lg),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('İptal'),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    CrimsonButton(
                      label: 'Envantere Kaydet',
                      icon: Icons.add_circle_outline,
                      onPressed: _onSubmit,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
