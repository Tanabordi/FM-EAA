import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../data/models/item_model.dart';
import '../../../../data/repositories/ai_repository.dart';
import '../../../../data/repositories/item_repository.dart';
import '../../../../shared/utils/date_input_formatter.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../../fridge_detail/providers/fridge_detail_provider.dart';
import '../../../fridges/providers/fridges_provider.dart';
import 'scan_label_page.dart';

/// Screen #11: Add items
/// AI Label Scan Card with Gemini button, form fields: Food Name, Category dropdown,
/// Quantity & Unit row, Storage Location dropdown, Expiration Date picker, and Save button.
class AddItemPage extends ConsumerStatefulWidget {
  final String fridgeId;
  final AiScanResult? initialScanResult;

  const AddItemPage({
    super.key,
    required this.fridgeId,
    this.initialScanResult,
  });

  @override
  ConsumerState<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends ConsumerState<AddItemPage> {
  final _foodNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _expirationDateController = TextEditingController();
  String? _selectedCategory;
  String? _selectedUnit;
  String? _selectedStorage;
  DateTime? _expirationDate;
  String? _imagePath;
  Uint8List? _imageBytes;
  bool _hasAnalyzed = false;
  bool _isScanning = false;
  bool _forceExit = false;
  bool _isAiEstimatedExpiry = false;

  String? _foodNameError;
  String? _categoryError;
  String? _quantityError;
  String? _unitError;
  String? _storageError;
  String? _expirationDateError;

  final _categories = ['Proteins', 'Veggies', 'Beverages', 'Meals', 'Sauces'];
  final _units = ['pieces', 'bag', 'punnet', 'bottle', 'box', 'can', 'pack', 'g', 'kg'];
  final _storages = ['Fridge', 'Freezer'];

  String? _normalizeCategory(String? cat) {
    if (cat == null || cat.trim().isEmpty) return null;
    final lower = cat.trim().toLowerCase();
    for (final c in _categories) {
      if (c.toLowerCase() == lower) return c;
    }
    if (lower.contains('veg') || lower.contains('fruit')) return 'Veggies';
    if (lower.contains('meat') || lower.contains('protein') || lower.contains('fish') || lower.contains('chicken') || lower.contains('beef')) return 'Proteins';
    if (lower.contains('drink') || lower.contains('bever') || lower.contains('milk') || lower.contains('juice') || lower.contains('water')) return 'Beverages';
    if (lower.contains('sauce') || lower.contains('condiment') || lower.contains('jam')) return 'Sauces';
    if (lower.contains('meal') || lower.contains('food') || lower.contains('leftover')) return 'Meals';
    return _categories.first;
  }

  String? _normalizeUnit(String? u) {
    if (u == null || u.trim().isEmpty) return null;
    final lower = u.trim().toLowerCase();
    for (final unit in _units) {
      if (unit.toLowerCase() == lower) return unit;
    }
    if (lower.contains('piece') || lower == 'pc' || lower == 'pcs') return 'pieces';
    if (lower.contains('bottle')) return 'bottle';
    if (lower.contains('bag')) return 'bag';
    if (lower.contains('box')) return 'box';
    if (lower.contains('can')) return 'can';
    if (lower.contains('pack') || lower.contains('pkt')) return 'pack';
    if (lower.contains('punnet')) return 'punnet';
    if (lower == 'g' || lower.contains('gram')) return 'g';
    if (lower == 'kg' || lower.contains('kilo')) return 'kg';
    return _units.first;
  }

  String? _normalizeStorage(String? s) {
    if (s == null || s.trim().isEmpty) return null;
    final lower = s.trim().toLowerCase();
    if (lower.contains('freez')) return 'Freezer';
    return 'Fridge';
  }

  String _getCategoryDisplay(String c, bool isTh) {
    if (!isTh) return c;
    switch (c) {
      case 'Proteins':
        return 'โปรตีน';
      case 'Veggies':
        return 'ผักและผลไม้';
      case 'Beverages':
        return 'เครื่องดื่ม';
      case 'Meals':
        return 'อาหารปรุงสำเร็จ';
      case 'Sauces':
        return 'เครื่องปรุงและซอส';
      default:
        return c;
    }
  }

  String _getUnitDisplay(String u, bool isTh) {
    if (!isTh) return u;
    switch (u) {
      case 'pieces':
        return 'ชิ้น';
      case 'bag':
        return 'ถุง';
      case 'punnet':
        return 'ตะกร้า';
      case 'bottle':
        return 'ขวด';
      case 'box':
        return 'กล่อง';
      case 'can':
        return 'กระป๋อง';
      case 'pack':
        return 'แพ็ค';
      case 'g':
        return 'กรัม (g)';
      case 'kg':
        return 'กิโลกรัม (kg)';
      default:
        return u;
    }
  }

  String _getStorageDisplay(String s, bool isTh) {
    if (!isTh) return s;
    switch (s) {
      case 'Fridge':
        return 'ช่องแช่เย็น (Fridge)';
      case 'Freezer':
        return 'ช่องแช่แข็ง (Freezer)';
      default:
        return s;
    }
  }

  DateTime? _tryParseDate(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    final iso = DateTime.tryParse(trimmed);
    if (iso != null) return iso;

    final mdyMatch = RegExp(r'^(\d{1,2})[\/\-\.](\d{1,2})[\/\-\.](\d{2,4})$').firstMatch(trimmed);
    if (mdyMatch != null) {
      final p1 = int.tryParse(mdyMatch.group(1)!);
      final p2 = int.tryParse(mdyMatch.group(2)!);
      var year = int.tryParse(mdyMatch.group(3)!);
      if (p1 != null && p2 != null && year != null) {
        if (year < 100) year += 2000;
        // Priority 1: MM/DD/YYYY (e.g. 10/28/2026)
        if (p1 >= 1 && p1 <= 12 && p2 >= 1 && p2 <= 31) {
          try {
            final dt = DateTime(year, p1, p2);
            if (dt.year == year && dt.month == p1 && dt.day == p2) return dt;
          } catch (_) {}
        }
        // Priority 2: Fallback to DD/MM/YYYY (if day > 12)
        if (p2 >= 1 && p2 <= 12 && p1 >= 1 && p1 <= 31) {
          try {
            final dt = DateTime(year, p2, p1);
            if (dt.year == year && dt.month == p2 && dt.day == p1) return dt;
          } catch (_) {}
        }
      }
    }

    final monthsMap = {
      'jan': 1, 'january': 1,
      'feb': 2, 'february': 2,
      'mar': 3, 'march': 3,
      'apr': 4, 'april': 4,
      'may': 5,
      'jun': 6, 'june': 6,
      'jul': 7, 'july': 7,
      'aug': 8, 'august': 8,
      'sep': 9, 'september': 9,
      'oct': 10, 'october': 10,
      'nov': 11, 'november': 11,
      'dec': 12, 'december': 12,
    };

    final wordsMatch = RegExp(r'^(\d{1,2})\s+([A-Za-z]+),?\s+(\d{2,4})$').firstMatch(trimmed);
    if (wordsMatch != null) {
      final day = int.tryParse(wordsMatch.group(1)!);
      final monthName = wordsMatch.group(2)!.toLowerCase();
      var year = int.tryParse(wordsMatch.group(3)!);
      final month = monthsMap[monthName];
      if (day != null && month != null && year != null) {
        if (year < 100) year += 2000;
        try {
          final dt = DateTime(year, month, day);
          if (dt.year == year && dt.month == month && dt.day == day) return dt;
        } catch (_) {}
      }
    }

    final monthFirstMatch = RegExp(r'^([A-Za-z]+)\s+(\d{1,2}),?\s+(\d{2,4})$').firstMatch(trimmed);
    if (monthFirstMatch != null) {
      final monthName = monthFirstMatch.group(1)!.toLowerCase();
      final day = int.tryParse(monthFirstMatch.group(2)!);
      var year = int.tryParse(monthFirstMatch.group(3)!);
      final month = monthsMap[monthName];
      if (day != null && month != null && year != null) {
        if (year < 100) year += 2000;
        try {
          final dt = DateTime(year, month, day);
          if (dt.year == year && dt.month == month && dt.day == day) return dt;
        } catch (_) {}
      }
    }

    return null;
  }

  bool get _hasUnsavedChanges {
    if (_forceExit) return false;
    return _foodNameController.text.trim().isNotEmpty ||
        _quantityController.text.trim().isNotEmpty ||
        _expirationDateController.text.trim().isNotEmpty ||
        _selectedCategory != null ||
        _selectedUnit != null ||
        _selectedStorage != null ||
        _expirationDate != null ||
        _imagePath != null ||
        _imageBytes != null;
  }

  bool get _isTh {
    try {
      return ref.watch(localeProvider).languageCode == 'th';
    } catch (_) {
      try {
        return Localizations.localeOf(context).languageCode == 'th';
      } catch (_) {
        return false;
      }
    }
  }

  bool _isThRead() {
    try {
      return ref.read(localeProvider).languageCode == 'th';
    } catch (_) {
      try {
        return Localizations.localeOf(context).languageCode == 'th';
      } catch (_) {
        return false;
      }
    }
  }

  void _handleBack() {
    final isTh = _isThRead();
    if (_hasUnsavedChanges) {
      showDialog(
        context: context,
        builder: (dialogContext) => ConfirmDialog(
          title: isTh ? 'ยกเลิกการเปลี่ยนแปลง?' : 'Discard changes?',
          message: isTh
              ? 'คุณมีข้อมูลที่ยังไม่ได้บันทึก ต้องการยกเลิกใช่หรือไม่?'
              : 'You have unsaved changes. Are you sure you want to discard them?',
          confirmLabel: isTh ? 'ยกเลิก' : 'Discard',
          cancelLabel: isTh ? 'แก้ไขต่อ' : 'Keep editing',
          isDestructive: true,
          onConfirm: () {
            setState(() => _forceExit = true);
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              try {
                context.pop();
              } catch (_) {}
            }
          },
        ),
      );
    } else {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        try {
          context.pop();
        } catch (_) {}
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialScanResult != null) {
      _applyScanResult(widget.initialScanResult!);
    }
  }

