// lib/core/theme/app_text_styles.dart
// Text style tokens from design.md section 4.1.
// Fonts: Bricolage Grotesque (headings) and Figtree (body) are deferred to Phase 9.
// For now, fontFamily is left null so Flutter uses the system font.
// Phase 9 (T9.3) will add the google_fonts package and wire the families here.

import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  // ── Bricolage Grotesque styles (headings and display) ──────────────────────
  // display: splash title, large route distance/time
  static const TextStyle display = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 34,
    height: 40 / 34, // line height 40 sp
    letterSpacing: 0,
  );

  // headline: screen titles
  static const TextStyle headline = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 24,
    height: 30 / 24,
  );

  // title: card titles, place names
  static const TextStyle title = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 18,
    height: 24 / 18,
  );

  // ── Figtree styles (body, labels, data) ────────────────────────────────────
  // bodyLarge: main reading text
  static const TextStyle bodyLarge = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 24 / 16,
  );

  // body: secondary text, list subtitles
  static const TextStyle body = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 20 / 14,
  );

  // label: buttons, chips, tabs
  static const TextStyle label = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 20 / 14,
  );

  // caption: timestamps, accuracy, helper text
  static const TextStyle caption = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 12,
    height: 16 / 12,
  );

  // data: coordinates, distances, durations
  // tabularFigures keeps number-width stable so the UI doesn't jump when values update.
  static const TextStyle data = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 22 / 16,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}

// ── Spacing constants (from design.md section 5) ──────────────────────────────
// 4 dp grid: 4, 8, 12, 16, 24, 32, 48.
// Use these everywhere instead of raw double literals.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double screenPadding = 16; // edge padding for all screens
  static const double cardPadding = 16;   // internal card padding
  static const double cardGap = 12;       // space between cards
  static const double minTouchTarget = 48; // accessibility minimum
}
