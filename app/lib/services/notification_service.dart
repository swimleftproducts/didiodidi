import '../data/database.dart';
import '../domain/due_logic.dart';
import '../domain/reminder_content.dart';
import '../domain/reminder_schedule.dart';
import 'notification_scheduler.dart';
import 'settings_repository.dart';

/// Reschedules the three daily reminders from current DB state.
///
/// Notification text is baked in at schedule time (it can't query the DB
/// when it fires), so [rescheduleAll] must be called every time the app is
/// foregrounded or backgrounded — see CLAUDE.md Section 7.
class NotificationService {
  static const morningId = 1;
  static const middayId = 2;
  static const eveningId = 3;

  final NotificationScheduler _scheduler;

  NotificationService([NotificationScheduler? scheduler])
      : _scheduler = scheduler ?? FlutterLocalNotificationsScheduler();

  Future<void> init() => _scheduler.initialize();

  Future<void> rescheduleAll({
    required AppDatabase db,
    required SettingsRepository settings,
    DateTime? now,
  }) async {
    now ??= DateTime.now();
    final today = isoDate(now);
    final dueTasks = await db.taskDao.getTasksDueOn(now.weekday, today: today);
    final completions = await db.completionDao.getCompletionsForDate(today);
    final completedIds = completions.map((c) => c.taskId).toSet();
    final incompleteTitles = dueTasks
        .where((t) => !completedIds.contains(t.id))
        .map((t) => t.title)
        .toList();
    final dueTitles = dueTasks.map((t) => t.title).toList();

    final morningTime = await settings.getMorningTime();
    final middayTime = await settings.getMiddayTime();
    final eveningTime = await settings.getEveningTime();

    await _rescheduleOne(
      id: morningId,
      title: "Today's exercises",
      body: morningMessage(dueTitles),
      scheduledDate: nextInstanceOfTime(now, morningTime.hour, morningTime.minute),
    );
    await _rescheduleOne(
      id: middayId,
      title: 'Midday check-in',
      body: incompleteMessage(incompleteTitles),
      scheduledDate: nextInstanceOfTime(now, middayTime.hour, middayTime.minute),
    );
    await _rescheduleOne(
      id: eveningId,
      title: 'Evening check-in',
      body: incompleteMessage(incompleteTitles),
      scheduledDate: nextInstanceOfTime(now, eveningTime.hour, eveningTime.minute),
    );
  }

  // A null scheduledDate means today's occurrence is within the grace
  // window (see reminder_schedule.dart) — leave the existing alarm alone
  // instead of cancelling a still-pending, not-yet-delivered one.
  Future<void> _rescheduleOne({
    required int id,
    required String title,
    required String body,
    required DateTime? scheduledDate,
  }) async {
    if (scheduledDate == null) return;
    await _scheduler.cancel(id);
    await _scheduler.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
    );
  }
}
