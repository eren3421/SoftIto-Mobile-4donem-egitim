import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/crimson_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../auth/domain/models/user_role.dart';
import '../controllers/vehicle_controller.dart';
import '../domain/models/vehicle_filter_state.dart';
import '../domain/models/vehicle_type.dart';

class VehicleFilterPanel extends StatefulWidget {
  final VehicleController controller;
  final VoidCallback? onFilterApplied;

  const VehicleFilterPanel({
    super.key,
    required this.controller,
    this.onFilterApplied,
  });

  @override
  State<VehicleFilterPanel> createState() => _VehicleFilterPanelState();
}

class _VehicleFilterPanelState extends State<VehicleFilterPanel> {
  late TextEditingController _ownerQueryController;
  late TextEditingController _modelController;
  late TextEditingController _plateController;

  UserRole? _selectedOwnerRole;
  String? _selectedCountry;
  String? _selectedCity;
  VehicleCategory? _selectedType;
  String? _selectedBrand;

  @override
  void initState() {
    super.initState();
    final f = widget.controller.currentFilter;
    _ownerQueryController = TextEditingController(text: f.ownerQuery ?? '');
    _modelController = TextEditingController(text: f.model ?? '');
    _plateController = TextEditingController(text: f.plateNumberQuery ?? '');

    _selectedOwnerRole = f.ownerRoleFilter;
    _selectedCountry = f.country;
    _selectedCity = f.city;
    _selectedType = f.vehicleType;
    _selectedBrand = f.brand;
  }

  @override
  void dispose() {
    _ownerQueryController.dispose();
    _modelController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final newState = VehicleFilterState(
      ownerQuery: _ownerQueryController.text.trim().isEmpty ? null : _ownerQueryController.text.trim(),
      ownerRoleFilter: _selectedOwnerRole,
      country: _selectedCountry,
      city: _selectedCity,
      vehicleType: _selectedType,
      brand: _selectedBrand,
      model: _modelController.text.trim().isEmpty ? null : _modelController.text.trim(),
      plateNumberQuery: _plateController.text.trim().isEmpty ? null : _plateController.text.trim(),
    );

    widget.controller.updateFilter(newState);
    widget.onFilterApplied?.call();
  }

  void _clearFilters() {
    setState(() {
      _ownerQueryController.clear();
      _modelController.clear();
      _plateController.clear();
      _selectedOwnerRole = null;
      _selectedCountry = null;
      _selectedCity = null;
      _selectedType = null;
      _selectedBrand = null;
    });

    widget.controller.resetFilters();
    widget.onFilterApplied?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final countries = widget.controller.availableCountries;
    final cities = widget.controller.getCitiesForCountry(_selectedCountry);
    final brands = widget.controller.getBrandsForCategory(_selectedType);
    final count = widget.controller.filteredVehicles.length;

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '7 Kriterli Filtreleme',
                style: AppTypography.sectionTitle(
                  color: isDark ? AppColors.platinumText : AppColors.lightTextPrimary,
                ),
              ),
              if (widget.controller.currentFilter.hasActiveFilters)
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text('Temizle', style: TextStyle(color: AppColors.crimsonLight)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // 1. Kriter: Araç Sahibi (Tümü / Sivil / Firma + İsim)
          _buildFilterHeader('1. Araç Sahibi'),
          Row(
            children: [
              Expanded(
                child: SegmentedButton<UserRole?>(
                  segments: const [
                    ButtonSegment(value: null, label: Text('Tümü')),
                    ButtonSegment(value: UserRole.civilian, label: Text('Sivil')),
                    ButtonSegment(value: UserRole.company, label: Text('Firma')),
                  ],
                  selected: {_selectedOwnerRole},
                  onSelectionChanged: (set) => setState(() => _selectedOwnerRole = set.first),
                ),
              ),
            ],
          ),
          CustomTextField(
            controller: _ownerQueryController,
            label: 'Sahip / Firma Adı Ara',
            hint: 'Örn: Ahmet, SkyJet...',
            prefixIcon: const Icon(Icons.person_search, size: 18),
          ),
          const SizedBox(height: AppSpacing.sm),

          // 2. Kriter: Ülke
          _buildFilterHeader('2. Ülke'),
          DropdownButtonFormField<String?>(
            initialValue: _selectedCountry,
            decoration: const InputDecoration(isDense: true),
            hint: const Text('Tüm Ülkeler'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Tüm Ülkeler')),
              ...countries.map((c) => DropdownMenuItem(value: c, child: Text(c))),
            ],
            onChanged: (val) {
              setState(() {
                _selectedCountry = val;
                _selectedCity = null; // Reset city on country change
              });
            },
          ),
          const SizedBox(height: AppSpacing.sm),

          // 3. Kriter: Şehir
          _buildFilterHeader('3. Şehir'),
          DropdownButtonFormField<String?>(
            initialValue: _selectedCity,
            decoration: const InputDecoration(isDense: true),
            hint: const Text('Tüm Şehirler'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Tüm Şehirler')),
              ...cities.map((c) => DropdownMenuItem(value: c, child: Text(c))),
            ],
            onChanged: (val) => setState(() => _selectedCity = val),
          ),
          const SizedBox(height: AppSpacing.sm),

          // 4. Kriter: Taşıt Türü
          _buildFilterHeader('4. Taşıt Türü'),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Tümü'),
                selected: _selectedType == null,
                onSelected: (_) => setState(() => _selectedType = null),
              ),
              ChoiceChip(
                label: const Text('Kara'),
                selected: _selectedType == VehicleCategory.land,
                onSelected: (_) => setState(() => _selectedType = VehicleCategory.land),
              ),
              ChoiceChip(
                label: const Text('Hava'),
                selected: _selectedType == VehicleCategory.air,
                onSelected: (_) => setState(() => _selectedType = VehicleCategory.air),
              ),
              ChoiceChip(
                label: const Text('Deniz'),
                selected: _selectedType == VehicleCategory.sea,
                onSelected: (_) => setState(() => _selectedType = VehicleCategory.sea),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // 5. Kriter: Marka
          _buildFilterHeader('5. Marka'),
          DropdownButtonFormField<String?>(
            initialValue: _selectedBrand,
            decoration: const InputDecoration(isDense: true),
            hint: const Text('Tüm Markalar'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Tüm Markalar')),
              ...brands.map((b) => DropdownMenuItem(value: b, child: Text(b))),
            ],
            onChanged: (val) => setState(() => _selectedBrand = val),
          ),
          const SizedBox(height: AppSpacing.sm),

          // 6. Kriter: Model
          _buildFilterHeader('6. Model'),
          CustomTextField(
            controller: _modelController,
            label: 'Model Adı',
            hint: 'Örn: G63, CJ4, Grande...',
            prefixIcon: const Icon(Icons.drive_file_rename_outline, size: 18),
          ),
          const SizedBox(height: AppSpacing.sm),

          // 7. Kriter: Plaka / Tescil No
          _buildFilterHeader('7. Plaka / Tescil No'),
          CustomTextField(
            controller: _plateController,
            label: 'Plaka / Kuyruk / Sicil No',
            hint: 'Örn: 34 VR, TC-SKY, GCK...',
            prefixIcon: const Icon(Icons.tag, size: 18),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearFilters,
                  child: const Text('Temizle'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 2,
                child: CrimsonButton(
                  label: 'Uygula ($count Araç)',
                  onPressed: _applyFilters,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.silverText,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
