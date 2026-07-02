// Assembles the last-7-days SnapshotPayload for the share flow.
// See CLAUDE.md Section 7 (share flow) and Section 3 (1.8MB payload ceiling).
import 'dart:convert';
import 'dart:typed_data';

import '../data/daos/completion_dao.dart';
import '../data/daos/task_dao.dart';
import 'due_logic.dart';
import 'image_thumbnail.dart';
import 'slug.dart';
import 'snapshot_models.dart';

// DO Functions rejects bodies over ~2MB; stay comfortably under (~1.8 MiB).
const kMaxSnapshotPayloadBytes = 1887436;

typedef ImageBytesLoader = Future<Uint8List> Function(String imagePath);

class SnapshotTooLargeException implements Exception {
  final String message;
  SnapshotTooLargeException(this.message);

  @override
  String toString() => 'SnapshotTooLargeException: $message';
}

/// Builds the contract payload for the last 7 days (inclusive of [now]'s
/// date), embedding a downscaled thumbnail for any task with an image, and
/// enforces the <1.8MB ceiling by progressively dropping images (oldest/
/// last task first) before giving up with [SnapshotTooLargeException].
Future<SnapshotPayload> buildSnapshotPayload({
  required TaskDao taskDao,
  required CompletionDao completionDao,
  required String username,
  required String deviceSecretBase64,
  required DateTime now,
  required ImageBytesLoader loadImageBytes,
}) async {
  final end = DateTime(now.year, now.month, now.day);
  final start = end.subtract(const Duration(days: 6));

  final allTasks = await taskDao.getAllTasksWithWeekdays();
  final completions = await completionDao.getCompletionsForWindow(
    isoDate(start),
    isoDate(end),
  );
  final completedIdsByDate = <String, Set<String>>{};
  for (final c in completions) {
    completedIdsByDate.putIfAbsent(c.date, () => {}).add(c.taskId);
  }

  final days = <SnapshotDay>[];
  var totalDue = 0;
  var totalCompleted = 0;

  for (var offset = 0; offset < 7; offset++) {
    final date = start.add(Duration(days: offset));
    final dateStr = isoDate(date);
    final weekday = date.weekday;
    final completedIds = completedIdsByDate[dateStr] ?? const {};

    final dueToday = allTasks.where(
      (t) =>
          t.task.active &&
          t.weekdays.contains(weekday) &&
          taskStillActiveOn(t.task.endDate, date),
    );

    final tasks = <SnapshotTask>[];
    for (final t in dueToday) {
      String? image;
      final imagePath = t.task.imagePath;
      if (imagePath != null) {
        try {
          final bytes = await loadImageBytes(imagePath);
          image = encodeThumbnailDataUri(bytes);
        } catch (_) {
          // A missing/corrupt thumbnail shouldn't block the whole share.
          image = null;
        }
      }
      final completed = completedIds.contains(t.task.id);
      totalDue++;
      if (completed) totalCompleted++;
      tasks.add(SnapshotTask(
        id: t.task.id,
        title: t.task.title,
        description: t.task.description,
        completed: completed,
        image: image,
      ));
    }

    days.add(SnapshotDay(date: dateStr, weekday: weekday, tasks: tasks));
  }

  final normalizedUsername = username.toLowerCase();
  final payload = SnapshotPayload(
    schemaVersion: kSchemaVersion,
    username: normalizedUsername,
    slug: computeSlug(deviceSecretBase64, normalizedUsername),
    generatedAt: isoDate(end),
    window: SnapshotWindow(start: isoDate(start), end: isoDate(end)),
    stats: SnapshotStats(completed: totalCompleted, total: totalDue),
    days: days,
  );

  return enforceSnapshotSizeCeiling(payload);
}

int snapshotPayloadByteLength(SnapshotPayload payload) =>
    utf8.encode(jsonEncode(payload.toJson())).length;

/// Drops images (last task, last day first) until [payload] fits under
/// [kMaxSnapshotPayloadBytes], or throws if it still doesn't fit with none.
SnapshotPayload enforceSnapshotSizeCeiling(SnapshotPayload payload) {
  var current = payload;
  while (snapshotPayloadByteLength(current) > kMaxSnapshotPayloadBytes) {
    final location = _lastImageLocation(current);
    if (location == null) {
      throw SnapshotTooLargeException(
        'Snapshot is ${snapshotPayloadByteLength(current)} bytes even with '
        'all images removed (ceiling: $kMaxSnapshotPayloadBytes bytes)',
      );
    }
    current = _withImageDropped(current, location);
  }
  return current;
}

(int dayIndex, int taskIndex)? _lastImageLocation(SnapshotPayload payload) {
  for (var d = payload.days.length - 1; d >= 0; d--) {
    final tasks = payload.days[d].tasks;
    for (var t = tasks.length - 1; t >= 0; t--) {
      if (tasks[t].image != null) return (d, t);
    }
  }
  return null;
}

SnapshotPayload _withImageDropped(
  SnapshotPayload payload,
  (int, int) location,
) {
  final (dayIndex, taskIndex) = location;
  final days = [...payload.days];
  final tasks = [...days[dayIndex].tasks];
  tasks[taskIndex] = tasks[taskIndex].copyWith(image: null);
  days[dayIndex] = days[dayIndex].copyWith(tasks: tasks);
  return payload.copyWith(days: days);
}
