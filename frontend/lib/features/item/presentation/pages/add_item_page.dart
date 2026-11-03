import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../data/models/item_model.dart';
import '../../../../data/repositories/ai_repository.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
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
  String? _selectedCategory;
  String? _selectedUnit;
  String? _selectedStorage;
  DateTime? _expirationDate;
  String? _imagePath;
  Uint8List? _imageBytes;
  bool _hasAnalyzed = false;
  bool _isScanning = false;
  bool _forceExit = false;

  String? _foodNameError;
  String? _categoryError;
  String? _quantityError;
  String? _unitError;
  String? _storageError;
  String? _expirationDateError;

  final _categories = ['Proteins', 'Veggies', 'Beverages', 'Meals', 'Sauces'];
  final _units = ['pieces', 'bag', 'punnet', 'bottle', 'box', 'can', 'pack', 'g', 'kg'];
  final _storages = ['Fridge', 'Freezer'];

  bool get _hasUnsavedChanges {
    if (_forceExit) return false;
    return _foodNameController.text.trim().isNotEmpty ||
        _quantityController.text.trim().isNotEmpty ||
        _selectedCategory != null ||
        _selectedUnit != null ||
        _selectedStorage != null ||
        _expirationDate != null ||
        _imagePath != null ||
        _imageBytes != null;
  }

  void _handleBack() {
    if (_hasUnsavedChanges) {
      showDialog(
        context: context,
        builder: (dialogContext) => ConfirmDialog(
          title: 'Discard changes?',
          message: 'You have unsaved changes. Are you sure you want to discard them?',
          confirmLabel: 'Discard',
          cancelLabel: 'Keep editing',
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
    if (result.foodName != null && result.foodName!.trim().isNotEmpty) {
      _foodNameController.text = result.foodName!;
      _foodNameError = null;
    }
    if (result.imagePath != null && result.imagePath!.isNotEmpty) {
      _imagePath = result.imagePath;
      try {
        final f = File(result.imagePath!);
        if (f.existsSync()) {
          _imageBytes = f.readAsBytesSync();
        }
      } catch (_) {}
    }
    _selectedCategory = result.category;
    _categoryError = null;
    if (_quantityController.text.trim().isEmpty) {
      _quantityController.text = '2';
      _quantityError = null;
    }
    _selectedUnit = result.unit;
    _unitError = null;
    _selectedStorage = result.storage;
    _storageError = null;
    if (result.expiryDate != null) {
      _expirationDate = result.expiryDate;
      _expirationDateError = null;
    }
    _hasAnalyzed = true;
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
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
      _selectedCategory = null;
      _selectedUnit = null;
      _selectedStorage = null;
      _expirationDate = null;
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

  void _onSave() {
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
      nameErr = 'Please enter a food name before saving';
    }
    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      catErr = 'Please select a category';
    }
    if (qtyText.isEmpty || parsedQty == null || parsedQty <= 0) {
      qtyErr = 'Please enter a valid quantity';
    }
    if (_selectedUnit == null || _selectedUnit!.isEmpty) {
      unitErr = 'Please select a unit';
    }
    if (_selectedStorage == null || _selectedStorage!.isEmpty) {
      storageErr = 'Please select a storage location';
    }
    if (_expirationDate == null) {
      dateErr = 'Please select an expiration date';
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

    ref.read(fridgeItemsProvider(widget.fridgeId).notifier).addItem(newItem);
    final currentItems = ref.read(fridgeItemsProvider(widget.fridgeId));
    ref.read(fridgesProvider.notifier).updateItemCount(widget.fridgeId, currentItems.length);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "${newItem.name}" successfully'),
        duration: const Duration(seconds: 2),
      ),
    );

    if (context.mounted) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        try {
          context.pop();
        } catch (_) {}
      }
    }
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

  Widget _buildScanCardContent() {
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
          const Text(
            'Analyzing label with Gemini AI Vision...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF181D17),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Extracting product name and expiration date',
            style: TextStyle(
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
      return Column(
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
                      : (_imagePath!.startsWith('assets/')
                          ? Image.asset(
                              _imagePath!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(Icons.fastfood, size: 48, color: Colors.grey),
                              ),
                            )
                          : Image.file(
                              File(_imagePath!),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(Icons.fastfood, size: 48, color: Colors.grey),
                              ),
                            )),
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
                        _hasAnalyzed ? 'Label Scanned with AI' : 'Photo Selected',
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
                  onTap: _clearAllData,
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
                ? 'Detected: ${_foodNameController.text}'
                : 'Photo Loaded',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF181D17),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _hasAnalyzed
                ? 'Tap card to retake or change photo'
                : 'Tap card to change photo, or tap ✕ to remove',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF414941),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    // Default Card (Matching media_1793560538466_0ad00275.png exact design)
    return const Column(
      children: [
        Icon(
          Icons.camera_alt_outlined,
          size: 32,
          color: Color(0xFF181D17),
        ),
        SizedBox(height: 10),
        Text(
          'Scan Label with AI',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF181D17),
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Capture the label. We'll fill in the details.",
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF414941),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    const Text(
                      'Add items',
                      style: TextStyle(
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
                    // AI Label Scan Card matching media_1793560538466_0ad00275.png
                    Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: _isScanning ? null : _openScanLabelScanner,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
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
                          child: _buildScanCardContent(),
                        ),
                      ),
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
                        hintText: 'Food Name',
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
                      hint: const Text(
                        'Category',
                        style: TextStyle(
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
                                  c,
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
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF181D17),
                              fontWeight: FontWeight.w400,
                            ),
                            decoration: _inputDecoration(
                              hintText: 'Quantity',
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
                            hint: const Text(
                              'Unit',
                              style: TextStyle(
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
                                        u,
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
                      hint: const Text(
                        'Storage Location',
                        style: TextStyle(
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
                                  s,
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
                          _selectedStorage = val;
                          _storageError = null;
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    // Expiration Date Picker
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _expirationDate ?? DateTime.now().add(const Duration(days: 7)),
                          firstDate: DateTime.now().subtract(const Duration(days: 30)),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                        );
                        if (picked != null) {
                          setState(() {
                            _expirationDate = picked;
                            _expirationDateError = null;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: _inputDecoration(
                          suffixIcon: const Icon(
                            Icons.calendar_month_outlined,
                            size: 20,
                            color: Color(0xFF414941),
                          ),
                          errorText: _expirationDateError,
                        ),
                        child: Text(
                          _expirationDate != null
                              ? _formatDate(_expirationDate!)
                              : 'Expiration Date',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: _expirationDate != null
                                ? const Color(0xFF181D17)
                                : const Color(0xFF717971),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Padding(
                      padding: EdgeInsets.only(left: 12.0),
                      child: Text(
                        'Use-by or best-before date',
                        style: TextStyle(fontSize: 12, color: Color(0xFF414941)),
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
                        child: const Text('Save'),
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
