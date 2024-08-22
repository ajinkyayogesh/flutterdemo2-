import 'package:shared_preferences/shared_preferences.dart';

class SharedprefranceController
{
  static SharedPreferences? _preferences;

  // Initialize SharedPreferences instance
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Save a String value
  static Future<void> saveString(String key, String value) async {
    await _preferences?.setString(key, value);
  }

  // Retrieve a String value
  static String? getString(String key) {
    return _preferences?.getString(key);
  }

  // Save an int value
  static Future<void> saveInt(String key, int value) async {
    await _preferences?.setInt(key, value);
  }

  // Retrieve an int value
  static int? getInt(String key) {
    return _preferences?.getInt(key);
  }

  // Save a boolean value
  static Future<void> saveBoolean(String key, bool value) async {
    await _preferences?.setBool(key, value);
  }

  // Retrieve a boolean value
  static bool? getBoolean(String key) {
    return _preferences?.getBool(key);
  }

  // Save a double value
  static Future<void> saveDouble(String key, double value) async {
    await _preferences?.setDouble(key, value);
  }

  // Retrieve a double value
  static double? getDouble(String key) {
    return _preferences?.getDouble(key);
  }

  // Remove a specific key
  static Future<void> remove(String key) async {
    await _preferences?.remove(key);
  }

  // Clear all preferences
  static Future<void> clear() async {
    await _preferences?.clear();
  }
}