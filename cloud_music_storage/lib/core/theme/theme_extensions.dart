/// Custom ThemeExtension classes for design tokens not covered by Material 3.
///
/// These extensions carry app-specific color semantics, spacing, and
/// component-level tokens through the theme system.
library;

import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Extended color tokens beyond Material's built-in scheme.
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.surfaceVariant,
    required this.surfaceElevated,
    required this.border,
    required this.accent,
    required this.success,
    required this.warning,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.miniPlayerBackground,
    required this.playerBackground,
  });

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color surfaceVariant;
  final Color surfaceElevated;
  final Color border;
  final Color accent;
  final Color success;
  final Color warning;
  final Color shimmerBase;
  final Color shimmerHighlight;
  final Color miniPlayerBackground;
  final Color playerBackground;

  /// Dark theme colors.
  static const dark = AppColorsExtension(
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    textTertiary: AppColors.darkTextTertiary,
    surfaceVariant: AppColors.darkSurfaceVariant,
    surfaceElevated: AppColors.darkSurfaceElevated,
    border: AppColors.darkBorder,
    accent: AppColors.accent,
    success: AppColors.success,
    warning: AppColors.warning,
    shimmerBase: AppColors.shimmerBaseDark,
    shimmerHighlight: AppColors.shimmerHighlightDark,
    miniPlayerBackground: AppColors.darkSurface,
    playerBackground: AppColors.darkBackground,
  );

  /// Light theme colors.
  static const light = AppColorsExtension(
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    textTertiary: AppColors.lightTextTertiary,
    surfaceVariant: AppColors.lightSurfaceVariant,
    surfaceElevated: AppColors.lightSurfaceElevated,
    border: AppColors.lightBorder,
    accent: AppColors.accent,
    success: AppColors.success,
    warning: AppColors.warning,
    shimmerBase: AppColors.shimmerBaseLight,
    shimmerHighlight: AppColors.shimmerHighlightLight,
    miniPlayerBackground: AppColors.lightSurface,
    playerBackground: AppColors.lightBackground,
  );

  @override
  AppColorsExtension copyWith({
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? surfaceVariant,
    Color? surfaceElevated,
    Color? border,
    Color? accent,
    Color? success,
    Color? warning,
    Color? shimmerBase,
    Color? shimmerHighlight,
    Color? miniPlayerBackground,
    Color? playerBackground,
  }) {
    return AppColorsExtension(
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      border: border ?? this.border,
      accent: accent ?? this.accent,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
      miniPlayerBackground: miniPlayerBackground ?? this.miniPlayerBackground,
      playerBackground: playerBackground ?? this.playerBackground,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      border: Color.lerp(border, other.border, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
      miniPlayerBackground: Color.lerp(miniPlayerBackground, other.miniPlayerBackground, t)!,
      playerBackground: Color.lerp(playerBackground, other.playerBackground, t)!,
    );
  }
}
