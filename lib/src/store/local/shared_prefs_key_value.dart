import 'package:shared_preferences/shared_preferences.dart';

import 'key_value.dart';

/// Key value store implemented using shared preferences
/// This class is only capable of storing strings. Attempting to store other
/// types will cause an exception.
class SharedPrefsKeyValueStore implements KeyValueStore {
  SharedPreferences _sharedPreferences;

  /// Constructor for internal use only
  SharedPrefsKeyValueStore._internal(this._sharedPreferences);

  /// Constructor for external use
  static Future<SharedPrefsKeyValueStore> create() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    return SharedPrefsKeyValueStore._internal(_prefs);
  }

  @override
  Future<void> setItem(Object key, dynamic value) async {
    await _sharedPreferences.setString(key, value);
  }

  @override
  dynamic getItem(String key) {
    return _sharedPreferences.getString(key);
  }

  @override
  Future<void> clear() async {
    await _sharedPreferences.clear();
  }
}