  void _applyScanResult(AiScanResult result) {
    if (!result.isFood || result.foodName == null || result.foodName!.trim().isEmpty) {
      _hasAnalyzed = false;
      return;
    }

    _foodNameController.text = result.foodName!;
    _foodNameError = null;
    if (result.imagePath != null && result.imagePath!.isNotEmpty) {
      _imagePath = result.imagePath;
      try {
        final f = File(result.imagePath!);
        if (f.existsSync()) {
          _imageBytes = f.readAsBytesSync();
        }
      } catch (_) {}
    }
    _selectedCategory = _normalizeCategory(result.category);
    _categoryError = null;
    if (_quantityController.text.trim().isEmpty) {
      _quantityController.text = '1';
      _quantityError = null;
    }
    _selectedUnit = _normalizeUnit(result.unit);
    _unitError = null;
    _selectedStorage = _normalizeStorage(result.storage);
    _storageError = null;
    _isAiEstimatedExpiry = result.isAiEstimated;
    if (result.expiryDate != null) {
      _expirationDate = result.expiryDate;
      _expirationDateController.text = _formatDate(result.expiryDate!);
      _expirationDateError = null;
    } else {
      _expirationDate = null;
      _expirationDateController.text = '';
    }
    _hasAnalyzed = true;
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _quantityController.dispose();
    _expirationDateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$m/$d/${date.year}';
  }

