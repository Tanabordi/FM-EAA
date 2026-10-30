import 'package:flutter/material.dart';

/// Counter with - and + buttons for Mark as Consumed bottom sheet
class QuantityStepper extends StatelessWidget {
  final double value;
  final double max;
  final String unit;
  final ValueChanged<double> onChanged;

  const QuantityStepper({
    super.key,
    required this.value,
    required this.max,
    required this.unit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.filledTonal(
          icon: const Icon(Icons.remove),
          onPressed: value > 1 ? () => onChanged(value - 1) : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            '${value.toInt()} of ${max.toInt()} $unit',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton.filledTonal(
          icon: const Icon(Icons.add),
          onPressed: value < max ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }
}

