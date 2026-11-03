import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../providers/fridges_provider.dart';

// TODO(screen #6 Add New Fridge): ช่อง Fridge Name, Description, ปุ่ม Create Fridge
class AddFridgePage extends StatefulWidget {
  const AddFridgePage({super.key});

  @override
  State<AddFridgePage> createState() => _AddFridgePageState();
}

class _AddFridgePageState extends State<AddFridgePage> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Fridge', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _nameController,
                labelText: 'Fridge Name',
                hintText: 'e.g. Kitchen fridge, Studio fridge',
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _descController,
                labelText: 'Description (optional)',
                hintText: 'e.g. 1st floor, shared household',
              ),
              const Spacer(),
              Consumer(
                builder: (context, ref, _) {
                  return PrimaryButton(
                    label: 'Create Fridge',
                    onPressed: () {
                      if (_nameController.text.trim().isNotEmpty) {
                        ref.read(fridgesProvider.notifier).addFridge(
                              _nameController.text.trim(),
                              _descController.text.trim(),
                            );
                        context.pop();
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
