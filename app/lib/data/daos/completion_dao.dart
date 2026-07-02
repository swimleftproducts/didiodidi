import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'completion_dao.g.dart';

@DriftAccessor(tables: [Completions])
class CompletionDao extends DatabaseAccessor<AppDatabase>
    with _$CompletionDaoMixin {
  CompletionDao(super.db);

  Future<List<Completion>> getCompletionsForDate(String date) =>
      (select(completions)..where((c) => c.date.equals(date))).get();

  Future<List<Completion>> getCompletionsForWindow(
    String startDate,
    String endDate,
  ) =>
      (select(completions)
            ..where(
              (c) =>
                  c.date.isBiggerOrEqualValue(startDate) &
                  c.date.isSmallerOrEqualValue(endDate),
            ))
          .get();

  Future<void> toggleCompletion(String taskId, String date) async {
    final existing = await (select(completions)
          ..where((c) => c.taskId.equals(taskId) & c.date.equals(date)))
        .getSingleOrNull();
    if (existing != null) {
      await (delete(completions)
            ..where((c) => c.taskId.equals(taskId) & c.date.equals(date)))
          .go();
    } else {
      await into(completions).insert(CompletionsCompanion.insert(
        taskId: taskId,
        date: date,
        completedAt: DateTime.now(),
      ));
    }
  }

  Future<bool> isCompleted(String taskId, String date) async {
    final row = await (select(completions)
          ..where((c) => c.taskId.equals(taskId) & c.date.equals(date)))
        .getSingleOrNull();
    return row != null;
  }
}
