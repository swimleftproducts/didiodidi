// Pure domain functions — no I/O, no Flutter dependencies.

/// Notifications are rescheduled on every app foreground/background
/// transition (see NotificationService). Without a grace window, a
/// transition landing just after today's target time — e.g. the user
/// unlocks their phone a minute after 8:55 — would read "8:55 already
/// passed" and roll the alarm to tomorrow, cancelling one that's still
/// pending delivery. Within this window the existing alarm is left alone.
const reminderGracePeriod = Duration(minutes: 15);

/// The next DateTime at which [hour]:[minute] should be scheduled, given
/// [now]. Returns null if today's occurrence is in the past by less than
/// [reminderGracePeriod] — the caller should leave any already-scheduled
/// alarm untouched rather than cancel and replace it. Otherwise rolls to
/// tomorrow once that grace period has elapsed.
DateTime? nextInstanceOfTime(DateTime now, int hour, int minute) {
  final todayTarget = DateTime(now.year, now.month, now.day, hour, minute);
  final elapsed = now.difference(todayTarget);
  if (!elapsed.isNegative) {
    if (elapsed <= reminderGracePeriod) return null;
    return todayTarget.add(const Duration(days: 1));
  }
  return todayTarget;
}
