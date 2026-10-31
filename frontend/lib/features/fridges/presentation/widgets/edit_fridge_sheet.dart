import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/fridge_model.dart';
import '../../providers/fridges_provider.dart';
import 'delete_fridge_dialog.dart';

/// Screen #7: Edit Fridge Bottom Sheet (Matching Image 2: media_1793353271111_f1213365.png 100% pixel-perfect)
class EditFridgeSheet extends ConsumerStatefulWidget {
  final FridgeModel fridge;

  const EditFridgeSheet({super.key, required this.fridge});

  @override
  ConsumerState<EditFridgeSheet> createState() => _EditFridgeSheetState();
}

class _EditFridgeSheetState extends ConsumerState<EditFridgeSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  String? _nameError;

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

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _nameError = 'Fridge name is required';
      });
      return;
    }

    final desc = _descController.text.trim();
    ref.read(fridgesProvider.notifier).updateFridge(
          widget.fridge.id,
          name,
          desc,
        );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fridge "$name" updated successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const sheetBg = Color(0xFFEAEFE8);
    const borderColor = Color(0xFF717971);
    const primaryGreen = Color(0xFF2E6A44);
    const deleteRed = Color(0xFFBA1A1A);
    const textDark = Color(0xFF181D18);
    const textMuted = Color(0xFF414942);

    return Container(
      decoration: const BoxDecoration(
        color: sheetBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: "Edit Fridge" Title + "X" Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Edit Fridge',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                    letterSpacing: -0.3,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 24, color: textMuted),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Update your fridge details.',
              style: TextStyle(
                fontSize: 14.5,
                color: textMuted,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 20),

            // Field 1: Fridge Name
            const Text(
              'Fridge Name',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _nameError != null ? deleteRed : borderColor.withValues(alpha: 0.7),
                  width: _nameError != null ? 1.5 : 1.0,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: TextField(
                controller: _nameController,
                maxLength: 100,
                style: const TextStyle(
                  fontSize: 15,
                  color: textDark,
                  fontWeight: FontWeight.w400,
                ),
                onChanged: (_) {
                  if (_nameError != null) {
                    setState(() {
                      _nameError = null;
                    });
                  }
                },
                decoration: InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  fillColor: Colors.transparent,
                  hintText: 'Fridge Name',
                  hintStyle: TextStyle(
                    fontSize: 15,
                    color: textMuted.withValues(alpha: 0.8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            if (_nameError != null) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  _nameError!,
                  style: const TextStyle(fontSize: 12, color: deleteRed),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Field 2: Description
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 110,
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: borderColor.withValues(alpha: 0.7),
                  width: 1.0,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: TextField(
                controller: _descController,
                maxLength: 500,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(
                  fontSize: 15,
                  color: textDark,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  fillColor: Colors.transparent,
                  isDense: true,
                  hintText: 'Add a description (optional)',
                  hintStyle: TextStyle(
                    fontSize: 15,
                    color: textMuted.withValues(alpha: 0.8),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Save Button (Green Stadium)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
                onPressed: _save,
                child: const Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Thin Divider Line
            Container(
              height: 1,
              color: borderColor.withValues(alpha: 0.35),
            ),

            const SizedBox(height: 14),

            // Delete Fridge Button (Red Stadium with trash icon)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
                label: const Text(
                  'Delete Fridge',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: deleteRed,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    useRootNavigator: true,
                    builder: (_) => DeleteFridgeDialog(
                      fridgeId: widget.fridge.id,
                      fridgeName: widget.fridge.name,
                    ),
                  );

                  if (confirmed == true && context.mounted) {
                    Navigator.of(context).pop('deleted');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
