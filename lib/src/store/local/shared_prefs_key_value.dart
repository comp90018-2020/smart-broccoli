import 'package:shared_preferences/shared_preferences.dart';

import 'key_value.dart';

/// Key value store implemented using shared preferences
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
  Future<bool> setString(Object key, String value) {
    return _sharedPreferences.setString(key, value);
  }

  @override
  String getString(String key) {
    return _sharedPreferences.getString(key);
  }

  @override
  Future<bool> clear() {
    return _sharedPreferences.clear();
  }
}
