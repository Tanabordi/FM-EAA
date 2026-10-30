/// Minimal localization strings dictionary for TH/EN switching.
class AppStrings {
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'Fridge Management & Expiry Alert App',
      'welcome_title': 'Welcome To Fridge Management & Expiry Alert App',
      'my_fridges': 'My Fridges',
      'fresh': 'Fresh',
      'use_soon': 'Use soon',
      'expired': 'Expired',
      'mark_as_consumed': 'Mark as Consumed',
      'delete': 'Delete',
      'cancel': 'Cancel',
      'save': 'Save',
      'confirm': 'Confirm',
      'undo': 'Undo',
      'language': 'Language',
      'theme': 'Theme',
      'logout': 'Log out',
    },
    'th': {
      'app_name': 'แอปพลิเคชันจัดการสต็อกตู้เย็นและแจ้งเตือนวันหมดอายุ',
      'welcome_title': 'ยินดีต้อนรับสู่แอปจัดการตู้เย็นและแจ้งเตือนวันหมดอายุ',
      'my_fridges': 'ตู้เย็นของฉัน',
      'fresh': 'สดใหม่',
      'use_soon': 'ใกล้หมดอายุ',
      'expired': 'หมดอายุแล้ว',
      'mark_as_consumed': 'บันทึกว่ากินแล้ว',
      'delete': 'ลบ',
      'cancel': 'ยกเลิก',
      'save': 'บันทึก',
      'confirm': 'ยืนยัน',
      'undo': 'ย้อนกลับ',
      'language': 'ภาษา',
      'theme': 'ธีม',
      'logout': 'ออกจากระบบ',
    },
  };

  static String get(String key, String locale) {
    final lang = _localizedValues.containsKey(locale) ? locale : 'en';
    return _localizedValues[lang]?[key] ?? key;
  }
}

