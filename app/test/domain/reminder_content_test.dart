import 'package:flutter_test/flutter_test.dart';
import 'package:didiodidi/domain/reminder_content.dart';

void main() {
  group('morningMessage', () {
    test('lists all due task titles', () {
      expect(
        morningMessage(['Hamstring stretch', 'Hip bridges']),
        'Hamstring stretch, Hip bridges',
      );
    });

    test('handles no tasks due today', () {
      expect(morningMessage([]), 'No tasks due today.');
    });
  });

  group('incompleteMessage', () {
    test('lists still-incomplete task titles', () {
      expect(
        incompleteMessage(['Calf raises']),
        'Still to do: Calf raises',
      );
    });

    test('handles everything already completed', () {
      expect(incompleteMessage([]), 'All done for today.');
    });
  });
}
