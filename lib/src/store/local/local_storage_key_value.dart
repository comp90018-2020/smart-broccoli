import 'package:smart_broccoli/src/store/local/key_value.dart';

import 'package:localstorage/localstorage.dart';

class LocalStorageKeyValue extends KeyValueStore {
  LocalStorage _localStorage;

  LocalStorageKeyValue(this._localStorage);

  @override
  Future<void> clear() {
    return _localStorage.clear();
  }

  @override
  dynamic getItem(String key) {
    return _localStorage.getItem(key);
  }

  @override
  Future<void> setItem(String key, dynamic value) {
    return _localStorage.setItem(key, value);
  }
}
