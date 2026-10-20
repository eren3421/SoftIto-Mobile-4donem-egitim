import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/crimson_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';
import '../domain/models/address_model.dart';
import '../domain/models/app_user.dart';
import '../domain/models/user_role.dart';

class AuthPortalScreen extends StatefulWidget {
  final AuthController authController;
  final VoidCallback onLoginSuccess;

  const AuthPortalScreen({
    super.key,
    required this.authController,
    required this.onLoginSuccess,
  });

  @override
  State<AuthPortalScreen> createState() => _AuthPortalScreenState();
}

class _AuthPortalScreenState extends State<AuthPortalScreen> {
  UserRole _selectedRole = UserRole.civilian;
  bool _isRegisterMode = false;

  final _formKey = GlobalKey<FormState>();

  // Sivil Controllers
  final _tcOrPhoneController = TextEditingController(text: '10000000146');
  final _civilianPasswordController = TextEditingController(text: '123456');
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _tcController = TextEditingController();
  final _phoneController = TextEditingController();
  final _civCountryController = TextEditingController(text: 'Türkiye');
  final _civCityController = TextEditingController(text: 'İstanbul');
  final _civDistrictController = TextEditingController(text: 'Beşiktaş');
  final _civAddressController = TextEditingController();

  // Firma Controllers
  final _companyIdentifierController = TextEditingController(text: 'SkyJet Havacılık');
  final _companyPasswordController = TextEditingController(text: '123456');
  final _companyNameController = TextEditingController();
  final _branchNameController = TextEditingController();
  final _compPhoneController = TextEditingController();
  final _compCountryController = TextEditingController(text: 'Türkiye');
  final _compCityController = TextEditingController(text: 'İstanbul');
  final _compDistrictController = TextEditingController(text: 'Bakırköy');
  final _compAddressController = TextEditingController();

  @override
  void dispose() {
    _tcOrPhoneController.dispose();
    _civilianPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _tcController.dispose();
    _phoneController.dispose();
    _civCountryController.dispose();
    _civCityController.dispose();
    _civDistrictController.dispose();
    _civAddressController.dispose();
    _companyIdentifierController.dispose();
    _companyPasswordController.dispose();
    _companyNameController.dispose();
    _branchNameController.dispose();
    _compPhoneController.dispose();
    _compCountryController.dispose();
    _compCityController.dispose();
    _compDistrictController.dispose();
    _compAddressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRole == UserRole.civilian) {
      if (_isRegisterMode) {
        widget.authController.registerCivilian(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          tcNumber: _tcController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          address: AddressModel(
            country: _civCountryController.text.trim(),
            city: _civCityController.text.trim(),
            district: _civDistrictController.text.trim(),
            fullAddress: _civAddressController.text.trim(),
          ),
        );
      } else {
        widget.authController.loginCivilian(
          tcOrPhone: _tcOrPhoneController.text.trim(),
          password: _civilianPasswordController.text.trim(),
        );
      }
    } else {
      if (_isRegisterMode) {
        widget.authController.registerCompany(
          companyName: _companyNameController.text.trim(),
          branchName: _branchNameController.text.trim(),
          branchAddress: AddressModel(
            country: _compCountryController.text.trim(),
            city: _compCityController.text.trim(),
            district: _compDistrictController.text.trim(),
            fullAddress: _compAddressController.text.trim(),
          ),
          contactPhone: _compPhoneController.text.trim(),
        );
      } else {
        widget.authController.loginCompany(
          companyOrBranchCode: _companyIdentifierController.text.trim(),
          password: _companyPasswordController.text.trim(),
        );
      }
    }

