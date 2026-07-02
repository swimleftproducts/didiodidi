// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'snapshot_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SnapshotPayload _$SnapshotPayloadFromJson(Map<String, dynamic> json) {
  return _SnapshotPayload.fromJson(json);
}

/// @nodoc
mixin _$SnapshotPayload {
  @JsonKey(name: 'schema_version')
  int get schemaVersion => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;
  @JsonKey(name: 'generated_at')
  String get generatedAt => throw _privateConstructorUsedError;
  SnapshotWindow get window => throw _privateConstructorUsedError;
  SnapshotStats get stats => throw _privateConstructorUsedError;
  List<SnapshotDay> get days => throw _privateConstructorUsedError;

  /// Serializes this SnapshotPayload to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SnapshotPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnapshotPayloadCopyWith<SnapshotPayload> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnapshotPayloadCopyWith<$Res> {
  factory $SnapshotPayloadCopyWith(
    SnapshotPayload value,
    $Res Function(SnapshotPayload) then,
  ) = _$SnapshotPayloadCopyWithImpl<$Res, SnapshotPayload>;
  @useResult
  $Res call({
    @JsonKey(name: 'schema_version') int schemaVersion,
    String username,
    String slug,
    @JsonKey(name: 'generated_at') String generatedAt,
    SnapshotWindow window,
    SnapshotStats stats,
    List<SnapshotDay> days,
  });

  $SnapshotWindowCopyWith<$Res> get window;
  $SnapshotStatsCopyWith<$Res> get stats;
}

