import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/match.dart';
import 'player_row.dart';
import 'bowling_row.dart';

/// Full scorecard tab showing batting + bowling tables
/// in Hero Bento Scorecard style.
class ScorecardTab extends StatelessWidget {
  final Match match;

  const ScorecardTab({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final innings = match.currentInnings;
    if (innings == null) {
      return Center(
        child: Text(
          'Scorecard will appear once the match starts',
          style: AppTypography.bodyMedium,
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppConstants.spacingLg),

          // ─── Batting Card ────────────────────────────
          _buildScorecardCard(
            title: '${match.battingTeam?.shortName ?? "Batting"} Innings',
            subtitle: '${innings.scoreString} ${innings.oversString}',
            child: Column(
              children: [
                // Header row
                _headerRow(['', 'Batter', 'R', 'B', 'SR', '']),
                // Player rows
                for (final batsman in innings.batsmen)
                  PlayerRow(batsman: batsman),
                // Extras
                _extrasRow(innings.extras),
                // Total
                _totalRow(innings),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.spacingLg),

          // ─── Bowling Card ────────────────────────────
          if (innings.bowlers.isNotEmpty)
            _buildScorecardCard(
              title: match.bowlingTeam?.shortName ?? 'Bowling',
              child: Column(
                children: [
                  _headerRow(['', 'Bowler', 'O', 'M', 'R', 'W', 'Econ']),
                  for (final bowler in innings.bowlers)
                    BowlingRow(bowler: bowler),
                ],
              ),
            ),

          const SizedBox(height: AppConstants.spacingLg),

          // ─── Fall of Wickets ─────────────────────────
          if (innings.fallOfWickets.isNotEmpty)
            _buildScorecardCard(
              title: 'Fall of Wickets',
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingLg),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    for (final fow in innings.fallOfWickets)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.alertWicket.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                AppColors.alertWicket.withValues(alpha: 0.2),
                            width: 0.5,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${fow.runs}/${fow.wicketNumber}',
                              style: AppTypography.scoreCompact.copyWith(
                                color: AppColors.alertWicket,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '(${fow.overs} ov)',
                              style: AppTypography.bodySmall.copyWith(
                                fontSize: 9,
                              ),
                            ),
                            Text(
                              fow.batsmanName.split(' ').last,
                              style: AppTypography.bodySmall.copyWith(
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScorecardCard({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingLg,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: AppColors.divider,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingLg),
            child: Row(
              children: [
                Text(title, style: AppTypography.headlineSmall),
                if (subtitle != null) ...[
                  const Spacer(),
                  Text(
                    subtitle,
                    style: AppTypography.scoreCompact.copyWith(
                      color: AppColors.accentGreen,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          child,
        ],
      ),
    );
  }

  Widget _headerRow(List<String> labels) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.scorecardHorizontalPadding,
        vertical: 6,
      ),
      color: AppColors.primaryBackground.withValues(alpha: 0.5),
      child: Row(
        children: [
          SizedBox(width: AppConstants.playerAvatarSize + 10),
          Expanded(
            flex: 3,
            child: Text(labels.length > 1 ? labels[1] : '',
                style: AppTypography.labelSmall),
          ),
          for (int i = 2; i < labels.length; i++)
            SizedBox(
              width: i == labels.length - 1 ? 50 : 35,
              child: Text(
                labels[i],
                style: AppTypography.labelSmall,
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _extrasRow(int extras) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.scorecardHorizontalPadding,
        vertical: 8,
      ),
      child: Row(
        children: [
          Text('Extras', style: AppTypography.bodySmall),
          const Spacer(),
          Text(
            '$extras',
            style: AppTypography.playerStat.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _totalRow(Innings innings) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.scorecardHorizontalPadding,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentGreen.withValues(alpha: 0.06),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppConstants.radiusMd),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Total',
            style: AppTypography.headlineSmall.copyWith(fontSize: 14),
          ),
          const Spacer(),
          Text(
            innings.scoreString,
            style: AppTypography.scoreMedium.copyWith(
              color: AppColors.accentGreen,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            innings.oversString,
            style: AppTypography.overLabel,
          ),
          if (innings.runRate != null) ...[
            const SizedBox(width: 12),
            Text(
              'RR: ${innings.runRate!.toStringAsFixed(2)}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
