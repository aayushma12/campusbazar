import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../../../core/providers/shake_theme_provider.dart';
import '../../../../core/providers/theme_mode_provider.dart';

class ShakeThemeListener extends ConsumerStatefulWidget {
  final Widget child;

  const ShakeThemeListener({super.key, required this.child});

  @override
  ConsumerState<ShakeThemeListener> createState() => _ShakeThemeListenerState();
}

class _ShakeThemeListenerState extends ConsumerState<ShakeThemeListener> {
  StreamSubscription<UserAccelerometerEvent>? _accelerometerSub;

  DateTime _lastToggleAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastSpikeAt = DateTime.fromMillisecondsSinceEpoch(0);
  int _shakeCount = 0;

  // Tuned for physical devices to reduce false positives.
  static const double _shakeThreshold = 3.2;
  static const Duration _sequenceWindow = Duration(milliseconds: 900);
  static const Duration _spikeGap = Duration(milliseconds: 120);
  static const Duration _cooldown = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _setupSubscription());
  }

  @override
  void didUpdateWidget(covariant ShakeThemeListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    _setupSubscription();
  }

  @override
  void dispose() {
    _accelerometerSub?.cancel();
    super.dispose();
  }

  void _setupSubscription() {
    if (kIsWeb) {
      _accelerometerSub?.cancel();
      _accelerometerSub = null;
      return;
    }

    final enabled = ref.read(shakeToToggleProvider);
    if (!enabled) {
      _accelerometerSub?.cancel();
      _accelerometerSub = null;
      return;
    }

    _accelerometerSub ??= userAccelerometerEventStream().listen(_onAccelerometerEvent);
  }

  Future<void> _onAccelerometerEvent(UserAccelerometerEvent event) async {
    if (!mounted) return;
    if (!ref.read(shakeToToggleProvider)) return;

    final now = DateTime.now();
    if (now.difference(_lastToggleAt) < _cooldown) return;

    final magnitude = math.sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
    if (magnitude < _shakeThreshold) return;

    final previousSpikeAt = _lastSpikeAt;
    // Ignore immediate repeated spikes within a very short burst.
    if (now.difference(previousSpikeAt) < _spikeGap) return;
    _lastSpikeAt = now;

    if (_shakeCount == 0) {
      _shakeCount = 1;
    } else if (now.difference(previousSpikeAt) <= _sequenceWindow) {
      _shakeCount += 1;
    } else {
      _shakeCount = 1;
    }

    // Require 2 strong motions close together to avoid accidental triggers.
    if (_shakeCount < 2) return;

    _shakeCount = 0;
    _lastToggleAt = now;

    final current = ref.read(themeModeProvider);
    final isDark = current == ThemeMode.dark;
    await ref.read(themeModeProvider.notifier).toggleDarkMode(!isDark);

    if (!mounted) return;

    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 1400),
        content: Text(!isDark ? 'Dark Mode Activated 🌙' : 'Light Mode Activated ☀️'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Keep subscription in sync with setting changes without rebuilding app tree.
    ref.listen<bool>(shakeToToggleProvider, (previous, next) => _setupSubscription());
    return widget.child;
  }
}
