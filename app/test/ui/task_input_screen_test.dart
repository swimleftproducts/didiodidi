import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:didiodidi/data/database.dart';
import 'package:didiodidi/ui/task_input_screen.dart';

AppDatabase _db() => AppDatabase(NativeDatabase.memory());

void main() {
  late AppDatabase db;
  setUp(() => db = _db());
  tearDown(() => db.close());

  Widget buildAddScreen() => MaterialApp(home: TaskInputScreen(db: db));

  testWidgets('shows title and description text fields', (tester) async {
    await tester.pumpWidget(buildAddScreen());
    expect(find.byKey(const Key('titleField')), findsOneWidget);
    expect(find.byKey(const Key('descField')), findsOneWidget);
  });

  testWidgets('shows 7 weekday buttons', (tester) async {
    await tester.pumpWidget(buildAddScreen());
    for (var day = 1; day <= 7; day++) {
      expect(find.byKey(Key('weekday_$day')), findsOneWidget);
    }
  });

  testWidgets('save creates task in database', (tester) async {
    await tester.pumpWidget(buildAddScreen());

    await tester.enterText(find.byKey(const Key('titleField')), 'Quad stretch');
    await tester.tap(find.byKey(const Key('weekday_1'))); // Monday
    await tester.pump();
    await tester.tap(find.byKey(const Key('saveFab')));
    await tester.pumpAndSettle();

    final tasks = await db.taskDao.getAllActiveTasks();
    expect(tasks.length, 1);
    expect(tasks.first.title, 'Quad stretch');

    final tw = await db.taskDao.getTaskWithWeekdays(tasks.first.id);
    expect(tw.weekdays, contains(1));
  });

  testWidgets('save with no title does nothing', (tester) async {
    await tester.pumpWidget(buildAddScreen());
    await tester.tap(find.byKey(const Key('weekday_1')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('saveFab')));
    await tester.pumpAndSettle();

    expect(await db.taskDao.getAllActiveTasks(), isEmpty);
  });

  testWidgets('save with no weekdays selected does nothing', (tester) async {
    await tester.pumpWidget(buildAddScreen());
    await tester.enterText(find.byKey(const Key('titleField')), 'Hip bridges');
    await tester.tap(find.byKey(const Key('saveFab')));
    await tester.pumpAndSettle();

    expect(await db.taskDao.getAllActiveTasks(), isEmpty);
  });

  testWidgets('edit mode pre-populates fields', (tester) async {
    final id = await db.taskDao.insertTask(
      title: 'Hamstring stretch',
      description: '3x10',
      weekdays: [1, 3],
    );
    await tester.pumpWidget(
        MaterialApp(home: TaskInputScreen(db: db, taskId: id)));
    await tester.pumpAndSettle();

    expect(
      (tester.widget(find.byKey(const Key('titleField'))) as TextField)
          .controller!
          .text,
      'Hamstring stretch',
    );
  });

  testWidgets('delete button deactivates task', (tester) async {
    final id = await db.taskDao.insertTask(
      title: 'To delete',
      description: '',
      weekdays: [5],
    );
    await tester.pumpWidget(
        MaterialApp(home: TaskInputScreen(db: db, taskId: id)));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(await db.taskDao.getAllActiveTasks(), isEmpty);
  });
}
