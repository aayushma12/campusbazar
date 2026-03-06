import 'package:flutter/material.dart';

class AppButtonTheme {
  AppButtonTheme._();

  static const Color primaryGreen = Colors.green;
  static const Color onPrimary = Colors.white;
  static const Color onSurface = Colors.black45;

  static final BorderRadius _radius = BorderRadius.circular(10);
  static const EdgeInsets _padding = EdgeInsets.symmetric(horizontal: 18, vertical: 14);
  // NOTE: Size.fromHeight(48) implies an infinite min-width, which breaks buttons in Row/Flex.
  static const Size _minimumSize = Size(0, 48);

  static final TextStyle _labelStyle = const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  static ElevatedButtonThemeData get elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all(_minimumSize),
        padding: WidgetStateProperty.all(_padding),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: _radius),
        ),
        textStyle: WidgetStateProperty.all(_labelStyle),
        elevation: WidgetStateProperty.resolveWith<double>((states) {
          if (states.contains(WidgetState.disabled)) return 0;
          if (states.contains(WidgetState.pressed)) return 1;
          return 2;
        }),
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) return primaryGreen.withOpacity(0.45);
          if (states.contains(WidgetState.pressed)) return Colors.green.shade700;
          if (states.contains(WidgetState.hovered)) return Colors.green.shade600;
          return primaryGreen;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) return onPrimary.withOpacity(0.9);
          return onPrimary;
        }),
        overlayColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.pressed)) return Colors.white.withOpacity(0.12);
          if (states.contains(WidgetState.hovered)) return Colors.white.withOpacity(0.06);
          return Colors.transparent;
        }),
      ),
    );
  }

  static FilledButtonThemeData get filledButtonTheme {
    return FilledButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all(_minimumSize),
        padding: WidgetStateProperty.all(_padding),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: _radius),
        ),
        textStyle: WidgetStateProperty.all(_labelStyle),
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) return primaryGreen.withOpacity(0.45);
          if (states.contains(WidgetState.pressed)) return Colors.green.shade700;
          if (states.contains(WidgetState.hovered)) return Colors.green.shade600;
          return primaryGreen;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) return onPrimary.withOpacity(0.9);
          return onPrimary;
        }),
        overlayColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.pressed)) return Colors.white.withOpacity(0.12);
          if (states.contains(WidgetState.hovered)) return Colors.white.withOpacity(0.06);
          return Colors.transparent;
        }),
      ),
    );
  }

  static OutlinedButtonThemeData get outlinedButtonTheme {
    return OutlinedButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all(_minimumSize),
        padding: WidgetStateProperty.all(_padding),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: _radius),
        ),
        textStyle: WidgetStateProperty.all(_labelStyle),
        side: WidgetStateProperty.resolveWith<BorderSide>((states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(color: primaryGreen.withOpacity(0.4), width: 1.2);
          }
          if (states.contains(WidgetState.pressed)) {
            return BorderSide(color: Colors.green.shade700, width: 1.4);
          }
          return const BorderSide(color: primaryGreen, width: 1.3);
        }),
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.pressed)) return Colors.green.withOpacity(0.08);
          if (states.contains(WidgetState.hovered)) return Colors.green.withOpacity(0.04);
          return Colors.white;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) return Colors.green.withOpacity(0.45);
          if (states.contains(WidgetState.pressed)) return Colors.green.shade700;
          return primaryGreen;
        }),
      ),
    );
  }

  static TextButtonThemeData get textButtonTheme {
    return TextButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: _radius),
        ),
        textStyle: WidgetStateProperty.all(_labelStyle),
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) return Colors.green.withOpacity(0.45);
          if (states.contains(WidgetState.pressed)) return Colors.green.shade700;
          return primaryGreen;
        }),
        overlayColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.pressed)) return Colors.green.withOpacity(0.10);
          if (states.contains(WidgetState.hovered)) return Colors.green.withOpacity(0.06);
          return Colors.transparent;
        }),
      ),
    );
  }

  static ButtonStyle primary() => elevatedButtonTheme.style!;

  static ButtonStyle secondary() => outlinedButtonTheme.style!;
}
