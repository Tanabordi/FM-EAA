import 'package:flutter/material.dart';

/// Text input field styled to match Figma design:
/// - Rounded rectangle container (border-radius 12)
/// - Light surface fill (#EAEFE8 / SurfaceContainer)
/// - Bottom border indicator line
/// - Optional floating label / top title
/// - Visibility toggle and lock icon support
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final String? labelText;
  final String? helperText;
  final String? errorText;
  final bool obscureText;
  final bool readOnly;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;

  const AppTextField({
    super.key,
    this.controller,
    required this.hintText,
    this.labelText,
    this.helperText,
    this.errorText,
    this.obscureText = false,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border(
              bottom: BorderSide(
                color: errorText != null
                    ? colorScheme.error
                    : colorScheme.outline.withValues(alpha: 0.5),
                width: errorText != null ? 1.5 : 1.0,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            readOnly: readOnly,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: TextStyle(
              fontSize: 15,
              color: colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              isDense: true,
              labelText: labelText,
              labelStyle: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
              hintText: hintText,
              hintStyle: TextStyle(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontSize: 14,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
            ),
          ),
        ),
        if (helperText != null && errorText == null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              helperText!,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              errorText!,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.error,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
