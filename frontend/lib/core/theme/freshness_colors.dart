import 'package:flutter/material.dart';

/// Design tokens for Freshness Visual Cues and Status indicators.
/// Sourced directly from docs/DESIGN_SPEC.md.
class FreshnessColors {
  /// Fresh status color (#34C759) - Star icon
  static const Color fresh = Color(0xFF34C759);

  /// Use soon status color (#FF8D28) - Clock icon
  static const Color useSoon = Color(0xFFFF8D28);

  /// Expired status color (#FF383C) - Alert warning icon
  static const Color expired = Color(0xFFFF383C);

  /// Danger action buttons (Delete, Log out, Clear All, Decline) (#B91C1C)
  static const Color danger = Color(0xFFB91C1C);
}

enum FreshnessStatus {
  fresh,
  useSoon,
  expired;

  Color get color {
    switch (this) {
      case FreshnessStatus.fresh:
        return FreshnessColors.fresh;
      case FreshnessStatus.useSoon:
        return FreshnessColors.useSoon;
      case FreshnessStatus.expired:
        return FreshnessColors.expired;
    }
  }

  IconData get icon {
    switch (this) {
      case FreshnessStatus.fresh:
        return Icons.star_rounded;
      case FreshnessStatus.useSoon:
        return Icons.access_time_rounded;
      case FreshnessStatus.expired:
        return Icons.warning_amber_rounded;
    }
  }

  String get label {
    switch (this) {
      case FreshnessStatus.fresh:
        return 'Fresh';
      case FreshnessStatus.useSoon:
        return 'Use soon';
      case FreshnessStatus.expired:
        return 'Expired';
    }
  }
}

