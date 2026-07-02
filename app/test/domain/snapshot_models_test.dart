// Drift guard (CLAUDE.md Section 5): every shared fixture must round-trip
// fixture -> fromJson -> toJson == fixture with no field drift.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:didiodidi/domain/snapshot_models.dart';

void main() {
  final fixturesDir = Directory('../contract/fixtures');
  final fixtureFiles = fixturesDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.json'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  group('SnapshotPayload round-trip against contract fixtures', () {
    test('fixtures directory is not empty', () {
      expect(fixtureFiles, isNotEmpty);
    });

    for (final file in fixtureFiles) {
      test('${file.uri.pathSegments.last} round-trips exactly', () {
        final fixtureJson =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        final payload = SnapshotPayload.fromJson(fixtureJson);
        final roundTripped = payload.toJson();
        expect(roundTripped, equals(fixtureJson));
      });
    }
  });

  test('schema_version constant matches contract', () {
    expect(kSchemaVersion, 1);
  });
}
