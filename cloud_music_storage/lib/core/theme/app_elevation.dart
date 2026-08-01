/// Elevation and shadow tokens.
///
/// From UI/UX Design Brief §2: "Elevation via soft shadow + subtle blur, not heavy drop shadows."
library;

import 'package:flutter/material.dart';

class AppElevation {
  const AppElevation._();

  // ── Box Shadows ──
  static const List<BoxShadow> none = [];

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x1A000000), // 10% black
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> cardHover = [
    BoxShadow(
      color: Color(0x26000000), // 15% black
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> sheet = [
    BoxShadow(
      color: Color(0x33000000), // 20% black
      blurRadius: 24,
      offset: Offset(0, -4),
    ),
  ];

  static const List<BoxShadow> dialog = [
    BoxShadow(
      color: Color(0x40000000), // 25% black
      blurRadius: 32,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> miniPlayer = [
    BoxShadow(
      color: Color(0x26000000),
      blurRadius: 12,
      offset: Offset(0, -2),
    ),
  ];

  // ── For Dark Theme (softer shadows) ──
  static const List<BoxShadow> cardDark = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> sheetDark = [
    BoxShadow(
      color: Color(0x4D000000),
      blurRadius: 24,
      offset: Offset(0, -4),
    ),
  ];
}
