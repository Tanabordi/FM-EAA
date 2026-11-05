import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'locale_provider.dart';

/// Centralized localization dictionary for English (en) and Thai (th).
class AppStrings {
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // General & Common
      'app_name': 'Fridge Management & Expiry Alert App',
      'welcome_title': 'Welcome To Fridge Management & Expiry Alert App',
      'welcome_subtitle': 'Sign in to your account to continue.',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'confirm': 'Confirm',
      'undo': 'Undo',
      'discard': 'Discard',
      'close': 'Close',
      'back': 'Back',
      'edit': 'Edit',
      'loading': 'Loading...',
      'success': 'Success',
      'error': 'Error',

      // Navigation & Settings
      'settings': 'Settings',
      'preferences': 'Preferences',
      'profile': 'Profile',
      'edit_profile': 'Edit Profile',
      'language': 'Language',
      'theme': 'Theme',
      'light': 'Light',
      'dark': 'Dark',
      'logout': 'Log out',
      'logout_confirm_title': 'Log Out',
      'logout_confirm_desc': 'Are you sure you want to log out of your account?',

      // Freshness Status
      'fresh': 'Fresh',
      'use_soon': 'Use soon',
      'expired': 'Expired',
      'days_left': 'days left',
      'day_left': 'day left',
      'expires_today': 'Expires today',
      'expired_days_ago': 'days ago',

      // Categories
      'all': 'All',
      'proteins': 'Proteins',
      'veggies': 'Veggies',
      'beverages': 'Beverages',
      'meals': 'Meals',
      'sauces': 'Sauces',

      // Zones
      'fridge': 'Fridge',
      'freezer': 'Freezer',

      // Fridges
      'my_fridges': 'My Fridges',
      'add_fridge': 'Add Fridge',
      'edit_fridge': 'Edit Fridge',
      'delete_fridge': 'Delete Fridge',
      'fridge_name': 'Fridge Name',
      'fridge_name_hint': 'e.g. Kitchen, Dorm, Office',
      'description': 'Description (Optional)',
      'description_hint': 'Add a note about this fridge',
      'members': 'members',
      'personal': 'Personal',
      'owner': 'Owner',
      'member': 'Member',
      'items_count': 'items',
      'empty_fridges': 'No fridges yet. Create one to get started!',

      // Inventory & Items
      'add_item': 'Add Item',
      'edit_item': 'Edit Item',
      'item_details': 'Item Details',
      'food_name': 'Food Name',
      'food_name_hint': 'e.g. Fresh Milk, Salmon',
      'category_label': 'Category',
      'storage_location': 'Storage Location',
      'quantity': 'Quantity',
      'unit': 'Unit',
      'expiry_date': 'Expiry Date',
      'scan_label': 'Scan Label',
      'open_ai_scanner': 'Open AI Label Scanner',
      'take_photo': 'Take Photo',
      'choose_gallery': 'Choose from Gallery',
      'mark_as_consumed': 'Mark as Consumed',
      'finished_all': 'Finished all',
      'amount_consumed': 'Amount consumed',
      'consumed_success': 'Marked as consumed',
      'empty_fridge_items': 'No items in this section.',

      // Search
      'search': 'Search',
      'search_ingredients_hint': 'Search ingredients...',
      'no_items_found': 'No items found',
      'clear': 'Clear',

      // History
      'history': 'History',
      'consumed_tab': 'Consumed',
      'expired_tab': 'Expired',
      'clear_all': 'Clear All',
      'clear_history_confirm': 'Are you sure you want to clear all history?',
      'empty_history': 'No history records yet.',
      'history_retention_notice': 'Records are kept for 30 days.',

      // Family & Sharing
      'family_share': 'Family Share',
      'invite_member': 'Invite Member',
      'remove_member': 'Remove Member',
      'enter_username': 'Enter username',
      'send_invite': 'Send Invite',
      'invite_success': 'Invitation sent successfully',

      // Notifications
      'notifications': 'Notifications',
      'accept': 'Accept',
      'decline': 'Decline',
      'no_notifications': 'No new notifications.',

      // AI Recipe Suggestion
      'ai_recipes': 'AI Recipe Ideas',
      'suggest_recipes': 'Suggest Recipes',
      'regenerate': 'Regenerate Recipes',
      'ingredients': 'Ingredients',
      'instructions': 'Instructions',
      'done_mark_consumed': 'Done! Mark as Consumed',
      'cooldown_notice': 'Please wait before regenerating again.',
      'recipe_time': 'Cook Time',
      'recipe_difficulty': 'Difficulty',
      'zero_waste_tip': 'Cook these recipes to prevent food waste!',

