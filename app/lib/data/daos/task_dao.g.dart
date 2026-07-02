// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_dao.dart';

// ignore_for_file: type=lint
mixin _$TaskDaoMixin on DatabaseAccessor<AppDatabase> {
  $TasksTable get tasks => attachedDatabase.tasks;
  $TaskDaysTable get taskDays => attachedDatabase.taskDays;
  $CompletionsTable get completions => attachedDatabase.completions;
  TaskDaoManager get managers => TaskDaoManager(this);
}

class TaskDaoManager {
  final _$TaskDaoMixin _db;
  TaskDaoManager(this._db);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db.attachedDatabase, _db.tasks);
  $$TaskDaysTableTableManager get taskDays =>
      $$TaskDaysTableTableManager(_db.attachedDatabase, _db.taskDays);
  $$CompletionsTableTableManager get completions =>
      $$CompletionsTableTableManager(_db.attachedDatabase, _db.completions);
}
