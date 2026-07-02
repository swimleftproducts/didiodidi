import 'package:drift/drift.dart';

class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get imagePath => text().nullable()();
  // YYYY-MM-DD; null = repeats weekly forever, set = stops being due after this date.
  TextColumn get endDate => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class TaskDays extends Table {
  TextColumn get taskId => text()();
  IntColumn get weekday => integer()(); // ISO 1–7 (Mon=1, Sun=7)

  @override
  Set<Column> get primaryKey => {taskId, weekday};
}

class Completions extends Table {
  TextColumn get taskId => text()();
  TextColumn get date => text()(); // YYYY-MM-DD
  DateTimeColumn get completedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {taskId, date};
}
