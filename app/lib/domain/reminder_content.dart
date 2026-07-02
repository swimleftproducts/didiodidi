// Pure domain functions — no I/O, no Flutter dependencies.

/// Message for the morning reminder: every task due today, by title.
String morningMessage(List<String> dueTitles) {
  if (dueTitles.isEmpty) return 'No tasks due today.';
  return dueTitles.join(', ');
}

/// Message for the midday/evening reminders: tasks still not done.
String incompleteMessage(List<String> incompleteTitles) {
  if (incompleteTitles.isEmpty) return 'All done for today.';
  return 'Still to do: ${incompleteTitles.join(', ')}';
}
