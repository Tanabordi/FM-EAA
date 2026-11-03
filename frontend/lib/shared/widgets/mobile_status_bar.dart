import 'package:flutter/material.dart';

/// Legacy simulated status bar widget - disabled to allow device native status bar to show cleanly.
class MobileStatusBar extends StatelessWidget {
  final Color? color;
  final Color? backgroundColor;
  final bool forceShow;

  const MobileStatusBar({
    super.key,
    this.color,
    this.backgroundColor,
    this.forceShow = false,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
