import 'package:shared_preferences/shared_preferences.dart';
import 'package:fuzzy_broccoli/client-api/key_value.dart';

/// Key value store implemented using shared preferences
class SharedPrefsKeyValueStore implements KeyValueStore {
  SharedPreferences _sharedPreferences;

  /// Constructor for internal use only
  SharedPrefsKeyValueStore._internal(this._sharedPreferences);

  static Future<SharedPrefsKeyValueStore> create() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    return SharedPrefsKeyValueStore._internal(_prefs);
  }

  Future<bool> setString(Object key, String value) {
    return _sharedPreferences.setString(key, value);
  }

  String getString(String key) {
    return _sharedPreferences.getString(key);
  }

  Future<bool> clear() {
    return _sharedPreferences.clear();
  }
}
