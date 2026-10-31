import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/item_model.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../fridge_detail/providers/fridge_detail_provider.dart';

/// Screen #13: Edit Item details
/// Displays food photo with floating camera button,
/// editable fields: Food Name, Category dropdown, Quantity & Unit row,
/// Storage Location dropdown, Expiration Date picker with calendar icon, and Save button.
class EditItemPage extends ConsumerStatefulWidget {
  final String fridgeId;
  final String itemId;

  const EditItemPage({
    super.key,
    required this.fridgeId,
    required this.itemId,
  });

  @override
  ConsumerState<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends ConsumerState<EditItemPage> {
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late String _category;
  late String _unit;
  late String _storage;
  late DateTime _expirationDate;
  String? _imagePath;
  bool _initialized = false;

  final _categories = ['Proteins', 'Veggies', 'Beverages', 'Meals', 'Sauces'];
  final _units = ['g', 'kg', 'pieces', 'bag', 'punnet', 'bottle', 'box', 'can', 'pack'];
  final _storages = ['Fridge', 'Freezer'];

  String _normalizeCategory(String cat) {
    for (final c in _categories) {
      if (c.toLowerCase() == cat.toLowerCase()) return c;
    }
    return 'Veggies';
  }

  String _normalizeUnit(String u) {
    if (u.contains('250 g') || u == 'g') return 'g';
    if (u.contains('kg')) return 'kg';
    if (u.contains('punnet')) return 'punnet';
    if (u.contains('bag')) return 'bag';
    if (u.contains('bottle')) return 'bottle';
    for (final unit in _units) {
      if (unit.toLowerCase() == u.toLowerCase()) return unit;
    }
    return 'pieces';
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final items = ref.read(fridgeItemsProvider(widget.fridgeId));
      ItemModel? foundItem;
      try {
        foundItem = items.firstWhere((it) => it.id == widget.itemId);
      } catch (_) {
        foundItem = null;
      }

      final item = foundItem ??
          ItemModel(
            id: widget.itemId,
            fridgeId: widget.fridgeId,
            name: 'Strawberries',
            category: 'veggies',
            zone: 'fridge',
            quantity: 250,
            unit: 'g',
            expiryDate: DateTime(2026, 10, 28),
            imagePath: 'assets/images/food_strawberries.png',
            updatedAt: DateTime.now(),
          );

      _nameController = TextEditingController(text: item.name);
      _quantityController = TextEditingController(
        text: item.quantity % 1 == 0
            ? item.quantity.toInt().toString()
            : item.quantity.toString(),
      );
      _category = _normalizeCategory(item.category);
      _unit = _normalizeUnit(item.unit);
      _storage = item.zone.toLowerCase() == 'freezer' ? 'Freezer' : 'Fridge';
      _expirationDate = item.expiryDate;
      _imagePath = item.imagePath;
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({String? hintText, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF717971),
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: const Color(0xFFF6FBF3),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF717971), width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2E6A44), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        backgroundColor: Color(0xFFF6FBF3),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6FBF3),
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  AppBackButton(),
                  SizedBox(width: 14),
                  Text(
                    'Edit Item details',
                    style: TextStyle(
                      fontSize: 22,
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
                    // Photo with floating camera button
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            height: 220,
                            width: double.infinity,
                            color: const Color(0xFFEAEFE8),
                            child: _imagePath != null && _imagePath!.isNotEmpty
                                ? Image.asset(
                                    _imagePath!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(Icons.fastfood, size: 64, color: Colors.grey),
                                    ),
                                  )
                                : const Center(
                                    child: Icon(Icons.fastfood, size: 64, color: Colors.grey),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.camera_alt_outlined,
                                color: Color(0xFF2E6A44),
                                size: 22,
                              ),
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                // Image picker simulation
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Food Name Field
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF181D17),
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: _inputDecoration(hintText: 'Food Name'),
                    ),
                    const SizedBox(height: 14),
                    // Category Dropdown
                    DropdownButtonFormField<String>(
                      key: ValueKey('cat_$_category'),
                      initialValue: _category,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF181D17),
                        fontWeight: FontWeight.w400,
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF414941)),
                      decoration: _inputDecoration(),
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
                        if (val != null) setState(() => _category = val);
                      },
                    ),
                    const SizedBox(height: 14),
                    // Quantity and Unit Row
                    Row(
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
                            decoration: _inputDecoration(hintText: 'Quantity'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            key: ValueKey('unit_$_unit'),
                            initialValue: _unit,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF181D17),
                              fontWeight: FontWeight.w400,
                            ),
                            icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF414941)),
                            decoration: _inputDecoration(),
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
                              if (val != null) setState(() => _unit = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Storage Location Dropdown
                    DropdownButtonFormField<String>(
                      key: ValueKey('storage_$_storage'),
                      initialValue: _storage,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF181D17),
                        fontWeight: FontWeight.w400,
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF414941)),
                      decoration: _inputDecoration(),
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
                        if (val != null) setState(() => _storage = val);
                      },
                    ),
                    const SizedBox(height: 14),
                    // Expiration Date Picker
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _expirationDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                        );
                        if (picked != null) {
                          setState(() => _expirationDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: _inputDecoration(
                          suffixIcon: const Icon(
                            Icons.calendar_today_outlined,
                            size: 20,
                            color: Color(0xFF414941),
                          ),
                        ),
                        child: Text(
                          _formatDate(_expirationDate),
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF181D17),
                            fontWeight: FontWeight.w400,
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
                        onPressed: () {
                          final parsedQty = double.tryParse(_quantityController.text) ?? 1.0;
                          final updated = ItemModel(
                            id: widget.itemId,
                            fridgeId: widget.fridgeId,
                            name: _nameController.text.trim().isEmpty
                                ? 'Item'
                                : _nameController.text.trim(),
                            category: _category.toLowerCase(),
                            zone: _storage.toLowerCase(),
                            quantity: parsedQty,
                            unit: _unit,
                            expiryDate: _expirationDate,
                            imagePath: _imagePath,
                            updatedAt: DateTime.now(),
                          );
                          ref.read(fridgeItemsProvider(widget.fridgeId).notifier).updateItem(updated);
                          Navigator.pop(context);
                        },
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
    );
  }
}
