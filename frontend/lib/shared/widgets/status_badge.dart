import 'package:flutter/material.dart';
import '../../core/theme/freshness_colors.dart';

/// StatusBadge matching Figma node 11:178 & design mockup
class StatusBadge extends StatelessWidget {
  final FreshnessStatus status;
  final String? customLabel;
  final bool solid;

  const StatusBadge({
    super.key,
    required this.status,
    this.customLabel,
    bool solid = true,
    bool? isSolid,
  }) : solid = isSolid ?? solid;

  @override
  Widget build(BuildContext context) {
    final text = customLabel ?? status.label;

    Color bgColor;
    const Color fgColor = Colors.white;

    switch (status) {
      case FreshnessStatus.fresh:
        bgColor = const Color(0xFF34C759); // Figma exact green #34C759
        break;
      case FreshnessStatus.useSoon:
        bgColor = const Color(0xFFFF8D28); // Figma exact orange #FF8D28
        break;
      case FreshnessStatus.expired:
        bgColor = const Color(0xFFFF383C); // Figma exact red #FF383C
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.5, vertical: 3.5),
      decoration: BoxDecoration(
        color: solid ? bgColor : bgColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: solid ? null : Border.all(color: bgColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            status.icon,
            size: 13.5,
            color: solid ? fgColor : bgColor,
          ),
          const SizedBox(width: 4.5),
          Text(
            text,
            style: TextStyle(
              color: solid ? fgColor : bgColor,
              fontSize: 12.0,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
