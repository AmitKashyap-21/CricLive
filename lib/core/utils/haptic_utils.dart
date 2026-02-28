import 'package:flutter/services.dart';

/// Haptic feedback utility for key cricket events.
///
/// Provides subtle tactile feedback for significant moments:
/// wickets, sixes, and match starts.
abstract final class HapticUtils {
  /// Light impact — used for boundaries (fours).
  static Future<void> boundary() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium impact — used for sixes.
  static Future<void> six() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy impact — used for wickets.
  static Future<void> wicket() async {
    await HapticFeedback.heavyImpact();
  }

  /// Selection click — used for match start and navigation.
  static Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  /// Vibrate — used for important alerts.
  static Future<void> alert() async {
    await HapticFeedback.vibrate();
  }
}
