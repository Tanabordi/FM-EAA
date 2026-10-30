import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';

// TODO(screen #11 Add Items): การ์ด "Scan Label with AI" (ไอคอนกล้อง "Capture the label. We'll fill in the details."), ปุ่มวิเคราะห์ด้วย Gemini ("ให้ Gemini AI Vision Engine วิเคราะห์"), ฟอร์ม: Food Name, Category (dropdown), Quantity + Unit (dropdown), Storage Location (Fridge/Freezer), Expiration Date (date picker, "Use-by or best-before date"), ปุ่ม Save
class AddItemPage extends StatefulWidget {
  final String fridgeId;

  const AddItemPage({super.key, required this.fridgeId});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _foodNameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  String _selectedCategory = 'Proteins';
  String _selectedUnit = 'pieces';
  String _selectedStorage = 'Fridge';
  DateTime _expirationDate = DateTime.now().add(const Duration(days: 7));

  final _categories = ['Proteins', 'Veggies', 'Beverages', 'Meals', 'Sauces'];
  final _units = ['pieces', 'bag', 'punnet', 'bottle', 'box', 'can', 'pack', 'g', 'kg'];
  final _storages = ['Fridge', 'Freezer'];

  @override
  void dispose() {
    _foodNameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Items', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: const AppBackButton(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // AI Label Scan Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                          child: Icon(Icons.camera_alt, color: theme.colorScheme.primary),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Scan Label with AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              SizedBox(height: 2),
                              Text("Capture the label. We'll fill in the details.", style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        shape: const StadiumBorder(),
                        minimumSize: const Size.fromHeight(44),
                      ),
                      icon: const Icon(Icons.auto_awesome, size: 18),
                      label: const Text('ให้ Gemini AI Vision Engine วิเคราะห์'),
                      onPressed: () {
                        // TODO(gemini scan): Pick image and call Gemini Vision API to auto-fill form
                        setState(() {
                          _foodNameController.text = 'Avocado (AI Detected)';
                          _selectedCategory = 'Veggies';
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _foodNameController,
                labelText: 'Food Name',
                hintText: 'e.g. Milk, Salmon, Eggs',
              ),
              const SizedBox(height: 16),
              // Category Dropdown
              const Text('Category', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
                decoration: const InputDecoration(),
              ),
              const SizedBox(height: 16),
              // Quantity & Unit
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: AppTextField(
                      controller: _quantityController,
                      labelText: 'Quantity',
                      hintText: '1',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Unit', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedUnit,
                          items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                          onChanged: (val) => setState(() => _selectedUnit = val!),
                          decoration: const InputDecoration(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Storage Location
              const Text('Storage Location', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedStorage,
                items: _storages.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _selectedStorage = val!),
                decoration: const InputDecoration(),
              ),
              const SizedBox(height: 16),
              // Expiration Date Picker
              const Text('Expiration Date', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 6),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _expirationDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => _expirationDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_expirationDate.day}/${_expirationDate.month}/${_expirationDate.year}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Save',
                onPressed: () {
                  // TODO(item add): Add item to Drift and sync
                  context.pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
