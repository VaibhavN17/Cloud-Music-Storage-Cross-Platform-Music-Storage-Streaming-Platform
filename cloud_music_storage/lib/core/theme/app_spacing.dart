/// Spacing system based on 8pt grid.
///
/// From UI/UX Design Brief §4.
/// Scale: 4, 8, 12, 16, 24, 32, 48, 64.
library;

class AppSpacing {
  const AppSpacing._();

  // ── Base Scale ──
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;
  static const double xxxxl = 64.0;

  // ── Semantic Aliases ──
  /// Horizontal screen padding: 16px mobile, 24px tablet/desktop.
  static const double screenPaddingMobile = 16.0;
  static const double screenPaddingDesktop = 24.0;

  /// Card internal padding.
  static const double cardPadding = 16.0;

  /// Section vertical gap.
  static const double sectionGap = 24.0;
  static const double sectionGapLarge = 32.0;

  /// List item spacing.
  static const double listItemGap = 8.0;

  /// Grid spacing.
  static const double gridGap = 12.0;
  static const double gridGapLarge = 16.0;
}
