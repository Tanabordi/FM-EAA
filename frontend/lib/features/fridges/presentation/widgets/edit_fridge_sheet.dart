import 'package:flutter/material.dart';
import '../../../../core/theme/freshness_colors.dart';
import '../../../../data/models/fridge_model.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import 'delete_fridge_dialog.dart';

// TODO(screen #7 Edit Fridge): "Edit Fridge", ช่อง Fridge Name, Description (optional), ปุ่ม Save, ปุ่ม Delete Fridge (แดง)
class EditFridgeSheet extends StatefulWidget {
  final FridgeModel fridge;

  const EditFridgeSheet({super.key, required this.fridge});

  @override
  State<EditFridgeSheet> createState() => _EditFridgeSheetState();
}

class _EditFridgeSheetState extends State<EditFridgeSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.fridge.name);
    _descController = TextEditingController(text: widget.fridge.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Edit Fridge', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _nameController,
            labelText: 'Fridge Name',
            hintText: 'Enter fridge name',
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _descController,
            labelText: 'Description (optional)',
            hintText: 'Enter description',
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Save',
            onPressed: () {
              // TODO(fridge update): Update fridge name & description
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 12),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: FreshnessColors.danger),
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (_) => DeleteFridgeDialog(fridgeId: widget.fridge.id),
              );
            },
            child: const Text('Delete Fridge', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

