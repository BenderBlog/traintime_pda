// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_test/flutter_test.dart';
import 'package:watermeter/page/setting/dialogs/change_swift_dialog.dart';

void main() {
  group('signedIntegerInputFormatter', () {
    const empty = TextEditingValue.empty;

    test('accepts signed integers and an intermediate sign', () {
      expect(
        signedIntegerInputFormatter.formatEditUpdate(
          empty,
          const TextEditingValue(text: '-'),
        ),
        const TextEditingValue(text: '-'),
      );
      expect(
        signedIntegerInputFormatter.formatEditUpdate(
          empty,
          const TextEditingValue(text: '-2'),
        ),
        const TextEditingValue(text: '-2'),
      );
      expect(
        signedIntegerInputFormatter.formatEditUpdate(
          empty,
          const TextEditingValue(text: '+3'),
        ),
        const TextEditingValue(text: '+3'),
      );
    });

    test('rejects misplaced signs and non-digits', () {
      const oldValue = TextEditingValue(text: '-2');

      expect(
        signedIntegerInputFormatter.formatEditUpdate(
          oldValue,
          const TextEditingValue(text: '--2'),
        ),
        oldValue,
      );
      expect(
        signedIntegerInputFormatter.formatEditUpdate(
          oldValue,
          const TextEditingValue(text: '2-'),
        ),
        oldValue,
      );
      expect(
        signedIntegerInputFormatter.formatEditUpdate(
          oldValue,
          const TextEditingValue(text: 'two'),
        ),
        oldValue,
      );
    });
  });

  group('parseWeekSwiftInput', () {
    test('parses signed integers', () {
      expect(parseWeekSwiftInput('-2'), -2);
      expect(parseWeekSwiftInput('+3'), 3);
    });

    test('uses zero for empty or incomplete input', () {
      expect(parseWeekSwiftInput(''), 0);
      expect(parseWeekSwiftInput('-'), 0);
      expect(parseWeekSwiftInput('+'), 0);
    });
  });
}
