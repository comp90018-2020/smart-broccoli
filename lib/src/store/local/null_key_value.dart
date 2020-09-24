import 'dart:io' show Platform;

import 'key_value.dart';

/// Dummy key value store for testing
/// Ignores all keys except 'token', the initial value of which is read from
/// an environment variable.
class NullKeyValueStore implements KeyValueStore {
  String _token = Platform.environment['TOKEN'];

  /// Constructor for external use
  NullKeyValueStore();

  @override
  Future<bool> clear() {
    return Future.sync(() => true);
  }

  @override
  String getString(String key) {
    if (key == 'token') return _token;
    return null;
  }

  @override
  Future<bool> setString(Object key, String value) {
    if (key == 'token') _token = value;
    return Future.sync(() => true);
  }
}
