// Pure domain functions — no I/O, no Flutter dependencies.

String isoDate(DateTime dt) =>
    '${dt.year.toString().padLeft(4, '0')}-'
    '${dt.month.toString().padLeft(2, '0')}-'
    '${dt.day.toString().padLeft(2, '0')}';

/// Returns task IDs whose weekday list includes [date]'s ISO weekday.
List<String> taskIdsDueOn(
  Map<String, List<int>> taskWeekdays,
  DateTime date,
) =>
    taskWeekdays.entries
        .where((e) => e.value.contains(date.weekday))
        .map((e) => e.key)
        .toList();

/// Returns IDs from [dueTaskIds] that are NOT in [completedTaskIds].
List<String> incompleteTaskIds(
  List<String> dueTaskIds,
  Set<String> completedTaskIds,
) =>
    dueTaskIds.where((id) => !completedTaskIds.contains(id)).toList();

/// Whether a task with the given [endDate] (nullable YYYY-MM-DD, null =
/// repeats forever) is still active on [date].
bool taskStillActiveOn(String? endDate, DateTime date) {
  if (endDate == null) return true;
  return isoDate(date).compareTo(endDate) <= 0;
}

/// Completion stats for a single day.
({int completed, int total}) computeStats(
  List<String> dueTaskIds,
  Set<String> completedTaskIds,
) {
  final completed =
      dueTaskIds.where((id) => completedTaskIds.contains(id)).length;
  return (completed: completed, total: dueTaskIds.length);
}
