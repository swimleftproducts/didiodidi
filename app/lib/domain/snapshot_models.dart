// Wire models for the app -> /ingest contract. Mirrors
// contract/schema/snapshot.schema.json exactly — snake_case on the wire,
// ISO weekday (1-7), YYYY-MM-DD date strings, full data: URIs for images.
// See CLAUDE.md Section 5.
//
// ignore_for_file: invalid_annotation_target
// (known false positive: @JsonKey on a freezed constructor parameter)
import 'package:freezed_annotation/freezed_annotation.dart';

part 'snapshot_models.freezed.dart';
part 'snapshot_models.g.dart';

const kSchemaVersion = 1;

@freezed
class SnapshotPayload with _$SnapshotPayload {
  const factory SnapshotPayload({
    @JsonKey(name: 'schema_version') required int schemaVersion,
    required String username,
    required String slug,
    @JsonKey(name: 'generated_at') required String generatedAt,
    required SnapshotWindow window,
    required SnapshotStats stats,
    required List<SnapshotDay> days,
  }) = _SnapshotPayload;

  factory SnapshotPayload.fromJson(Map<String, dynamic> json) =>
      _$SnapshotPayloadFromJson(json);
}

@freezed
class SnapshotWindow with _$SnapshotWindow {
  const factory SnapshotWindow({
    required String start,
    required String end,
  }) = _SnapshotWindow;

  factory SnapshotWindow.fromJson(Map<String, dynamic> json) =>
      _$SnapshotWindowFromJson(json);
}

@freezed
class SnapshotStats with _$SnapshotStats {
  const factory SnapshotStats({
    required int completed,
    required int total,
  }) = _SnapshotStats;

  factory SnapshotStats.fromJson(Map<String, dynamic> json) =>
      _$SnapshotStatsFromJson(json);
}

@freezed
class SnapshotDay with _$SnapshotDay {
  const factory SnapshotDay({
    required String date,
    required int weekday,
    required List<SnapshotTask> tasks,
  }) = _SnapshotDay;

  factory SnapshotDay.fromJson(Map<String, dynamic> json) =>
      _$SnapshotDayFromJson(json);
}

@freezed
class SnapshotTask with _$SnapshotTask {
  const factory SnapshotTask({
    required String id,
    required String title,
    required String description,
    required bool completed,
    @JsonKey(includeIfNull: false) String? image,
  }) = _SnapshotTask;

  factory SnapshotTask.fromJson(Map<String, dynamic> json) =>
      _$SnapshotTaskFromJson(json);
}
