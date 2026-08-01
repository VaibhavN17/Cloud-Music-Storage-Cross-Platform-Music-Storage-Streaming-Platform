/// Corner radius tokens.
///
/// From UI/UX Design Brief §2.
/// Cards: 12px, Sheets/Modals: 24px, Pills/Avatars/Play: full-round.
library;

import 'package:flutter/material.dart';

class AppRadius {
  const AppRadius._();

  // ── Raw Values ──
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 999.0;

  // ── BorderRadius Shortcuts ──
  static final BorderRadius cardRadius = BorderRadius.circular(md);
  static final BorderRadius sheetRadius = BorderRadius.circular(xl);
  static final BorderRadius pillRadius = BorderRadius.circular(full);
  static final BorderRadius buttonRadius = BorderRadius.circular(md);
  static final BorderRadius inputRadius = BorderRadius.circular(md);
  static final BorderRadius chipRadius = BorderRadius.circular(sm);
  static final BorderRadius imageRadius = BorderRadius.circular(sm);

  /// Top-only radius for bottom sheets and modals.
  static const BorderRadius sheetTopRadius = BorderRadius.only(
    topLeft: Radius.circular(xl),
    topRight: Radius.circular(xl),
  );
}
