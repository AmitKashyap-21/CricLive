import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/match.dart';

/// Compact match card for secondary Bento tiles (2×1 or 1×1).
class MatchCard extends StatelessWidget {
  final Match match;
  final VoidCallback? onTap;

  const MatchCard({
    super.key,
    required this.match,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.secondarySurface,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(
            color: AppColors.divider,
            width: 0.5,
          ),
        ),
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status row
            Row(
              children: [
                if (match.isLive) _liveDot(),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    match.isLive
                        ? 'LIVE'
                        : match.isUpcoming
                            ? 'UPCOMING'
                            : 'COMPLETED',
                    style: AppTypography.labelSmall.copyWith(
                      color: match.isLive
                          ? AppColors.liveIndicator
                          : match.isUpcoming
                              ? AppColors.accentGreen
                              : AppColors.textTertiary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingSm),

            // Team rows
            _teamRow(match.teamA, isTeamA: true),
            const SizedBox(height: 6),
            _teamRow(match.teamB, isTeamA: false),

            // Result or status
            if (match.result != null) ...[
              const SizedBox(height: AppConstants.spacingSm),
              Text(
                match.result!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.accentGreen,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            if (match.isUpcoming) ...[
              const SizedBox(height: AppConstants.spacingSm),
              Text(
                _formatTime(match.startTime),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _teamRow(Team team, {required bool isTeamA}) {
    String? score;
    if (match.currentInnings != null &&
        match.currentInnings!.battingTeamId == team.id) {
      score = match.currentInnings!.scoreString;
    } else {
      for (final inn in match.innings) {
        if (inn.battingTeamId == team.id) {
          score = inn.scoreString;
          break;
        }
      }
    }

    return Row(
      children: [
        Text(team.flagEmoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            team.shortName,
            style: AppTypography.labelLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (score != null)
          Text(
            score,
            style: AppTypography.scoreSmall,
          ),
      ],
    );
  }

  Widget _liveDot() {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: AppColors.liveIndicator,
        shape: BoxShape.circle,
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return 'Today, $hour:$minute $period';
  }
}
