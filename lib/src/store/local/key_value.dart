/// Interface for local cache management
/// Classes implementing this interface are not for direct use by the UI.
abstract class KeyValueStore {
  /// Store [value] in the cache associated with [key].
  Future<void> setString(String key, String value);

  /// Retrieve the value associated with [key] from the cache.
  String getString(String key);

  /// Remove all key-value pairs from the cache.
  Future<void> clear();
}
