/// Animation duration and curve constants.
///
/// From UI/UX Design Brief §11:
/// - 150–250ms for micro-interactions
/// - 300–400ms for screen transitions
/// - Standard ease-in-out; spring curves for playback feedback
library;

import 'package:flutter/material.dart';

class AppAnimations {
  const AppAnimations._();

  // ── Durations ──
  static const Duration micro = Duration(milliseconds: 150);
  static const Duration short = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration long = Duration(milliseconds: 500);
  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Duration sheetTransition = Duration(milliseconds: 400);

  // ── Curves ──
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve decelerate = Curves.decelerate;
  static const Curve accelerate = Curves.easeIn;
  static const Curve emphasizedDecelerate = Curves.easeOutCubic;
  static const Curve emphasizedAccelerate = Curves.easeInCubic;

  /// Spring curve for playback control feedback (play/pause morph, like heart pop).
  static const Curve spring = Curves.elasticOut;
  static const Curve bounce = Curves.bounceOut;

  /// Page transition curve.
  static const Curve pageCurve = Curves.easeInOutCubic;

  // ── Delays ──
  static const Duration staggerDelay = Duration(milliseconds: 50);
  static const Duration splashDuration = Duration(seconds: 2);
}
