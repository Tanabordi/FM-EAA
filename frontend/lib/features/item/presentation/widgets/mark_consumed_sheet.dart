import 'package:flutter/material.dart';

/// Screen #14 & #15: "Mark as Consumed" Bottom Sheet.
/// Allows selecting consumed quantity with interactive stepper [-] N [+] or finishing all.
class MarkConsumedSheet extends StatefulWidget {
  final String itemName;
  final double availablePieces;
  final String unit;
  final void Function(double amount, bool finishedAll) onConsumed;

  const MarkConsumedSheet({
    super.key,
    required this.itemName,
    required this.availablePieces,
    required this.unit,
    required this.onConsumed,
  });

  @override
  State<MarkConsumedSheet> createState() => _MarkConsumedSheetState();
}

class _MarkConsumedSheetState extends State<MarkConsumedSheet> {
  double _consumeAmount = 1;

  @override
  Widget build(BuildContext context) {
    final canDecrement = _consumeAmount > 1;
    final canIncrement = _consumeAmount < widget.availablePieces;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF6FBF3),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                    color: const Color(0xFF717971),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Title
              const Text(
                'How much did you consume?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF181D17),
                ),
              ),
              const SizedBox(height: 6),
              // Subtitle
              Text(
                '${widget.itemName} · ${widget.availablePieces.toInt()} ${widget.unit} in fridge',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF414941),
                ),
              ),
              const SizedBox(height: 28),
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
                              ? const Color(0xFF717971)
                              : const Color(0xFFC4C8C1),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.remove,
                        size: 20,
                        color: canDecrement
                            ? const Color(0xFF181D17)
                            : const Color(0xFFA8ADA5),
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
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF181D17),
                          ),
                        ),
                        Text(
                          'of ${widget.availablePieces.toInt()} ${widget.unit}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF414941),
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
                            ? const Color(0xFF2E6A44)
                            : const Color(0xFF818981),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Confirm Button
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
                  onPressed: () => widget.onConsumed(_consumeAmount, false),
                  child: const Text('Confirm'),
                ),
              ),
              const SizedBox(height: 12),
              // Finished all Button
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFEAEFE8),
                    side: const BorderSide(color: Color(0xFF717971), width: 1.0),
                    foregroundColor: const Color(0xFF181D17),
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => widget.onConsumed(widget.availablePieces, true),
                  child: const Text('Finished all'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
