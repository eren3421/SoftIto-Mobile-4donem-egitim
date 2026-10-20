import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/slate_card.dart';
import '../../vehicles/controllers/vehicle_controller.dart';
import '../controllers/auth_controller.dart';
import '../domain/models/app_user.dart';

class ProfileScreen extends StatelessWidget {
  final AuthController authController;
  final ThemeController themeController;
  final VehicleController vehicleController;
  final VoidCallback onLogout;

  const ProfileScreen({
    super.key,
    required this.authController,
    required this.themeController,
    required this.vehicleController,
    required this.onLogout,
  });

  void _showAccountSwitcherDialog(BuildContext context) {
    final civilians = authController.demoCivilians;
    final companies = authController.demoCompanies;

    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: AppSpacing.cardPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Hesap Değiştir (Roller)', style: AppTypography.sectionTitle()),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Sistemde Sivil ve Firma rollerinin farklı yetkilerini test etmek için hesap seçin:',
                  style: TextStyle(fontSize: 12, color: AppColors.silverText),
                ),
                const SizedBox(height: AppSpacing.md),
                const Text('Sivil Kullanıcılar (Kiralayabilir & Kiraya Verebilir):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                ...civilians.map((c) {
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(c.fullName),
                    subtitle: Text('TC: ${c.tcIdentityNumber} • ${c.address.city}'),
                    onTap: () {
                      authController.switchToUser(AppUser.civilian(c));
                      Navigator.of(context).pop();
                    },
                  );
                }),
                const Divider(),
                const Text('Kurumsal Firmalar (Yalnızca Kiraya Verebilir):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                ...companies.map((comp) {
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.business)),
                    title: Text(comp.companyName),
                    subtitle: Text('${comp.branchName} • ${comp.branchAddress.city}'),
                    onTap: () {
                      authController.switchToUser(AppUser.company(comp));
                      Navigator.of(context).pop();
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmLogout(BuildContext context) {
    ConfirmationDialog.show(
      context,
      title: 'Çıkış Yap',
      message: 'Mevcut oturumu sonlandırmak ve giriş portalına dönmek istiyor musunuz?',
      confirmLabel: 'Çıkış Yap',
      isDestructive: true,
    ).then((confirmed) {
      if (confirmed == true) {
        authController.logout();
        onLogout();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = authController.currentUser.value;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Giriş yapılmadı.')),
      );
    }

    final ownedVehicles = vehicleController.allVehicles.where((v) => v.ownerId == user.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil ve Sistem Yönetimi', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          children: [
            // User Header Card
            SlateCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.crimsonPrimary,
                    child: Icon(
                      user.isCompany ? Icons.business : Icons.person,
                      size: 34,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName,
                          style: AppTypography.cardTitle(
                            color: isDark ? AppColors.platinumText : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.crimsonSurface,
                            borderRadius: AppSpacing.radiusSm,
                            border: Border.all(color: AppColors.crimsonPrimary, width: 0.8),
                          ),
                          child: Text(
                            user.role.displayName,
                            style: const TextStyle(fontSize: 11, color: AppColors.crimsonLight, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Profile Details Card
            SlateCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hesap Bilgileri', style: AppTypography.cardTitle()),
                  const SizedBox(height: AppSpacing.md),
                  if (user.isCivilian && user.civilian != null) ...[
                    _buildRow('T.C. Kimlik Numarası:', user.civilian!.tcIdentityNumber),
                    _buildRow('İletişim Numarası:', user.civilian!.phoneNumber),
                    _buildRow('Ülke & Şehir:', user.civilian!.address.shortCityCountry),
                    _buildRow('Açık Adres:', user.civilian!.address.fullAddress),
                    _buildRow('Kiralama Yetkisi:', 'Aktif (Kiralayabilir & Kiraya Verebilir)'),
                  ] else if (user.isCompany && user.company != null) ...[
                    _buildRow('Firma Adı:', user.company!.companyName),
                    _buildRow('Şube Adı / Kodu:', user.company!.branchName),
                    _buildRow('Şube İletişim No:', user.company!.contactPhone),
                    _buildRow('Şube Adresi:', user.company!.branchAddress.fullAddress),
                    _buildRow('Kiralama Yetkisi:', 'Yalnızca Kiraya Verme (Filo Sahibi)'),
                  ],
                  _buildRow('Envanterdeki Araç Sayısı:', '${ownedVehicles.length} Araç'),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Theme Management & Settings
            SlateCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Material Design 3 & Tema Yönetimi', style: AppTypography.cardTitle()),
                  const SizedBox(height: AppSpacing.sm),
                  AnimatedBuilder(
                    animation: themeController,
                    builder: (context, _) {
                      return SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Karanlık Tema (Obsidian & Crimson)'),
                        subtitle: Text(
                          themeController.isDark
                              ? 'Aktif: Koyu Kırmızı ve Endüstriyel Gri Tonları'
                              : 'Aktif: Aydınlık Yönetici Teması',
                          style: const TextStyle(fontSize: 12),
                        ),
                        secondary: Icon(
                          themeController.isDark ? Icons.dark_mode : Icons.light_mode,
                          color: AppColors.crimsonLight,
                        ),
                        value: themeController.isDark,
                        onChanged: (_) => themeController.toggleTheme(),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Actions Card
            SlateCard(
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.switch_account, color: AppColors.crimsonLight),
                    title: const Text('Hesap Değiştir / Rol Değiştir'),
                    subtitle: const Text('Sivil veya Firma şubeleri arasında hızlı geçiş yap', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => _showAccountSwitcherDialog(context),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.logout, color: AppColors.statusRed),
                    title: const Text('Güvenli Çıkış Yap', style: TextStyle(color: AppColors.statusRed)),
                    onTap: () => _confirmLogout(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.silverText)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
