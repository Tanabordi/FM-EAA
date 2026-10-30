import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Unified Back Button matching Image 2 and Figma exact styling:
/// Square 42x42 with rounded corners (13dp), transparent/canvas background,
/// thin border (#818981), and dark slate/charcoal arrow (#414942).
class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? backgroundColor;

  const AppBackButton({
    super.key,
    this.onPressed,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: const Color(0xFF818981), // Image 2 exact border #818981
            width: 1.2,
          ),
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(
            Icons.arrow_back,
            size: 20,
            color: Color(0xFF414942), // Image 2 exact arrow #414942
          ),
          onPressed: onPressed ??
              () {
                if (Navigator.of(context).canPop()) {
                  context.pop();
                } else {
                  context.go('/fridges');
                }
              },
        ),
      ),
    );
  }
}
