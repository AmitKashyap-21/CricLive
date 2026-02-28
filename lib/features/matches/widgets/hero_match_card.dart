import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/match.dart';
import '../../../shared/widgets/animated_score_text.dart';

/// Hero match card — occupies 4×2 in the Bento grid.
///
/// Shows the featured live match with: series badge, team flags,
/// team names, live scores, overs, run rate, required rate,
/// recent balls, and match status.
class HeroMatchCard extends ConsumerWidget {
  final Match match;
  final VoidCallback? onTap;

  const HeroMatchCard({
    super.key,
    required this.match,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final innings = match.currentInnings;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.secondarySurface,
              AppColors.tertiaryContainer,
            ],
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(
            color: AppColors.divider,
            width: 0.5,
          ),
        ),
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Top: Series + Live badge ──────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.tertiaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    match.series,
                    style: AppTypography.labelSmall,
                  ),
                ),
                const Spacer(),
                if (match.isLive) _liveBadge(),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMd),

            // ─── Middle: Teams + Scores ────────────────
            Row(
              children: [
                // Team A
                Expanded(child: _teamColumn(match.teamA, isTeamA: true)),

                // VS divider
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingSm,
                  ),
                  child: Text(
                    'vs',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),

                // Team B
                Expanded(child: _teamColumn(match.teamB, isTeamA: false)),
              ],
            ),

            const SizedBox(height: AppConstants.spacingMd),

            // ─── Bottom: Status + Recent Balls ─────────
            if (match.isLive && innings != null) ...[
              // Run rate info
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _statChip('CRR', innings.runRate?.toStringAsFixed(2) ?? '-'),
                  const SizedBox(width: AppConstants.spacingSm),
                  if (innings.requiredRunRate != null)
                    _statChip(
                      'RRR',
                      innings.requiredRunRate!.toStringAsFixed(2),
                    ),
                  if (innings.target != null) ...[
                    const SizedBox(width: AppConstants.spacingSm),
                    _statChip('Target', '${innings.target}'),
                  ],
                ],
              ),
              const SizedBox(height: AppConstants.spacingSm),

              // Recent balls
              if (match.recentBalls.isNotEmpty) _recentBallsRow(),
            ],

            if (match.isCompleted && match.result != null)
              Center(
                child: Text(
                  match.result!,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.accentGreen,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _teamColumn(Team team, {required bool isTeamA}) {
    // Determine if this team is currently batting
    final innings = match.currentInnings;
    final isBatting =
        innings != null && innings.battingTeamId == team.id;

    // Get score for this team
    String? scoreText;
    String? oversText;

    if (isBatting) {
      scoreText = innings.scoreString;
      oversText = innings.oversString;
    } else {
      // Check completed innings
      for (final inn in match.innings) {
        if (inn.battingTeamId == team.id) {
          scoreText = inn.scoreString;
          oversText = inn.oversString;
          break;
        }
      }
    }

    return Column(
      children: [
        // Team emoji/flag
        Text(
          team.flagEmoji,
          style: const TextStyle(fontSize: 32),
        ),
        const SizedBox(height: 4),
        // Team name
        Text(
          team.shortName,
          style: AppTypography.teamName,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        // Score
        if (scoreText != null)
          AnimatedScoreText(
            score: scoreText,
            style: AppTypography.scoreMedium,
          ),
        if (oversText != null)
          Text(
            oversText,
            style: AppTypography.overLabel,
          ),
      ],
    );
  }

  Widget _liveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.liveIndicator.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.liveIndicator.withValues(alpha: 0.4),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.liveIndicator,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'LIVE',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.liveIndicator,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryBackground.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          Text(
            value,
            style: AppTypography.scoreCompact.copyWith(
              color: AppColors.accentGreen,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentBallsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Recent: ',
          style: AppTypography.labelSmall,
        ),
        ...match.recentBalls.map((ball) => Padding(
              padding: const EdgeInsets.only(left: 3),
              child: _ballChip(ball),
            )),
      ],
    );
  }

  Widget _ballChip(String ball) {
    Color bgColor;
    Color textColor = AppColors.textPrimary;

    switch (ball) {
      case 'W':
        bgColor = AppColors.alertWicket;
        textColor = Colors.white;
        break;
      case '4':
        bgColor = AppColors.eventFour.withValues(alpha: 0.2);
        textColor = AppColors.eventFour;
        break;
      case '6':
        bgColor = AppColors.eventSix.withValues(alpha: 0.2);
        textColor = AppColors.eventSix;
        break;
      case '0':
        bgColor = AppColors.eventDotBall.withValues(alpha: 0.2);
        textColor = AppColors.eventDotBall;
        break;
      default:
        bgColor = AppColors.primaryBackground.withValues(alpha: 0.5);
    }

    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Text(
        ball,
        style: AppTypography.labelSmall.copyWith(
          color: textColor,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
