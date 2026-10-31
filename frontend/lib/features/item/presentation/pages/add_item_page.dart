import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../data/models/item_model.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../fridge_detail/providers/fridge_detail_provider.dart';

/// Screen #11: Add items
/// AI Label Scan Card with Gemini button, form fields: Food Name, Category dropdown,
/// Quantity & Unit row, Storage Location dropdown, Expiration Date picker, and Save button.
class AddItemPage extends ConsumerStatefulWidget {
  final String fridgeId;

  const AddItemPage({super.key, required this.fridgeId});

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

  final _categories = ['Proteins', 'Veggies', 'Beverages', 'Meals', 'Sauces'];
  final _units = ['pieces', 'bag', 'punnet', 'bottle', 'box', 'can', 'pack', 'g', 'kg'];
  final _storages = ['Fridge', 'Freezer'];

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

  void _onScanWithGemini() {
    setState(() {
      _foodNameController.text = 'Avocados';
      _selectedCategory = 'Veggies';
      _quantityController.text = '2';
      _selectedUnit = 'pieces';
      _selectedStorage = 'Fridge';
      _expirationDate = DateTime.now().add(const Duration(days: 5));
      _imagePath = 'assets/images/food_avocados.png';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gemini Vision Engine: Avocados detected!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    // AI Label Scan Card
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAEFE8),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Column(
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
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Gemini AI Vision Engine Button (Separate floating button with shadow)
                    InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: _onScanWithGemini,
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAEFE8),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: const Color(0xFF717971),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.22),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
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
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'ให้ Gemini AI Vision Engine วิเคราะห์',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF181D17),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Food Name Field
                    TextFormField(
                      controller: _foodNameController,
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
                      onChanged: (val) => setState(() => _selectedCategory = val),
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
                            onChanged: (val) => setState(() => _selectedUnit = val),
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
                      onChanged: (val) => setState(() => _selectedStorage = val),
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
                          setState(() => _expirationDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: _inputDecoration(
                          suffixIcon: const Icon(
                            Icons.calendar_month_outlined,
                            size: 20,
                            color: Color(0xFF414941),
                          ),
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
                        onPressed: () {
                          final parsedQty = double.tryParse(_quantityController.text) ?? 1.0;
                          final newItem = ItemModel(
                            id: 'item_${DateTime.now().millisecondsSinceEpoch}',
                            fridgeId: widget.fridgeId,
                            name: _foodNameController.text.trim().isEmpty
                                ? 'Food Item'
                                : _foodNameController.text.trim(),
                            category: (_selectedCategory ?? 'Veggies').toLowerCase(),
                            zone: (_selectedStorage ?? 'Fridge').toLowerCase(),
                            quantity: parsedQty,
                            unit: _selectedUnit ?? 'pieces',
                            expiryDate: _expirationDate ?? DateTime.now().add(const Duration(days: 7)),
                            imagePath: _imagePath ?? 'assets/images/food_avocados.png',
                            updatedAt: DateTime.now(),
                          );
                          ref.read(fridgeItemsProvider(widget.fridgeId).notifier).addItem(newItem);
                          context.pop();
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
