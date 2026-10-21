import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../services/i18n_service.dart';
import '../utils/care_calculator.dart';
import '../widgets/right_action_sidebar.dart';
import '../widgets/care_alert_card.dart';
import '../widgets/harvest_countdown_bar.dart';
import '../widgets/plant_care_guide_card.dart';
import '../widgets/pest_diagnosis_panel.dart';
import '../widgets/custom_modals.dart';
import 'calendar_logs_screen.dart';

class PlantDetailScreen extends StatefulWidget {
  final String plantId;

  const PlantDetailScreen({
    super.key,
    required this.plantId,
  });

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _diagnosisKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToDiagnosis() {
    final context = _diagnosisKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final lang = state.lang;
    final plant = state.getPlantById(widget.plantId);
    final isMobile = MediaQuery.of(context).size.width < 700;

    if (plant == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                lang == 'en' ? 'Plant not found!' : 'Bitki bulunamadı!',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppStrings.get('btn_back_to_greenhouse', lang)),
              ),
            ],
          ),
        ),
      );
    }

    final species = state.getSpeciesById(plant.speciesId);
    final plantNotes = state.getNotesForPlant(plant.id);

    // Care Statuses
    final waterInterval =
        plant.customWateringDays ?? species?.wateringIntervalDays ?? 3;
    final fertInterval =
        plant.customFertilizingDays ?? species?.fertilizingIntervalDays ?? 14;
    final pruneInterval =
        plant.customPruningDays ?? species?.pruningIntervalDays ?? 21;

    final waterStatus = CareCalculator.evaluate(
      lastActionDate: plant.lastWateredAt,
      intervalDays: waterInterval,
    );
    final fertStatus = CareCalculator.evaluate(
      lastActionDate: plant.lastFertilizedAt,
      intervalDays: fertInterval,
    );
    final pruneStatus = CareCalculator.evaluate(
      lastActionDate: plant.lastPrunedAt,
      intervalDays: pruneInterval,
    );

    final expectedHarvestDays =
        plant.customHarvestDays ?? species?.expectedHarvestDays ?? 60;

    final sidebarWidget = RightActionSidebar(
      contextType: SidebarContext.plantDetail,
      lang: lang,
      isDrawer: isMobile,
      width: isMobile ? double.infinity : 200,
      onAddNote: () {
        if (isMobile) Navigator.pop(context);
        CustomModals.showAddNote(
          context,
          lang: lang,
          onConfirm: (title, content) {
            state.addNote(
              greenhouseId: plant.greenhouseId,
              plantId: plant.id,
              title: title,
              content: content,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(lang == 'en'
                    ? 'Note added to plant!'
                    : 'Not bitkiye eklendi!'),
                backgroundColor: const Color(0xFF1B5E20),
              ),
            );
          },
        );
      },
      onOpenCalendar: () {
        if (isMobile) Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const CalendarLogsScreen(),
          ),
        );
      },
      onOpenDiagnosis: () {
        if (isMobile) Navigator.pop(context);
        _scrollToDiagnosis();
      },
      onLogout: () {
        Navigator.popUntil(context, (route) => route.isFirst);
        state.logout();
      },
    );

    final mainContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Header Bar
        _buildTopBar(
          context,
          plant.customName,
          species != null
              ? '${species.name.get(lang)} (${species.scientificName})'
              : '',
          species?.icon ?? '🌱',
          lang,
          isMobile,
        ),

        // Scrollable Content
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // MODULE 1: Harvest Countdown
                _buildSectionHeader(
                  icon: Icons.timer_outlined,
                  title: AppStrings.get('module_harvest_title', lang),
                ),
                const SizedBox(height: 12),
                HarvestCountdownBar(
                  plantedAt: plant.plantedAt,
                  expectedHarvestDays: expectedHarvestDays,
                  lang: lang,
                  onAddHarvestLog: () {
                    CustomModals.showAddHarvest(
                      context,
                      plantName: plant.customName,
                      lang: lang,
                      onConfirm: ({
                        required title,
                        required content,
                        required amountGrams,
                        required rating,
                      }) {
                        state.addHarvestRecord(
                          greenhouseId: plant.greenhouseId,
                          plantId: plant.id,
                          title: title,
                          content: content,
                          harvestAmountGrams: amountGrams,
                          qualityRating: rating,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(lang == 'en'
                                ? 'Harvest recorded successfully!'
                                : 'Hasat kaydı başarıyla eklendi!'),
                            backgroundColor: const Color(0xFF1B5E20),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),

                // MODULE 2: Color Alert Care Cards
                _buildSectionHeader(
                  icon: Icons.palette_outlined,
                  title: AppStrings.get('module_care_cards_title', lang),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    // 1. Watering Card
                    CareAlertCard(
                      title: AppStrings.get('watering_card_title', lang),
                      iconEmoji: '💧',
                      status: waterStatus,
                      intervalDays: waterInterval,
                      actionButtonLabel: AppStrings.get('mark_watered', lang),
                      lang: lang,
                      width: isMobile ? double.infinity : 220,
                      onAction: () {
                        state.waterPlant(plant.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(lang == 'en'
                                ? 'Watering recorded! Status is now healthy.'
                                : 'Sulandı olarak işaretlendi! Durum güvenli yeşile döndü.'),
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                      },
                    ),

                    // 2. Fertilizing Card
                    CareAlertCard(
                      title: AppStrings.get('fertilizing_card_title', lang),
                      iconEmoji: '🌱',
                      status: fertStatus,
                      intervalDays: fertInterval,
                      actionButtonLabel:
                          AppStrings.get('mark_fertilized', lang),
                      lang: lang,
                      width: isMobile ? double.infinity : 220,
                      onAction: () {
                        state.fertilizePlant(plant.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(lang == 'en'
                                ? 'Fertilizing recorded! Status is now healthy.'
                                : 'Gübrelendi olarak işaretlendi! Durum güvenli yeşile döndü.'),
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                      },
                    ),

                    // 3. Pruning Card
                    CareAlertCard(
                      title: AppStrings.get('pruning_card_title', lang),
                      iconEmoji: '✂️',
                      status: pruneStatus,
                      intervalDays: pruneInterval,
                      actionButtonLabel: AppStrings.get('mark_pruned', lang),
                      lang: lang,
                      width: isMobile ? double.infinity : 220,
                      onAction: () {
                        state.prunePlant(plant.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(lang == 'en'
                                ? 'Pruning recorded! Status is now healthy.'
                                : 'Budandı olarak işaretlendi! Durum güvenli yeşile döndü.'),
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // MODULE 3: Plant Care Guide
                if (species != null) ...[
                  _buildSectionHeader(
                    icon: Icons.menu_book_rounded,
                    title: AppStrings.get('module_guide_title', lang),
                  ),
                  const SizedBox(height: 12),
                  PlantCareGuideCard(species: species, lang: lang),
                  const SizedBox(height: 24),
                ],

                // MODULE 4: Pest & Disease Diagnosis
                Container(
                  key: _diagnosisKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        icon: Icons.pest_control_rounded,
                        title: AppStrings.get('module_diagnosis_title', lang),
                      ),
                      const SizedBox(height: 12),
                      PestDiagnosisPanel(
                        catalog: state.pestCatalog,
                        lang: lang,
                        onApplyTreatment: (title, treatment) {
                          state.addTreatmentRecord(
                            greenhouseId: plant.greenhouseId,
                            plantId: plant.id,
                            diagnosisTitle: title,
                            treatmentContent: treatment,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(lang == 'en'
                                  ? 'Treatment note saved to plant logs!'
                                  : 'Tedavi notu bitki günlüğüne kaydedildi!'),
                              backgroundColor: const Color(0xFF1B5E20),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Plant Specific Logs / Notes
                _buildSectionHeader(
                  icon: Icons.history_edu_rounded,
                  title: lang == 'en'
                      ? '5. PLANT NOTES & LOGS'
                      : '5. BİTKİ NOTLARI VE GÜNLÜK',
                ),
                const SizedBox(height: 12),
                _buildPlantNotesList(
                  context,
                  plantNotes,
                  state,
                  plant.id,
                  plant.greenhouseId,
                  lang,
                ),
              ],
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      endDrawer: isMobile ? Drawer(child: SafeArea(child: sidebarWidget)) : null,
      body: SafeArea(
        child: isMobile
            ? mainContent
            : Row(
                children: [
                  Expanded(child: mainContent),
                  sidebarWidget,
                ],
              ),
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    String plantName,
    String speciesName,
    String emoji,
    String lang,
    bool isMobile,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded, size: 15),
            label: Text(
              isMobile ? '' : AppStrings.get('btn_back_to_greenhouse', lang),
              style: const TextStyle(fontSize: 12),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1B5E20),
              side: const BorderSide(color: Color(0xFF1B5E20)),
              padding: isMobile
                  ? const EdgeInsets.all(8)
                  : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plantName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (speciesName.isNotEmpty)
                  Text(
                    speciesName,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (isMobile)
            Builder(
              builder: (ctx) => ElevatedButton.icon(
                onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                icon: const Icon(Icons.bolt_rounded, size: 16),
                label: Text(
                  lang == 'en' ? 'Actions' : 'Menü',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F8E9),
                  foregroundColor: const Color(0xFF1B5E20),
                  elevation: 0,
                  side: const BorderSide(color: Color(0xFFC8E6C9)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1B5E20)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: Color(0xFF1B5E20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlantNotesList(
    BuildContext context,
    List<dynamic> notes,
    AppState state,
    String plantId,
    String greenhouseId,
    String lang,
  ) {
    if (notes.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            const Text('📝', style: TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              lang == 'en'
                  ? 'No notes or logs for this plant yet.'
                  : 'Bu bitki için henüz not veya günlük kaydı eklenmedi.',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                CustomModals.showAddNote(
                  context,
                  lang: lang,
                  onConfirm: (title, content) {
                    state.addNote(
                      greenhouseId: greenhouseId,
                      plantId: plantId,
                      title: title,
                      content: content,
                    );
                  },
                );
              },
              icon: const Icon(Icons.add_rounded, size: 16),
              label: Text(AppStrings.get('sidebar_add_note', lang)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ],
        ),
      );
    }

    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: notes.length,
            separatorBuilder: (_, __) => const Divider(color: Color(0xFFF1F5F9)),
            itemBuilder: (context, index) {
              final note = notes[index];
              String iconStr = '📝';
              Color badgeColor = const Color(0xFF2563EB);
              if (note.type == 'harvest') {
                iconStr = '🧺';
                badgeColor = const Color(0xFF16A34A);
              } else if (note.type == 'treatment') {
                iconStr = '💊';
                badgeColor = const Color(0xFFD97706);
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(iconStr, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  note.title,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                              Text(
                                dateFormat.format(note.createdAt),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 16,
                                  color: Color(0xFFEF4444),
                                ),
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(2),
                                onPressed: () {
                                  CustomModals.showDeleteConfirm(
                                    context,
                                    title: lang == 'en'
                                        ? 'Delete Note'
                                        : 'Notu Sil',
                                    message: lang == 'en'
                                        ? 'Are you sure you want to delete "${note.title}"?'
                                        : '"${note.title}" başlıklı notu silmek istediğinize emin misiniz?',
                                    lang: lang,
                                    onConfirm: () => state.deleteNote(note.id),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            note.content,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF475569),
                              height: 1.3,
                            ),
                          ),
                          if (note.type == 'harvest' &&
                              note.harvestAmountGrams != null) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: badgeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${note.harvestAmountGrams} ${AppStrings.get('grams_unit', lang)} • ${'★' * (note.qualityRating ?? 5)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: badgeColor,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              CustomModals.showAddNote(
                context,
                lang: lang,
                onConfirm: (title, content) {
                  state.addNote(
                    greenhouseId: greenhouseId,
                    plantId: plantId,
                    title: title,
                    content: content,
                  );
                },
              );
            },
            icon: const Icon(Icons.add_rounded, size: 16),
            label: Text(
              AppStrings.get('sidebar_add_note', lang),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1B5E20),
              side: const BorderSide(color: Color(0xFFC8E6C9)),
            ),
          ),
        ],
      ),
    );
  }
}