      // Auth
      'sign_in': 'Sign In',
      'sign_up': 'Sign Up',
      'email_or_username': 'Username or Email',
      'password': 'Password',
      'forgot_password': 'Forgot password?',
      'sign_in_google': 'Sign in with Google',
      'create_account': 'Create Account',
      'already_have_account': 'Already have an account? Sign In',
      'dont_have_account': "Don't have an account? Sign up",
    },
    'th': {
      // General & Common
      'app_name': 'แอปพลิเคชันจัดการตู้เย็นและแจ้งเตือนวันหมดอายุ',
      'welcome_title': 'ยินดีต้อนรับสู่แอปจัดการตู้เย็นและแจ้งเตือนวันหมดอายุ',
      'welcome_subtitle': 'เข้าสู่ระบบเพื่อเริ่มจัดการอาหารในตู้เย็นของคุณ',
      'save': 'บันทึก',
      'cancel': 'ยกเลิก',
      'delete': 'ลบ',
      'confirm': 'ยืนยัน',
      'undo': 'ย้อนกลับ',
      'discard': 'ละทิ้ง',
      'close': 'ปิด',
      'back': 'ย้อนกลับ',
      'edit': 'แก้ไข',
      'loading': 'กำลังโหลด...',
      'success': 'สำเร็จ',
      'error': 'เกิดข้อผิดพลาด',

      // Navigation & Settings
      'settings': 'การตั้งค่า',
      'preferences': 'การตั้งค่าทั่วไป',
      'profile': 'ข้อมูลส่วนตัว',
      'edit_profile': 'แก้ไขโปรไฟล์',
      'language': 'ภาษา',
      'theme': 'ธีม',
      'light': 'สว่าง',
      'dark': 'มืด',
      'logout': 'ออกจากระบบ',
      'logout_confirm_title': 'ออกจากระบบ',
      'logout_confirm_desc': 'คุณแน่ใจหรือไม่ว่าต้องการออกจากระบบบัญชีของคุณ?',

      // Freshness Status
      'fresh': 'สดใหม่',
      'use_soon': 'ควรบริโภคก่อน',
      'expired': 'หมดอายุแล้ว',
      'days_left': 'วัน',
      'day_left': 'วัน',
      'expires_today': 'หมดอายุวันนี้',
      'expired_days_ago': 'วันที่แล้ว',

      // Categories
      'all': 'ทั้งหมด',
      'proteins': 'โปรตีน',
      'veggies': 'ผักและผลไม้',
      'beverages': 'เครื่องดื่ม',
      'meals': 'อาหารปรุงสุก',
      'sauces': 'ซอสและเครื่องปรุง',

      // Zones
      'fridge': 'ช่องธรรมดา',
      'freezer': 'ช่องแช่แข็ง',

      // Fridges
      'my_fridges': 'ตู้เย็นของฉัน',
      'add_fridge': 'เพิ่มตู้เย็น',
      'edit_fridge': 'แก้ไขตู้เย็น',
      'delete_fridge': 'ลบตู้เย็น',
      'fridge_name': 'ชื่อตู้เย็น',
      'fridge_name_hint': 'เช่น ตู้เย็นห้องครัว, หอพัก, ออฟฟิศ',
      'description': 'รายละเอียด (ระบุหรือไม่ก็ได้)',
      'description_hint': 'เพิ่มบันทึกเกี่ยวกับตู้เย็นนี้',
      'members': 'สมาชิก',
      'personal': 'ส่วนตัว',
      'owner': 'เจ้าของ',
      'member': 'สมาชิก',
      'items_count': 'รายการ',
      'empty_fridges': 'ยังไม่มีตู้เย็น เริ่มต้นสร้างตู้เย็นใหม่ได้เลย!',

      // Inventory & Items
      'add_item': 'เพิ่มวัตถุดิบ',
      'edit_item': 'แก้ไขวัตถุดิบ',
      'item_details': 'รายละเอียดวัตถุดิบ',
      'food_name': 'ชื่ออาหาร',
      'food_name_hint': 'เช่น นมสด, เนื้อปลาแซลมอน',
      'category_label': 'หมวดหมู่',
      'storage_location': 'ช่องจัดเก็บ',
      'quantity': 'จำนวน',
      'unit': 'หน่วย',
      'expiry_date': 'วันหมดอายุ',
      'scan_label': 'สแกนฉลาก',
      'open_ai_scanner': 'เปิดกล้องสแกนฉลากด้วย AI',
      'take_photo': 'ถ่ายภาพ',
      'choose_gallery': 'เลือกจากคลังรูปภาพ',
      'mark_as_consumed': 'บันทึกว่ากินแล้ว',
      'finished_all': 'กินหมดแล้ว',
      'amount_consumed': 'จำนวนที่บริโภค',
      'consumed_success': 'บันทึกว่ากินแล้วเรียบร้อย',
      'empty_fridge_items': 'ไม่มีรายการอาหารในช่องนี้',

      // Search
      'search': 'ค้นหา',
      'search_ingredients_hint': 'ค้นหาชื่อวัตถุดิบ...',
      'no_items_found': 'ไม่พบรายการที่ค้นหา',
      'clear': 'ล้าง',

      // History
      'history': 'ประวัติการใช้งาน',
      'consumed_tab': 'กินแล้ว',
      'expired_tab': 'หมดอายุ',
      'clear_all': 'ล้างประวัติทั้งหมด',
      'clear_history_confirm': 'คุณแน่ใจหรือไม่ว่าต้องการล้างประวัติทั้งหมด?',
      'empty_history': 'ยังไม่มีประวัติการใช้งาน',
      'history_retention_notice': 'ระบบจะเก็บประวัติย้อนหลัง 30 วัน',

      // Family & Sharing
      'family_share': 'แชร์ในครอบครัว',
      'invite_member': 'เชิญสมาชิก',
      'remove_member': 'นำสมาชิกออก',
      'enter_username': 'กรอกชื่อผู้ใช้ (@username)',
      'send_invite': 'ส่งคำเชิญ',
      'invite_success': 'ส่งคำเชิญเข้าร่วมตู้เย็นเรียบร้อยแล้ว',

      // Notifications
      'notifications': 'การแจ้งเตือน',
      'accept': 'ยอมรับ',
      'decline': 'ปฏิเสธ',
      'no_notifications': 'ไม่มีการแจ้งเตือนใหม่',

      // AI Recipe Suggestion
      'ai_recipes': 'เมนูอาหารแนะนำจาก AI',
      'suggest_recipes': 'แนะนำเมนูอาหาร',
      'regenerate': 'สุ่มเมนูใหม่',
      'ingredients': 'วัตถุดิบที่ใช้',
      'instructions': 'ขั้นตอนการปรุง',
      'done_mark_consumed': 'เสร็จแล้ว! บันทึกว่ากินแล้ว',
      'cooldown_notice': 'กรุณารอสักครู่ก่อนขอเมนูใหม่',
      'recipe_time': 'เวลาทำ',
      'recipe_difficulty': 'ระดับความยาก',
      'zero_waste_tip': 'ทำเมนูเหล่านี้เพื่อลดขยะอาหารจากของใกล้หมดอายุ!',

      // Auth
      'sign_in': 'เข้าสู่ระบบ',
      'sign_up': 'สมัครสมาชิก',
      'email_or_username': 'ชื่อผู้ใช้ หรือ อีเมล',
      'password': 'รหัสผ่าน',
      'forgot_password': 'ลืมรหัสผ่าน?',
      'sign_in_google': 'เข้าสู่ระบบด้วย Google',
      'create_account': 'สร้างบัญชีผู้ใช้ใหม่',
      'already_have_account': 'มีบัญชีอยู่แล้ว? เข้าสู่ระบบ',
      'dont_have_account': 'ยังไม่มีบัญชีผู้ใช้? สมัครสมาชิก',
    },
  };

  /// Get localized string by key and locale language code ('en' or 'th')
  static String get(String key, String locale) {
    final lang = _localizedValues.containsKey(locale) ? locale : 'en';
    final dict = _localizedValues[lang] ?? _localizedValues['en']!;
    return dict[key] ?? _localizedValues['en']?[key] ?? key;
  }

  /// Helper to get text using current BuildContext
  static String tr(BuildContext context, String key) {
    try {
      final locale = Localizations.localeOf(context).languageCode;
      return get(key, locale);
    } catch (_) {
      return get(key, 'en');
    }
  }
}

/// Extension on BuildContext for quick syntax: context.tr('my_fridges')
extension BuildContextLocalizationExtension on BuildContext {
  String tr(String key) => AppStrings.tr(this, key);
}

/// Extension on WidgetRef for ConsumerWidget: ref.tr('my_fridges')
extension WidgetRefLocalizationExtension on WidgetRef {
  String tr(String key) {
    final locale = watch(localeProvider).languageCode;
    return AppStrings.get(key, locale);
  }
}
