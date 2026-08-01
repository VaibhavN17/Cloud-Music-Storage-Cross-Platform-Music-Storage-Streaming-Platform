/// Convenience extension on [BuildContext] for accessing theme tokens.
///
/// Usage:
/// ```dart
/// final colors = context.appColors;
/// final textPrimary = colors.textPrimary;
/// ```
library;

import 'package:flutter/material.dart';

import '../theme/theme_extensions.dart';

extension ThemeContextExtension on BuildContext {
  /// Access the app's custom color extension.
  AppColorsExtension get appColors =>
      Theme.of(this).extension<AppColorsExtension>()!;

  /// Quick access to the Material ColorScheme.
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Quick access to the Material TextTheme.
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Whether the current theme is dark.
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Screen size helpers.
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;
  bool get isDesktop => screenWidth >= 1024;

  /// Safe area padding.
  EdgeInsets get safePadding => MediaQuery.paddingOf(this);
}
