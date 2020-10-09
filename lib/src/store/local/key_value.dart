/// Interface for local cache management
/// Classes implementing this interface are not for direct use by the UI.
abstract class KeyValueStore {
  /// Store [value] in the cache associated with [key].
  Future<void> setString(Object key, String value);

  /// Retrieve the value associated with [key] from the cache.
  String getString(String key);

  Future<void> setItem(String key, dynamic value);

  dynamic getItem(String key);

  /// Remove all key-value pairs from the cache.
  Future<void> clear();
}