  InputDecoration _inputDecoration({String? hintText, Widget? suffixIcon, String? errorText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF717971),
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      errorText: errorText,
      errorStyle: const TextStyle(
        color: Color(0xFFBA1A1A),
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: const Color(0xFFF6FBF3),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: errorText != null ? const Color(0xFFBA1A1A) : const Color(0xFF717971),
          width: errorText != null ? 1.5 : 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: errorText != null ? const Color(0xFFBA1A1A) : const Color(0xFF2E6A44),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: 1.5),
      ),
    );
  }

  void _clearAllData() {
    setState(() {
      _imagePath = null;
      _imageBytes = null;
      _hasAnalyzed = false;
      _isScanning = false;
      _foodNameController.clear();
      _quantityController.clear();
      _expirationDateController.clear();
      _selectedCategory = null;
      _selectedUnit = null;
      _selectedStorage = null;
      _expirationDate = null;
      _isAiEstimatedExpiry = false;
      _foodNameError = null;
      _categoryError = null;
      _quantityError = null;
      _unitError = null;
      _storageError = null;
      _expirationDateError = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cleared all data'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _onSave() async {
    final isTh = _isThRead();
    final name = _foodNameController.text.trim();
    final qtyText = _quantityController.text.trim();
    final parsedQty = double.tryParse(qtyText);

    String? nameErr;
    String? catErr;
    String? qtyErr;
    String? unitErr;
    String? storageErr;
    String? dateErr;

    if (name.isEmpty) {
      nameErr = isTh ? 'กรุณากรอกชื่ออาหารก่อนบันทึก' : 'Please enter a food name before saving';
    }
    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      catErr = isTh ? 'กรุณาเลือกหมวดหมู่' : 'Please select a category';
    }
    if (qtyText.isEmpty || parsedQty == null || parsedQty <= 0) {
      qtyErr = isTh ? 'กรุณากรอกจำนวนที่ถูกต้อง' : 'Please enter a valid quantity';
    }
    if (_selectedUnit == null || _selectedUnit!.isEmpty) {
      unitErr = isTh ? 'กรุณาเลือกหน่วย' : 'Please select a unit';
    }
    if (_selectedStorage == null || _selectedStorage!.isEmpty) {
      storageErr = isTh ? 'กรุณาเลือกสถานที่จัดเก็บ' : 'Please select a storage location';
    }

    final dateInput = _expirationDateController.text.trim();
    if (_expirationDate == null && dateInput.isNotEmpty) {
      _expirationDate = _tryParseDate(dateInput);
    }

    if (dateInput.isEmpty && _expirationDate == null) {
      dateErr = isTh ? 'กรุณากรอกหรือเลือกวันหมดอายุ' : 'Please enter or select an expiration date';
    } else if (dateInput.isNotEmpty && _expirationDate == null) {
      dateErr = isTh ? 'รูปแบบวันที่ไม่ถูกต้อง กรุณาใช้วันที่ที่ถูกต้อง' : 'Invalid date. Use MM/DD/YYYY (or YYYY-MM-DD)';
    }

    setState(() {
      _foodNameError = nameErr;
      _categoryError = catErr;
      _quantityError = qtyErr;
      _unitError = unitErr;
      _storageError = storageErr;
      _expirationDateError = dateErr;
    });

    if (nameErr != null ||
        catErr != null ||
        qtyErr != null ||
        unitErr != null ||
        storageErr != null ||
        dateErr != null) {
      return;
    }

    // If the image is a local file, ensure it's uploaded to OCI Object Storage so all devices can display it
    if (_imagePath != null &&
        !_imagePath!.startsWith('http') &&
        !_imagePath!.startsWith('assets/') &&
        !Platform.environment.containsKey('FLUTTER_TEST')) {
      try {
        if (_imageBytes == null && !kIsWeb) {
          final f = File(_imagePath!);
          if (f.existsSync()) {
            _imageBytes = await f.readAsBytes();
          }
        }
        if (_imageBytes != null) {
          final cloudUrl = await ref.read(itemRepositoryProvider).uploadItemImageBytes(
            _imageBytes!,
            filename: 'item.jpg',
          );
          if (cloudUrl != null) {
            _imagePath = cloudUrl;
          }
        }
      } catch (_) {}
    }

    final newItem = ItemModel(
      id: 'item_${DateTime.now().millisecondsSinceEpoch}',
      fridgeId: widget.fridgeId,
      name: name,
      category: _selectedCategory!.toLowerCase(),
      zone: _selectedStorage!.toLowerCase(),
      quantity: parsedQty!,
      unit: _selectedUnit!,
      expiryDate: _expirationDate!,
      imagePath: _imagePath ?? 'assets/images/food_avocados.png',
      updatedAt: DateTime.now(),
    );

    await ref.read(fridgeItemsProvider(widget.fridgeId).notifier).addItem(newItem);
    final currentItems = ref.read(fridgeItemsProvider(widget.fridgeId));
    ref.read(fridgesProvider.notifier).updateItemCount(widget.fridgeId, currentItems.length);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isTh
              ? 'เพิ่ม "${newItem.name}" เรียบร้อยแล้ว'
              : 'Added "${newItem.name}" successfully',
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      try {
        context.pop();
      } catch (_) {}
    }
  }


  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickManualPhoto(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        if (mounted) {
          setState(() {
            _imageBytes = bytes;
            _imagePath = picked.path;
            _hasAnalyzed = false;
          });
        }

        // Upload to OCI Object Storage in background
        if (!Platform.environment.containsKey('FLUTTER_TEST')) {
          try {
            final cloudUrl = await ref.read(itemRepositoryProvider).uploadItemImageBytes(
              bytes,
              filename: picked.name,
            );
            if (cloudUrl != null && mounted) {
              setState(() {
                _imagePath = cloudUrl;
              });
            }
          } catch (_) {}
        }
      }
    } catch (e) {
      if (mounted) {
        final errStr = e.toString().toLowerCase();
        String message;
        if (errStr.contains('camera_access_denied') ||
            errStr.contains('cameraaccessdenied') ||
            (errStr.contains('camera') && errStr.contains('denied'))) {
          message = 'Camera permission was denied. Please allow camera access in Settings.';
        } else if (errStr.contains('photo_access_denied') ||
            errStr.contains('permission_denied') ||
            (errStr.contains('gallery') && errStr.contains('denied')) ||
            (errStr.contains('photo') && errStr.contains('denied'))) {
          message = 'Photo access was denied. Please allow gallery access in Settings.';
        } else if (errStr.contains('permission')) {
          message = source == ImageSource.camera
              ? 'Camera permission was denied. Please allow camera access in Settings.'
              : 'Gallery access was denied. Please allow photo access in Settings.';
        } else {
          message = source == ImageSource.camera
              ? 'Unable to open camera. Please try again.'
              : 'Unable to open gallery. Please try again.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _removePhoto() {
    setState(() {
      _imagePath = null;
      _imageBytes = null;
      _hasAnalyzed = false;
    });
  }

  void _showRemoveOptionsSheet() {
    final hasFormData = _foodNameController.text.trim().isNotEmpty ||
        _selectedCategory != null ||
        _quantityController.text.trim().isNotEmpty ||
        _expirationDateController.text.trim().isNotEmpty ||
        _selectedUnit != null ||
        _selectedStorage != null ||
        _expirationDate != null;

    if (!hasFormData) {
      _removePhoto();
      return;
    }

    final isTh = _isThRead();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDE4DC),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    isTh ? 'นำรูปออกหรือรีเซ็ตแบบฟอร์ม?' : 'Remove Photo or Reset Form?',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF181D17),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAEFE8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_outlined, color: Color(0xFF2E6A44), size: 22),
                ),
                title: Text(
                  isTh ? 'นำรูปภาพออกเท่านั้น' : 'Remove photo only',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF181D17),
                  ),
                ),
                subtitle: Text(
                  isTh
                      ? 'เก็บรายละเอียดที่กรอกไว้ และลบเฉพาะรูปภาพ'
                      : 'Keep entered details and delete only the photo',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF5C665F)),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _removePhoto();
                },
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_sweep_outlined, color: Color(0xFFDC2626), size: 22),
                ),
                title: Text(
                  isTh ? 'ล้างข้อมูลทั้งหมดและรีเซ็ต' : 'Clear all and reset form',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFDC2626),
                  ),
                ),
                subtitle: Text(
                  isTh
                      ? 'ลบรูปภาพและรีเซ็ตข้อมูลอาหารทั้งหมด'
                      : 'Delete photo and reset all food details',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF5C665F)),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _clearAllData();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePhotoSheet() {
    final isTh = _isThRead();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.auto_awesome, color: Color(0xFF2E6A44)),
                title: Text(isTh ? 'สแกนฉลากด้วย AI' : 'Scan Label with AI'),
                onTap: () {
                  Navigator.pop(ctx);
                  _openScanLabelScanner();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: Color(0xFF2E6A44)),
                title: Text(isTh ? 'ถ่ายภาพ (ด้วยตัวเอง)' : 'Take Photo (Manual)'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickManualPhoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: Color(0xFF2E6A44)),
                title: Text(isTh ? 'เลือกจากคลังภาพ' : 'Choose from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickManualPhoto(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: Text(isTh ? 'นำรูปภาพออก' : 'Remove Photo', style: const TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showRemoveOptionsSheet();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openScanLabelScanner() async {
    final result = await Navigator.push<AiScanResult>(
      context,
      MaterialPageRoute(
        builder: (context) => ScanLabelPage(fridgeId: widget.fridgeId),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _applyScanResult(result);
      });
    }
  }

  Widget _buildScanCardContent([bool isTh = false]) {
    if (_isScanning) {
      return Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: ShaderMask(
                shaderCallback: (bounds) => const SweepGradient(
                  colors: [
                    Color(0xFF4285F4),
                    Color(0xFF9B72CF),
                    Color(0xFFEA4335),
                    Color(0xFFFBBC04),
                    Color(0xFF4285F4),
                  ],
                ).createShader(bounds),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isTh
                ? 'กำลังวิเคราะห์ฉลากด้วย Gemini AI Vision...'
                : 'Analyzing label with Gemini AI Vision...',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF181D17),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isTh
                ? 'กำลังดึงชื่อผลิตภัณฑ์และวันหมดอายุ'
                : 'Extracting product name and expiration date',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF414941),
            ),
          ),
          const SizedBox(height: 14),
          const ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            child: LinearProgressIndicator(
              minHeight: 4,
              backgroundColor: Color(0xFFDDE4DC),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E6A44)),
            ),
          ),
        ],
      );
    }

    if (_imageBytes != null || (_imagePath != null && _imagePath!.isNotEmpty)) {
      return InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _showChangePhotoSheet,
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 130,
                    width: double.infinity,
                    child: _imageBytes != null
                        ? Image.memory(
                            _imageBytes!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.fastfood, size: 48, color: Colors.grey),
                            ),
                          )
                        : (_imagePath!.startsWith('http://') || _imagePath!.startsWith('https://')
                            ? Image.network(
                                _imagePath!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.fastfood, size: 48, color: Colors.grey),
                                ),
                              )
                            : (_imagePath!.startsWith('assets/')
                                ? Image.asset(
                                    _imagePath!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(Icons.fastfood, size: 48, color: Colors.grey),
                                    ),
                                  )
                                : (!kIsWeb
                                    ? Image.file(
                                        File(_imagePath!),
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Center(
                                          child: Icon(Icons.fastfood, size: 48, color: Colors.grey),
                                        ),
                                      )
                                    : const Center(
                                        child: Icon(Icons.fastfood, size: 48, color: Colors.grey),
                                      )))),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _hasAnalyzed ? Icons.check_circle_rounded : Icons.photo_camera_rounded,
                          color: const Color(0xFF2E6A44),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _hasAnalyzed
                              ? (isTh ? 'สแกนฉลากด้วย AI แล้ว' : 'Label Scanned with AI')
                              : (isTh ? 'แนบรูปภาพแล้ว' : 'Photo Attached'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E6A44),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    key: const Key('add_item_remove_photo_btn'),
                    onTap: _showRemoveOptionsSheet,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _hasAnalyzed && _foodNameController.text.isNotEmpty
                  ? (isTh
                      ? 'ตรวจพบ: ${_foodNameController.text}'
                      : 'Detected: ${_foodNameController.text}')
                  : (_foodNameController.text.isNotEmpty
                      ? _foodNameController.text
                      : (isTh ? 'แนบรูปภาพอาหารแล้ว' : 'Food photo attached')),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF181D17),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isTh
                  ? 'แตะการ์ดเพื่อเปลี่ยนรูป หรือแตะ ✕ เพื่อนำออก'
                  : 'Tap card to change photo, or tap ✕ to remove',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF414941),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Default Card: AI Scan & Manual Photo Options
    return Column(
      children: [
        const Icon(
          Icons.camera_alt_outlined,
          size: 32,
          color: Color(0xFF181D17),
        ),
        const SizedBox(height: 8),
        Text(
          isTh ? 'เพิ่มรูปภาพหรือสแกนฉลาก' : 'Add Photo or Scan Label',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF181D17),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isTh
              ? 'สแกนฉลากเพื่อกรอกข้อมูลอัตโนมัติ หรือถ่ายภาพ/อัปโหลดภาพ'
              : 'Scan label to autofill details, or take/upload a photo',
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF414941),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        // Primary action: Scan Label with AI
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            key: const Key('add_item_scan_ai_btn'),
            onPressed: _openScanLabelScanner,
            icon: const Icon(Icons.auto_awesome, size: 18, color: Colors.white),
            label: Text(
              isTh ? 'สแกนฉลากด้วย AI' : 'Scan Label with AI',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E6A44),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Secondary actions: Take Photo & Gallery
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                key: const Key('add_item_take_photo_btn'),
                onPressed: () => _pickManualPhoto(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined, size: 16, color: Color(0xFF2E6A44)),
                label: Text(
                  isTh ? 'ถ่ายภาพ' : 'Take Photo',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF181D17),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.8),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                key: const Key('add_item_gallery_btn'),
                onPressed: () => _pickManualPhoto(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined, size: 16, color: Color(0xFF2E6A44)),
                label: Text(
                  isTh ? 'คลังภาพ' : 'Gallery',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF181D17),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.8),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTh = _isTh;

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6FBF3),
        body: SafeArea(
          child: Column(
            children: [
              // Top Navigation Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    AppBackButton(
                      onPressed: _handleBack,
                    ),
                    const SizedBox(width: 14),
                    Text(
                      isTh ? 'เพิ่มรายการอาหาร' : 'Add items',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF181D17),
                      ),
                    ),
                  ],
                ),
              ),
              // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Photo / Scan Card
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAEFE8),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: (_imagePath != null || _imageBytes != null)
                              ? const Color(0xFF2E6A44).withValues(alpha: 0.3)
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: _buildScanCardContent(isTh),
                    ),
                    const SizedBox(height: 20),
                    // Food Name Field
                    TextFormField(
                      controller: _foodNameController,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF181D17),
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: _inputDecoration(
                        hintText: isTh ? 'ชื่ออาหาร' : 'Food Name',
                        errorText: _foodNameError,
                      ),
                      onChanged: (_) {
                        if (_foodNameError != null) {
                          setState(() => _foodNameError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    // Category Dropdown
                    DropdownButtonFormField<String>(
                      key: ValueKey('cat_$_selectedCategory'),
                      initialValue: _selectedCategory,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF181D17),
                        fontWeight: FontWeight.w400,
                      ),
                      hint: Text(
                        isTh ? 'หมวดหมู่' : 'Category',
                        style: const TextStyle(
                          color: Color(0xFF717971),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF414941)),
                      decoration: _inputDecoration(errorText: _categoryError),
                      items: _categories
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(
                                  _getCategoryDisplay(c, isTh),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF181D17),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCategory = val;
                          _categoryError = null;
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    // Quantity and Unit Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            controller: _quantityController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF181D17),
                              fontWeight: FontWeight.w400,
                            ),
                            decoration: _inputDecoration(
                              hintText: isTh ? 'จำนวน' : 'Quantity',
                              errorText: _quantityError,
                            ),
                            onChanged: (_) {
                              if (_quantityError != null) {
                                setState(() => _quantityError = null);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            key: ValueKey('unit_$_selectedUnit'),
                            initialValue: _selectedUnit,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF181D17),
                              fontWeight: FontWeight.w400,
                            ),
                            hint: Text(
                              isTh ? 'หน่วย' : 'Unit',
                              style: const TextStyle(
                                color: Color(0xFF717971),
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF414941)),
                            decoration: _inputDecoration(errorText: _unitError),
                            items: _units
                                .map((u) => DropdownMenuItem(
                                      value: u,
                                      child: Text(
                                        _getUnitDisplay(u, isTh),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Color(0xFF181D17),
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedUnit = val;
                                _unitError = null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Storage Location Dropdown
                    DropdownButtonFormField<String>(
                      key: ValueKey('storage_$_selectedStorage'),
                      initialValue: _selectedStorage,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF181D17),
                        fontWeight: FontWeight.w400,
                      ),
                      hint: Text(
                        isTh ? 'สถานที่จัดเก็บ' : 'Storage Location',
                        style: const TextStyle(
                          color: Color(0xFF717971),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF414941)),
                      decoration: _inputDecoration(errorText: _storageError),
                      items: _storages
                          .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(
                                  _getStorageDisplay(s, isTh),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF181D17),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          final oldStorage = _selectedStorage;
                          _selectedStorage = val;
                          _storageError = null;

                          // Auto-recalibrate expiry if it was estimated by AI and storage location changed
                          if (_isAiEstimatedExpiry &&
                              val != null &&
                              val != oldStorage &&
                              _foodNameController.text.trim().isNotEmpty) {
                            final recalculated = AiRepository.estimateShelfLife(
                              _foodNameController.text.trim(),
                              category: _selectedCategory,
                              storage: val,
                            );
                            _expirationDate = recalculated;
                            _expirationDateController.text = _formatDate(recalculated);
                            _expirationDateError = null;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isTh
                                      ? '✨ คำนวณอายุการเก็บรักษาใหม่สำหรับ ${_getStorageDisplay(val, isTh)} (${_formatDate(recalculated)})'
                                      : '✨ Recalculated shelf life for $val (${_formatDate(recalculated)})',
                                ),
                                backgroundColor: const Color(0xFF2D6A4F),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    // Expiration Date Field (Typeable & Date Picker)
                    TextFormField(
                      key: const Key('add_item_expiration_date'),
                      controller: _expirationDateController,
                      keyboardType: TextInputType.datetime,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                        DateInputFormatter(),
                      ],
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF181D17),
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: _inputDecoration(
                        hintText: isTh ? 'วันหมดอายุ (วว/ดด/ปปปป)' : 'Expiration Date (MM/DD/YYYY)',
                        errorText: _expirationDateError,
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.calendar_month_outlined,
                            size: 22,
                            color: Color(0xFF414941),
                          ),
                          tooltip: isTh ? 'เลือกวันที่' : 'Choose date',
                          onPressed: () async {
                            final initial = _expirationDate ??
                                _tryParseDate(_expirationDateController.text) ??
                                DateTime.now().add(const Duration(days: 7));
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: initial,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2035),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: Color(0xFF2E6A44),
                                      onPrimary: Colors.white,
                                      onSurface: Color(0xFF181D17),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setState(() {
                                _isAiEstimatedExpiry = false;
                                _expirationDate = picked;
                                _expirationDateController.text = _formatDate(picked);
                                _expirationDateError = null;
                              });
                            }
                          },
                        ),
                      ),
                      onChanged: (val) {
                        _isAiEstimatedExpiry = false;
                        final parsed = _tryParseDate(val);
                        if (parsed != null) {
                          setState(() {
                            _expirationDate = parsed;
                            _expirationDateError = null;
                          });
                        } else {
                          setState(() {
                            _expirationDate = null;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Text(
                        isTh
                            ? 'วันหมดอายุหรือควรบริโภคก่อน (วว/ดด/ปปปป)'
                            : 'Use-by or best-before date (MM/DD/YYYY)',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF414941)),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Save Button
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2E6A44),
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: _onSave,
                        child: Text(isTh ? 'บันทึก' : 'Save'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
