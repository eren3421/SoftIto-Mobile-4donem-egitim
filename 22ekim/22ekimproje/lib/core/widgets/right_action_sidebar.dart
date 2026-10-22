import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class RightActionSidebar extends StatelessWidget {
  final VoidCallback onNotificationsTap;
  final VoidCallback onNotesTap;
  final VoidCallback onMentorTap;
  final VoidCallback onDocumentsTap;
  final VoidCallback onAccountTap;
  final String notesTooltip;
  final String documentsTooltip;
  final int? notesCount;

  const RightActionSidebar({
    super.key,
    required this.onNotificationsTap,
    required this.onNotesTap,
    required this.onMentorTap,
    required this.onDocumentsTap,
    required this.onAccountTap,
    this.notesTooltip = 'Notlar (Ekle / Görüntüle)',
    this.documentsTooltip = 'Belgeler & Bilgi',
    this.notesCount,
  });

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    int? badgeCount,
    Color iconColor = AppColors.softPink,
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Tooltip(
        message: tooltip,
        preferBelow: false,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary, width: 1),
        ),
        textStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            splashColor: AppColors.primary.withOpacity(0.3),
            hoverColor: AppColors.surfaceVariant,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isHighlighted
                    ? AppColors.primary.withOpacity(0.2)
                    : AppColors.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isHighlighted
                      ? AppColors.accent
                      : AppColors.border.withOpacity(0.6),
                  width: 1.2,
                ),
                boxShadow: isHighlighted
                    ? [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    icon,
                    size: 24,
                    color: isHighlighted ? AppColors.accent : iconColor,
                  ),
                  if (badgeCount != null && badgeCount > 0)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          badgeCount > 9 ? '9+' : '$badgeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          left: BorderSide(
            color: AppColors.border,
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Bildirimler İkonu
            _buildIconButton(
              icon: Icons.notifications_active_outlined,
              tooltip: 'Bildirimler ve Hatırlatıcılar',
              onTap: onNotificationsTap,
            ),

            // 2. Not İkonu
            _buildIconButton(
              icon: Icons.note_alt_outlined,
              tooltip: notesTooltip,
              onTap: onNotesTap,
              badgeCount: notesCount,
            ),

            // 3. Konuşma Balonu İkonu (Mentor / Chatbot)
            _buildIconButton(
              icon: Icons.psychology_outlined,
              tooltip: 'AI Mentor / Chatbot',
              onTap: onMentorTap,
              isHighlighted: true,
              iconColor: AppColors.accent,
            ),

            // 4. Belge İkonu (Gizlilik / Rapor Arşivi)
            _buildIconButton(
              icon: Icons.description_outlined,
              tooltip: documentsTooltip,
              onTap: onDocumentsTap,
            ),

            // 5. Bilgi / Hesap İkonu (Hesap Sil / Çıkış)
            _buildIconButton(
              icon: Icons.manage_accounts_outlined,
              tooltip: 'Hesap & Çıkış İşlemleri',
              onTap: onAccountTap,
              iconColor: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
