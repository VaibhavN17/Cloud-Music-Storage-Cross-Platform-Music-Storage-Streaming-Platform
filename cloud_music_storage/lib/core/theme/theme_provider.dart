/// Theme mode provider using Riverpod.
///
/// Manages dark/light/system theme preference with local persistence.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/storage_keys.dart';
import '../storage/settings_storage.dart';

/// Provider for the current theme mode.
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
      final storage = ref.watch(settingsStorageProvider);
      return ThemeModeNotifier(storage);
    });

/// Notifier that persists theme mode changes to local storage.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._storage) : super(ThemeMode.system) {
    _loadThemeMode();
  }

  final SettingsStorage _storage;

  Future<void> _loadThemeMode() async {
    final saved = await _storage.getString(StorageKeys.themeMode);
    if (saved != null) {
      state = ThemeMode.values.firstWhere(
        (e) => e.name == saved,
        orElse: () => ThemeMode.system,
      );
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _storage.setString(StorageKeys.themeMode, mode.name);
  }

  void toggleTheme() {
    switch (state) {
      case ThemeMode.dark:
        setThemeMode(ThemeMode.light);
      case ThemeMode.light:
        setThemeMode(ThemeMode.system);
      case ThemeMode.system:
        setThemeMode(ThemeMode.dark);
    }
  }
}
