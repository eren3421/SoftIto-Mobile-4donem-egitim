import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../models/plant.dart';
import '../models/note_and_harvest.dart';
import '../services/i18n_service.dart';
import '../utils/care_calculator.dart';
import '../utils/harvest_calculator.dart';
import '../widgets/right_action_sidebar.dart';
import '../widgets/custom_modals.dart';
import 'plant_detail_screen.dart';
import 'calendar_logs_screen.dart';

class GreenhouseDetailScreen extends StatefulWidget {
  final String greenhouseId;

  const GreenhouseDetailScreen({
    super.key,
    required this.greenhouseId,
  });

  @override
  State<GreenhouseDetailScreen> createState() => _GreenhouseDetailScreenState();
}

class _GreenhouseDetailScreenState extends State<GreenhouseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final lang = state.lang;
    final greenhouse = state.getGreenhouseById(widget.greenhouseId);
    final isMobile = MediaQuery.of(context).size.width < 700;

    if (greenhouse == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                lang == 'en' ? 'Greenhouse not found!' : 'Sera bulunamadı!',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppStrings.get('btn_main_menu', lang)),
              ),
            ],
          ),
        ),
      );
    }

    final plants = state.getPlantsForGreenhouse(widget.greenhouseId);
    final notes = state.getNotesForGreenhouse(widget.greenhouseId);

    final sidebarWidget = RightActionSidebar(
      contextType: SidebarContext.greenhouseDetail,
      lang: lang,
      isDrawer: isMobile,
      width: isMobile ? double.infinity : 200,
      onAddNote: () {
        if (isMobile) Navigator.pop(context);
        _showAddNoteModal(context, state, lang);
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
      onLogout: () {
        Navigator.popUntil(context, (route) => route.isFirst);
        state.logout();
      },
    );

    final mainContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Header Bar
        _buildTopBar(context, greenhouse.name, lang, isMobile),

        // Tabs Header (Plants vs Greenhouse Notes)
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF1B5E20),
            unselectedLabelColor: const Color(0xFF64748B),
            indicatorColor: const Color(0xFF1B5E20),
            indicatorWeight: 3,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: [
              Tab(
                icon: const Icon(Icons.yard_rounded, size: 18),
                text: '${AppStrings.get('tab_plants', lang)} (${plants.length})',
              ),
              Tab(
                icon: const Icon(Icons.edit_note_rounded, size: 18),
                text:
                    '${AppStrings.get('tab_greenhouse_notes', lang)} (${notes.length})',
              ),
            ],
          ),
        ),

        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // TAB 1: Plants List
              plants.isEmpty
                  ? _buildEmptyState(context, lang)
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: plants.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final plant = plants[index];
                        final species = state.getSpeciesById(plant.speciesId);

                        return _buildPlantRowCard(
                          context: context,
                          plant: plant,
                          species: species,
                          lang: lang,
                          onDetail: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PlantDetailScreen(
                                  plantId: plant.id,
                                ),
                              ),
                            );
                          },
                          onDelete: () {
                            CustomModals.showDeleteConfirm(
                              context,
                              title: lang == 'en' ? 'Delete Plant' : 'Bitkiyi Sil',
                              message: lang == 'en'
                                  ? 'Are you sure you want to delete this plant and its care records?'
                                  : 'Bu bitkiyi ve tüm bakım geçmişini silmek istediğinize emin misiniz?',
                              lang: lang,
                              onConfirm: () => state.deletePlant(plant.id),
                            );
                          },
                        );
                      },
                    ),

              // TAB 2: Notes List
              _buildNotesTab(context, notes, state, lang),
            ],
          ),
        ),

        // Bottom Action Bar: [<- Ana Menü] and Action Button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
          child: Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: Text(
                  AppStrings.get('btn_main_menu', lang),
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF475569),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_tabController.index == 1) {
                      _showAddNoteModal(context, state, lang);
                    } else {
                      _showAddPlantModal(context, state, lang);
                    }
                  },
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: AnimatedBuilder(
                    animation: _tabController,
                    builder: (context, _) {
                      return Text(
                        _tabController.index == 1
                            ? AppStrings.get('sidebar_add_note', lang)
                            : AppStrings.get('add_plant_btn', lang),
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
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

  void _showAddNoteModal(BuildContext context, AppState state, String lang) {
    CustomModals.showAddNote(
      context,
      lang: lang,
      onConfirm: (title, content) {
        state.addNote(
          greenhouseId: widget.greenhouseId,
          title: title,
          content: content,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang == 'en'
                ? 'Note saved to greenhouse!'
                : 'Not seraya kaydedildi!'),
            backgroundColor: const Color(0xFF1B5E20),
          ),
        );
      },
    );
  }

  void _showAddPlantModal(BuildContext context, AppState state, String lang) {
    CustomModals.showAddPlant(
      context,
      speciesCatalog: state.speciesCatalog,
      lang: lang,
      onConfirm: ({
        required speciesId,
        required customName,
        required plantedAt,
        required locationNote,
      }) {
        state.addPlant(
          greenhouseId: widget.greenhouseId,
          speciesId: speciesId,
          customName: customName,
          plantedAt: plantedAt,
          locationNote: locationNote,
        );
      },
    );
  }

  Widget _buildNotesTab(BuildContext context, List<NoteAndHarvest> notes,
      AppState state, String lang) {
    if (notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📝', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 12),
            Text(
              AppStrings.get('no_notes_message', lang),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _showAddNoteModal(context, state, lang),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: Text(AppStrings.get('sidebar_add_note', lang)),
            ),
          ],
        ),
      );
    }

    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: notes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final note = notes[index];
        String emoji = '📝';
        Color badgeColor = const Color(0xFF2563EB);
        if (note.type == 'harvest') {
          emoji = '🧺';
          badgeColor = const Color(0xFF16A34A);
        } else if (note.type == 'treatment') {
          emoji = '💊';
          badgeColor = const Color(0xFFD97706);
        }

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      note.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    dateFormat.format(note.createdAt),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: () {
                      CustomModals.showDeleteConfirm(
                        context,
                        title: lang == 'en' ? 'Delete Note' : 'Notu Sil',
                        message: AppStrings.get('delete_note_confirm', lang),
                        lang: lang,
                        onConfirm: () => state.deleteNote(note.id),
                      );
                    },
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: Color(0xFFEF4444), size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                note.content,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF475569),
                  height: 1.35,
                ),
              ),
              if (note.type == 'harvest' && note.harvestAmountGrams != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
        );
      },
    );
  }

  Widget _buildTopBar(
      BuildContext context, String ghName, String lang, bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded,
                color: Color(0xFF1B5E20)),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppStrings.get('greenhouse_detail_title', lang)} $ghName',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1B5E20),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  lang == 'en'
                      ? 'Plant inventory & status'
                      : 'Bitki envanteri ve durum',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
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

  Widget _buildPlantRowCard({
    required BuildContext context,
    required Plant plant,
    required dynamic species,
    required String lang,
    required VoidCallback onDetail,
    required VoidCallback onDelete,
  }) {
    final waterInterval =
        plant.customWateringDays ?? species?.wateringIntervalDays ?? 3;
    final fertInterval =
        plant.customFertilizingDays ?? species?.fertilizingIntervalDays ?? 14;

    final waterStatus = CareCalculator.evaluate(
      lastActionDate: plant.lastWateredAt,
      intervalDays: waterInterval,
    );
    final fertStatus = CareCalculator.evaluate(
      lastActionDate: plant.lastFertilizedAt,
      intervalDays: fertInterval,
    );

    CareStatus displayStatus = waterStatus;
    String careTypeLabel = AppStrings.get('watering_card_title', lang);
    if (fertStatus.level == CareAlertLevel.overdue &&
        waterStatus.level != CareAlertLevel.overdue) {
      displayStatus = fertStatus;
      careTypeLabel = AppStrings.get('fertilizing_card_title', lang);
    }

    final harvestDays =
        plant.customHarvestDays ?? species?.expectedHarvestDays ?? 60;
    final harvestInfo = HarvestCalculator.calculate(
      plantedAt: plant.plantedAt,
      expectedHarvestDays: harvestDays,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    species?.icon ?? '🌱',
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plant.customName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      species != null ? species.name.get(lang) : 'Bitki',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Color(0xFFEF4444), size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Badges Row
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: displayStatus.backgroundColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: displayStatus.borderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(displayStatus.icon,
                        size: 13, color: displayStatus.primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      '$careTypeLabel: ${displayStatus.getLabel(lang)}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: displayStatus.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${harvestInfo.remainingDays} ${AppStrings.get('days_unit', lang)} • %${harvestInfo.progressPercent.toInt()}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Details Action
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: onDetail,
              icon: const Icon(Icons.arrow_forward_rounded, size: 14),
              label: Text(
                AppStrings.get('btn_detail', lang),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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

  Widget _buildEmptyState(BuildContext context, String lang) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🌱', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 12),
          Text(
            AppStrings.get('no_plants_message', lang),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
