/// Form validation helpers for Civilian TC No, Phone, Plate, and required fields.
class Validators {
  Validators._();

  static String? requiredField(String? value, [String fieldName = 'Bu alan']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName zorunludur.';
    }
    return null;
  }

  /// Validates 11-digit Turkish Identity Number (TCKN)
  static String? tcKimlikNo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'T.C. Kimlik Numarası zorunludur.';
    }
    final clean = value.replaceAll(RegExp(r'\D'), '');
    if (clean.length != 11) {
      return 'T.C. Kimlik Numarası 11 haneli olmalıdır.';
    }
    if (clean.startsWith('0')) {
      return 'T.C. Kimlik Numarası sıfır ile başlayamaz.';
    }

    // Algorithmic check
    final digits = clean.split('').map(int.parse).toList();
    final oddSum = digits[0] + digits[2] + digits[4] + digits[6] + digits[8];
    final evenSum = digits[1] + digits[3] + digits[5] + digits[7];

    final digit10 = ((oddSum * 7) - evenSum) % 10;
    if (digits[9] != digit10) {
      return 'Geçersiz T.C. Kimlik Numarası algoritması.';
    }

    final totalFirst10 = digits.take(10).reduce((a, b) => a + b);
    if (digits[10] != totalFirst10 % 10) {
      return 'Geçersiz T.C. Kimlik Numarası sağlama hanesi.';
    }

    return null;
  }

  /// Validates international or domestic telephone number
  static String? phoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'İletişim numarası zorunludur.';
    }
    final clean = value.replaceAll(RegExp(r'\D'), '');
    if (clean.length < 10 || clean.length > 13) {
      return 'Geçerli bir telefon numarası giriniz (Örn: 0532 123 45 67).';
    }
    return null;
  }

  /// Validates plate or tail or boat registration number
  static String? plateNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Plaka / Tescil numarası zorunludur.';
    }
    if (value.trim().length < 4) {
      return 'Plaka / Tescil numarası en az 4 karakter olmalıdır.';
    }
    return null;
  }

  /// Validates tracking number (e.g. TRK-LAND-3401, TRK-HAVA-10492, TRK-DENIZ-55301)
  static String? trackingNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Takip numarası zorunludur.';
    }
    if (!value.toUpperCase().startsWith('TRK-')) {
      return 'Takip numarası TRK- formatında olmalıdır (Örn: TRK-LAND-3401).';
    }
    return null;
  }

  /// Validates numeric positive price
  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Birim fiyat zorunludur.';
    }
    final numVal = double.tryParse(value.replaceAll('.', '').replaceAll(',', '.'));
    if (numVal == null || numVal <= 0) {
      return 'Geçerli bir tutar giriniz.';
    }
    return null;
  }
}
