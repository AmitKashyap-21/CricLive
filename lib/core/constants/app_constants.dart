/// CricLive design and behavior constants.
abstract final class AppConstants {
  // ─── Spacing ─────────────────────────────────────────────
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 24.0;
  static const double spacingXxl = 32.0;

  // ─── Border Radius ──────────────────────────────────────
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusFull = 999.0;

  // ─── Touch Targets ──────────────────────────────────────
  static const double minTouchTarget = 48.0;
  static const double navBarHeight = 56.0;

  // ─── Animation Durations ────────────────────────────────
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animMedium = Duration(milliseconds: 250);
  static const Duration animSlow = Duration(milliseconds: 300);
  static const Duration animPulse = Duration(milliseconds: 600);

  // ─── Bento Grid ─────────────────────────────────────────
  static const int bentoCrossAxisCount = 4;
  static const double bentoMainSpacing = 8.0;
  static const double bentoCrossSpacing = 8.0;

  // ─── Match Update ───────────────────────────────────────
  /// Target perceived update latency.
  static const Duration updateLatencyTarget = Duration(milliseconds: 500);

  /// Mock WebSocket event interval range.
  static const Duration mockEventMinInterval = Duration(seconds: 3);
  static const Duration mockEventMaxInterval = Duration(seconds: 8);

  // ─── Scorecard ──────────────────────────────────────────
  static const double scorecardHorizontalPadding = 16.0;
  static const double scorecardVerticalPadding = 8.0;
  static const double playerAvatarSize = 36.0;

  // ─── Chart ──────────────────────────────────────────────
  static const double chartHeight = 200.0;
  static const double chartStrokeWidth = 2.5;
  static const double chartDotRadius = 4.0;
}
