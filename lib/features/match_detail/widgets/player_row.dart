import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/match.dart';

/// Hero Bento Scorecard player row.
///
/// Each row shows: avatar, name (Montserrat bold), runs (Oswald large),
/// balls, strike rate, and boundary count icons.
class PlayerRow extends StatelessWidget {
  final BatsmanInnings batsman;

  const PlayerRow({super.key, required this.batsman});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.scorecardHorizontalPadding,
        vertical: AppConstants.scorecardVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: batsman.isOnStrike
            ? AppColors.accentGreen.withValues(alpha: 0.06)
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: AppConstants.playerAvatarSize,
            height: AppConstants.playerAvatarSize,
            decoration: BoxDecoration(
              color: AppColors.tertiaryContainer,
              shape: BoxShape.circle,
              border: batsman.isOnStrike
                  ? Border.all(color: AppColors.accentGreen, width: 1.5)
                  : null,
            ),
            child: Center(
              child: Text(
                batsman.name.isNotEmpty
                    ? batsman.name[0].toUpperCase()
                    : '?',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.accentGreen,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Name + dismissal
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        batsman.name,
                        style: AppTypography.playerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (batsman.isOnStrike) ...[
                      const SizedBox(width: 4),
                      Text(
                        '*',
                        style: AppTypography.playerName.copyWith(
                          color: AppColors.accentGreen,
                        ),
                      ),
                    ],
                  ],
                ),
                if (batsman.isOut && batsman.dismissal != null)
                  Text(
                    batsman.dismissal!,
                    style: AppTypography.bodySmall.copyWith(
                      fontSize: 10,
                      color: AppColors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // Runs (large Oswald)
          SizedBox(
            width: 45,
            child: Text(
              '${batsman.runs}',
              style: AppTypography.playerStat.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Balls
          SizedBox(
            width: 35,
            child: Text(
              '${batsman.balls}',
              style: AppTypography.playerStat.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // SR
          SizedBox(
            width: 45,
            child: Text(
              batsman.strikeRate.toStringAsFixed(1),
              style: AppTypography.playerStat.copyWith(
                color: _srColor(batsman.strikeRate),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Boundary icons
          SizedBox(
            width: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (batsman.fours > 0)
                  _boundaryChip('4', batsman.fours, AppColors.eventFour),
                if (batsman.sixes > 0) ...[
                  const SizedBox(width: 4),
                  _boundaryChip('6', batsman.sixes, AppColors.eventSix),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _srColor(double sr) {
    if (sr >= 150) return AppColors.accentGreen;
    if (sr >= 100) return AppColors.textPrimary;
    if (sr >= 70) return AppColors.textSecondary;
    return AppColors.alertWicket;
  }

  Widget _boundaryChip(String type, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$type×$count',
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
