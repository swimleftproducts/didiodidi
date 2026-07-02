import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:didiodidi/data/database.dart';

AppDatabase _db() => AppDatabase(NativeDatabase.memory());

void main() {
  late AppDatabase db;
  setUp(() => db = _db());
  tearDown(() => db.close());

  group('TaskDao', () {
    test('insert and retrieve', () async {
      final id = await db.taskDao.insertTask(
        title: 'Hamstring stretch',
        description: '3x10, hold 20s',
        weekdays: [1, 3, 5],
      );
      final tasks = await db.taskDao.getAllActiveTasks();
      expect(tasks.length, 1);
      expect(tasks.first.id, id);
      expect(tasks.first.title, 'Hamstring stretch');
    });

    test('getTasksDueOn filters by weekday', () async {
      await db.taskDao.insertTask(title: 'MWF', description: '', weekdays: [1, 3, 5]);
      await db.taskDao.insertTask(title: 'Weekend', description: '', weekdays: [6, 7]);

      final mon = await db.taskDao.getTasksDueOn(1);
      expect(mon.map((t) => t.title), contains('MWF'));
      expect(mon.map((t) => t.title), isNot(contains('Weekend')));

      final sat = await db.taskDao.getTasksDueOn(6);
      expect(sat.map((t) => t.title), contains('Weekend'));
      expect(sat.length, 1);
    });

    test('getTasksDueOn returns empty for day with no tasks', () async {
      await db.taskDao.insertTask(title: 'Mon only', description: '', weekdays: [1]);
      expect(await db.taskDao.getTasksDueOn(7), isEmpty);
    });

    test('getTaskWithWeekdays round-trips', () async {
      final id = await db.taskDao.insertTask(
        title: 'Hip bridges',
        description: '3x15',
        weekdays: [1, 2, 3, 4, 5],
      );
      final tw = await db.taskDao.getTaskWithWeekdays(id);
      expect(tw.task.title, 'Hip bridges');
      expect(tw.weekdays..sort(), [1, 2, 3, 4, 5]);
    });

    test('updateTask replaces title, description, and weekdays', () async {
      final id = await db.taskDao.insertTask(
          title: 'Old', description: 'old desc', weekdays: [1]);
      await db.taskDao.updateTask(
          id: id, title: 'New', description: 'new desc', weekdays: [2, 4]);
      final tw = await db.taskDao.getTaskWithWeekdays(id);
      expect(tw.task.title, 'New');
      expect(tw.task.description, 'new desc');
      expect(tw.weekdays..sort(), [2, 4]);
    });

    test('deactivateTask removes from active list and due list', () async {
      final id = await db.taskDao.insertTask(
          title: 'Task', description: '', weekdays: [1]);
      await db.taskDao.deactivateTask(id);
      expect(await db.taskDao.getAllActiveTasks(), isEmpty);
      expect(await db.taskDao.getTasksDueOn(1), isEmpty);
    });

    test('inactive tasks not returned even if weekday matches', () async {
      final id1 = await db.taskDao.insertTask(
          title: 'Active', description: '', weekdays: [3]);
      final id2 = await db.taskDao.insertTask(
          title: 'Inactive', description: '', weekdays: [3]);
      await db.taskDao.deactivateTask(id2);
      final due = await db.taskDao.getTasksDueOn(3);
      expect(due.map((t) => t.id), contains(id1));
      expect(due.map((t) => t.id), isNot(contains(id2)));
    });
  });

  group('CompletionDao', () {
    late String taskId;
    const date = '2026-07-01';

    setUp(() async {
      taskId =
          await db.taskDao.insertTask(title: 'Task', description: '', weekdays: [3]);
    });

    test('toggleCompletion marks complete', () async {
      await db.completionDao.toggleCompletion(taskId, date);
      expect(await db.completionDao.isCompleted(taskId, date), isTrue);
    });

    test('toggleCompletion twice marks incomplete', () async {
      await db.completionDao.toggleCompletion(taskId, date);
      await db.completionDao.toggleCompletion(taskId, date);
      expect(await db.completionDao.isCompleted(taskId, date), isFalse);
    });

    test('getCompletionsForDate is date-scoped', () async {
      await db.completionDao.toggleCompletion(taskId, '2026-07-01');
      await db.completionDao.toggleCompletion(taskId, '2026-07-02');
      final c = await db.completionDao.getCompletionsForDate('2026-07-01');
      expect(c.length, 1);
      expect(c.first.date, '2026-07-01');
    });

    test('getCompletionsForWindow returns inclusive range', () async {
      await db.completionDao.toggleCompletion(taskId, '2026-06-25');
      await db.completionDao.toggleCompletion(taskId, '2026-07-01');
      final c = await db.completionDao
          .getCompletionsForWindow('2026-06-25', '2026-07-01');
      expect(c.length, 2);
    });

    test('completion on other date does not affect isCompleted for date', () async {
      await db.completionDao.toggleCompletion(taskId, '2026-07-02');
      expect(await db.completionDao.isCompleted(taskId, '2026-07-01'), isFalse);
    });
  });
}
