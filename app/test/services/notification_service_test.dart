import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:didiodidi/data/database.dart';
import 'package:didiodidi/domain/due_logic.dart';
import 'package:didiodidi/services/notification_service.dart';
import 'package:didiodidi/services/settings_repository.dart';
import '../test_fakes.dart';

void main() {
  late AppDatabase db;
  late FakeNotificationScheduler scheduler;
  late SettingsRepository settings;
  late NotificationService service;

  const morningId = 1;
  const middayId = 2;
  const eveningId = 3;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    scheduler = FakeNotificationScheduler();
    settings = SettingsRepository(InMemoryKeyValueStore());
    service = NotificationService(scheduler);
  });

  tearDown(() => db.close());

  test('cancels all three notifications before rescheduling', () async {
    await service.rescheduleAll(db: db, settings: settings);
    expect(scheduler.cancelled, containsAll([morningId, middayId, eveningId]));
  });

  test('morning message lists all tasks due today regardless of completion',
      () async {
    final weekday = DateTime.now().weekday;
    final id = await db.taskDao.insertTask(
      title: 'Hamstring stretch',
      description: '',
      weekdays: [weekday],
    );
    await db.completionDao.toggleCompletion(id, isoDate(DateTime.now()));

    await service.rescheduleAll(db: db, settings: settings);

    final morning =
        scheduler.scheduled.firstWhere((c) => c.id == morningId);
    expect(morning.body, 'Hamstring stretch');
  });

  test('midday/evening messages list only incomplete tasks', () async {
    final weekday = DateTime.now().weekday;
    await db.taskDao.insertTask(
      title: 'Done already',
      description: '',
      weekdays: [weekday],
    );
    final incompleteId = await db.taskDao.insertTask(
      title: 'Still pending',
      description: '',
      weekdays: [weekday],
    );
    final doneId = (await db.taskDao.getTasksDueOn(weekday))
        .firstWhere((t) => t.title == 'Done already')
        .id;
    await db.completionDao.toggleCompletion(doneId, isoDate(DateTime.now()));

    await service.rescheduleAll(db: db, settings: settings);

    final midday = scheduler.scheduled.firstWhere((c) => c.id == middayId);
    final evening = scheduler.scheduled.firstWhere((c) => c.id == eveningId);
    expect(midday.body, 'Still to do: Still pending');
    expect(evening.body, 'Still to do: Still pending');
    expect(incompleteId, isNotEmpty);
  });

  test('schedules using the configured times', () async {
    await settings.setMorningTime(const TimeOfDay(hour: 7, minute: 30));
    await service.rescheduleAll(db: db, settings: settings);

    final morning =
        scheduler.scheduled.firstWhere((c) => c.id == morningId);
    expect(morning.scheduledDate.hour, 7);
    expect(morning.scheduledDate.minute, 30);
  });

  test('no tasks due today produces the empty-state messages', () async {
    await service.rescheduleAll(db: db, settings: settings);

    final morning =
        scheduler.scheduled.firstWhere((c) => c.id == morningId);
    final evening =
        scheduler.scheduled.firstWhere((c) => c.id == eveningId);
    expect(morning.body, 'No tasks due today.');
    expect(evening.body, 'All done for today.');
  });
}
