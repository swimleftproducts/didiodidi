// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snapshot_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SnapshotPayloadImpl _$$SnapshotPayloadImplFromJson(
  Map<String, dynamic> json,
) => _$SnapshotPayloadImpl(
  schemaVersion: (json['schema_version'] as num).toInt(),
  username: json['username'] as String,
  slug: json['slug'] as String,
  generatedAt: json['generated_at'] as String,
  window: SnapshotWindow.fromJson(json['window'] as Map<String, dynamic>),
  stats: SnapshotStats.fromJson(json['stats'] as Map<String, dynamic>),
  days: (json['days'] as List<dynamic>)
      .map((e) => SnapshotDay.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$SnapshotPayloadImplToJson(
  _$SnapshotPayloadImpl instance,
) => <String, dynamic>{
  'schema_version': instance.schemaVersion,
  'username': instance.username,
  'slug': instance.slug,
  'generated_at': instance.generatedAt,
  'window': instance.window.toJson(),
  'stats': instance.stats.toJson(),
  'days': instance.days.map((e) => e.toJson()).toList(),
};

_$SnapshotWindowImpl _$$SnapshotWindowImplFromJson(Map<String, dynamic> json) =>
    _$SnapshotWindowImpl(
      start: json['start'] as String,
      end: json['end'] as String,
    );

Map<String, dynamic> _$$SnapshotWindowImplToJson(
  _$SnapshotWindowImpl instance,
) => <String, dynamic>{'start': instance.start, 'end': instance.end};

_$SnapshotStatsImpl _$$SnapshotStatsImplFromJson(Map<String, dynamic> json) =>
    _$SnapshotStatsImpl(
      completed: (json['completed'] as num).toInt(),
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$$SnapshotStatsImplToJson(_$SnapshotStatsImpl instance) =>
    <String, dynamic>{'completed': instance.completed, 'total': instance.total};

_$SnapshotDayImpl _$$SnapshotDayImplFromJson(Map<String, dynamic> json) =>
    _$SnapshotDayImpl(
      date: json['date'] as String,
      weekday: (json['weekday'] as num).toInt(),
      tasks: (json['tasks'] as List<dynamic>)
          .map((e) => SnapshotTask.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$SnapshotDayImplToJson(_$SnapshotDayImpl instance) =>
    <String, dynamic>{
      'date': instance.date,
      'weekday': instance.weekday,
      'tasks': instance.tasks.map((e) => e.toJson()).toList(),
    };

_$SnapshotTaskImpl _$$SnapshotTaskImplFromJson(Map<String, dynamic> json) =>
    _$SnapshotTaskImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      completed: json['completed'] as bool,
      image: json['image'] as String?,
    );

Map<String, dynamic> _$$SnapshotTaskImplToJson(_$SnapshotTaskImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'completed': instance.completed,
      if (instance.image case final value?) 'image': value,
    };
