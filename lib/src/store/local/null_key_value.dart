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
  Future<void> clear() async {
    _token = null;
  }

  @override
  dynamic getItem(String key) {
    if (key == 'token') return _token;
    return null;
  }

  @override
  Future<void> setItem(Object key, dynamic value) async {
    if (key == 'token') _token = value;
  }
}
