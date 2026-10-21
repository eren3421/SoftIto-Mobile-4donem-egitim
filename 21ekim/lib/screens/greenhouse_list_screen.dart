import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/greenhouse.dart';
import '../services/i18n_service.dart';
import '../widgets/right_action_sidebar.dart';
import '../widgets/custom_modals.dart';
import 'greenhouse_detail_screen.dart';
import 'calendar_logs_screen.dart';

class GreenhouseListScreen extends StatelessWidget {
  const GreenhouseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final lang = state.lang;
    final greenhouses = state.greenhouses;
    final isMobile = MediaQuery.of(context).size.width < 700;

    final sidebarWidget = RightActionSidebar(
      contextType: SidebarContext.dashboard,
      lang: lang,
      isDrawer: isMobile,
      width: isMobile ? double.infinity : 200,
      onOpenCalendar: () {
        if (isMobile) Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const CalendarLogsScreen(),
          ),
        );
      },
      onAddNote: () {
        if (isMobile) Navigator.pop(context);
        if (greenhouses.isNotEmpty) {
          CustomModals.showAddNote(
            context,
            lang: lang,
            onConfirm: (title, content) {
              state.addNote(
                greenhouseId: greenhouses.first.id,
                title: title,
                content: content,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(lang == 'en'
                      ? 'Note added successfully!'
                      : 'Not başarıyla kaydedildi!'),
                  backgroundColor: const Color(0xFF1B5E20),
                ),
              );
            },
          );
        }
      },
      onOpenHelp: () {
        if (isMobile) Navigator.pop(context);
        CustomModals.showUserGuide(context, lang: lang);
      },
      onToggleLanguage: () {
        state.toggleLanguage();
      },
      onLogout: () {
        state.logout();
      },
    );

    final mainContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Header Bar
        _buildTopBar(context, lang, isMobile),

        // Greenhouse Cards List
        Expanded(
          child: greenhouses.isEmpty
              ? _buildEmptyState(context, lang)
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: greenhouses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final gh = greenhouses[index];
                    final hasUrgent = state.hasUrgentCareInGreenhouse(gh.id);
                    final plantCount =
                        state.getPlantsForGreenhouse(gh.id).length;

                    return _buildGreenhouseCard(
                      context: context,
                      greenhouse: gh,
                      plantCount: plantCount,
                      hasUrgent: hasUrgent,
                      lang: lang,
                      onDetail: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GreenhouseDetailScreen(
                              greenhouseId: gh.id,
                            ),
                          ),
                        );
                      },
                      onDelete: () {
                        CustomModals.showDeleteConfirm(
                          context,
                          title: AppStrings.get('delete_greenhouse_title', lang),
                          message:
                              AppStrings.get('delete_greenhouse_warning', lang),
                          lang: lang,
                          onConfirm: () => state.deleteGreenhouse(gh.id),
                        );
                      },
                    );
                  },
                ),
        ),

        // Bottom Action Bar: [+ Sera Ekle]
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
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    CustomModals.showAddGreenhouse(
                      context,
                      lang: lang,
                      onConfirm: (name, icon) {
                        state.addGreenhouse(name: name, icon: icon);
                      },
                    );
                  },
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: Text(
                    AppStrings.get('add_greenhouse_btn', lang),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
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

  Widget _buildTopBar(BuildContext context, String lang, bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1B5E20).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('🌿', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.get('greenhouses_title', lang),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                Text(
                  AppStrings.get('greenhouses_subtitle', lang),
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
          IconButton(
            tooltip: AppStrings.get('tab_all_notes', lang),
            icon: const Icon(Icons.note_alt_outlined, color: Color(0xFF1B5E20)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CalendarLogsScreen(),
                ),
              );
            },
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
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

  Widget _buildGreenhouseCard({
    required BuildContext context,
    required Greenhouse greenhouse,
    required int plantCount,
    required bool hasUrgent,
    required String lang,
    required VoidCallback onDetail,
    required VoidCallback onDelete,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Avatar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8E9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFC8E6C9)),
                ),
                child: Center(
                  child: Text(
                    greenhouse.icon,
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title and Badges
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greenhouse.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$plantCount ${AppStrings.get('plants_count', lang)}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: hasUrgent
                                ? const Color(0xFFFEF2F2)
                                : const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: hasUrgent
                                  ? const Color(0xFFFCA5A5)
                                  : const Color(0xFF6EE7B7),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                hasUrgent
                                    ? Icons.warning_rounded
                                    : Icons.check_circle_rounded,
                                size: 12,
                                color: hasUrgent
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF10B981),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                hasUrgent
                                    ? AppStrings.get('urgent_care_alert', lang)
                                    : AppStrings.get('all_care_healthy', lang),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: hasUrgent
                                      ? const Color(0xFFDC2626)
                                      : const Color(0xFF047857),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          // Actions Row: [Detay] [Sil]
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: onDetail,
                icon: const Icon(Icons.arrow_forward_rounded, size: 15),
                label: Text(AppStrings.get('btn_detail', lang)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1B5E20),
                  side: const BorderSide(color: Color(0xFF1B5E20), width: 1.2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Color(0xFFEF4444), size: 20),
                tooltip: AppStrings.get('btn_delete', lang),
              ),
            ],
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
          const Text('🏡', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            lang == 'en'
                ? 'No greenhouses added yet.'
                : 'Henüz kayıtlı bir seranız bulunmuyor.',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            lang == 'en'
                ? 'Click the button below to add your first greenhouse.'
                : 'Aşağıdaki butona tıklayarak ilk seranızı oluşturun.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
