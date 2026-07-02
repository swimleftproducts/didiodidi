// Pure domain functions — no I/O, no Flutter dependencies.

/// The next DateTime at which [hour]:[minute] occurs, given [now].
/// If that time today is not strictly in the future, rolls to tomorrow.
DateTime nextInstanceOfTime(DateTime now, int hour, int minute) {
  var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
  if (!scheduled.isAfter(now)) {
    scheduled = scheduled.add(const Duration(days: 1));
  }
  return scheduled;
}
