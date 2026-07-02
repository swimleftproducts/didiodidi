import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../domain/due_logic.dart';
import '../database.dart';
import '../tables.dart';

part 'task_dao.g.dart';

class TaskWithWeekdays {
  final Task task;
  final List<int> weekdays;
  const TaskWithWeekdays({required this.task, required this.weekdays});
}

@DriftAccessor(tables: [Tasks, TaskDays, Completions])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  Future<List<Task>> getAllActiveTasks() =>
      (select(tasks)..where((t) => t.active.equals(true))).get();

  /// All tasks (active and stopped alike), each with its weekdays —
  /// backs the All Tasks management screen.
  Future<List<TaskWithWeekdays>> getAllTasksWithWeekdays() async {
    final allTasks = await select(tasks).get();
    final result = <TaskWithWeekdays>[];
    for (final t in allTasks) {
      final days =
          await (select(taskDays)..where((td) => td.taskId.equals(t.id)))
              .get();
      result.add(TaskWithWeekdays(
        task: t,
        weekdays: days.map((d) => d.weekday).toList()..sort(),
      ));
    }
    return result;
  }

  Future<List<Task>> getTasksDueOn(int weekday, {String? today}) async {
    final asOf = today ?? isoDate(DateTime.now());
    final dueIds = await (select(taskDays)..where((td) => td.weekday.equals(weekday)))
        .map((td) => td.taskId)
        .get();
    if (dueIds.isEmpty) return [];
    return (select(tasks)
          ..where((t) =>
              t.active.equals(true) &
              t.id.isIn(dueIds) &
              (t.endDate.isNull() | t.endDate.isBiggerOrEqualValue(asOf))))
        .get();
  }

  Future<TaskWithWeekdays> getTaskWithWeekdays(String taskId) async {
    final task =
        await (select(tasks)..where((t) => t.id.equals(taskId))).getSingle();
    final days =
        await (select(taskDays)..where((td) => td.taskId.equals(taskId))).get();
    return TaskWithWeekdays(
      task: task,
      weekdays: days.map((d) => d.weekday).toList(),
    );
  }

  Future<String> insertTask({
    required String title,
    required String description,
    required List<int> weekdays,
    String? endDate,
  }) async {
    final id = const Uuid().v4();
    await into(tasks).insert(TasksCompanion.insert(
      id: id,
      title: title,
      description: Value(description),
      createdAt: DateTime.now(),
      endDate: Value(endDate),
    ));
    await batch((b) {
      b.insertAll(
        taskDays,
        weekdays.map((w) => TaskDaysCompanion.insert(taskId: id, weekday: w)),
      );
    });
    return id;
  }

  Future<void> updateTask({
    required String id,
    required String title,
    required String description,
    required List<int> weekdays,
    String? endDate,
  }) async {
    await (update(tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        title: Value(title),
        description: Value(description),
        endDate: Value(endDate),
      ),
    );
    await (delete(taskDays)..where((td) => td.taskId.equals(id))).go();
    await batch((b) {
      b.insertAll(
        taskDays,
        weekdays.map((w) => TaskDaysCompanion.insert(taskId: id, weekday: w)),
      );
    });
  }

  /// Pauses the task: it stops being due, but stays visible (as "Stopped")
  /// in the All Tasks screen. One-way from the UI — no reactivate action.
  Future<void> deactivateTask(String id) =>
      (update(tasks)..where((t) => t.id.equals(id)))
          .write(const TasksCompanion(active: Value(false)));

  /// Hard delete: removes the task and all its weekdays/completions.
  /// Unlike [deactivateTask], this is destructive and cannot be undone.
  Future<void> deleteTaskPermanently(String id) async {
    await transaction(() async {
      await (delete(taskDays)..where((td) => td.taskId.equals(id))).go();
      await (delete(completions)..where((c) => c.taskId.equals(id))).go();
      await (delete(tasks)..where((t) => t.id.equals(id))).go();
    });
  }
}
