import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'key_value_store.dart';

/// User-configurable settings: the Anthropic API key, username, the device
/// secret used for the share slug (CLAUDE.md Section 9), and the three
/// daily reminder times. Backed by an injectable [KeyValueStore] so it can
/// be tested without the real secure-storage plugin.
class SettingsRepository {
  static const _kApiKey = 'anthropic_api_key';
  static const _kUsername = 'username';
  static const _kDeviceSecret = 'device_secret';
  static const _kMorning = 'reminder_morning';
  static const _kMidday = 'reminder_midday';
  static const _kEvening = 'reminder_evening';

  static const defaultMorningTime = TimeOfDay(hour: 8, minute: 0);
  static const defaultMiddayTime = TimeOfDay(hour: 12, minute: 30);
  static const defaultEveningTime = TimeOfDay(hour: 18, minute: 0);

  final KeyValueStore _store;

  SettingsRepository(this._store);

  Future<String?> getApiKey() => _store.read(_kApiKey);
  Future<void> setApiKey(String value) => _store.write(_kApiKey, value);

  Future<String?> getUsername() => _store.read(_kUsername);
  Future<void> setUsername(String value) => _store.write(_kUsername, value);

  /// Returns the 32-byte device secret (base64), generating and persisting
  /// one on first call. Never regenerated afterward — the share slug is
  /// derived from this value, so changing it would break existing links.
  Future<String> getOrCreateDeviceSecret() async {
    final existing = await _store.read(_kDeviceSecret);
    if (existing != null) return existing;
    final secret = _generateDeviceSecret();
    await _store.write(_kDeviceSecret, secret);
    return secret;
  }

  String _generateDeviceSecret() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64.encode(bytes);
  }

  Future<TimeOfDay> getMorningTime() => _getTime(_kMorning, defaultMorningTime);
  Future<TimeOfDay> getMiddayTime() => _getTime(_kMidday, defaultMiddayTime);
  Future<TimeOfDay> getEveningTime() => _getTime(_kEvening, defaultEveningTime);

  Future<void> setMorningTime(TimeOfDay time) => _setTime(_kMorning, time);
  Future<void> setMiddayTime(TimeOfDay time) => _setTime(_kMidday, time);
  Future<void> setEveningTime(TimeOfDay time) => _setTime(_kEvening, time);

  Future<TimeOfDay> _getTime(String key, TimeOfDay fallback) async {
    final raw = await _store.read(key);
    if (raw == null) return fallback;
    final parts = raw.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> _setTime(String key, TimeOfDay time) => _store.write(
        key,
        '${time.hour.toString().padLeft(2, '0')}:'
            '${time.minute.toString().padLeft(2, '0')}',
      );
}
