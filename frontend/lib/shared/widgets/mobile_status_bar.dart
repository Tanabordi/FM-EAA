import 'package:flutter/material.dart';

/// Simulated iOS / Mobile status bar matching Figma Screen mockups:
/// Left: 9:41 time
/// Right: Cellular signal bars, Wifi icon, Battery outline with fill level
class MobileStatusBar extends StatelessWidget {
  final Color? color;
  final Color? backgroundColor;

  const MobileStatusBar({
    super.key,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final fgColor = color ?? const Color(0xFF1A201C);

    return Container(
      height: 44,
      color: backgroundColor ?? Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Time 9:41
          Text(
            '9:41',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: fgColor,
              letterSpacing: -0.3,
            ),
          ),
          // System Icons: Signal, Wifi, Battery
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.signal_cellular_4_bar_rounded, size: 16, color: fgColor),
              const SizedBox(width: 5),
              Icon(Icons.wifi_rounded, size: 16, color: fgColor),
              const SizedBox(width: 5),
              // Battery icon capsule
              Container(
                width: 23,
                height: 11.5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3.5),
                  border: Border.all(color: fgColor, width: 1.2),
                ),
                padding: const EdgeInsets.all(1.5),
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 15,
                  decoration: BoxDecoration(
                    color: fgColor,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
