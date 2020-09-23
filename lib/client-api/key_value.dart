abstract class KeyValueStore {
  Future<bool> setString(Object key, String value);
  String getString(String key);
  Future<bool> clear();
}
