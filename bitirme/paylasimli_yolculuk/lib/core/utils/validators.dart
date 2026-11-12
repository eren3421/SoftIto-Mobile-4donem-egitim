/// Form doğrulama yardımcı sınıfı.
class Validators {
  Validators._();

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-posta adresi zorunludur';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Geçerli bir e-posta adresi giriniz';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre zorunludur';
    }
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalıdır';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName alanı boş bırakılamaz';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Telefon numarası zorunludur';
    }
    if (value.trim().length < 10) {
      return 'Geçerli bir telefon numarası giriniz';
    }
    return null;
  }

  static String? validateLicensePlate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Plaka bilgisi zorunludur';
    }
    if (value.trim().length < 5) {
      return 'Geçerli bir plaka giriniz (Örn: 34 ABC 123)';
    }
    return null;
  }
}

