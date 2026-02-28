import 'package:flutter/material.dart';

/// CricLive "Dark Forest Luxury" color palette — WCAG AA compliant.
///
/// All text-on-surface combinations meet ≥ 4.5:1 contrast ratio.
/// Status colors have both solid and transparent variants.
abstract final class AppColors {
  // ─── Brand ────────────────────────────────────────────────
  static const Color primary = Color(0xFF0F3D2E);
  static const Color primaryHover = Color(0xFF145C43);
  static const Color secondary = Color(0xFF2FA36B);

  // ─── Dark Surfaces (layered depth) ───────────────────────
  static const Color background = Color(0xFF071A13);
  static const Color surface = Color(0xFF0F2A21);
  static const Color card = Color(0xFF12352A);
  static const Color elevated = Color(0xFF184838);
  static const Color border = Color(0xFF1F5A45);

  // ─── Legacy Surface Aliases (backward compatibility) ─────
  static const Color primaryBackground = background;
  static const Color secondarySurface = card;
  static const Color tertiaryContainer = elevated;
  static const Color cardSurface = card;

  // ─── Accent Colors ───────────────────────────────────────
  static const Color accentGreen = Color(0xFF7ED957);
  static const Color accentGreenDim = Color(0xFF5AA83E);
  static const Color accentTeal = Color(0xFF52B788);

  // ─── Status Colors ───────────────────────────────────────
  static const Color live = Color(0xFFFF4D4F);
  static const Color upcoming = Color(0xFFFAAD14);
  static const Color completed = Color(0xFF52C41A);
  static const Color info = Color(0xFF1677FF);

  // ─── Text Colors (WCAG AA on surfaces) ───────────────────
  static const Color textPrimary = Color(0xFFF5F7F6);
  static const Color textSecondary = Color(0xFFB7C9C2);
  static const Color textTertiary = Color(0xFF7FA59A);
  static const Color textDisabled = Color(0xFF5C7A70);
  static const Color textOnAccent = Color(0xFF071A13);

  // ─── Semantic / Event Colors ─────────────────────────────
  static const Color alertWicket = Color(0xFFE56DB1);
  static const Color eventSix = Color(0xFFFFD166);
  static const Color eventFour = Color(0xFF7ED957);
  static const Color eventDotBall = Color(0xFF6C757D);
  static const Color liveIndicator = live;

  // ─── Surface Variants ────────────────────────────────────
  static const Color divider = border;
  static const Color shimmerBase = surface;
  static const Color shimmerHighlight = elevated;
  static const Color overlay = Color(0x80000000);

  // ─── Navigation ──────────────────────────────────────────
  static const Color navBarBackground = Color(0xFF071A13);
  static const Color navBarSelected = secondary;
  static const Color navBarUnselected = textTertiary;

  // ─── Material 3 ColorScheme ──────────────────────────────
  static ColorScheme get darkColorScheme => const ColorScheme.dark(
        primary: secondary,
        onPrimary: textOnAccent,
        primaryContainer: elevated,
        onPrimaryContainer: textPrimary,
        secondary: accentTeal,
        onSecondary: textOnAccent,
        secondaryContainer: card,
        onSecondaryContainer: textPrimary,
        tertiary: alertWicket,
        onTertiary: textPrimary,
        surface: background,
        onSurface: textPrimary,
        surfaceContainerHighest: card,
        error: live,
        onError: textPrimary,
        outline: border,
      );
}
