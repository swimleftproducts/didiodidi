import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:didiodidi/services/settings_repository.dart';
import '../test_fakes.dart';

void main() {
  late SettingsRepository repo;

  setUp(() {
    repo = SettingsRepository(InMemoryKeyValueStore());
  });

  test('api key defaults to null and round-trips', () async {
    expect(await repo.getApiKey(), isNull);
    await repo.setApiKey('sk-ant-test');
    expect(await repo.getApiKey(), 'sk-ant-test');
  });

  test('username defaults to null and round-trips', () async {
    expect(await repo.getUsername(), isNull);
    await repo.setUsername('alice');
    expect(await repo.getUsername(), 'alice');
  });

  test('reminder times default to 08:00 / 12:30 / 18:00', () async {
    expect(await repo.getMorningTime(), const TimeOfDay(hour: 8, minute: 0));
    expect(await repo.getMiddayTime(), const TimeOfDay(hour: 12, minute: 30));
    expect(await repo.getEveningTime(), const TimeOfDay(hour: 18, minute: 0));
  });

  test('reminder times round-trip through the underlying store', () async {
    final store = InMemoryKeyValueStore();
    final a = SettingsRepository(store);
    await a.setMorningTime(const TimeOfDay(hour: 7, minute: 15));
    await a.setMiddayTime(const TimeOfDay(hour: 13, minute: 5));
    await a.setEveningTime(const TimeOfDay(hour: 19, minute: 45));

    final b = SettingsRepository(store);
    expect(await b.getMorningTime(), const TimeOfDay(hour: 7, minute: 15));
    expect(await b.getMiddayTime(), const TimeOfDay(hour: 13, minute: 5));
    expect(await b.getEveningTime(), const TimeOfDay(hour: 19, minute: 45));
  });
}
