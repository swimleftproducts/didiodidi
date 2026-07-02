import 'package:flutter_test/flutter_test.dart';
import 'package:didiodidi/domain/due_logic.dart';

void main() {
  group('isoDate', () {
    test('formats with zero-padding', () {
      expect(isoDate(DateTime(2026, 7, 1)), '2026-07-01');
      expect(isoDate(DateTime(2026, 1, 5)), '2026-01-05');
    });
  });

  group('taskIdsDueOn', () {
    final weekdays = {
      'stretch': [1, 3, 5], // Mon, Wed, Fri
      'bridges': [1, 2, 3, 4, 5, 6, 7], // every day
      'weekend': [6, 7],
    };

    test('returns tasks due on Monday (ISO 1)', () {
      final due = taskIdsDueOn(weekdays, DateTime(2026, 6, 29)); // Monday
      expect(due, containsAll(['stretch', 'bridges']));
      expect(due, isNot(contains('weekend')));
    });

    test('returns tasks due on Saturday (ISO 6)', () {
      final due = taskIdsDueOn(weekdays, DateTime(2026, 6, 27)); // Saturday
      expect(due, containsAll(['bridges', 'weekend']));
      expect(due, isNot(contains('stretch')));
    });

    test('returns empty when no tasks match', () {
      final due = taskIdsDueOn({'mon-only': [1]}, DateTime(2026, 6, 27));
      expect(due, isEmpty);
    });

    test('empty map returns empty list', () {
      expect(taskIdsDueOn({}, DateTime(2026, 7, 1)), isEmpty);
    });
  });

  group('taskStillActiveOn', () {
    test('null end date is always active', () {
      expect(taskStillActiveOn(null, DateTime(2099, 1, 1)), isTrue);
    });

    test('active on and before its end date', () {
      expect(taskStillActiveOn('2026-07-01', DateTime(2026, 7, 1)), isTrue);
      expect(taskStillActiveOn('2026-07-01', DateTime(2026, 6, 25)), isTrue);
    });

    test('inactive after its end date', () {
      expect(taskStillActiveOn('2026-07-01', DateTime(2026, 7, 2)), isFalse);
    });
  });

  group('incompleteTaskIds', () {
    test('filters completed tasks out', () {
      final result = incompleteTaskIds(['a', 'b', 'c'], {'b'});
      expect(result, containsAll(['a', 'c']));
      expect(result, isNot(contains('b')));
    });

    test('returns all when none completed', () {
      expect(incompleteTaskIds(['a', 'b'], {}), containsAll(['a', 'b']));
    });

    test('returns empty when all completed', () {
      expect(incompleteTaskIds(['a', 'b'], {'a', 'b'}), isEmpty);
    });

    test('empty due list returns empty', () {
      expect(incompleteTaskIds([], {'a'}), isEmpty);
    });
  });

  group('computeStats', () {
    test('counts correctly', () {
      final s = computeStats(['a', 'b', 'c'], {'a', 'c'});
      expect(s.completed, 2);
      expect(s.total, 3);
    });

    test('all complete', () {
      final s = computeStats(['a', 'b'], {'a', 'b'});
      expect(s.completed, 2);
      expect(s.total, 2);
    });

    test('none complete', () {
      final s = computeStats(['a', 'b'], {});
      expect(s.completed, 0);
      expect(s.total, 2);
    });

    test('empty inputs', () {
      final s = computeStats([], {});
      expect(s.completed, 0);
      expect(s.total, 0);
    });
  });
}
