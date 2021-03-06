import 'key_value.dart';

/// Key value store in main memory implemented with a Map
/// Data stored in this class is non-persistent.
/// For testing purposes; not intended for use in production.
class MainMemKeyValueStore implements KeyValueStore {
  final Map<String, String> _map = Map();

  /// Constructor for external use
  /// Initial values may optionally be passed in with [init].
  MainMemKeyValueStore({Map<String, String> init}) {
    if (init != null) _map.addAll(init);
  }

  @override
  Future<void> clear() async {
    _map.clear();
  }

  @override
  String getString(String key) {
    return _map[key];
  }

  @override
  Future<void> setString(Object key, String value) async {
    _map[key] = value;
  }
}