/// @nodoc
class _$SnapshotPayloadCopyWithImpl<$Res, $Val extends SnapshotPayload>
    implements $SnapshotPayloadCopyWith<$Res> {
  _$SnapshotPayloadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SnapshotPayload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? schemaVersion = null,
    Object? username = null,
    Object? slug = null,
    Object? generatedAt = null,
    Object? window = null,
    Object? stats = null,
    Object? days = null,
  }) {
    return _then(
      _value.copyWith(
            schemaVersion: null == schemaVersion
                ? _value.schemaVersion
                : schemaVersion // ignore: cast_nullable_to_non_nullable
                      as int,
            username: null == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String,
            slug: null == slug
                ? _value.slug
                : slug // ignore: cast_nullable_to_non_nullable
                      as String,
            generatedAt: null == generatedAt
                ? _value.generatedAt
                : generatedAt // ignore: cast_nullable_to_non_nullable
                      as String,
            window: null == window
                ? _value.window
                : window // ignore: cast_nullable_to_non_nullable
                      as SnapshotWindow,
            stats: null == stats
                ? _value.stats
                : stats // ignore: cast_nullable_to_non_nullable
                      as SnapshotStats,
            days: null == days
                ? _value.days
                : days // ignore: cast_nullable_to_non_nullable
                      as List<SnapshotDay>,
          )
          as $Val,
    );
  }

  /// Create a copy of SnapshotPayload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnapshotWindowCopyWith<$Res> get window {
    return $SnapshotWindowCopyWith<$Res>(_value.window, (value) {
      return _then(_value.copyWith(window: value) as $Val);
    });
  }

  /// Create a copy of SnapshotPayload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnapshotStatsCopyWith<$Res> get stats {
    return $SnapshotStatsCopyWith<$Res>(_value.stats, (value) {
      return _then(_value.copyWith(stats: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SnapshotPayloadImplCopyWith<$Res>
    implements $SnapshotPayloadCopyWith<$Res> {
  factory _$$SnapshotPayloadImplCopyWith(
    _$SnapshotPayloadImpl value,
    $Res Function(_$SnapshotPayloadImpl) then,
  ) = __$$SnapshotPayloadImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'schema_version') int schemaVersion,
    String username,
    String slug,
    @JsonKey(name: 'generated_at') String generatedAt,
    SnapshotWindow window,
    SnapshotStats stats,
    List<SnapshotDay> days,
  });

  @override
  $SnapshotWindowCopyWith<$Res> get window;
  @override
  $SnapshotStatsCopyWith<$Res> get stats;
}

/// @nodoc
class __$$SnapshotPayloadImplCopyWithImpl<$Res>
    extends _$SnapshotPayloadCopyWithImpl<$Res, _$SnapshotPayloadImpl>
    implements _$$SnapshotPayloadImplCopyWith<$Res> {
  __$$SnapshotPayloadImplCopyWithImpl(
    _$SnapshotPayloadImpl _value,
    $Res Function(_$SnapshotPayloadImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SnapshotPayload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? schemaVersion = null,
    Object? username = null,
    Object? slug = null,
    Object? generatedAt = null,
    Object? window = null,
    Object? stats = null,
    Object? days = null,
  }) {
    return _then(
      _$SnapshotPayloadImpl(
        schemaVersion: null == schemaVersion
            ? _value.schemaVersion
            : schemaVersion // ignore: cast_nullable_to_non_nullable
                  as int,
        username: null == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String,
        slug: null == slug
            ? _value.slug
            : slug // ignore: cast_nullable_to_non_nullable
                  as String,
        generatedAt: null == generatedAt
            ? _value.generatedAt
            : generatedAt // ignore: cast_nullable_to_non_nullable
                  as String,
        window: null == window
            ? _value.window
            : window // ignore: cast_nullable_to_non_nullable
                  as SnapshotWindow,
        stats: null == stats
            ? _value.stats
            : stats // ignore: cast_nullable_to_non_nullable
                  as SnapshotStats,
        days: null == days
            ? _value._days
            : days // ignore: cast_nullable_to_non_nullable
                  as List<SnapshotDay>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SnapshotPayloadImpl implements _SnapshotPayload {
  const _$SnapshotPayloadImpl({
    @JsonKey(name: 'schema_version') required this.schemaVersion,
    required this.username,
    required this.slug,
    @JsonKey(name: 'generated_at') required this.generatedAt,
    required this.window,
    required this.stats,
    required final List<SnapshotDay> days,
  }) : _days = days;

  factory _$SnapshotPayloadImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnapshotPayloadImplFromJson(json);

  @override
  @JsonKey(name: 'schema_version')
  final int schemaVersion;
  @override
  final String username;
  @override
  final String slug;
  @override
  @JsonKey(name: 'generated_at')
  final String generatedAt;
  @override
  final SnapshotWindow window;
  @override
  final SnapshotStats stats;
  final List<SnapshotDay> _days;
  @override
  List<SnapshotDay> get days {
    if (_days is EqualUnmodifiableListView) return _days;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_days);
  }

  @override
  String toString() {
    return 'SnapshotPayload(schemaVersion: $schemaVersion, username: $username, slug: $slug, generatedAt: $generatedAt, window: $window, stats: $stats, days: $days)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnapshotPayloadImpl &&
            (identical(other.schemaVersion, schemaVersion) ||
                other.schemaVersion == schemaVersion) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.generatedAt, generatedAt) ||
                other.generatedAt == generatedAt) &&
            (identical(other.window, window) || other.window == window) &&
            (identical(other.stats, stats) || other.stats == stats) &&
            const DeepCollectionEquality().equals(other._days, _days));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    schemaVersion,
    username,
    slug,
    generatedAt,
    window,
    stats,
    const DeepCollectionEquality().hash(_days),
  );

  /// Create a copy of SnapshotPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnapshotPayloadImplCopyWith<_$SnapshotPayloadImpl> get copyWith =>
      __$$SnapshotPayloadImplCopyWithImpl<_$SnapshotPayloadImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SnapshotPayloadImplToJson(this);
  }
}

abstract class _SnapshotPayload implements SnapshotPayload {
  const factory _SnapshotPayload({
    @JsonKey(name: 'schema_version') required final int schemaVersion,
    required final String username,
    required final String slug,
    @JsonKey(name: 'generated_at') required final String generatedAt,
    required final SnapshotWindow window,
    required final SnapshotStats stats,
    required final List<SnapshotDay> days,
  }) = _$SnapshotPayloadImpl;

