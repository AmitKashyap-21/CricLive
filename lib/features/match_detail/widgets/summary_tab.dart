import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/match.dart';
import '../../../shared/widgets/animated_score_text.dart';

/// Summary tab showing match overview, key events,
/// and recent balls.
class SummaryTab extends StatelessWidget {
  final Match match;

  const SummaryTab({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Score Summary Card ──────────────────────
          _buildScoreSummary(),
          const SizedBox(height: AppConstants.spacingLg),

          // ─── Recent Balls ───────────────────────────
          if (match.recentBalls.isNotEmpty) ...[
            _buildRecentBalls(),
            const SizedBox(height: AppConstants.spacingLg),
          ],

          // ─── Key Stats ──────────────────────────────
          _buildKeyStats(),
          const SizedBox(height: AppConstants.spacingLg),

          // ─── Venue Info ─────────────────────────────
          _buildVenueCard(),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildScoreSummary() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.secondarySurface, AppColors.tertiaryContainer],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        children: [
          // First innings (if any)
          for (final inn in match.innings) ...[
            _inningsRow(
              teamName: _teamName(inn.battingTeamId),
              emoji: _teamEmoji(inn.battingTeamId),
              score: inn.scoreString,
              overs: inn.oversString,
            ),
            const Divider(height: 20),
          ],

          // Current innings
          if (match.currentInnings != null)
            _inningsRow(
              teamName: _teamName(match.currentInnings!.battingTeamId),
              emoji: _teamEmoji(match.currentInnings!.battingTeamId),
              score: match.currentInnings!.scoreString,
              overs: match.currentInnings!.oversString,
              isLive: match.isLive,
            ),

          // Result
          if (match.result != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                match.result!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.accentGreen,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],

          // Target info
          if (match.currentInnings?.target != null) ...[
            const SizedBox(height: 8),
            Text(
              'Need ${match.currentInnings!.target! - match.currentInnings!.runs} runs from ${(20 - match.currentInnings!.overs).toStringAsFixed(1)} overs',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _inningsRow({
    required String teamName,
    required String emoji,
    required String score,
    required String overs,
    bool isLive = false,
  }) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(teamName, style: AppTypography.teamName),
              if (isLive)
                Text(
                  'Batting',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.accentGreen,
                  ),
                ),
            ],
          ),
        ),
        AnimatedScoreText(
          score: score,
          style: AppTypography.scoreLarge,
        ),
        const SizedBox(width: 6),
        Text(overs, style: AppTypography.overLabel),
      ],
    );
  }

  Widget _buildRecentBalls() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This Over', style: AppTypography.labelMedium),
          const SizedBox(height: AppConstants.spacingSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: match.recentBalls
                .map((ball) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _ballChip(ball),
                    ))
                .toList(),
          ),
        ],
      ),
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
        bgColor = AppColors.tertiaryContainer;
    }

    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Text(
        ball,
        style: AppTypography.labelLarge.copyWith(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildKeyStats() {
    final innings = match.currentInnings;
    if (innings == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: _statCard(
            'Run Rate',
            innings.runRate?.toStringAsFixed(2) ?? '-',
            Icons.speed,
          ),
        ),
        const SizedBox(width: AppConstants.spacingSm),
        if (innings.requiredRunRate != null)
          Expanded(
            child: _statCard(
              'Req. Rate',
              innings.requiredRunRate!.toStringAsFixed(2),
              Icons.trending_up,
            ),
          ),
        const SizedBox(width: AppConstants.spacingSm),
        Expanded(
          child: _statCard(
            'Partnership',
            '44(28)',
            Icons.handshake_outlined,
          ),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.accentGreen, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.scoreSmall.copyWith(fontSize: 16),
          ),
          Text(label, style: AppTypography.labelSmall),
        ],
      ),
    );
  }

  Widget _buildVenueCard() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.stadium_outlined,
              color: AppColors.textTertiary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(match.venue, style: AppTypography.bodyMedium),
                Text(
                  '${match.format} · ${match.series}',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _teamName(String teamId) {
    if (teamId == match.teamA.id) return match.teamA.name;
    return match.teamB.name;
  }

  String _teamEmoji(String teamId) {
    if (teamId == match.teamA.id) return match.teamA.flagEmoji;
    return match.teamB.flagEmoji;
  }
}