    widget.onLoginSuccess();
  }

  void _quickLogin(AppUser user) {
    widget.authController.switchToUser(user);
    widget.onLoginSuccess();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Branding & Title
                      Center(
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.crimsonPrimary,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.crimsonAccent.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.hub, color: Colors.white, size: 32),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Çok Modlu Araç Kiralama',
                        textAlign: TextAlign.center,
                        style: AppTypography.displayHeader(
                          color: isDark ? AppColors.platinumText : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kara, Hava ve Deniz Taşıtları Giriş Portalı',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? AppColors.silverText : AppColors.lightTextSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Segmented Role Selector
                      SegmentedButton<UserRole>(
                        segments: const [
                          ButtonSegment(
                            value: UserRole.civilian,
                            label: Text('Sivil Kullanıcı'),
                            icon: Icon(Icons.person),
                          ),
                          ButtonSegment(
                            value: UserRole.company,
                            label: Text('Kurumsal Firma'),
                            icon: Icon(Icons.business),
                          ),
                        ],
                        selected: {_selectedRole},
                        onSelectionChanged: (set) => setState(() => _selectedRole = set.first),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Dynamic Form Body
                      if (_selectedRole == UserRole.civilian)
                        _buildCivilianForm()
                      else
                        _buildCompanyForm(),

                      const SizedBox(height: AppSpacing.lg),

                      // Submit Button
                      CrimsonButton(
                        label: _isRegisterMode
                            ? (_selectedRole == UserRole.civilian ? 'Sivil Hesabı Oluştur' : 'Firma Şubesini Kaydet')
                            : 'Güvenli Giriş Yap',
                        icon: _isRegisterMode ? Icons.person_add : Icons.login,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Toggle Login / Register
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isRegisterMode ? 'Zaten hesabınız var mı?' : 'Hesabınız yok mu?',
                            style: const TextStyle(fontSize: 13, color: AppColors.silverText),
                          ),
                          TextButton(
                            onPressed: () => setState(() => _isRegisterMode = !_isRegisterMode),
                            child: Text(
                              _isRegisterMode ? 'Giriş Yap' : 'Kayıt Ol',
                              style: const TextStyle(
                                color: AppColors.crimsonLight,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.md),
                      const Divider(),
                      const SizedBox(height: AppSpacing.sm),

                      // Quick Demo Account Switcher
                      Text(
                        'Hızlı Demo Hesap Seçici (Test İçin):',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.mutedGreyText : AppColors.lightTextSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          ActionChip(
                            avatar: const Icon(Icons.person, size: 14),
                            label: const Text('Ahmet Yılmaz (Sivil)'),
                            onPressed: () => _quickLogin(AppUser.civilian(widget.authController.demoCivilians.first)),
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.flight, size: 14),
                            label: const Text('SkyJet Havacılık (Firma)'),
                            onPressed: () => _quickLogin(AppUser.company(widget.authController.demoCompanies.first)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- SİVİL FORM ---
  Widget _buildCivilianForm() {
    if (!_isRegisterMode) {
      return Column(
        children: [
          CustomTextField(
            controller: _tcOrPhoneController,
            label: 'T.C. Kimlik No veya Telefon',
            hint: '11 Haneli TC No veya 05XX...',
            prefixIcon: const Icon(Icons.badge, size: 18),
            validator: (v) => Validators.requiredField(v, 'Kimlik veya Telefon'),
          ),
          CustomTextField(
            controller: _civilianPasswordController,
            label: 'Şifre',
            hint: '••••••',
            obscureText: true,
            prefixIcon: const Icon(Icons.lock, size: 18),
            validator: (v) => Validators.requiredField(v, 'Şifre'),
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _firstNameController,
                label: 'Ad *',
                hint: 'Adınız',
                validator: (v) => Validators.requiredField(v, 'Ad'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: CustomTextField(
                controller: _lastNameController,
                label: 'Soyad *',
                hint: 'Soyadınız',
                validator: (v) => Validators.requiredField(v, 'Soyad'),
              ),
            ),
          ],
        ),
        CustomTextField(
          controller: _tcController,
          label: 'T.C. Kimlik Numarası (11 Hane Algoritmik) *',
          hint: '10000000146',
          keyboardType: TextInputType.number,
          prefixIcon: const Icon(Icons.credit_card, size: 18),
          validator: Validators.tcKimlikNo,
        ),
        CustomTextField(
          controller: _phoneController,
          label: 'İletişim Numarası *',
          hint: '+90 5XX XXX XX XX',
          keyboardType: TextInputType.phone,
          prefixIcon: const Icon(Icons.phone, size: 18),
          validator: Validators.phoneNumber,
        ),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _civCountryController,
                label: 'Ülke *',
                hint: 'Türkiye',
                validator: (v) => Validators.requiredField(v, 'Ülke'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: CustomTextField(
                controller: _civCityController,
                label: 'Şehir *',
                hint: 'İstanbul',
                validator: (v) => Validators.requiredField(v, 'Şehir'),
              ),
            ),
          ],
        ),
        CustomTextField(
          controller: _civDistrictController,
          label: 'İlçe *',
          hint: 'Beşiktaş, Kadıköy...',
          validator: (v) => Validators.requiredField(v, 'İlçe'),
        ),
        CustomTextField(
          controller: _civAddressController,
          label: 'Açık Adres *',
          hint: 'Cadde, sokak, no, daire...',
          validator: (v) => Validators.requiredField(v, 'Açık Adres'),
        ),
      ],
    );
  }

  // --- FİRMA FORM ---
  Widget _buildCompanyForm() {
    if (!_isRegisterMode) {
      return Column(
        children: [
          CustomTextField(
            controller: _companyIdentifierController,
            label: 'Firma / Şube Kodu veya E-posta',
            hint: 'SkyJet Havacılık veya info@...',
            prefixIcon: const Icon(Icons.apartment, size: 18),
            validator: (v) => Validators.requiredField(v, 'Firma tanımlayıcısı'),
          ),
          CustomTextField(
            controller: _companyPasswordController,
            label: 'Kurumsal Şifre',
            hint: '••••••',
            obscureText: true,
            prefixIcon: const Icon(Icons.lock, size: 18),
            validator: (v) => Validators.requiredField(v, 'Şifre'),
          ),
        ],
      );
    }

    return Column(
      children: [
        CustomTextField(
          controller: _companyNameController,
          label: 'Firma Resmi Unvanı / Marka Adı *',
          hint: 'Örn: SkyJet Havacılık A.Ş.',
          prefixIcon: const Icon(Icons.business, size: 18),
          validator: (v) => Validators.requiredField(v, 'Firma Adı'),
        ),
        CustomTextField(
          controller: _branchNameController,
          label: 'Şube Adı / Kodu *',
          hint: 'Örn: Atatürk Havalimanı Şb., Göcek Marina Şb.',
          prefixIcon: const Icon(Icons.store, size: 18),
          validator: (v) => Validators.requiredField(v, 'Şube Adı'),
        ),
        CustomTextField(
          controller: _compPhoneController,
          label: 'Şube İletişim Numarası *',
          hint: '+90 212 465 00 00',
          keyboardType: TextInputType.phone,
          prefixIcon: const Icon(Icons.phone, size: 18),
          validator: Validators.phoneNumber,
        ),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _compCountryController,
                label: 'Ülke *',
                hint: 'Türkiye',
                validator: (v) => Validators.requiredField(v, 'Ülke'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: CustomTextField(
                controller: _compCityController,
                label: 'Şehir *',
                hint: 'İstanbul',
                validator: (v) => Validators.requiredField(v, 'Şehir'),
              ),
            ),
          ],
        ),
        CustomTextField(
          controller: _compDistrictController,
          label: 'İlçe *',
          hint: 'Bakırköy, Fethiye...',
          validator: (v) => Validators.requiredField(v, 'İlçe'),
        ),
        CustomTextField(
          controller: _compAddressController,
          label: 'Şubenin Açık Adresi *',
          hint: 'Terminal, Hangar, Rıhtım, Açık Adres...',
          validator: (v) => Validators.requiredField(v, 'Şube Adresi'),
        ),
      ],
    );
  }
}
