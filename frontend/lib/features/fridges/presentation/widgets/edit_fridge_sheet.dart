import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/fridge_model.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../providers/fridges_provider.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import 'delete_fridge_dialog.dart';

/// Screen #7: Edit Fridge Bottom Sheet
/// Features:
/// - Original full 4-sided container border frame matching Figma
/// - Close button (X) and back gesture show Discard changes confirmation dialog
/// - Fridge Name: Required, 1–15 characters
/// - Description: Optional, 0–100 characters
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
  String? _descError;
  bool _forceExit = false;

  bool get _isTh {
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

  bool get _hasUnsavedChanges {
    if (_forceExit) return false;
    return _nameController.text.trim() != widget.fridge.name.trim() ||
        _descController.text.trim() != widget.fridge.description.trim();
  }

  void _handleClose() {
    final isTh = _isThRead();
    if (_hasUnsavedChanges) {
      showDialog(
        context: context,
        builder: (dialogContext) => ConfirmDialog(
          title: isTh ? 'ละทิ้งการเปลี่ยนแปลง?' : 'Discard changes?',
          message: isTh
              ? 'คุณมีข้อมูลที่ยังไม่ได้บันทึก คุณแน่ใจหรือไม่ว่าต้องการละทิ้ง?'
              : 'You have unsaved changes. Are you sure you want to discard them?',
          confirmLabel: isTh ? 'ละทิ้ง' : 'Discard',
          cancelLabel: isTh ? 'แก้ไขต่อ' : 'Keep editing',
          isDestructive: true,
          onConfirm: () {
            setState(() => _forceExit = true);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              Navigator.pop(context);
            });
          },
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _save() {
    final isTh = _isThRead();
    setState(() {
      _nameError = null;
      _descError = null;
    });

    final name = _nameController.text.trim();
    final desc = _descController.text.trim();
    bool hasError = false;

    if (name.isEmpty) {
      setState(() {
        _nameError = isTh ? 'กรุณากรอกชื่อตู้เย็น' : 'Fridge name is required';
      });
      hasError = true;
    } else if (name.length > 15) {
      setState(() {
        _nameError = isTh ? 'ชื่อตู้เย็นต้องไม่เกิน 15 ตัวอักษร' : 'Fridge name must not exceed 15 characters';
      });
      hasError = true;
    }

    if (desc.length > 100) {
      setState(() {
        _descError = isTh ? 'คำอธิบายต้องไม่เกิน 100 ตัวอักษร' : 'Description must not exceed 100 characters';
      });
      hasError = true;
    }

    if (hasError) return;

    ref.read(fridgesProvider.notifier).updateFridge(
          widget.fridge.id,
          name,
          desc,
        );

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _forceExit = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pop(context);
    });
    messenger.showSnackBar(
      SnackBar(
        content: Text(isTh ? 'อัปเดตตู้เย็น "$name" เรียบร้อยแล้ว' : 'Fridge "$name" updated successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    const sheetBg = Color(0xFFF6FBF3);
    const borderColor = Color(0xFF717971);
    const primaryGreen = Color(0xFF2E6A44);
    const deleteRed = Color(0xFFBA1A1A);
    const textDark = Color(0xFF181D18);
    const textMuted = Color(0xFF414942);
    final isTh = _isTh;

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleClose();
      },
      child: Container(
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
                  Text(
                    isTh ? 'แก้ไขข้อมูลตู้เย็น' : 'Edit Fridge',
                    style: const TextStyle(
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
                    tooltip: isTh ? 'ปิด' : 'Close',
                    onPressed: _handleClose,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                isTh ? 'อัปเดตรายละเอียดตู้เย็นของคุณ' : 'Update your fridge details.',
                style: const TextStyle(
                  fontSize: 14.5,
                  color: textMuted,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 20),

              // Field 1: Fridge Name (Required 1–15 chars)
              AppTextField(
                controller: _nameController,
                labelText: isTh ? 'ชื่อตู้เย็น' : 'Fridge Name',
                hintText: '',
                helperText: isTh ? '1–15 ตัวอักษร' : '1–15 characters',
                errorText: _nameError,
                textInputAction: TextInputAction.next,
                onChanged: (val) {
                  if (val.trim().length > 15) {
                    setState(() {
                      _nameError = isTh ? 'ชื่อตู้เย็นต้องไม่เกิน 15 ตัวอักษร' : 'Fridge name must not exceed 15 characters';
                    });
                  } else if (_nameError != null && val.trim().isNotEmpty) {
                    setState(() {
                      _nameError = null;
                    });
                  }
                },
              ),

              const SizedBox(height: 20),

              // Field 2: Description (Optional 0–100 chars)
              AppTextField(
                controller: _descController,
                labelText: isTh ? 'คำอธิบาย' : 'Description',
                hintText: '',
                helperText: isTh ? '0–100 ตัวอักษร (ไม่บังคับ)' : '0–100 characters (optional)',
                errorText: _descError,
                maxLines: 5,
                minLines: 4,
                onChanged: (val) {
                  if (val.trim().length > 100) {
                    setState(() {
                      _descError = isTh ? 'คำอธิบายต้องไม่เกิน 100 ตัวอักษร' : 'Description must not exceed 100 characters';
                    });
                  } else if (_descError != null) {
                    setState(() {
                      _descError = null;
                    });
                  }
                },
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
                  child: Text(
                    isTh ? 'บันทึก' : 'Save',
                    style: const TextStyle(
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
                  label: Text(
                    isTh ? 'ลบตู้เย็น' : 'Delete Fridge',
                    style: const TextStyle(
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
      ),
    );
  }
}
