import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final shakeToToggleProvider = NotifierProvider<ShakeToToggleNotifier, bool>(
  ShakeToToggleNotifier.new,
);

class ShakeToToggleNotifier extends Notifier<bool> {
  static const _boxName = 'settingsBox';
  static const _key = 'shake_to_toggle_dark_mode';

  @override
  bool build() {
    _restore();
    return true;
  }

  Future<void> _restore() async {
    try {
      final box = await _openBox();
      final raw = box.get(_key);
      if (raw is bool) {
        state = raw;
      }
    } catch (_) {}
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    try {
      final box = await _openBox();
      await box.put(_key, enabled);
    } catch (_) {}
  }

  Future<Box> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) return Hive.box(_boxName);
    return Hive.openBox(_boxName);
  }
}
