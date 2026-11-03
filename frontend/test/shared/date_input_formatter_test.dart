import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/shared/utils/date_input_formatter.dart';

void main() {
  group('DateInputFormatter', () {
    late DateInputFormatter formatter;

    setUp(() {
      formatter = DateInputFormatter();
    });

    TextEditingValue format(String oldText, String newText) {
      return formatter.formatEditUpdate(
        TextEditingValue(
          text: oldText,
          selection: TextSelection.collapsed(offset: oldText.length),
        ),
        TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        ),
      );
    }

    test('automatically inserts slashes as digits are entered', () {
      expect(format('', '1').text, '1');
      expect(format('1', '10').text, '10/');
      expect(format('10/', '10/2').text, '10/2');
      expect(format('10/2', '10/28').text, '10/28/');
      expect(format('10/28/', '10/28/2').text, '10/28/2');
      expect(format('10/28/202', '10/28/2026').text, '10/28/2026');
    });

    test('formats raw digit stream into MM/DD/YYYY', () {
      expect(format('', '10282026').text, '10/28/2026');
    });

    test('caps at 8 digits (MM/DD/YYYY)', () {
      expect(format('10/28/2026', '10/28/20269').text, '10/28/2026');
    });

    test('deleting slash deletes the digit before it', () {
      // User is at '10/' and hits backspace, deleting '/'
      final result = format('10/', '10');
      expect(result.text, '1');
    });

    test('deleting slash after day deletes the digit before it', () {
      // User is at '10/28/' and hits backspace, deleting '/'
      final result = format('10/28/', '10/28');
      expect(result.text, '10/2');
    });
  });
}
