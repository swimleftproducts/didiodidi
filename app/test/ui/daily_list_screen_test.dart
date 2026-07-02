import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:didiodidi/data/database.dart';
import 'package:didiodidi/ui/daily_list_screen.dart';

AppDatabase _db() => AppDatabase(NativeDatabase.memory());

void main() {
  late AppDatabase db;
  setUp(() => db = _db());
  tearDown(() => db.close());

  Widget buildScreen() => MaterialApp(home: DailyListScreen(db: db));

  testWidgets('shows empty-state message when no tasks due today',
      (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();
    expect(find.text('No tasks due today.\nTap + to add one.'), findsOneWidget);
  });

  testWidgets('shows task due today', (tester) async {
    await db.taskDao.insertTask(
      title: 'Hamstring stretch',
      description: '3x10',
      weekdays: [DateTime.now().weekday],
    );
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();
    expect(find.text('Hamstring stretch'), findsOneWidget);
  });

  testWidgets('does not show task not due today', (tester) async {
    final notToday =
        DateTime.now().weekday == 7 ? 1 : DateTime.now().weekday + 1;
    await db.taskDao.insertTask(
      title: 'Not today',
      description: '',
      weekdays: [notToday],
    );
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();
    expect(find.text('Not today'), findsNothing);
  });

  testWidgets('tapping task toggles completion icon', (tester) async {
    await db.taskDao.insertTask(
      title: 'Hip bridges',
      description: '',
      weekdays: [DateTime.now().weekday],
    );
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('tapping completed task toggles back to unchecked', (tester) async {
    await db.taskDao.insertTask(
      title: 'Calf raises',
      description: '',
      weekdays: [DateTime.now().weekday],
    );
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_circle), findsOneWidget);

    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
  });

  testWidgets('header shows correct progress count', (tester) async {
    final weekday = DateTime.now().weekday;
    await db.taskDao.insertTask(title: 'A', description: '', weekdays: [weekday]);
    await db.taskDao.insertTask(title: 'B', description: '', weekdays: [weekday]);
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    // Initially 0/2
    expect(find.textContaining('0/2'), findsOneWidget);

    // Complete one task
    await tester.tap(find.byType(ListTile).first);
    await tester.pumpAndSettle();
    expect(find.textContaining('1/2'), findsOneWidget);
  });
}
