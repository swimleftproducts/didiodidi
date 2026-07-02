import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'tables.dart';
import 'daos/task_dao.dart';
import 'daos/completion_dao.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Tasks, TaskDays, Completions],
  daos: [TaskDao, CompletionDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;
}

Future<AppDatabase> openAppDatabase() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(p.join(dbFolder.path, 'didiodidi.sqlite'));
  return AppDatabase(NativeDatabase(file));
}
