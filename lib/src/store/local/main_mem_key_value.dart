import 'key_value.dart';

/// Key value store in main memory implemented with a Map
/// Data stored in this class is non-persistent.
/// For testing purposes; not intended for use in production.
class MainMemKeyValueStore implements KeyValueStore {
  final Map<String, String> _map = Map();

  /// Constructor for external use
  /// Initial values may optionally be passed in with [init].
  MainMemKeyValueStore({Map<String, String> init}) {
    _map.addAll(init);
  }

  @override
  Future<bool> clear() {
    _map.clear();
    return Future.sync(() => true);
  }

  @override
  String getString(String key) {
    return _map[key];
  }

  @override
  Future<bool> setString(Object key, String value) {
    _map[key] = value;
    return Future.sync(() => true);
  }
}
