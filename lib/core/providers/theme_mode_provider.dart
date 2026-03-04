import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _boxName = 'settingsBox';
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    _restore();
    return ThemeMode.light;
  }

  Future<void> _restore() async {
    try {
      final box = await _openBox();
      final raw = box.get(_key)?.toString();
      if (raw == null || raw.isEmpty) return;

      if (raw == ThemeMode.dark.name) {
        state = ThemeMode.dark;
      } else if (raw == ThemeMode.system.name) {
        state = ThemeMode.system;
      } else {
        state = ThemeMode.light;
      }
    } catch (_) {}
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      final box = await _openBox();
      await box.put(_key, mode.name);
    } catch (_) {}
  }

  Future<void> toggleDarkMode(bool enabled) async {
    await setThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
  }

  Future<Box> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) return Hive.box(_boxName);
    return Hive.openBox(_boxName);
  }
}
