// lib/core/theme/app_colors.dart
// Every color token from design.md section 3.
// Rule: no hex values appear anywhere else in the codebase — import this file instead.

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Light theme ("Chart") ──────────────────────────────────────────────────
  static const Color background = Color(0xFFF1F5F3); // pale chart-paper
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE3EBE8); // chips, inputs
  static const Color outline = Color(0xFFC3D1CD); // borders, dividers
  static const Color ink = Color(0xFF10262C); // primary text
  static const Color inkMuted = Color(0xFF4B6168); // secondary text
  static const Color primary = Color(0xFF0B7285); // Lagoon teal — buttons, nav
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFCDEBEF); // selected chip
  static const Color onPrimaryContainer = Color(0xFF06373F);

  // ── Dark theme ("Night chart") ─────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0C1A1F);
  static const Color darkSurface = Color(0xFF13262D);
  static const Color darkSurfaceVariant = Color(0xFF1C343C);
  static const Color darkOutline = Color(0xFF2D4A53);
  static const Color darkInk = Color(0xFFE6F0EE);
  static const Color darkInkMuted = Color(0xFF9DB4B9);
  static const Color darkPrimary = Color(0xFF5CC8D7);
  static const Color darkOnPrimary = Color(0xFF04252B);
  static const Color darkPrimaryContainer = Color(0xFF12474F);
  static const Color darkOnPrimaryContainer = Color(0xFFCDEBEF);

  // ── Semantic / map colors (same in both themes unless noted) ───────────────
  // userBlue: my location dot and the walked-path polyline.
  // Using this for decoration is not allowed (design.md section 3.5 — color carries meaning).
  static const Color userBlue = Color(0xFF2F6FED);

  // savedAmber: saved place pin fill only. Too pale for text — use icon on top.
  static const Color savedAmber = Color(0xFFE8A100);

  // destinationCoral: the chosen destination pin and the Stop tracking button.
  static const Color destinationCoral = Color(0xFFD9432B);

  // routeTeal: the route polyline. Different value per theme.
  static const Color routeTealLight = Color(0xFF0B7285);
  static const Color routeTealDark = Color(0xFF5CC8D7);

  static const Color success = Color(0xFF2E8B57);
  static const Color warning = Color(0xFFB7791F);
  static const Color errorLight = Color(0xFFC62F2F);
  static const Color errorDark = Color(0xFFF08A8A);

  // ── Nearby category colors (pin fill, white icon) ─────────────────────────
  static const Color catHospital = Color(0xFFD64550);
  static const Color catPharmacy = Color(0xFF2E8B57);
  static const Color catCafe = Color(0xFF8A5A3B);
  static const Color catRestaurant = Color(0xFFD9822B);
  static const Color catAtm = Color(0xFF5B5FC7);
  static const Color catFuel = Color(0xFF5F6B73);
}
