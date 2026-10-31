import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/fridges_provider.dart';

/// Screen #6: Add New Fridge (Matching Image 1: media_1793353246698_627203a3.png 100% pixel-perfect)
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

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _nameFocusNode.dispose();
    _descFocusNode.dispose();
    super.dispose();
  }

  void _createFridge() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _nameError = 'Please enter a fridge name';
      });
      return;
    }

    final desc = _descController.text.trim();
    ref.read(fridgesProvider.notifier).addFridge(name, desc);

    final messenger = ScaffoldMessenger.of(context);
    context.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text('Fridge "$name" created successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF6FBF3);
    const borderColor = Color(0xFF717971);
    const primaryGreen = Color(0xFF2E6A44);
    const textDark = Color(0xFF181D18);
    const textMuted = Color(0xFF414942);
    const errorRed = Color(0xFFBA1A1A);

    return Scaffold(
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
                          InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => context.pop(),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: borderColor.withValues(alpha: 0.6),
                                  width: 1.0,
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                size: 20,
                                color: textDark,
                              ),
                            ),
                          ),
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

                      // Field 1: Fridge Name (Corner radius 4, height 48, matching media_1793355338844_cada3e94.png)
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
                          maxLength: 100,
                          style: const TextStyle(
                            fontSize: 15,
                            color: textDark,
                            fontWeight: FontWeight.w400,
                          ),
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => _descFocusNode.requestFocus(),
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

                      // Field 2: Description (Corner radius 4, height 178, matching media_1793355338844_cada3e94.png)
                      Container(
                        height: 178,
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: borderColor.withValues(alpha: 0.7),
                            width: 1.0,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          controller: _descController,
                          focusNode: _descFocusNode,
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
    );
  }
}
