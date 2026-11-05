import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Screen #14 & #15: "Mark as Consumed" Bottom Sheet.
/// Allows selecting consumed quantity with interactive stepper [-] N [+] or finishing all,
/// with shortcut to trigger Gemini AI recipe recommendations.
class MarkConsumedSheet extends StatefulWidget {
  final String itemName;
  final double availablePieces;
  final String unit;
  final String? category;
  final void Function(double amount, bool finishedAll) onConsumed;
  final VoidCallback? onRecommendRecipe;
  final bool hideGeminiShortcut;

  const MarkConsumedSheet({
    super.key,
    required this.itemName,
    required this.availablePieces,
    required this.unit,
    this.category,
    required this.onConsumed,
    this.onRecommendRecipe,
    this.hideGeminiShortcut = false,
  });

  @override
  State<MarkConsumedSheet> createState() => _MarkConsumedSheetState();
}

class _MarkConsumedSheetState extends State<MarkConsumedSheet> {
  late double _consumeAmount;

  @override
  void initState() {
    super.initState();
    _consumeAmount = widget.availablePieces <= 1 ? widget.availablePieces : 1.0;
  }

  void _onGeminiRecipe() {
    if (widget.onRecommendRecipe != null) {
      widget.onRecommendRecipe!();
    } else {
      Navigator.of(context).pop();
      final catParam = widget.category != null ? '&category=${Uri.encodeComponent(widget.category!)}' : '';
      context.push('/recipes?ingredient=${Uri.encodeComponent(widget.itemName)}$catParam');
    }
  }

  String _getLocalizedUnit(String unit, bool isTh) {
    if (!isTh) return unit;
    final u = unit.toLowerCase();
    if (u.contains('bottle')) return 'ขวด';
    if (u.contains('piece') || u == 'pc' || u == 'pcs') return 'ชิ้น';
    if (u.contains('bag')) return 'ถุง';
    if (u.contains('box')) return 'กล่อง';
    if (u.contains('can')) return 'กระป๋อง';
    if (u.contains('pack') || u.contains('pkt')) return 'แพ็ค';
    if (u.contains('punnet')) return 'ตะกร้า';
    if (u.contains('portion')) return 'ส่วน';
    if (u == 'g' || u.contains('gram')) return 'g';
    if (u == 'kg' || u.contains('kilo')) return 'kg';
    return unit;
  }

  @override
  Widget build(BuildContext context) {
    final isTh = Localizations.localeOf(context).languageCode == 'th';
    final canDecrement = _consumeAmount > 1;
    final canIncrement = _consumeAmount < widget.availablePieces;
    final localizedUnit = _getLocalizedUnit(widget.unit, isTh);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                isTh ? 'บริโภคไปปริมาณเท่าไหร่?' : 'How much did you consume?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              // Subtitle
              Text(
                isTh
                    ? '${widget.itemName} · ${widget.availablePieces.toInt()} $localizedUnit ในตู้เย็น'
                    : '${widget.itemName} · ${widget.availablePieces.toInt()} ${widget.unit} in fridge',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              // Stepper section
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Minus Button
                  InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: canDecrement
                        ? () => setState(() => _consumeAmount -= 1)
                        : null,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: canDecrement
                              ? theme.colorScheme.outline
                              : theme.colorScheme.outlineVariant,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.remove,
                        size: 20,
                        color: canDecrement
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  // Center Quantity Display
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        Text(
                          '${_consumeAmount.toInt()}',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          isTh
                              ? 'จากทั้งหมด ${widget.availablePieces.toInt()} $localizedUnit'
                              : 'of ${widget.availablePieces.toInt()} ${widget.unit}',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Plus Button
                  InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: canIncrement
                        ? () => setState(() => _consumeAmount += 1)
                        : null,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: canIncrement
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHigh,
                      ),
                      child: Icon(
                        Icons.add,
                        size: 22,
                        color: canIncrement
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ],
              ),
              if (!widget.hideGeminiShortcut) ...[
                const SizedBox(height: 24),
                // Gemini AI Recipe Recommendation Button (Floating pill button with shadow)
                InkWell(
                  borderRadius: BorderRadius.circular(28),
                  onTap: _onGeminiRecipe,
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: theme.colorScheme.outline,
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.16),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
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
                        Text(
                          isTh
                              ? 'ขอไอเดียเมนูอาหารจาก Gemini AI'
                              : 'Ask Gemini AI for recipe ideas',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              // Confirm Button
              SizedBox(
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () => widget.onConsumed(_consumeAmount, false),
                  child: Text(isTh ? 'ยืนยัน' : 'Confirm'),
                ),
              ),
              const SizedBox(height: 12),
              // Finished all Button
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceContainer,
                    side: BorderSide(color: theme.colorScheme.outline, width: 1.0),
                    foregroundColor: theme.colorScheme.onSurface,
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => widget.onConsumed(widget.availablePieces, true),
                  child: Text(isTh ? 'บริโภคหมดแล้ว' : 'Finished all'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
