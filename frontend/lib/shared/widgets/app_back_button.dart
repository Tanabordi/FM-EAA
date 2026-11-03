import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Unified Back Button matching DESIGN_SPEC.md and Material 3 exact styling:
/// Square 42x42 with rounded corners (13dp), solid white background (#FFFFFF),
/// outline border (#717971 width 1.2), and dark slate arrow (#414942).
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
          color: backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: const Color(0xFF717971), // Material 3 Outline #717971
            width: 1.2,
          ),
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(
            Icons.arrow_back,
            size: 20,
            color: Color(0xFF414942), // Material 3 On Surface Variant #414942
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
