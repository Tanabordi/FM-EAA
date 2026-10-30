import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';

// TODO(screen #13 Edit Item details): รูป + ปุ่มกล้องเปลี่ยนรูป, ชื่อ, Category, จำนวน + หน่วย, Storage (Fridge/Freezer), Expiration date, ปุ่ม Save
class EditItemPage extends StatefulWidget {
  final String fridgeId;
  final String itemId;

  const EditItemPage({super.key, required this.fridgeId, required this.itemId});

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  final _nameController = TextEditingController(text: 'Avocados');
  final _quantityController = TextEditingController(text: '1');
  String _category = 'Veggies';
  String _unit = 'punnet';
  String _storage = 'Fridge';

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FBF3),
      body: SafeArea(
        child: Column(
          children: [
            const AppTopBar(title: 'Edit Item'),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photo with change camera icon
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.fastfood, size: 50, color: Colors.grey),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AppTextField(
                controller: _nameController,
                labelText: 'Food Name',
                hintText: 'Enter name',
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _quantityController,
                labelText: 'Quantity',
                hintText: '1',
              ),
              const SizedBox(height: 16),
              const Text('Category', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _category,
                items: ['Proteins', 'Veggies', 'Beverages', 'Meals', 'Sauces']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setState(() => _category = val!),
              ),
              const SizedBox(height: 16),
              const Text('Unit', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _unit,
                items: ['pieces', 'bag', 'punnet', 'bottle']
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (val) => setState(() => _unit = val!),
              ),
              const SizedBox(height: 16),
              const Text('Storage Location', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _storage,
                items: ['Fridge', 'Freezer']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => setState(() => _storage = val!),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Save',
                onPressed: () {
                  // TODO(item edit): Save item changes
                  Navigator.pop(context);
                },
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
