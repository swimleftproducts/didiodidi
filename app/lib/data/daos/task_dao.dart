import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database.dart';
import '../tables.dart';

part 'task_dao.g.dart';

class TaskWithWeekdays {
  final Task task;
  final List<int> weekdays;
  const TaskWithWeekdays({required this.task, required this.weekdays});
}

@DriftAccessor(tables: [Tasks, TaskDays])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  Future<List<Task>> getAllActiveTasks() =>
      (select(tasks)..where((t) => t.active.equals(true))).get();

  Future<List<Task>> getTasksDueOn(int weekday) async {
    final dueIds = await (select(taskDays)..where((td) => td.weekday.equals(weekday)))
        .map((td) => td.taskId)
        .get();
    if (dueIds.isEmpty) return [];
    return (select(tasks)
          ..where((t) => t.active.equals(true) & t.id.isIn(dueIds)))
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
  }) async {
    final id = const Uuid().v4();
    await into(tasks).insert(TasksCompanion.insert(
      id: id,
      title: title,
      description: Value(description),
      createdAt: DateTime.now(),
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
  }) async {
    await (update(tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(title: Value(title), description: Value(description)),
    );
    await (delete(taskDays)..where((td) => td.taskId.equals(id))).go();
    await batch((b) {
      b.insertAll(
        taskDays,
        weekdays.map((w) => TaskDaysCompanion.insert(taskId: id, weekday: w)),
      );
    });
  }

  Future<void> deactivateTask(String id) =>
      (update(tasks)..where((t) => t.id.equals(id)))
          .write(const TasksCompanion(active: Value(false)));
}
