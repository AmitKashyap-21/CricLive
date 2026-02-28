import 'dart:async';
import 'dart:ui';

/// Lifecycle-safe auto-refresh timer utility.
///
/// Features:
///   • Prevents duplicate timers (calls [stop] before starting)
///   • Null-safe disposal
///   • Lightweight — no state management overhead
///
/// Usage:
/// ```dart
/// final _refresh = AutoRefreshController();
/// _refresh.start(interval: Duration(seconds: 30), onRefresh: _fetch);
/// // ...
/// _refresh.stop(); // in dispose()
/// ```
class AutoRefreshController {
  Timer? _timer;

  /// Start periodic refresh. Stops any existing timer first.
  void start({
    required Duration interval,
    required VoidCallback onRefresh,
  }) {
    stop();
    _timer = Timer.periodic(interval, (_) => onRefresh());
  }

  /// Stop the timer and release resources.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Whether a timer is currently active.
  bool get isActive => _timer?.isActive ?? false;
}
