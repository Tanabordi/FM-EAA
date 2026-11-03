import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/fridges_provider.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/confirm_dialog.dart';

/// Screen #6: Add New Fridge
/// Features:
/// - Original full 4-sided container border frame matching Figma
/// - Inline error validation underneath field
/// - Fridge Name: Required, 1–15 characters
/// - Description: Optional, 0–100 characters
/// - Discard changes confirmation dialog on back when unsaved edits exist
class AddFridgePage extends ConsumerStatefulWidget {
  const AddFridgePage({super.key});

  @override
  ConsumerState<AddFridgePage> createState() => _AddFridgePageState();
}

class _AddFridgePageState extends ConsumerState<AddFridgePage> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _descFocusNode = FocusNode();
  String? _nameError;
  String? _descError;
  bool _forceExit = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _nameFocusNode.dispose();
    _descFocusNode.dispose();
    super.dispose();
  }

  bool get _hasUnsavedChanges {
    if (_forceExit) return false;
    return _nameController.text.trim().isNotEmpty || _descController.text.trim().isNotEmpty;
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
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/fridges');
              }
            });
          },
        ),
      );
    } else {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/fridges');
      }
    }
  }

  void _createFridge() async {
    setState(() {
      _nameError = null;
      _descError = null;
    });

    final name = _nameController.text.trim();
    final desc = _descController.text.trim();
    bool hasError = false;

    if (name.isEmpty) {
      setState(() => _nameError = 'Fridge name is required');
      hasError = true;
    } else if (name.length > 15) {
      setState(() => _nameError = 'Fridge name must not exceed 15 characters');
      hasError = true;
    }

    if (desc.length > 100) {
      setState(() => _descError = 'Description must not exceed 100 characters');
      hasError = true;
    }

    if (hasError) return;

    final messenger = ScaffoldMessenger.of(context);

    try {
      await ref.read(fridgesProvider.notifier).addFridge(name, desc);
      if (!mounted) return;
      setState(() => _forceExit = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/fridges');
        }
      });
      messenger.showSnackBar(
        SnackBar(
          content: Text('Fridge "$name" created successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to create fridge: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF6FBF3);
    const borderColor = Color(0xFF717971);
    const primaryGreen = Color(0xFF2E6A44);
    const textDark = Color(0xFF181D18);
    const textMuted = Color(0xFF414942);
    const errorRed = Color(0xFFBA1A1A);

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        // Top Header: Back Button box + "Add New Fridge" Title
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AppBackButton(onPressed: _handleBack),
                            const SizedBox(width: 14),
                            const Text(
                              'Add New Fridge',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: textDark,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Field 1: Fridge Name (Original corner radius 4 frame)
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: _nameError != null
                                  ? errorRed
                                  : borderColor.withValues(alpha: 0.7),
                              width: _nameError != null ? 1.5 : 1.0,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerLeft,
                          child: TextField(
                            controller: _nameController,
                            focusNode: _nameFocusNode,
                            style: const TextStyle(
                              fontSize: 15,
                              color: textDark,
                              fontWeight: FontWeight.w400,
                            ),
                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) => _descFocusNode.requestFocus(),
                            onChanged: (val) {
                              if (val.trim().length > 15) {
                                setState(() {
                                  _nameError = 'Fridge name must not exceed 15 characters';
                                });
                              } else if (_nameError != null && val.trim().isNotEmpty) {
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
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              filled: false,
                              fillColor: Colors.transparent,
                              isDense: true,
                              hintText: 'Fridge Name',
                              hintStyle: TextStyle(
                                fontSize: 15,
                                color: textMuted.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w400,
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_nameError != null) ...[
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              _nameError!,
                              style: const TextStyle(fontSize: 12, color: errorRed),
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Field 2: Description (Original corner radius 4 frame, height 178)
                        Container(
                          height: 178,
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: _descError != null
                                  ? errorRed
                                  : borderColor.withValues(alpha: 0.7),
                              width: _descError != null ? 1.5 : 1.0,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: TextField(
                            controller: _descController,
                            focusNode: _descFocusNode,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            style: const TextStyle(
                              fontSize: 15,
                              color: textDark,
                              fontWeight: FontWeight.w400,
                            ),
                            onChanged: (val) {
                              if (val.trim().length > 100) {
                                setState(() {
                                  _descError = 'Description must not exceed 100 characters';
                                });
                              } else if (_descError != null) {
                                setState(() {
                                  _descError = null;
                                });
                              }
                            },
                            decoration: InputDecoration(
                              counterText: '',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              filled: false,
                              fillColor: Colors.transparent,
                              isDense: true,
                              hintText: 'Description',
                              hintStyle: TextStyle(
                                fontSize: 15,
                                color: textMuted.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w400,
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_descError != null) ...[
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              _descError!,
                              style: const TextStyle(fontSize: 12, color: errorRed),
                            ),
                          ),
                        ],

                        const SizedBox(height: 32),

                        // Button: Create Fridge
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              foregroundColor: Colors.white,
                              shape: const StadiumBorder(),
                              elevation: 0,
                            ),
                            onPressed: _createFridge,
                            child: const Text(
                              'Create Fridge',
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const Spacer(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
