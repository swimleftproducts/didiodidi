import 'package:flutter_test/flutter_test.dart';
import 'package:didiodidi/domain/reminder_schedule.dart';

void main() {
  group('nextInstanceOfTime', () {
    test('returns today when the time has not yet passed', () {
      final now = DateTime(2026, 7, 1, 7, 0);
      final next = nextInstanceOfTime(now, 8, 0);
      expect(next, DateTime(2026, 7, 1, 8, 0));
    });

    test('returns tomorrow when the time passed well outside the grace period', () {
      final now = DateTime(2026, 7, 1, 9, 0);
      final next = nextInstanceOfTime(now, 8, 0);
      expect(next, DateTime(2026, 7, 2, 8, 0));
    });

    test('returns null when now is exactly the target time', () {
      final now = DateTime(2026, 7, 1, 8, 0);
      final next = nextInstanceOfTime(now, 8, 0);
      expect(next, isNull);
    });

    test('returns null just inside the grace period after the target time', () {
      final now = DateTime(2026, 7, 1, 8, 10);
      final next = nextInstanceOfTime(now, 8, 0);
      expect(next, isNull);
    });

    test('returns tomorrow just outside the grace period', () {
      final now = DateTime(2026, 7, 1, 8, 16);
      final next = nextInstanceOfTime(now, 8, 0);
      expect(next, DateTime(2026, 7, 2, 8, 0));
    });
  });
}
