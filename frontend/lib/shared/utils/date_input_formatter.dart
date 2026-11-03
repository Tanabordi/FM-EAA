import 'package:flutter/services.dart';

/// Automatically formats date input as MM/DD/YYYY.
/// Inserts '/' automatically after month (2 digits) and day (2 digits)
/// so the user doesn't have to type '/' manually.
class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // If the user deleted a single character
    if (oldValue.text.length - newValue.text.length == 1) {
      // If the deleted character was a trailing slash
      if (oldValue.text.endsWith('/') &&
          newValue.text == oldValue.text.substring(0, oldValue.text.length - 1)) {
        final remaining = newValue.text.isEmpty
            ? ''
            : newValue.text.substring(0, newValue.text.length - 1);
        return _formatDigits(remaining);
      }

      // If user deleted a slash in the middle
      final oldSelection = oldValue.selection.baseOffset;
      if (oldSelection > 0 && oldSelection <= oldValue.text.length) {
        final charDeleted = oldValue.text[oldSelection - 1];
        if (charDeleted == '/') {
          final deleteIndex = oldSelection - 2;
          if (deleteIndex >= 0) {
            final before = oldValue.text.substring(0, deleteIndex);
            final after = oldValue.text.substring(oldSelection);
            return _formatDigits('$before$after');
          }
        }
      }
    }

    return _formatDigits(newValue.text);
  }

  TextEditingValue _formatDigits(String text) {
    final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    final limitedDigits = digits.length > 8 ? digits.substring(0, 8) : digits;

    if (limitedDigits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final buffer = StringBuffer();
    for (int i = 0; i < limitedDigits.length; i++) {
      buffer.write(limitedDigits[i]);
      if (i == 1 || i == 3) {
        buffer.write('/');
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
