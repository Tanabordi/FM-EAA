import 'package:flutter/material.dart';
import 'app_back_button.dart';

/// Unified App Bar matching Image 2 and Figma exact styling:
/// Padding: fromLTRB(16, 6, 16, 8)
/// Back button: Unified AppBackButton (42x42 square, border #717971, white container)
/// Title: fontSize: 25, fontWeight: FontWeight.w800, color: #1A201C, letterSpacing: -0.5
/// Action Buttons: prominent circular 42x42 with #EAEFE8 background and enlarged 22dp icons
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
            const SizedBox(width: 12),
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

/// Circular action button (42x42 with enlarged 22dp icon) for top app bar (e.g. notifications, settings, family, history)
class AppTopBarAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  const AppTopBarAction({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 42,
    this.iconSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(size / 2),
          child: Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              color: Color(0xFFEAEFE8),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: iconSize, color: const Color(0xFF2C3A2F)),
          ),
        ),
      ),
    );
  }
}
