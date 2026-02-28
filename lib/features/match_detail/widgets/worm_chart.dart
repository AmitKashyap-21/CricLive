import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';

/// Worm chart using CustomPainter with smooth Bezier curves,
/// interactive scrubbing, and drag tooltips.
///
/// Normalization: y = height × (1 − (value − min) / (max − min))
class WormChart extends StatefulWidget {
  final List<double> teamAData;
  final List<double> teamBData;
  final String teamALabel;
  final String teamBLabel;
  final Color teamAColor;
  final Color teamBColor;

  const WormChart({
    super.key,
    required this.teamAData,
    required this.teamBData,
    this.teamALabel = 'Team A',
    this.teamBLabel = 'Team B',
    this.teamAColor = AppColors.accentGreen,
    this.teamBColor = AppColors.accentTeal,
  });

  @override
  State<WormChart> createState() => _WormChartState();
}

class _WormChartState extends State<WormChart> {
  double? _touchX;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingLg,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingLg),
            child: Row(
              children: [
                Text('Run Comparison', style: AppTypography.headlineSmall),
                const Spacer(),
                _legendDot(widget.teamALabel, widget.teamAColor),
                const SizedBox(width: 12),
                _legendDot(widget.teamBLabel, widget.teamBColor),
              ],
            ),
          ),

          // Chart
          SizedBox(
            height: AppConstants.chartHeight,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() => _touchX = details.localPosition.dx);
              },
              onPanEnd: (_) {
                setState(() => _touchX = null);
              },
              child: CustomPaint(
                size: Size.infinite,
                painter: _WormChartPainter(
                  teamAData: widget.teamAData,
                  teamBData: widget.teamBData,
                  teamAColor: widget.teamAColor,
                  teamBColor: widget.teamBColor,
                  touchX: _touchX,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppConstants.spacingSm),

          // Over labels
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingLg,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0', style: AppTypography.labelSmall),
                Text('5', style: AppTypography.labelSmall),
                Text('10', style: AppTypography.labelSmall),
                Text('15', style: AppTypography.labelSmall),
                Text('20', style: AppTypography.labelSmall),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: AppConstants.spacingMd,
            ),
            child: Center(
              child: Text('Overs', style: AppTypography.labelSmall),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(color: color),
        ),
      ],
    );
  }
}

class _WormChartPainter extends CustomPainter {
  final List<double> teamAData;
  final List<double> teamBData;
  final Color teamAColor;
  final Color teamBColor;
  final double? touchX;

  _WormChartPainter({
    required this.teamAData,
    required this.teamBData,
    required this.teamAColor,
    required this.teamBColor,
    this.touchX,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (teamAData.isEmpty && teamBData.isEmpty) return;

    final allValues = [...teamAData, ...teamBData];
    final maxVal =
        allValues.reduce((a, b) => a > b ? a : b).clamp(1.0, double.infinity);
    final minVal = 0.0;

    final padding = const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8);
    final chartWidth = size.width - padding.left - padding.right;
    final chartHeight = size.height - padding.top - padding.bottom;

    // Draw grid lines
    final gridPaint = Paint()
      ..color = AppColors.divider.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 4; i++) {
      final y = padding.top + chartHeight * (i / 4);
      canvas.drawLine(
        Offset(padding.left, y),
        Offset(size.width - padding.right, y),
        gridPaint,
      );
    }

    // Draw team lines
    _drawLine(canvas, size, teamAData, teamAColor, maxVal, minVal,
        chartWidth, chartHeight, padding);
    _drawLine(canvas, size, teamBData, teamBColor, maxVal, minVal,
        chartWidth, chartHeight, padding);

    // Draw tooltip on touch
    if (touchX != null) {
      _drawTooltip(canvas, size, maxVal, minVal, chartWidth, chartHeight,
          padding);
    }
  }

  void _drawLine(
    Canvas canvas,
    Size size,
    List<double> data,
    Color color,
    double maxVal,
    double minVal,
    double chartWidth,
    double chartHeight,
    EdgeInsets padding,
  ) {
    if (data.length < 2) return;

    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = padding.left + (i / (data.length - 1)) * chartWidth;
      final y = padding.top +
          chartHeight * (1 - (data[i] - minVal) / (maxVal - minVal));
      points.add(Offset(x, y));
    }

    // Draw filled area
    final fillPath = Path()..moveTo(points.first.dx, padding.top + chartHeight);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(points.last.dx, padding.top + chartHeight);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.2),
          color.withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Draw smooth Bezier curve
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = AppConstants.chartStrokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final cp1x = points[i - 1].dx + (points[i].dx - points[i - 1].dx) / 3;
      final cp1y = points[i - 1].dy;
      final cp2x = points[i].dx - (points[i].dx - points[i - 1].dx) / 3;
      final cp2y = points[i].dy;
      path.cubicTo(cp1x, cp1y, cp2x, cp2y, points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, linePaint);

    // Draw dots at each data point
    final dotPaint = Paint()..color = color;
    for (final p in points) {
      canvas.drawCircle(p, AppConstants.chartDotRadius, dotPaint);
    }
  }

  void _drawTooltip(
    Canvas canvas,
    Size size,
    double maxVal,
    double minVal,
    double chartWidth,
    double chartHeight,
    EdgeInsets padding,
  ) {
    // Vertical line
    final linePaint = Paint()
      ..color = AppColors.textTertiary.withValues(alpha: 0.4)
      ..strokeWidth = 1;

    final clampedX = touchX!.clamp(padding.left, size.width - padding.right);
    canvas.drawLine(
      Offset(clampedX, padding.top),
      Offset(clampedX, padding.top + chartHeight),
      linePaint,
    );

    // Calculate index
    final progress =
        ((clampedX - padding.left) / chartWidth).clamp(0.0, 1.0);

    String tooltip = '';
    if (teamAData.isNotEmpty) {
      final idx =
          (progress * (teamAData.length - 1)).round().clamp(0, teamAData.length - 1);
      tooltip = '${teamAData[idx].toInt()}';
    }
    if (teamBData.isNotEmpty) {
      final idx =
          (progress * (teamBData.length - 1)).round().clamp(0, teamBData.length - 1);
      tooltip += ' / ${teamBData[idx].toInt()}';
    }

    // Draw tooltip box
    final textPainter = TextPainter(
      text: TextSpan(
        text: tooltip,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final boxWidth = textPainter.width + 16;
    final boxHeight = textPainter.height + 8;
    final boxX = (clampedX - boxWidth / 2).clamp(0.0, size.width - boxWidth);

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(boxX, padding.top - boxHeight - 4, boxWidth, boxHeight),
      const Radius.circular(6),
    );

    canvas.drawRRect(
      rrect,
      Paint()..color = AppColors.tertiaryContainer,
    );

    textPainter.paint(
      canvas,
      Offset(boxX + 8, padding.top - boxHeight - 4 + 4),
    );
  }

  @override
  bool shouldRepaint(covariant _WormChartPainter oldDelegate) {
    return oldDelegate.touchX != touchX ||
        oldDelegate.teamAData != teamAData ||
        oldDelegate.teamBData != teamBData;
  }
}
