import 'package:flutter/material.dart';
import '../../core/theme/freshness_colors.dart';

/// Reusable status badge chip displaying freshness status:
/// Fresh (Green + Star), Use soon (Orange + Clock), Expired (Red + Alert)
class StatusBadge extends StatelessWidget {
  final FreshnessStatus status;
  final String? customLabel;
  final bool isSolid;

  const StatusBadge({
    super.key,
    required this.status,
    this.customLabel,
    this.isSolid = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = status.color;
    final text = customLabel ?? status.label;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isSolid ? color : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: isSolid ? null : Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 14, color: isSolid ? Colors.white : color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: isSolid ? Colors.white : color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
