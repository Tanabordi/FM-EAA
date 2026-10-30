import 'package:flutter/material.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/quantity_stepper.dart';

// TODO(screen #14 Mark as Consumed): "How much did you consume?", "<ชื่อ> · N pieces in fridge", ตัวนับ − / + (ค่าเริ่ม 1 "of N pieces"), ปุ่ม Confirm, ปุ่ม "Finished all"
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
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('How much did you consume?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.itemName} · ${widget.availablePieces.toInt()} ${widget.unit} in fridge',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          QuantityStepper(
            value: _consumeAmount,
            max: widget.availablePieces,
            unit: widget.unit,
            onChanged: (val) => setState(() => _consumeAmount = val),
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            label: 'Confirm',
            onPressed: () => widget.onConsumed(_consumeAmount, false),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: const StadiumBorder(),
            ),
            onPressed: () => widget.onConsumed(widget.availablePieces, true),
            child: const Text('Finished all'),
          ),
        ],
      ),
    );
  }
}

