/// Settings storage service.
///
/// Wraps SharedPreferences/Hive for simple key-value settings persistence.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for the settings storage singleton.
final settingsStorageProvider = Provider<SettingsStorage>((ref) {
  return SettingsStorage();
});

/// Simple key-value storage for app settings and preferences.
class SettingsStorage {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ── String ──
  Future<String?> getString(String key) async {
    final prefs = await _preferences;
    return prefs.getString(key);
  }

  Future<void> setString(String key, String value) async {
    final prefs = await _preferences;
    await prefs.setString(key, value);
  }

  // ── Bool ──
  Future<bool?> getBool(String key) async {
    final prefs = await _preferences;
    return prefs.getBool(key);
  }

  Future<void> setBool(String key, {required bool value}) async {
    final prefs = await _preferences;
    await prefs.setBool(key, value);
  }

  // ── Int ──
  Future<int?> getInt(String key) async {
    final prefs = await _preferences;
    return prefs.getInt(key);
  }

  Future<void> setInt(String key, int value) async {
    final prefs = await _preferences;
    await prefs.setInt(key, value);
  }

  // ── Double ──
  Future<double?> getDouble(String key) async {
    final prefs = await _preferences;
    return prefs.getDouble(key);
  }

  Future<void> setDouble(String key, double value) async {
    final prefs = await _preferences;
    await prefs.setDouble(key, value);
  }

  // ── Remove ──
  Future<void> remove(String key) async {
    final prefs = await _preferences;
    await prefs.remove(key);
  }

  // ── Clear All ──
  Future<void> clearAll() async {
    final prefs = await _preferences;
    await prefs.clear();
  }
}
