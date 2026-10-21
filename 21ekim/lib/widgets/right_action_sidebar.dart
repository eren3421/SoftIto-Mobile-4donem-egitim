import 'package:flutter/material.dart';
import '../services/i18n_service.dart';

enum SidebarContext {
  dashboard, // BAHÇELER
  greenhouseDetail, // Sera Adı
  plantDetail, // Bitki Detay
}

class RightActionSidebar extends StatelessWidget {
  final SidebarContext contextType;
  final String lang;
  final VoidCallback onAddNote;
  final VoidCallback? onOpenHelp;
  final VoidCallback? onToggleLanguage;
  final VoidCallback? onOpenCalendar;
  final VoidCallback? onOpenDiagnosis;
  final VoidCallback onLogout;
  final double? width;
  final bool isDrawer;

  const RightActionSidebar({
    super.key,
    required this.contextType,
    required this.lang,
    required this.onAddNote,
    this.onOpenHelp,
    this.onToggleLanguage,
    this.onOpenCalendar,
    this.onOpenDiagnosis,
    required this.onLogout,
    this.width = 200,
    this.isDrawer = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        border: isDrawer
            ? null
            : const Border(
                left: BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
              ),
        boxShadow: isDrawer
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(-2, 0),
                ),
              ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header / Brand Tag
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bolt_rounded,
                    size: 18, color: Color(0xFF1B5E20)),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    lang == 'en' ? 'ACTIONS' : 'AKSIYONLAR',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: Color(0xFF1B5E20),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isDrawer) ...[
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Common: Add Note
          _buildActionButton(
            icon: Icons.note_add_rounded,
            title: AppStrings.get('sidebar_add_note', lang),
            color: const Color(0xFF2E7D32),
            onTap: onAddNote,
          ),
          const SizedBox(height: 12),

          // Dashboard Context Items
          if (contextType == SidebarContext.dashboard) ...[
            if (onOpenHelp != null) ...[
              _buildActionButton(
                icon: Icons.help_outline_rounded,
                title: AppStrings.get('sidebar_help', lang),
                color: const Color(0xFF0284C7),
                onTap: onHelpTapped,
              ),
              const SizedBox(height: 12),
            ],
            if (onToggleLanguage != null) ...[
              _buildActionButton(
                icon: Icons.language_rounded,
                title: 'TR | EN (${lang.toUpperCase()})',
                color: const Color(0xFF7C3AED),
                onTap: onToggleLanguage!,
              ),
              const SizedBox(height: 12),
            ],
          ],

          // Calendar & Logs (Common when provided)
          if (onOpenCalendar != null) ...[
            _buildActionButton(
              icon: Icons.calendar_month_rounded,
              title: AppStrings.get('sidebar_calendar', lang),
              color: const Color(0xFFD97706),
              onTap: onOpenCalendar!,
            ),
            const SizedBox(height: 12),
          ],

          // Plant Detail Specific Item
          if (contextType == SidebarContext.plantDetail &&
              onOpenDiagnosis != null) ...[
            _buildActionButton(
              icon: Icons.pest_control_rounded,
              title: AppStrings.get('sidebar_diagnosis', lang),
              color: const Color(0xFFDC2626),
              onTap: onOpenDiagnosis!,
            ),
            const SizedBox(height: 12),
          ],

          const Spacer(),

          // Logout Action
          const Divider(color: Color(0xFFE2E8F0)),
          const SizedBox(height: 8),
          _buildActionButton(
            icon: Icons.logout_rounded,
            title: AppStrings.get('sidebar_logout', lang),
            color: const Color(0xFFEF4444),
            isOutlined: true,
            onTap: onLogout,
          ),
        ],
      ),
    );
  }

  void onHelpTapped() {
    if (onOpenHelp != null) onOpenHelp!();
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    bool isOutlined = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isOutlined ? Colors.transparent : color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isOutlined ? color : color.withOpacity(0.2),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
