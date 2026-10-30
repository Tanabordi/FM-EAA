import 'package:flutter/material.dart';
import 'app_back_button.dart';

/// Unified App Bar matching Image 2 and Figma exact styling:
/// Padding: fromLTRB(16, 6, 16, 8)
/// Back button: Unified AppBackButton (42x42 square, border #818981)
/// Title: fontSize: 25, fontWeight: FontWeight.w800, color: #1A201C, letterSpacing: -0.5
/// Optional Action Buttons: circular 38x38 with #EAEFE8 background
class AppTopBar extends StatelessWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Widget? trailing;

  const AppTopBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      child: Row(
        children: [
          if (showBackButton) ...[
            AppBackButton(onPressed: onBackPressed),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A201C),
                letterSpacing: -0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (actions != null) ...actions!,
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Circular action button (38x38) for top app bar (e.g. notifications, settings, family, history)
class AppTopBarAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const AppTopBarAction({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Color(0xFFEAEFE8),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 19, color: const Color(0xFF2C3A2F)),
          ),
        ),
      ),
    );
  }
}
