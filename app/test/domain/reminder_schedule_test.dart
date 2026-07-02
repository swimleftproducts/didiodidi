import 'package:flutter_test/flutter_test.dart';
import 'package:didiodidi/domain/reminder_schedule.dart';

void main() {
  group('nextInstanceOfTime', () {
    test('returns today when the time has not yet passed', () {
      final now = DateTime(2026, 7, 1, 7, 0);
      final next = nextInstanceOfTime(now, 8, 0);
      expect(next, DateTime(2026, 7, 1, 8, 0));
    });

    test('returns tomorrow when the time has already passed today', () {
      final now = DateTime(2026, 7, 1, 9, 0);
      final next = nextInstanceOfTime(now, 8, 0);
      expect(next, DateTime(2026, 7, 2, 8, 0));
    });

    test('returns tomorrow when now is exactly the target time', () {
      final now = DateTime(2026, 7, 1, 8, 0);
      final next = nextInstanceOfTime(now, 8, 0);
      expect(next, DateTime(2026, 7, 2, 8, 0));
    });
  });
}
