import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/match.dart';

/// Bowling stats row in the scorecard.
class BowlingRow extends StatelessWidget {
  final BowlerInnings bowler;

  const BowlingRow({super.key, required this.bowler});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.scorecardHorizontalPadding,
        vertical: AppConstants.scorecardVerticalPadding,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Bowler avatar
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: AppColors.tertiaryContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                bowler.name.isNotEmpty ? bowler.name[0] : '?',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.accentTeal,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Name
          Expanded(
            flex: 3,
            child: Text(
              bowler.name,
              style: AppTypography.playerName.copyWith(fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Overs
          SizedBox(
            width: 35,
            child: Text(
              '${bowler.overs}',
              style: AppTypography.playerStat.copyWith(fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),

          // Maidens
          SizedBox(
            width: 25,
            child: Text(
              '${bowler.maidens}',
              style: AppTypography.playerStat.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Runs
          SizedBox(
            width: 35,
            child: Text(
              '${bowler.runs}',
              style: AppTypography.playerStat.copyWith(fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),

          // Wickets
          SizedBox(
            width: 30,
            child: Text(
              '${bowler.wickets}',
              style: AppTypography.playerStat.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: bowler.wickets > 0
                    ? AppColors.alertWicket
                    : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Economy
          SizedBox(
            width: 40,
            child: Text(
              bowler.economy.toStringAsFixed(1),
              style: AppTypography.playerStat.copyWith(
                fontSize: 12,
                color: _econColor(bowler.economy),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Color _econColor(double econ) {
    if (econ <= 6) return AppColors.accentGreen;
    if (econ <= 8) return AppColors.textPrimary;
    if (econ <= 10) return AppColors.textSecondary;
    return AppColors.liveIndicator;
  }
}
