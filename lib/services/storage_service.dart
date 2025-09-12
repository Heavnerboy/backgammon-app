import 'package:shared_preferences/shared_preferences.dart';

class StorageKeys {
  static const user = 'user';
  static const opponents = 'opponents';
  static const sessions = 'sessions';
  static const games = 'games';
}

class StorageService {
  final SharedPreferences prefs;
  StorageService(this.prefs);

  static Future<StorageService> create() async =>
      StorageService(await SharedPreferences.getInstance());

  String? getString(String key) => prefs.getString(key);
  Future<bool> setString(String key, String value) => prefs.setString(key, value);
  Future<bool> remove(String key) => prefs.remove(key);
}