  factory _SnapshotPayload.fromJson(Map<String, dynamic> json) =
      _$SnapshotPayloadImpl.fromJson;

  @override
  @JsonKey(name: 'schema_version')
  int get schemaVersion;
  @override
  String get username;
  @override
  String get slug;
  @override
  @JsonKey(name: 'generated_at')
  String get generatedAt;
  @override
  SnapshotWindow get window;
  @override
  SnapshotStats get stats;
  @override
  List<SnapshotDay> get days;

  /// Create a copy of SnapshotPayload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnapshotPayloadImplCopyWith<_$SnapshotPayloadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SnapshotWindow _$SnapshotWindowFromJson(Map<String, dynamic> json) {
  return _SnapshotWindow.fromJson(json);
}

/// @nodoc
mixin _$SnapshotWindow {
  String get start => throw _privateConstructorUsedError;
  String get end => throw _privateConstructorUsedError;

  /// Serializes this SnapshotWindow to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SnapshotWindow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnapshotWindowCopyWith<SnapshotWindow> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnapshotWindowCopyWith<$Res> {
  factory $SnapshotWindowCopyWith(
    SnapshotWindow value,
    $Res Function(SnapshotWindow) then,
  ) = _$SnapshotWindowCopyWithImpl<$Res, SnapshotWindow>;
  @useResult
  $Res call({String start, String end});
}

