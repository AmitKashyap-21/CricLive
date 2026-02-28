import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/match_state_classifier.dart';

/// A match card that renders directly from Cricbuzz API JSON.
///
/// Improved visual depth with shadow, WCAG AA contrast, and
/// distinct status badges (solid LIVE, outlined UPCOMING/DONE).
class ApiMatchCard extends StatelessWidget {
  final Map<String, dynamic> matchInfo;
  final Map<String, dynamic>? matchScore;
  final VoidCallback? onTap;

  const ApiMatchCard({
    super.key,
    required this.matchInfo,
    this.matchScore,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Parse match info
    final team1 = matchInfo['team1'] as Map<String, dynamic>? ?? {};
    final team2 = matchInfo['team2'] as Map<String, dynamic>? ?? {};
    final team1Name =
        team1['teamSName'] as String? ?? team1['teamName'] as String? ?? '???';
    final team2Name =
        team2['teamSName'] as String? ?? team2['teamName'] as String? ?? '???';

    final status = matchInfo['status'] as String? ?? '';
    final seriesName = matchInfo['seriesName'] as String? ?? '';
    final venue = _extractVenue(matchInfo);
    final matchDesc = matchInfo['matchDesc'] as String? ?? '';

    final uiState = classifyMatchState(matchInfo);
    final badgeLabel = matchBadgeLabel(matchInfo);
    
    final isLiveActive = uiState == UiMatchState.live;
    final isDayBreak = uiState == UiMatchState.dayBreak;
    final isComplete = uiState == UiMatchState.completed;

    // Parse scores
    final team1Score = _getTeamScore(matchScore, 'team1Score');
    final team2Score = _getTeamScore(matchScore, 'team2Score');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.spacingSm),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLiveActive || isDayBreak
                ? AppColors.live.withValues(alpha: 0.4)
                : AppColors.border,
            width: isLiveActive || isDayBreak ? 1 : 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─── Header: Series + state badge ──────
            Row(
              children: [
                Expanded(
                  child: Text(
                    seriesName.isNotEmpty ? seriesName : matchDesc,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                if (isLiveActive)
                  _liveBadge(badgeLabel)
                else if (isDayBreak)
                  _outlinedBadge(badgeLabel, AppColors.upcoming) // amber for breaks
                else if (isComplete)
                  _outlinedBadge(badgeLabel, AppColors.completed)
                else
                  _outlinedBadge(badgeLabel, AppColors.upcoming),
              ],
            ),
            const SizedBox(height: 10),

            // ─── Team 1 ───────────────────────────
            _teamRow(team1Name, team1Score),
            const SizedBox(height: 6),

            // ─── Team 2 ───────────────────────────
            _teamRow(team2Name, team2Score),

            // ─── Status text ──────────────────────
            if (status.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                status,
                style: AppTypography.bodySmall.copyWith(
                  color: isLiveActive || isDayBreak
                      ? AppColors.secondary
                      : isComplete
                          ? AppColors.completed
                          : AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // ─── Venue ────────────────────────────
            if (venue.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 12,
                    color: AppColors.textDisabled,
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      venue,
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 12,
                        color: AppColors.textDisabled,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _teamRow(String teamName, String? score) {
    return Row(
      children: [
        Expanded(
          child: Text(
            teamName,
            style: AppTypography.labelLarge.copyWith(
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (score != null && score.isNotEmpty)
          Text(
            score,
            style: AppTypography.scoreSmall.copyWith(
              fontSize: 22,
              color: AppColors.textPrimary,
            ),
          ),
      ],
    );
  }

  /// Solid red LIVE badge — high visibility, not just color-coded.
  Widget _liveBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.live,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Outlined badge for UPCOMING / DONE — lower visual weight than LIVE.
  Widget _outlinedBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Extract score string like "185/6 (20)" from Cricbuzz innings data.
  String? _getTeamScore(Map<String, dynamic>? matchScore, String key) {
    if (matchScore == null) return null;
    final teamScore = matchScore[key] as Map<String, dynamic>?;
    if (teamScore == null) return null;

    final inngs1 = teamScore['inngs1'] as Map<String, dynamic>?;
    final inngs2 = teamScore['inngs2'] as Map<String, dynamic>?;

    String? scoreStr;
    if (inngs2 != null) {
      scoreStr = _formatInningsScore(inngs2);
      final inngs1Str = _formatInningsScore(inngs1);
      if (inngs1Str != null && scoreStr != null) {
        scoreStr = '$inngs1Str & $scoreStr';
      }
    } else if (inngs1 != null) {
      scoreStr = _formatInningsScore(inngs1);
    }
    return scoreStr;
  }

  String? _formatInningsScore(Map<String, dynamic>? innings) {
    if (innings == null) return null;
    final runs = innings['runs'];
    final wickets = innings['wickets'];
    final overs = innings['overs'];
    if (runs == null) return null;
    final wktStr = wickets != null ? '/$wickets' : '';
    final ovStr = overs != null ? ' ($overs)' : '';
    return '$runs$wktStr$ovStr';
  }

  String _extractVenue(Map<String, dynamic> info) {
    final venueInfo = info['venueInfo'] as Map<String, dynamic>?;
    if (venueInfo != null) {
      final ground = venueInfo['ground'] as String? ?? '';
      final city = venueInfo['city'] as String? ?? '';
      if (ground.isNotEmpty && city.isNotEmpty) return '$ground, $city';
      if (ground.isNotEmpty) return ground;
      if (city.isNotEmpty) return city;
    }
    return '';
  }
}
