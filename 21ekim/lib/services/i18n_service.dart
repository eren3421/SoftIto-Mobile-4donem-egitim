class AppStrings {
  static const Map<String, Map<String, String>> values = {
    // Auth
    'app_title': {'tr': 'BAHÇIVAN', 'en': 'GARDENER'},
    'app_subtitle': {
      'tr': 'Bahçecilik ve Sera Yönetimi',
      'en': 'Greenhouse & Plant Care Management'
    },
    'user_login': {'tr': 'Kullanıcı Giriş', 'en': 'User Login'},
    'register_title': {'tr': 'Kayıt Oluştur', 'en': 'Create Account'},
    'forgot_pw_title': {'tr': 'ŞİFRE DEĞİŞTİR', 'en': 'RESET PASSWORD'},
    'reset_pw_title': {'tr': 'Yeni Şifre Gir', 'en': 'Enter New Password'},
    'email_label': {'tr': 'E-posta Adresi', 'en': 'Email Address'},
    'email_hint': {'tr': 'ornek@bahcivan.com', 'en': 'user@gardener.com'},
    'password_label': {'tr': 'Şifre', 'en': 'Password'},
    'password_hint': {'tr': '••••••••', 'en': '••••••••'},
    'new_password_label': {'tr': 'Yeni Şifre', 'en': 'New Password'},
    'confirm_password_label': {
      'tr': 'Yeni Şifre Tekrar',
      'en': 'Confirm New Password'
    },
    'login_btn': {'tr': 'Giriş Yap', 'en': 'Log In'},
    'register_btn': {'tr': 'Kayıt Ol', 'en': 'Sign Up'},
    'verify_continue_btn': {
      'tr': 'Doğrula ve Devam Et',
      'en': 'Verify & Continue'
    },
    'refresh_pw_btn': {'tr': 'Yenile', 'en': 'Update Password'},
    'forgot_password_link': {'tr': 'Şifremi Unuttum', 'en': 'Forgot Password?'},
    'create_account_link': {'tr': 'Kayıt Oluştur', 'en': 'Create an Account'},
    'back_to_login': {'tr': 'Giriş ekranına geri dön', 'en': 'Back to Login'},
    'auth_error_msg': {
      'tr': 'Hatalı e-posta veya şifre girdiniz!',
      'en': 'Invalid email or password!'
    },
    'auth_pw_mismatch': {
      'tr': 'Girdiğiniz şifreler eşleşmiyor!',
      'en': 'Passwords do not match!'
    },
    'forgot_pw_instruction': {
      'tr':
          'E-posta adresinizi kontrol edin ve doğrulama adımıyla şifrenizi yenileyin.',
      'en':
          'Check your email address and verify to set a new secure password.'
    },

    // Navigation & Common
    'sidebar_add_note': {'tr': 'Not Ekle', 'en': 'Add Note'},
    'sidebar_view_notes': {'tr': 'Notları Görüntüle', 'en': 'View Notes'},
    'tab_plants': {'tr': 'Bitkiler', 'en': 'Plants'},
    'tab_greenhouse_notes': {'tr': 'Sera Notları', 'en': 'Greenhouse Notes'},
    'tab_all_notes': {'tr': 'Notlar & Günlük', 'en': 'Notes & Logs'},
    'no_notes_message': {
      'tr': 'Henüz kaydedilmiş bir not bulunmuyor. Yeni bir not ekleyin!',
      'en': 'No notes added yet. Tap Add Note to write one!'
    },
    'delete_note_confirm': {
      'tr': 'Bu notu silmek istediğinize emin misiniz?',
      'en': 'Are you sure you want to delete this note?'
    },
    'sidebar_help': {
      'tr': 'Kullanım Kılavuzu ve Yardım',
      'en': 'User Guide & Help'
    },
    'sidebar_lang': {'tr': 'TR | EN Dil Ayarı', 'en': 'Language (TR / EN)'},
    'sidebar_calendar': {
      'tr': 'Takvim ve Hatırlatıcı',
      'en': 'Calendar & Alerts'
    },
    'sidebar_diagnosis': {
      'tr': 'Hastalık Teşhis Rehberi',
      'en': 'Pest Diagnosis'
    },
    'sidebar_logout': {'tr': 'Çıkış', 'en': 'Logout'},
    'btn_cancel': {'tr': 'İptal', 'en': 'Cancel'},
    'btn_confirm': {'tr': 'Onayla', 'en': 'Confirm'},
    'btn_save': {'tr': 'Kaydet', 'en': 'Save'},
    'btn_close': {'tr': 'Kapat', 'en': 'Close'},
    'btn_delete': {'tr': 'Sil', 'en': 'Delete'},
    'btn_detail': {'tr': 'Detay', 'en': 'Details'},
    'btn_main_menu': {'tr': 'Ana Menü', 'en': 'Main Menu'},
    'btn_back_to_greenhouse': {
      'tr': 'Seraya Dön',
      'en': 'Back to Greenhouse'
    },

    // Dashboard (Greenhouses)
    'greenhouses_title': {'tr': 'BAHÇELER', 'en': 'GREENHOUSES'},
    'greenhouses_subtitle': {
      'tr': 'Mevcut Bahçe ve Seralarınız',
      'en': 'Your Active Gardens & Greenhouses'
    },
    'add_greenhouse_btn': {'tr': '+ Sera Ekle', 'en': '+ Add Greenhouse'},
    'add_greenhouse_modal_title': {
      'tr': 'BAHÇELER - Yeni Sera Ekle',
      'en': 'GREENHOUSES - Add New Greenhouse'
    },
    'greenhouse_name_label': {'tr': 'Sera Adı:', 'en': 'Greenhouse Name:'},
    'greenhouse_name_hint': {
      'tr': 'Örn: Kışlık Balkon Serası',
      'en': 'e.g. Winter Balcony Greenhouse'
    },
    'greenhouse_icon_label': {
      'tr': 'Sera İkonu / Türü:',
      'en': 'Greenhouse Icon / Type:'
    },
    'greenhouse_photo_label': {
      'tr': 'Fotoğraf (İsteğe Bağlı):',
      'en': 'Photo (Optional):'
    },
    'plants_count': {'tr': 'Bitki', 'en': 'Plants'},
    'urgent_care_alert': {
      'tr': 'Acil Bakım Bekleyen Bitki Var!',
      'en': 'Urgent Plant Care Needed!'
    },
    'all_care_healthy': {
      'tr': 'Tüm Bakımlar Tamam',
      'en': 'All Care Up to Date'
    },

    // Delete Greenhouse Modal
    'delete_greenhouse_title': {
      'tr': 'Sera Silme Onayı',
      'en': 'Confirm Greenhouse Deletion'
    },
    'delete_greenhouse_warning': {
      'tr':
          'Sildiğiniz seraya ait tüm bitkiler, takvim hatırlatıcıları ve not kayıtları kalıcı olarak silinir ve geri getirilemez! O yüzden silmeden önce iyi düşün.',
      'en':
          'All plants, calendar reminders and notes in this greenhouse will be permanently deleted and cannot be recovered! Think carefully before proceeding.'
    },

    // Greenhouse Detail (Plant List)
    'greenhouse_detail_title': {'tr': 'Sera Adı:', 'en': 'Greenhouse:'},
    'add_plant_btn': {'tr': '+ Bitki Ekle', 'en': '+ Add Plant'},
    'plant_name_col': {'tr': 'Bitki Adı', 'en': 'Plant Name'},
    'plant_status_col': {'tr': 'Bakım Durumu', 'en': 'Care Status'},
    'plant_harvest_col': {'tr': 'Hasat Sayacı', 'en': 'Harvest Countdown'},
    'plant_action_col': {'tr': 'İşlem', 'en': 'Action'},
    'no_plants_message': {
      'tr': 'Bu serada henüz ekili bitki yok. Yeni bir bitki ekleyin!',
      'en': 'No plants in this greenhouse yet. Add your first plant!'
    },

    // Add Plant Modal
    'add_plant_modal_title': {
      'tr': 'Yeni Bitki Ekle & İhtiyaç Profili',
      'en': 'Add Plant & Care Profile'
    },
    'select_species_label': {'tr': 'Bitki Türü Seçin:', 'en': 'Plant Species:'},
    'custom_name_label': {
      'tr': 'Bitki Adı / Etiketi:',
      'en': 'Custom Plant Label:'
    },
    'custom_name_hint': {
      'tr': 'Örn: Doğu Köşesi Pembe Domates #1',
      'en': 'e.g. East Corner Pink Tomato #1'
    },
    'planting_date_label': {'tr': 'Ekim / Dikim Tarihi:', 'en': 'Planting Date:'},
    'location_note_label': {
      'tr': 'Saksı / Konum Notu:',
      'en': 'Pot / Location Note:'
    },
    'location_note_hint': {
      'tr': 'Örn: Orta sıra No: 3, 15L saksı',
      'en': 'e.g. Middle row #3, 15L pot'
    },

    // Plant Detail Modules
    'module_harvest_title': {
      'tr': '1. EKİMDEN HASADA TAHMİNİ GÜN SAYACI',
      'en': '1. ESTIMATED HARVEST COUNTDOWN'
    },
    'module_care_cards_title': {
      'tr': '2. SULAMA / GÜBRELEME / BUDAMA RENKLİ UYARI KARTLARI',
      'en': '2. WATERING / FERTILIZING / PRUNING COLOR ALERT CARDS'
    },
    'module_guide_title': {
      'tr': '3. BİTKİ TÜRÜNE GÖRE SULAMA VE GÜNEŞ İHTİYACI REHBERİ',
      'en': '3. WATER & SUNLIGHT CARE GUIDE BY SPECIES'
    },
    'module_diagnosis_title': {
      'tr': '4. ZARARLI BÖCEK VE HASTALIK BELİRTİSİ TEŞHİS REHBERİ',
      'en': '4. PEST & DISEASE SYMPTOM DIAGNOSIS GUIDE'
    },

    // Harvest details
    'planted_date': {'tr': 'Ekim Tarihi', 'en': 'Planted On'},
    'estimated_harvest': {'tr': 'Tahmini Hasat', 'en': 'Estimated Harvest'},
    'total_period': {'tr': 'Toplam Periyot', 'en': 'Total Duration'},
    'elapsed_days': {'tr': 'GEÇEN', 'en': 'ELAPSED'},
    'remaining_days': {'tr': 'KALAN', 'en': 'REMAINING'},
    'days_unit': {'tr': 'Gün', 'en': 'Days'},
    'completed_badge': {'tr': 'Tamamlandı', 'en': 'Completed'},
    'add_harvest_record_btn': {
      'tr': '+ Hasat Kaydı Ekle',
      'en': '+ Add Harvest Record'
    },

    // Care Cards
    'watering_card_title': {'tr': 'SULAMA ZAMANI', 'en': 'WATERING TIME'},
    'fertilizing_card_title': {
      'tr': 'GÜBRELEME ZAMANI',
      'en': 'FERTILIZING TIME'
    },
    'pruning_card_title': {'tr': 'BUDAMA ZAMANI', 'en': 'PRUNING TIME'},
    'mark_watered': {'tr': 'Sulandı İşaretle', 'en': 'Mark Watered'},
    'mark_fertilized': {'tr': 'Gübrelendi İşaretle', 'en': 'Mark Fertilized'},
    'mark_pruned': {'tr': 'Budandı İşaretle', 'en': 'Mark Pruned'},
    'period_label': {'tr': 'Periyot', 'en': 'Period'},
    'days_interval': {'tr': 'Günde 1', 'en': 'Days'},

    // Care Guide details
    'sunlight_guide': {'tr': 'Güneş İhtiyacı', 'en': 'Sunlight Needs'},
    'watering_guide': {'tr': 'Sulama Rehberi', 'en': 'Watering Guide'},
    'climate_guide': {'tr': 'İdeal İklim & Nem', 'en': 'Climate & Humidity'},
    'pruning_guide': {'tr': 'Toprak & Budama', 'en': 'Soil & Pruning'},

    // Pest Diagnosis
    'select_symptoms_instruction': {
      'tr': 'Gözlemlediğiniz belirtileri seçin:',
      'en': 'Select observed symptoms:'
    },
    'matched_diagnoses': {
      'tr': 'Eşleşen Teşhisler ve Çözümler',
      'en': 'Matched Diagnoses & Solutions'
    },
    'severity_high': {'tr': 'Yüksek Aciliyet', 'en': 'High Urgency'},
    'severity_medium': {'tr': 'Orta Aciliyet', 'en': 'Medium Urgency'},
    'severity_low': {'tr': 'Düşük Aciliyet', 'en': 'Low Urgency'},
    'organic_solution': {
      'tr': 'Doğal / Organik Çözüm:',
      'en': 'Organic Solution:'
    },
    'prevention_advice': {
      'tr': 'Önleme & Korunma:',
      'en': 'Prevention & Protection:'
    },
    'apply_treatment_note': {
      'tr': 'Tedavi Notu Olarak Kaydet',
      'en': 'Save as Treatment Note'
    },

    // User Guide Modal (3 Cards)
    'guide_card_1_title': {
      'tr': '1. Nasıl Sera Eklerim?',
      'en': '1. How do I add a greenhouse?'
    },
    'guide_card_1_body': {
      'tr':
          "Sera Ekle butonuna tıkla, sera adı ve isteğe bağlı ikon/fotoğraf belirle, ardından 'Onayla' butonuna basarak seranı oluştur.",
      'en':
          "Click the 'Add Greenhouse' button, provide a name and optional photo/icon, then click 'Confirm' to save your greenhouse."
    },
    'guide_card_2_title': {
      'tr': '2. Sildiğim Seraları Geri Getirebilir Miyim?',
      'en': '2. Can I recover deleted greenhouses?'
    },
    'guide_card_2_body': {
      'tr':
          'Hayır! Sildiğiniz seraya ait tüm bitkiler, bakım kayıtları ve notlar kalıcı olarak silinir. Bu yüzden silmeden önce iyi düşün.',
      'en':
          'No! All plants, care records, and notes in the greenhouse will be permanently deleted and cannot be recovered. Please be careful before deleting.'
    },
    'guide_card_3_title': {
      'tr': '3. S.S.S. ve İletişim',
      'en': '3. FAQ & Support'
    },
    'guide_card_3_body': {
      'tr':
          'Destek E-posta: destek@bahcivanapp.com\nTelefon: +90 (212) 555 00 00\nVersiyon: v2.4 (2026)\nAdres: Tarım Teknokent No: 21',
      'en':
          'Support Email: support@gardenerapp.com\nPhone: +90 (212) 555 00 00\nVersion: v2.4 (2026)\nAgritech Hub #21'
    },

    // Calendar & Logs
    'calendar_page_title': {
      'tr': 'Bakım Takvimi ve Hasat Günlüğü',
      'en': 'Care Calendar & Harvest Log'
    },
    'tab_calendar': {'tr': 'Bakım Takvimi', 'en': 'Care Calendar'},
    'tab_harvest_logs': {'tr': 'Hasat ve Verim Günlüğü', 'en': 'Harvest Logs'},
    'filter_all': {'tr': 'Tümü', 'en': 'All'},
    'filter_general': {'tr': 'Genel Notlar', 'en': 'General Notes'},
    'filter_treatment': {'tr': 'Tedavi / İlaçlama', 'en': 'Treatment'},
    'filter_harvest': {'tr': 'Hasat', 'en': 'Harvest'},
    'btn_view_notes': {'tr': 'Notları Görüntüle', 'en': 'View Notes'},
    'calendar_summary': {
      'tr':
          'Tüm seralardaki sulama, gübreleme ve budama görevlerini renk kodlarıyla takip edin.',
      'en':
          'Track watering, fertilizing and pruning tasks across all greenhouses by color status.'
    },
    'harvest_amount': {'tr': 'Miktar', 'en': 'Amount'},
    'harvest_quality': {'tr': 'Kalite', 'en': 'Quality'},
    'grams_unit': {'tr': 'gram', 'en': 'grams'},
  };

  static String get(String key, String lang) {
    if (!values.containsKey(key)) return key;
    return values[key]![lang] ?? values[key]!['tr'] ?? key;
  }
}
