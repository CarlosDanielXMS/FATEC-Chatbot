import 'package:shared_preferences/shared_preferences.dart';
import 'local_storage.dart';

class SharedPrefsLocalStorage implements LocalStorage {
  SharedPrefsLocalStorage(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<void> writeBool({
    required String key,
    required bool value,
  }) async {
    await _prefs.setBool(key, value);
  }

  @override
  bool? readBool(String key) {
    return _prefs.getBool(key);
  }
}