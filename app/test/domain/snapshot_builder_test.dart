import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:didiodidi/data/database.dart';
import 'package:didiodidi/domain/slug.dart';
import 'package:didiodidi/domain/snapshot_builder.dart';
import 'package:didiodidi/domain/snapshot_models.dart';

AppDatabase _db() => AppDatabase(NativeDatabase.memory());

Uint8List _pngBytes() {
  final image = img.Image(width: 20, height: 10);
  img.fill(image, color: img.ColorRgb8(10, 20, 30));
  return Uint8List.fromList(img.encodePng(image));
}

Future<Uint8List> _failingLoader(String path) async =>
    throw Exception('no such file: $path');

void main() {
  late AppDatabase db;
  setUp(() => db = _db());
  tearDown(() => db.close());

  // A fixed Wednesday so the 7-day window is deterministic in tests.
  final now = DateTime(2026, 7, 1); // Wednesday, ISO weekday 3

  group('buildSnapshotPayload', () {
    test('window covers the 7 days ending on `now`', () async {
      final payload = await buildSnapshotPayload(
        taskDao: db.taskDao,
        completionDao: db.completionDao,
        username: 'alice',
        deviceSecretBase64: base64.encode(List.generate(32, (_) => 1)),
        now: now,
        loadImageBytes: _failingLoader,
      );

      expect(payload.window.start, '2026-06-25');
      expect(payload.window.end, '2026-07-01');
      expect(payload.generatedAt, '2026-07-01');
      expect(payload.days.length, 7);
      expect(payload.days.first.date, '2026-06-25');
      expect(payload.days.last.date, '2026-07-01');
    });

    test('includes only tasks due on each day, with correct completion', () async {
      final mwfId = await db.taskDao.insertTask(
        title: 'MWF stretch',
        description: '3x10',
        weekdays: [1, 3, 5],
      );
      await db.taskDao.insertTask(
        title: 'Weekend only',
        description: '',
        weekdays: [6, 7],
      );
      await db.completionDao.toggleCompletion(mwfId, '2026-07-01');

      final payload = await buildSnapshotPayload(
        taskDao: db.taskDao,
        completionDao: db.completionDao,
        username: 'alice',
        deviceSecretBase64: base64.encode(List.generate(32, (_) => 1)),
        now: now,
        loadImageBytes: _failingLoader,
      );

      final wednesday = payload.days.firstWhere((d) => d.date == '2026-07-01');
      expect(wednesday.tasks.map((t) => t.title), ['MWF stretch']);
      expect(wednesday.tasks.first.completed, isTrue);

      final saturday = payload.days.firstWhere((d) => d.date == '2026-06-27');
      expect(saturday.tasks.map((t) => t.title), ['Weekend only']);
      expect(saturday.tasks.first.completed, isFalse);

      expect(payload.stats.total, greaterThan(0));
      expect(payload.stats.completed, 1);
    });

    test('username is lowercased and slug matches computeSlug', () async {
      final secret = base64.encode(List.generate(32, (_) => 7));
      final payload = await buildSnapshotPayload(
        taskDao: db.taskDao,
        completionDao: db.completionDao,
        username: 'Alice',
        deviceSecretBase64: secret,
        now: now,
        loadImageBytes: _failingLoader,
      );

      expect(payload.username, 'alice');
      expect(payload.slug, computeSlug(secret, 'alice'));
    });

    test('embeds a downscaled JPEG data URI for tasks with an image', () async {
      final taskId = await db.taskDao.insertTask(
        title: 'With photo',
        description: '',
        weekdays: [3],
      );
      await (db.update(db.tasks)..where((t) => t.id.equals(taskId)))
          .write(const TasksCompanion(imagePath: Value('/fake/path.png')));

      final payload = await buildSnapshotPayload(
        taskDao: db.taskDao,
        completionDao: db.completionDao,
        username: 'alice',
        deviceSecretBase64: base64.encode(List.generate(32, (_) => 1)),
        now: now,
        loadImageBytes: (path) async {
          expect(path, '/fake/path.png');
          return _pngBytes();
        },
      );

      final task = payload.days
          .firstWhere((d) => d.date == '2026-07-01')
          .tasks
          .first;
      expect(task.image, startsWith('data:image/jpeg;base64,'));
    });

    test('a failing image loader leaves the task image null, not a crash', () async {
      final taskId = await db.taskDao.insertTask(
        title: 'Broken photo',
        description: '',
        weekdays: [3],
      );
      await (db.update(db.tasks)..where((t) => t.id.equals(taskId)))
          .write(const TasksCompanion(imagePath: Value('/missing.png')));

      final payload = await buildSnapshotPayload(
        taskDao: db.taskDao,
        completionDao: db.completionDao,
        username: 'alice',
        deviceSecretBase64: base64.encode(List.generate(32, (_) => 1)),
        now: now,
        loadImageBytes: _failingLoader,
      );

      final task = payload.days
          .firstWhere((d) => d.date == '2026-07-01')
          .tasks
          .first;
      expect(task.image, isNull);
    });
  });

  group('enforceSnapshotSizeCeiling', () {
    SnapshotPayload payloadWithImages(List<String?> images) {
      return SnapshotPayload(
        schemaVersion: kSchemaVersion,
        username: 'alice',
        slug: 'a3b4c5d6e7',
        generatedAt: '2026-07-01',
        window: const SnapshotWindow(start: '2026-06-25', end: '2026-07-01'),
        stats: const SnapshotStats(completed: 0, total: 0),
        days: [
          SnapshotDay(
            date: '2026-07-01',
            weekday: 3,
            tasks: [
              for (var i = 0; i < images.length; i++)
                SnapshotTask(
                  id: 'task-$i',
                  title: 'Task $i',
                  description: '',
                  completed: false,
                  image: images[i],
                ),
            ],
          ),
        ],
      );
    }

    test('leaves a payload under the ceiling untouched', () {
      final payload = payloadWithImages([null, null]);
      expect(identical(enforceSnapshotSizeCeiling(payload), payload) ||
          enforceSnapshotSizeCeiling(payload) == payload, isTrue);
    });

    test('drops images one at a time until under the ceiling', () {
      // Each "image" is ~1.2MB of base64 — two of them exceed the ceiling,
      // one does not.
      final bigImage = 'data:image/jpeg;base64,${'A' * 1200000}';
      final payload = payloadWithImages([bigImage, bigImage]);

      final result = enforceSnapshotSizeCeiling(payload);

      expect(snapshotPayloadByteLength(result), lessThanOrEqualTo(kMaxSnapshotPayloadBytes));
      final remainingImages = result.days.first.tasks.where((t) => t.image != null);
      expect(remainingImages.length, lessThan(2));
    });

    test('throws SnapshotTooLargeException when still too big with no images', () {
      final hugeDescription = 'x' * (kMaxSnapshotPayloadBytes + 1000);
      final payload = payloadWithImages([]).copyWith(
        days: [
          SnapshotDay(
            date: '2026-07-01',
            weekday: 3,
            tasks: [
              SnapshotTask(
                id: 't',
                title: 'Task',
                description: hugeDescription,
                completed: false,
              ),
            ],
          ),
        ],
      );

      expect(
        () => enforceSnapshotSizeCeiling(payload),
        throwsA(isA<SnapshotTooLargeException>()),
      );
    });
  });
}
