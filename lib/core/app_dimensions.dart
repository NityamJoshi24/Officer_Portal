import 'package:flutter/material.dart';

extension CustomSizer on BuildContext {
  // Provides a horizontally measured size respective to width and viewportWidth
  double getWidth(double designWidth, {double viewportWidth = 360}) =>
      MediaQuery.of(this).size.width * (designWidth / viewportWidth);

  // Provides a vertically measured size respective to height and viewportHeight
  double getHeight(double designHeight, {double viewportHeight = 915}) =>
      MediaQuery.of(this).size.height * (designHeight / viewportHeight);

  // Provides width of the whole viewport
  double get deviceScreenWidth => MediaQuery.of(this).size.width;

  // Provides height of the whole viewport
  double get deviceScreenHeight => MediaQuery.of(this).size.height;

  // Provides a font size scaled to both axes
  double getFontSize(double fontSize,
      {double viewportHeight = 915, double viewportWidth = 360}) =>
      (((MediaQuery.of(this).size.height * fontSize) / viewportHeight) +
          ((MediaQuery.of(this).size.width * fontSize) / viewportWidth)) /
          2;
}

/// ─────────────────────────────────────────────────────────────
/// Named design-token constants (in dp, based on 360×915 frame)
/// Use these as the first argument to context.getWidth / getHeight
/// ─────────────────────────────────────────────────────────────
class AppDimens {
  AppDimens._();

  // ── Spacing ──────────────────────────────────────
  static const double spaceXS  = 6.0;
  static const double spaceS   = 10.0;
  static const double spaceM   = 16.0;
  static const double spaceL   = 24.0;
  static const double spaceXL  = 32.0;

  // ── Border radius ────────────────────────────────
  static const double radiusS    = 8.0;
  static const double radiusM    = 12.0;
  static const double radiusL    = 20.0;
  static const double radiusFull = 100.0;

  // ── Font sizes ───────────────────────────────────
  static const double fontXS  = 10.0;
  static const double fontS   = 12.0;
  static const double fontM   = 14.0;
  static const double fontL   = 16.0;
  static const double fontXL  = 20.0;
  static const double fontXXL = 28.0;

  // ── Component heights ────────────────────────────
  static const double appBarH      = 56.0;
  static const double bottomNavH   = 64.0;
  static const double statCardH    = 100.0;
  static const double surveyItemH  = 88.0;
  static const double filterChipH  = 38.0;
  static const double buttonH      = 52.0;
  static const double statusBarH   = 40.0;
  static const double badgeSize    = 36.0;

  // ── Icon sizes ───────────────────────────────────
  static const double iconS  = 16.0;
  static const double iconM  = 20.0;
  static const double iconL  = 24.0;
}