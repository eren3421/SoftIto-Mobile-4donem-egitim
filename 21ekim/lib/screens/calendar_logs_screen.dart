import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../models/plant.dart';
import '../models/note_and_harvest.dart';
import '../widgets/custom_modals.dart';
import '../services/i18n_service.dart';
import '../utils/care_calculator.dart';
import '../utils/harvest_calculator.dart';

class CalendarLogsScreen extends StatefulWidget {
  const CalendarLogsScreen({super.key});

  @override
  State<CalendarLogsScreen> createState() => _CalendarLogsScreenState();
}

class _CalendarLogsScreenState extends State<CalendarLogsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _onlyShowUrgent = false;
  String _selectedNoteType = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    final plants = state.plants;
    final notes = state.notes;

    // Calculate Summary Stats
    int overdueCount = 0;
    int dueSoonCount = 0;
    int readyHarvestCount = 0;

    for (final plant in plants) {
      final species = state.getSpeciesById(plant.speciesId);
      final waterInterval =
          plant.customWateringDays ?? species?.wateringIntervalDays ?? 3;
      final fertInterval =
          plant.customFertilizingDays ?? species?.fertilizingIntervalDays ?? 14;

      final wStatus = CareCalculator.evaluate(
          lastActionDate: plant.lastWateredAt, intervalDays: waterInterval);
      final fStatus = CareCalculator.evaluate(
          lastActionDate: plant.lastFertilizedAt, intervalDays: fertInterval);

      if (wStatus.level == CareAlertLevel.overdue ||
          fStatus.level == CareAlertLevel.overdue) {
        overdueCount++;
      } else if (wStatus.level == CareAlertLevel.dueSoon ||
          fStatus.level == CareAlertLevel.dueSoon) {
        dueSoonCount++;
      }

      final hDays =
          plant.customHarvestDays ?? species?.expectedHarvestDays ?? 60;
      final hInfo = HarvestCalculator.calculate(
          plantedAt: plant.plantedAt, expectedHarvestDays: hDays);
      if (hInfo.isReadyForHarvest || hInfo.remainingDays <= 7) {
        readyHarvestCount++;
      }
    }

    final harvestLogs = notes.where((n) => n.type == 'harvest').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          AppStrings.get('calendar_page_title', lang),
          style: const TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1B5E20)),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF1B5E20),
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: const Color(0xFF1B5E20),
          indicatorWeight: 3,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: [
            Tab(
              icon: const Icon(Icons.calendar_month_rounded, size: 20),
              text: AppStrings.get('tab_calendar', lang),
            ),
            Tab(
              icon: const Icon(Icons.eco_rounded, size: 20),
              text: AppStrings.get('tab_harvest_logs', lang),
            ),
            Tab(
              icon: const Icon(Icons.note_alt_rounded, size: 20),
              text: AppStrings.get('tab_all_notes', lang),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Summary Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: overdueCount > 0
                  ? const Color(0xFFFEF2F2)
                  : const Color(0xFFECFDF5),
              border: Border(
                bottom: BorderSide(
                  color: overdueCount > 0
                      ? const Color(0xFFFCA5A5)
                      : const Color(0xFFA7F3D0),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  overdueCount > 0
                      ? Icons.warning_rounded
                      : Icons.task_alt_rounded,
                  color: overdueCount > 0
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF047857),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    lang == 'en'
                        ? 'Summary: $overdueCount overdue care tasks, $dueSoonCount due today/soon, and $readyHarvestCount harvest(s) approaching.'
                        : 'Özet: $overdueCount geciken bakım görevi, $dueSoonCount bugün/yakında yapılacak ve $readyHarvestCount yaklaşan hasat var.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: overdueCount > 0
                          ? const Color(0xFF991B1B)
                          : const Color(0xFF065F46),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tabs Body
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: Care Calendar List
                _buildCareCalendarTab(plants, state, lang),

                // TAB 2: Harvest Logs Table
                _buildHarvestLogsTab(harvestLogs, state, lang),

                // TAB 3: All Notes & Logs
                _buildAllNotesTab(notes, state, lang),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCareCalendarTab(
      List<Plant> plants, AppState state, String lang) {
    final taskItems = <Map<String, dynamic>>[];

    for (final plant in plants) {
      final greenhouse = state.getGreenhouseById(plant.greenhouseId);
      final species = state.getSpeciesById(plant.speciesId);

      final wInterval =
          plant.customWateringDays ?? species?.wateringIntervalDays ?? 3;
      final fInterval =
          plant.customFertilizingDays ?? species?.fertilizingIntervalDays ?? 14;
      final pInterval =
          plant.customPruningDays ?? species?.pruningIntervalDays ?? 21;

      final wStatus = CareCalculator.evaluate(
          lastActionDate: plant.lastWateredAt, intervalDays: wInterval);
      final fStatus = CareCalculator.evaluate(
          lastActionDate: plant.lastFertilizedAt, intervalDays: fInterval);
      final pStatus = CareCalculator.evaluate(
          lastActionDate: plant.lastPrunedAt, intervalDays: pInterval);

      taskItems.add({
        'plant': plant,
        'ghName': greenhouse?.name ?? '',
        'type': 'water',
        'title': AppStrings.get('watering_card_title', lang),
        'emoji': '💧',
        'status': wStatus,
        'action': () => state.waterPlant(plant.id),
      });

      taskItems.add({
        'plant': plant,
        'ghName': greenhouse?.name ?? '',
        'type': 'fertilize',
        'title': AppStrings.get('fertilizing_card_title', lang),
        'emoji': '🌱',
        'status': fStatus,
        'action': () => state.fertilizePlant(plant.id),
      });

      taskItems.add({
        'plant': plant,
        'ghName': greenhouse?.name ?? '',
        'type': 'prune',
        'title': AppStrings.get('pruning_card_title', lang),
        'emoji': '✂️',
        'status': pStatus,
        'action': () => state.prunePlant(plant.id),
      });
    }

    // Sort: Overdue first, then DueSoon, then Healthy
    taskItems.sort((a, b) {
      final statusA = a['status'] as CareStatus;
      final statusB = b['status'] as CareStatus;
      return statusA.level.index.compareTo(statusB.level.index);
    });

    final filtered = _onlyShowUrgent
        ? taskItems
            .where((t) => (t['status'] as CareStatus).level != CareAlertLevel.healthy)
            .toList()
        : taskItems;

    return Column(
      children: [
        // Filter Switch Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppStrings.get('tab_calendar', lang)} (${filtered.length})',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Row(
                children: [
                  Text(
                    lang == 'en' ? 'Only Urgent:' : 'Sadece Acil Olanlar:',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: _onlyShowUrgent,
                    activeColor: const Color(0xFF1B5E20),
                    onChanged: (val) {
                      setState(() => _onlyShowUrgent = val);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        // Tasks List
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    lang == 'en'
                        ? 'No tasks found for current filter.'
                        : 'Mevcut filtrede görev bulunamadı.',
                    style: const TextStyle(color: Color(0xFF64748B)),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final task = filtered[index];
                    final plant = task['plant'] as Plant;
                    final status = task['status'] as CareStatus;
                    final VoidCallback onComplete = task['action'];

                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: status.borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: status.backgroundColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(task['emoji'],
                                style: const TextStyle(fontSize: 22)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      task['title'],
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: status.primaryColor,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: status.primaryColor,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        status.getLabel(lang),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  plant.customName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  task['ghName'],
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              onComplete();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(lang == 'en'
                                      ? 'Task marked as completed!'
                                      : 'Görev tamamlandı olarak kaydedildi!'),
                                  backgroundColor: const Color(0xFF10B981),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            icon: const Icon(Icons.check_circle_outline_rounded,
                                color: Color(0xFF1B5E20), size: 24),
                            tooltip: lang == 'en' ? 'Complete' : 'Tamamla',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHarvestLogsTab(
      List<dynamic> harvestLogs, AppState state, String lang) {
    if (harvestLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🧺', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 12),
            Text(
              lang == 'en'
                  ? 'No harvest records yet.'
                  : 'Henüz kaydedilmiş bir hasat bulunmuyor.',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      );
    }

    final dateFormat = DateFormat('dd.MM.yyyy');

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: harvestLogs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final log = harvestLogs[index];
        final greenhouse = state.getGreenhouseById(log.greenhouseId);

        return Container(
          padding: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('🧺', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          log.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          dateFormat.format(log.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${greenhouse?.name ?? ''} • ${log.content}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${log.harvestAmountGrams ?? 0} ${AppStrings.get('grams_unit', lang)}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF047857),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '★' * (log.qualityRating ?? 5),
                          style: const TextStyle(
                            color: Color(0xFFF59E0B),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAllNotesTab(
      List<NoteAndHarvest> allNotes, AppState state, String lang) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    final filteredNotes = allNotes.where((note) {
      if (_selectedNoteType == 'all') return true;
      return note.type == _selectedNoteType;
    }).toList();

    // Sort newest first
    filteredNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Column(
      children: [
        // Filter bar & Add button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: AppStrings.get('filter_all', lang),
                      count: allNotes.length,
                      isSelected: _selectedNoteType == 'all',
                      onSelected: () => setState(() => _selectedNoteType = 'all'),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: '📝 ${AppStrings.get('filter_general', lang)}',
                      count: allNotes.where((n) => n.type == 'note').length,
                      isSelected: _selectedNoteType == 'note',
                      onSelected: () => setState(() => _selectedNoteType = 'note'),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: '💊 ${AppStrings.get('filter_treatment', lang)}',
                      count: allNotes.where((n) => n.type == 'treatment').length,
                      isSelected: _selectedNoteType == 'treatment',
                      onSelected: () =>
                          setState(() => _selectedNoteType = 'treatment'),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: '🧺 ${AppStrings.get('filter_harvest', lang)}',
                      count: allNotes.where((n) => n.type == 'harvest').length,
                      isSelected: _selectedNoteType == 'harvest',
                      onSelected: () =>
                          setState(() => _selectedNoteType = 'harvest'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    lang == 'en'
                        ? '${filteredNotes.length} note(s) found'
                        : '${filteredNotes.length} not bulundu',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      if (state.greenhouses.isEmpty) return;
                      CustomModals.showAddNote(
                        context,
                        lang: lang,
                        onConfirm: (title, content) {
                          state.addNote(
                            greenhouseId: state.greenhouses.first.id,
                            title: title,
                            content: content,
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: Text(
                      AppStrings.get('sidebar_add_note', lang),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const Divider(height: 1, color: Color(0xFFE2E8F0)),

        // Notes List or Empty State
        Expanded(
          child: filteredNotes.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('📝', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text(
                          lang == 'en'
                              ? 'No notes in this category yet.'
                              : 'Bu kategoride henüz bir not bulunamadı.',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (state.greenhouses.isEmpty) return;
                            CustomModals.showAddNote(
                              context,
                              lang: lang,
                              onConfirm: (title, content) {
                                state.addNote(
                                  greenhouseId: state.greenhouses.first.id,
                                  title: title,
                                  content: content,
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: Text(AppStrings.get('sidebar_add_note', lang)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B5E20),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredNotes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final note = filteredNotes[index];
                    final gh = state.getGreenhouseById(note.greenhouseId);
                    final plant = note.plantId != null
                        ? state.plants
                            .where((p) => p.id == note.plantId)
                            .firstOrNull
                        : null;

                    String emoji = '📝';
                    Color cardAccent = const Color(0xFF2563EB);
                    if (note.type == 'harvest') {
                      emoji = '🧺';
                      cardAccent = const Color(0xFF16A34A);
                    } else if (note.type == 'treatment') {
                      emoji = '💊';
                      cardAccent = const Color(0xFFD97706);
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: cardAccent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(emoji,
                                      style: const TextStyle(fontSize: 18)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      note.title,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      dateFormat.format(note.createdAt),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18,
                                  color: Color(0xFFEF4444),
                                ),
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(4),
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
                          const SizedBox(height: 10),
                          Text(
                            note.content,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF334155),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              if (gh != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.home_work_outlined,
                                          size: 12, color: Color(0xFF475569)),
                                      const SizedBox(width: 4),
                                      Text(
                                        gh.name,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF475569),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (plant != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('🌱',
                                          style: TextStyle(fontSize: 10)),
                                      const SizedBox(width: 4),
                                      Text(
                                        plant.customName,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF047857),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (note.type == 'harvest' &&
                                  note.harvestAmountGrams != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${note.harvestAmountGrams} ${AppStrings.get('grams_unit', lang)} • ${'★' * (note.qualityRating ?? 5)}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFB45309),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1B5E20) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1B5E20)
                : const Color(0xFFCBD5E1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.25)
                    : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
