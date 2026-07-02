import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Injectable string key-value storage, so services built on it can be
/// tested against a fake store instead of the real secure-storage plugin.
abstract class KeyValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

class SecureKeyValueStore implements KeyValueStore {
  final FlutterSecureStorage _storage;

  const SecureKeyValueStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
}
