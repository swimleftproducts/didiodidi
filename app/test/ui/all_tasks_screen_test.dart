import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:didiodidi/data/database.dart';
import 'package:didiodidi/ui/all_tasks_screen.dart';
import 'package:didiodidi/ui/task_input_screen.dart';

AppDatabase _db() => AppDatabase(NativeDatabase.memory());

void main() {
  late AppDatabase db;
  setUp(() => db = _db());
  tearDown(() => db.close());

  Widget buildScreen() => MaterialApp(home: AllTasksScreen(db: db));

  testWidgets('shows empty state with no tasks', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();
    expect(find.text('No tasks yet.\nTap + to add one.'), findsOneWidget);
  });

  testWidgets('lists active and stopped tasks together', (tester) async {
    await db.taskDao
        .insertTask(title: 'Active task', description: '', weekdays: [1]);
    final stoppedId = await db.taskDao
        .insertTask(title: 'Stopped task', description: '', weekdays: [2]);
    await db.taskDao.deactivateTask(stoppedId);

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('Active task'), findsOneWidget);
    expect(find.text('Stopped task'), findsOneWidget);
    expect(find.text('Tue · Stopped'), findsOneWidget);
  });

  testWidgets('tapping the edit icon navigates to TaskInputScreen',
      (tester) async {
    final id = await db.taskDao
        .insertTask(title: 'Edit me', description: '', weekdays: [1]);
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('editButton_$id')));
    await tester.pumpAndSettle();

    expect(find.byType(TaskInputScreen), findsOneWidget);
  });

  testWidgets('delete icon removes the task after confirmation',
      (tester) async {
    final id = await db.taskDao
        .insertTask(title: 'Delete me', description: '', weekdays: [1]);
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('deleteButton_$id')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Delete me'), findsNothing);
  });

  testWidgets('cancelling delete keeps the task', (tester) async {
    final id = await db.taskDao
        .insertTask(title: 'Keep me', description: '', weekdays: [1]);
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('deleteButton_$id')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Keep me'), findsOneWidget);
  });
}
