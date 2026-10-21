import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/plant_species.dart';
import '../services/i18n_service.dart';

class CustomModals {
  // 1. Add Greenhouse Modal
  static Future<void> showAddGreenhouse(
    BuildContext context, {
    required String lang,
    required Function(String name, String icon) onConfirm,
  }) async {
    final nameController = TextEditingController();
    String selectedIcon = '🏡';
    final icons = ['🏡', '🍅', '🍓', '🥒', '🌿', '🫑', '🥬', '🌸'];

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.add_home_work_rounded,
                      color: Color(0xFF1B5E20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppStrings.get('add_greenhouse_modal_title', lang),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.get('greenhouse_name_label', lang),
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: AppStrings.get('greenhouse_name_hint', lang),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.get('greenhouse_icon_label', lang),
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: icons.map((emoji) {
                        final isSelected = selectedIcon == emoji;
                        return InkWell(
                          onTap: () => setState(() => selectedIcon = emoji),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF1B5E20).withOpacity(0.15)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF1B5E20)
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child:
                                Text(emoji, style: const TextStyle(fontSize: 22)),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    '${AppStrings.get('btn_cancel', lang)} X',
                    style: const TextStyle(color: Color(0xFF64748B)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty) {
                      onConfirm(nameController.text.trim(), selectedIcon);
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(AppStrings.get('btn_confirm', lang)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 2. Delete Confirmation Modal (Rule from Help Card 2)
  static Future<void> showDeleteConfirm(
    BuildContext context, {
    required String title,
    required String message,
    required String lang,
    required VoidCallback onConfirm,
  }) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Color(0xFFEF4444), size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEF4444)),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
                fontSize: 13, height: 1.4, color: Color(0xFF334155)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                AppStrings.get('btn_cancel', lang),
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(AppStrings.get('btn_delete', lang)),
            ),
          ],
        );
      },
    );
  }

  // 3. Add Plant Modal with Species Selection & Automatic Profile Preview
  static Future<void> showAddPlant(
    BuildContext context, {
    required List<PlantSpecies> speciesCatalog,
    required String lang,
    required Function({
      required String speciesId,
      required String customName,
      required DateTime plantedAt,
      required String locationNote,
    }) onConfirm,
  }) async {
    PlantSpecies selectedSpecies = speciesCatalog.first;
    final nameController =
        TextEditingController(text: '${selectedSpecies.name.get(lang)} #1');
    final locationController = TextEditingController();
    DateTime plantedDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.yard_rounded, color: Color(0xFF1B5E20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppStrings.get('add_plant_modal_title', lang),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 440,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Species Dropdown
                      Text(
                        AppStrings.get('select_species_label', lang),
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<PlantSpecies>(
                        value: selectedSpecies,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                        ),
                        items: speciesCatalog.map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child: Row(
                              children: [
                                Text(s.icon, style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: 8),
                                Text(
                                  '${s.name.get(lang)} (${s.expectedHarvestDays} ${AppStrings.get('days_unit', lang)})',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (newSpecies) {
                          if (newSpecies != null) {
                            setState(() {
                              selectedSpecies = newSpecies;
                              nameController.text =
                                  '${newSpecies.name.get(lang)} #1';
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),

                      // Auto Preview Box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F8E9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFC8E6C9)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '🌱 ${AppStrings.get('module_guide_title', lang)}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '• ${AppStrings.get('watering_guide', lang)}: ${selectedSpecies.wateringIntervalDays} ${AppStrings.get('days_interval', lang)} (${selectedSpecies.wateringAmountMl} ml)\n'
                              '• ${AppStrings.get('sunlight_guide', lang)}: ${selectedSpecies.sunlightHours} (${selectedSpecies.sunlightType.get(lang)})\n'
                              '• ${AppStrings.get('estimated_harvest', lang)}: ${selectedSpecies.expectedHarvestDays} ${AppStrings.get('days_unit', lang)}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  height: 1.4,
                                  color: Color(0xFF2E7D32)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Plant Custom Name
                      Text(
                        AppStrings.get('custom_name_label', lang),
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: AppStrings.get('custom_name_hint', lang),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Planting Date Picker
                      Text(
                        AppStrings.get('planting_date_label', lang),
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: plantedDate,
                            firstDate: DateTime(2025),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() => plantedDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('dd.MM.yyyy').format(plantedDate),
                                style: const TextStyle(fontSize: 13),
                              ),
                              const Icon(Icons.calendar_today_rounded,
                                  size: 16, color: Color(0xFF64748B)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Location / Pot Note
                      Text(
                        AppStrings.get('location_note_label', lang),
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: locationController,
                        decoration: InputDecoration(
                          hintText: AppStrings.get('location_note_hint', lang),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    '${AppStrings.get('btn_cancel', lang)} X',
                    style: const TextStyle(color: Color(0xFF64748B)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty) {
                      onConfirm(
                        speciesId: selectedSpecies.speciesId,
                        customName: nameController.text.trim(),
                        plantedAt: plantedDate,
                        locationNote: locationController.text.trim(),
                      );
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(AppStrings.get('add_plant_btn', lang)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 4. Add Note Modal
  static Future<void> showAddNote(
    BuildContext context, {
    required String lang,
    required Function(String title, String content) onConfirm,
  }) async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.edit_note_rounded, color: Color(0xFF1B5E20)),
              const SizedBox(width: 8),
              Text(
                AppStrings.get('sidebar_add_note', lang),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: lang == 'en' ? 'Note Title' : 'Not Başlığı',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: lang == 'en' ? 'Note Content' : 'Not İçeriği',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppStrings.get('btn_cancel', lang)),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isNotEmpty) {
                  onConfirm(
                    titleController.text.trim(),
                    contentController.text.trim(),
                  );
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
              ),
              child: Text(AppStrings.get('btn_save', lang)),
            ),
          ],
        );
      },
    );
  }

  // 5. Add Harvest Record Modal
  static Future<void> showAddHarvest(
    BuildContext context, {
    required String plantName,
    required String lang,
    required Function({
      required String title,
      required String content,
      required int amountGrams,
      required int rating,
    }) onConfirm,
  }) async {
    final titleController =
        TextEditingController(text: '$plantName ${lang == 'en' ? 'Harvest' : 'Hasadı'}');
    final amountController = TextEditingController(text: '500');
    final contentController = TextEditingController();
    int rating = 5;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.eco_rounded, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppStrings.get('add_harvest_record_btn', lang),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: lang == 'en' ? 'Record Title' : 'Kayıt Başlığı',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText:
                            '${AppStrings.get('harvest_amount', lang)} (${AppStrings.get('grams_unit', lang)})',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppStrings.get('harvest_quality', lang),
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        final starIndex = index + 1;
                        return IconButton(
                          onPressed: () => setState(() => rating = starIndex),
                          icon: Icon(
                            starIndex <= rating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: const Color(0xFFF59E0B),
                            size: 28,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: contentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText:
                            lang == 'en' ? 'Harvest Notes' : 'Hasat Notları',
                        hintText: lang == 'en'
                            ? 'e.g. Firm texture, sweet flavor'
                            : 'Örn: Meyveler tatlı ve dolgundu',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(AppStrings.get('btn_cancel', lang)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final grams = int.tryParse(amountController.text) ?? 0;
                    onConfirm(
                      title: titleController.text.trim(),
                      content: contentController.text.trim(),
                      amountGrams: grams,
                      rating: rating,
                    );
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(AppStrings.get('btn_save', lang)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 6. User Guide Modal (3 Interactive Cards directly matching sketches)
  static Future<void> showUserGuide(BuildContext context,
      {required String lang}) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              const Icon(Icons.menu_book_rounded, color: Color(0xFF1B5E20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppStrings.get('sidebar_help', lang),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildGuideCard(
                    number: '1',
                    title: AppStrings.get('guide_card_1_title', lang),
                    body: AppStrings.get('guide_card_1_body', lang),
                    color: const Color(0xFF0284C7),
                    icon: Icons.add_circle_outline_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildGuideCard(
                    number: '2',
                    title: AppStrings.get('guide_card_2_title', lang),
                    body: AppStrings.get('guide_card_2_body', lang),
                    color: const Color(0xFFEF4444),
                    icon: Icons.delete_forever_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildGuideCard(
                    number: '3',
                    title: AppStrings.get('guide_card_3_title', lang),
                    body: AppStrings.get('guide_card_3_body', lang),
                    color: const Color(0xFF10B981),
                    icon: Icons.headset_mic_rounded,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
              ),
              child: Text(AppStrings.get('btn_close', lang)),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildGuideCard({
    required String number,
    required String title,
    required String body,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