/// @nodoc
class _$SnapshotWindowCopyWithImpl<$Res, $Val extends SnapshotWindow>
    implements $SnapshotWindowCopyWith<$Res> {
  _$SnapshotWindowCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SnapshotWindow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? start = null, Object? end = null}) {
    return _then(
      _value.copyWith(
            start: null == start
                ? _value.start
                : start // ignore: cast_nullable_to_non_nullable
                      as String,
            end: null == end
                ? _value.end
                : end // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SnapshotWindowImplCopyWith<$Res>
    implements $SnapshotWindowCopyWith<$Res> {
  factory _$$SnapshotWindowImplCopyWith(
    _$SnapshotWindowImpl value,
    $Res Function(_$SnapshotWindowImpl) then,
  ) = __$$SnapshotWindowImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String start, String end});
}

/// @nodoc
class __$$SnapshotWindowImplCopyWithImpl<$Res>
    extends _$SnapshotWindowCopyWithImpl<$Res, _$SnapshotWindowImpl>
    implements _$$SnapshotWindowImplCopyWith<$Res> {
  __$$SnapshotWindowImplCopyWithImpl(
    _$SnapshotWindowImpl _value,
    $Res Function(_$SnapshotWindowImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SnapshotWindow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? start = null, Object? end = null}) {
    return _then(
      _$SnapshotWindowImpl(
        start: null == start
            ? _value.start
            : start // ignore: cast_nullable_to_non_nullable
                  as String,
        end: null == end
            ? _value.end
            : end // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SnapshotWindowImpl implements _SnapshotWindow {
  const _$SnapshotWindowImpl({required this.start, required this.end});

  factory _$SnapshotWindowImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnapshotWindowImplFromJson(json);

  @override
  final String start;
  @override
  final String end;

  @override
  String toString() {
    return 'SnapshotWindow(start: $start, end: $end)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnapshotWindowImpl &&
            (identical(other.start, start) || other.start == start) &&
            (identical(other.end, end) || other.end == end));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, start, end);

  /// Create a copy of SnapshotWindow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnapshotWindowImplCopyWith<_$SnapshotWindowImpl> get copyWith =>
      __$$SnapshotWindowImplCopyWithImpl<_$SnapshotWindowImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SnapshotWindowImplToJson(this);
  }
}

abstract class _SnapshotWindow implements SnapshotWindow {
  const factory _SnapshotWindow({
    required final String start,
    required final String end,
  }) = _$SnapshotWindowImpl;

  factory _SnapshotWindow.fromJson(Map<String, dynamic> json) =
      _$SnapshotWindowImpl.fromJson;

  @override
  String get start;
  @override
  String get end;

  /// Create a copy of SnapshotWindow
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnapshotWindowImplCopyWith<_$SnapshotWindowImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SnapshotStats _$SnapshotStatsFromJson(Map<String, dynamic> json) {
  return _SnapshotStats.fromJson(json);
}

/// @nodoc
mixin _$SnapshotStats {
  int get completed => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;

  /// Serializes this SnapshotStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SnapshotStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnapshotStatsCopyWith<SnapshotStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnapshotStatsCopyWith<$Res> {
  factory $SnapshotStatsCopyWith(
    SnapshotStats value,
    $Res Function(SnapshotStats) then,
  ) = _$SnapshotStatsCopyWithImpl<$Res, SnapshotStats>;
  @useResult
  $Res call({int completed, int total});
}

/// @nodoc
class _$SnapshotStatsCopyWithImpl<$Res, $Val extends SnapshotStats>
    implements $SnapshotStatsCopyWith<$Res> {
  _$SnapshotStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SnapshotStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? completed = null, Object? total = null}) {
    return _then(
      _value.copyWith(
            completed: null == completed
                ? _value.completed
                : completed // ignore: cast_nullable_to_non_nullable
                      as int,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SnapshotStatsImplCopyWith<$Res>
    implements $SnapshotStatsCopyWith<$Res> {
  factory _$$SnapshotStatsImplCopyWith(
    _$SnapshotStatsImpl value,
    $Res Function(_$SnapshotStatsImpl) then,
  ) = __$$SnapshotStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int completed, int total});
}

/// @nodoc
class __$$SnapshotStatsImplCopyWithImpl<$Res>
    extends _$SnapshotStatsCopyWithImpl<$Res, _$SnapshotStatsImpl>
    implements _$$SnapshotStatsImplCopyWith<$Res> {
  __$$SnapshotStatsImplCopyWithImpl(
    _$SnapshotStatsImpl _value,
    $Res Function(_$SnapshotStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SnapshotStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? completed = null, Object? total = null}) {
    return _then(
      _$SnapshotStatsImpl(
        completed: null == completed
            ? _value.completed
            : completed // ignore: cast_nullable_to_non_nullable
                  as int,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SnapshotStatsImpl implements _SnapshotStats {
  const _$SnapshotStatsImpl({required this.completed, required this.total});

  factory _$SnapshotStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnapshotStatsImplFromJson(json);

  @override
  final int completed;
  @override
  final int total;

  @override
  String toString() {
    return 'SnapshotStats(completed: $completed, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnapshotStatsImpl &&
            (identical(other.completed, completed) ||
                other.completed == completed) &&
            (identical(other.total, total) || other.total == total));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, completed, total);

  /// Create a copy of SnapshotStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnapshotStatsImplCopyWith<_$SnapshotStatsImpl> get copyWith =>
      __$$SnapshotStatsImplCopyWithImpl<_$SnapshotStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SnapshotStatsImplToJson(this);
  }
}

abstract class _SnapshotStats implements SnapshotStats {
  const factory _SnapshotStats({
    required final int completed,
    required final int total,
  }) = _$SnapshotStatsImpl;

  factory _SnapshotStats.fromJson(Map<String, dynamic> json) =
      _$SnapshotStatsImpl.fromJson;

  @override
  int get completed;
  @override
  int get total;

  /// Create a copy of SnapshotStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnapshotStatsImplCopyWith<_$SnapshotStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SnapshotDay _$SnapshotDayFromJson(Map<String, dynamic> json) {
  return _SnapshotDay.fromJson(json);
}

/// @nodoc
mixin _$SnapshotDay {
  String get date => throw _privateConstructorUsedError;
  int get weekday => throw _privateConstructorUsedError;
  List<SnapshotTask> get tasks => throw _privateConstructorUsedError;

  /// Serializes this SnapshotDay to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SnapshotDay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnapshotDayCopyWith<SnapshotDay> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnapshotDayCopyWith<$Res> {
  factory $SnapshotDayCopyWith(
    SnapshotDay value,
    $Res Function(SnapshotDay) then,
  ) = _$SnapshotDayCopyWithImpl<$Res, SnapshotDay>;
  @useResult
  $Res call({String date, int weekday, List<SnapshotTask> tasks});
}

/// @nodoc
class _$SnapshotDayCopyWithImpl<$Res, $Val extends SnapshotDay>
    implements $SnapshotDayCopyWith<$Res> {
  _$SnapshotDayCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SnapshotDay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? weekday = null,
    Object? tasks = null,
  }) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            weekday: null == weekday
                ? _value.weekday
                : weekday // ignore: cast_nullable_to_non_nullable
                      as int,
            tasks: null == tasks
                ? _value.tasks
                : tasks // ignore: cast_nullable_to_non_nullable
                      as List<SnapshotTask>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SnapshotDayImplCopyWith<$Res>
    implements $SnapshotDayCopyWith<$Res> {
  factory _$$SnapshotDayImplCopyWith(
    _$SnapshotDayImpl value,
    $Res Function(_$SnapshotDayImpl) then,
  ) = __$$SnapshotDayImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String date, int weekday, List<SnapshotTask> tasks});
}

/// @nodoc
class __$$SnapshotDayImplCopyWithImpl<$Res>
    extends _$SnapshotDayCopyWithImpl<$Res, _$SnapshotDayImpl>
    implements _$$SnapshotDayImplCopyWith<$Res> {
  __$$SnapshotDayImplCopyWithImpl(
    _$SnapshotDayImpl _value,
    $Res Function(_$SnapshotDayImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SnapshotDay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? weekday = null,
    Object? tasks = null,
  }) {
    return _then(
      _$SnapshotDayImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        weekday: null == weekday
            ? _value.weekday
            : weekday // ignore: cast_nullable_to_non_nullable
                  as int,
        tasks: null == tasks
            ? _value._tasks
            : tasks // ignore: cast_nullable_to_non_nullable
                  as List<SnapshotTask>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SnapshotDayImpl implements _SnapshotDay {
  const _$SnapshotDayImpl({
    required this.date,
    required this.weekday,
    required final List<SnapshotTask> tasks,
  }) : _tasks = tasks;

  factory _$SnapshotDayImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnapshotDayImplFromJson(json);

  @override
  final String date;
  @override
  final int weekday;
  final List<SnapshotTask> _tasks;
  @override
  List<SnapshotTask> get tasks {
    if (_tasks is EqualUnmodifiableListView) return _tasks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tasks);
  }

  @override
  String toString() {
    return 'SnapshotDay(date: $date, weekday: $weekday, tasks: $tasks)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnapshotDayImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.weekday, weekday) || other.weekday == weekday) &&
            const DeepCollectionEquality().equals(other._tasks, _tasks));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    date,
    weekday,
    const DeepCollectionEquality().hash(_tasks),
  );

  /// Create a copy of SnapshotDay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnapshotDayImplCopyWith<_$SnapshotDayImpl> get copyWith =>
      __$$SnapshotDayImplCopyWithImpl<_$SnapshotDayImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SnapshotDayImplToJson(this);
  }
}

abstract class _SnapshotDay implements SnapshotDay {
  const factory _SnapshotDay({
    required final String date,
    required final int weekday,
    required final List<SnapshotTask> tasks,
  }) = _$SnapshotDayImpl;

  factory _SnapshotDay.fromJson(Map<String, dynamic> json) =
      _$SnapshotDayImpl.fromJson;

  @override
  String get date;
  @override
  int get weekday;
  @override
  List<SnapshotTask> get tasks;

  /// Create a copy of SnapshotDay
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnapshotDayImplCopyWith<_$SnapshotDayImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SnapshotTask _$SnapshotTaskFromJson(Map<String, dynamic> json) {
  return _SnapshotTask.fromJson(json);
}

/// @nodoc
mixin _$SnapshotTask {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  bool get completed => throw _privateConstructorUsedError;
  @JsonKey(includeIfNull: false)
  String? get image => throw _privateConstructorUsedError;

  /// Serializes this SnapshotTask to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SnapshotTask
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnapshotTaskCopyWith<SnapshotTask> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnapshotTaskCopyWith<$Res> {
  factory $SnapshotTaskCopyWith(
    SnapshotTask value,
    $Res Function(SnapshotTask) then,
  ) = _$SnapshotTaskCopyWithImpl<$Res, SnapshotTask>;
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    bool completed,
    @JsonKey(includeIfNull: false) String? image,
  });
}

/// @nodoc
class _$SnapshotTaskCopyWithImpl<$Res, $Val extends SnapshotTask>
    implements $SnapshotTaskCopyWith<$Res> {
  _$SnapshotTaskCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SnapshotTask
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? completed = null,
    Object? image = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            completed: null == completed
                ? _value.completed
                : completed // ignore: cast_nullable_to_non_nullable
                      as bool,
            image: freezed == image
                ? _value.image
                : image // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SnapshotTaskImplCopyWith<$Res>
    implements $SnapshotTaskCopyWith<$Res> {
  factory _$$SnapshotTaskImplCopyWith(
    _$SnapshotTaskImpl value,
    $Res Function(_$SnapshotTaskImpl) then,
  ) = __$$SnapshotTaskImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    bool completed,
    @JsonKey(includeIfNull: false) String? image,
  });
}

/// @nodoc
class __$$SnapshotTaskImplCopyWithImpl<$Res>
    extends _$SnapshotTaskCopyWithImpl<$Res, _$SnapshotTaskImpl>
    implements _$$SnapshotTaskImplCopyWith<$Res> {
  __$$SnapshotTaskImplCopyWithImpl(
    _$SnapshotTaskImpl _value,
    $Res Function(_$SnapshotTaskImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SnapshotTask
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? completed = null,
    Object? image = freezed,
  }) {
    return _then(
      _$SnapshotTaskImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        completed: null == completed
            ? _value.completed
            : completed // ignore: cast_nullable_to_non_nullable
                  as bool,
        image: freezed == image
            ? _value.image
            : image // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SnapshotTaskImpl implements _SnapshotTask {
  const _$SnapshotTaskImpl({
    required this.id,
    required this.title,
    required this.description,
    required this.completed,
    @JsonKey(includeIfNull: false) this.image,
  });

  factory _$SnapshotTaskImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnapshotTaskImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final bool completed;
  @override
  @JsonKey(includeIfNull: false)
  final String? image;

  @override
  String toString() {
    return 'SnapshotTask(id: $id, title: $title, description: $description, completed: $completed, image: $image)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnapshotTaskImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.completed, completed) ||
                other.completed == completed) &&
            (identical(other.image, image) || other.image == image));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, title, description, completed, image);

  /// Create a copy of SnapshotTask
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnapshotTaskImplCopyWith<_$SnapshotTaskImpl> get copyWith =>
      __$$SnapshotTaskImplCopyWithImpl<_$SnapshotTaskImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SnapshotTaskImplToJson(this);
  }
}

abstract class _SnapshotTask implements SnapshotTask {
  const factory _SnapshotTask({
    required final String id,
    required final String title,
    required final String description,
    required final bool completed,
    @JsonKey(includeIfNull: false) final String? image,
  }) = _$SnapshotTaskImpl;

  factory _SnapshotTask.fromJson(Map<String, dynamic> json) =
      _$SnapshotTaskImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  bool get completed;
  @override
  @JsonKey(includeIfNull: false)
  String? get image;

  /// Create a copy of SnapshotTask
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnapshotTaskImplCopyWith<_$SnapshotTaskImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
