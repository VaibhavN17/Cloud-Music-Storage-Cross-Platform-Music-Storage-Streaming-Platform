/// Application color palette.
///
/// All colors sourced from the UI/UX Design Brief §5.
/// Never use raw hex values in widgets — always reference [AppColors].
library;

import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // ── Primary & Accent ──
  static const Color primary = Color(0xFF2E6BFF);
  static const Color primaryLight = Color(0xFF5A8FFF);
  static const Color primaryDark = Color(0xFF1A4FCC);
  static const Color accent = Color(0xFFFF6B4A);
  static const Color accentLight = Color(0xFFFF8F73);
  static const Color accentDark = Color(0xFFCC5438);

  // ── Semantic ──
  static const Color success = Color(0xFF2ECC71);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF5A623);
  static const Color info = Color(0xFF3B82F6);

  // ── Dark Theme ──
  static const Color darkBackground = Color(0xFF0B0D12);
  static const Color darkSurface = Color(0xFF14171F);
  static const Color darkSurfaceVariant = Color(0xFF1C2029);
  static const Color darkSurfaceElevated = Color(0xFF22262F);
  static const Color darkBorder = Color(0xFF2A2E37);
  static const Color darkTextPrimary = Color(0xFFF5F6F8);
  static const Color darkTextSecondary = Color(0xA0F5F6F8); // 63% opacity
  static const Color darkTextTertiary = Color(0x66F5F6F8); // 40% opacity

  // ── Light Theme ──
  static const Color lightBackground = Color(0xFFFAFAFB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF5F5F7);
  static const Color lightSurfaceElevated = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightTextPrimary = Color(0xFF14171F);
  static const Color lightTextSecondary = Color(0xA014171F); // 63% opacity
  static const Color lightTextTertiary = Color(0x6614171F); // 40% opacity

  // ── Gradients ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2E6BFF), Color(0xFF5A8FFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkScrim = LinearGradient(
    colors: [Colors.transparent, Color(0xCC000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient playerGradient = LinearGradient(
    colors: [Color(0xFF0B0D12), Color(0xFF14171F), Color(0xFF0B0D12)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Shimmer ──
  static const Color shimmerBaseDark = Color(0xFF1C2029);
  static const Color shimmerHighlightDark = Color(0xFF2A2E37);
  static const Color shimmerBaseLight = Color(0xFFE5E7EB);
  static const Color shimmerHighlightLight = Color(0xFFF5F5F7);
}
