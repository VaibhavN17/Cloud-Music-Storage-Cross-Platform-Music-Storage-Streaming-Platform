/// Typography system.
///
/// Type scale from UI/UX Design Brief §3.
/// Uses Inter font family with defined weights and sizes.
/// All text styles accessed through [AppTypography] — never create ad-hoc TextStyles.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  const AppTypography._();

  static String get _fontFamily => GoogleFonts.inter().fontFamily!;

  // ── Display ── (Now Playing title)
  static TextStyle display({Color? color}) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
    color: color,
  );

  static TextStyle displayLarge({Color? color}) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.5,
    color: color,
  );

  // ── Headings ──
  static TextStyle h1({Color? color}) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.3,
    color: color,
  );

  static TextStyle h2({Color? color}) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.2,
    color: color,
  );

  static TextStyle h3({Color? color}) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: color,
  );

  // ── Body ──
  static TextStyle body({Color? color}) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: color,
  );

  static TextStyle bodyMedium({Color? color}) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: color,
  );

  static TextStyle bodySemiBold({Color? color}) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.5,
    color: color,
  );

  static TextStyle bodySmall({Color? color}) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: color,
  );

  // ── Caption / Meta ──
  static TextStyle caption({Color? color}) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
    color: color,
  );

  static TextStyle captionLarge({Color? color}) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: color,
  );

  // ── Button ──
  static TextStyle button({Color? color}) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.2,
    color: color,
  );

  static TextStyle buttonSmall({Color? color}) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.2,
    color: color,
  );

  // ── Overline / Label ──
  static TextStyle overline({Color? color}) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 1.0,
    color: color,
  );
}
