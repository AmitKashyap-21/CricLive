import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Brief color flash overlay for wicket events.
///
/// Overlays a translucent pink (#E56DB1) flash that fades in
/// and out over 300ms to signal a wicket has fallen.
class WicketFlash extends StatefulWidget {
  final Widget child;
  final bool trigger;

  const WicketFlash({
    super.key,
    required this.child,
    this.trigger = false,
  });

  @override
  State<WicketFlash> createState() => _WicketFlashState();
}

class _WicketFlashState extends State<WicketFlash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.35), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.35, end: 0.0), weight: 70),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void didUpdateWidget(covariant WicketFlash oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _opacity,
            builder: (context, _) {
              return IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.alertWicket
                        .withValues(alpha: _opacity.value),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
