import 'package:flutter/material.dart';

import '../../core/theme/app_typography.dart';

/// Smoothly animating score counter.
///
/// When the value changes, the old number slides out and the new
/// number slides in with a quick 200ms transition.
class AnimatedScoreText extends StatelessWidget {
  final String score;
  final TextStyle? style;

  const AnimatedScoreText({
    super.key,
    required this.score,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );
      },
      child: Text(
        score,
        key: ValueKey<String>(score),
        style: style ?? AppTypography.scoreLarge,
      ),
    );
  }
}
