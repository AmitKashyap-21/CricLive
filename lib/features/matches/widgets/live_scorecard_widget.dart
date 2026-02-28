import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/providers.dart';

/// Live scorecard widget that fetches and displays real cricket
/// data from the Cricbuzz RapidAPI.
///
/// Uses `scorecardProvider` with AsyncValue.when for clean
/// loading / error / data tri‑state handling.
class LiveScorecardWidget extends ConsumerWidget {
  final String matchId;

  const LiveScorecardWidget({
    super.key,
    this.matchId = '40381',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scorecardAsync = ref.watch(scorecardProvider(matchId));

    return scorecardAsync.when(
      loading: () => _loadingSkeleton(),
      error: (error, stack) => _errorCard(error, ref),
      data: (data) => _scorecardCard(data),
    );
  }

  // ─── Data Card ───────────────────────────────────────────

  Widget _scorecardCard(Map<String, dynamic> data) {
    // Safely navigate the Cricbuzz hscard JSON structure
    final scoreCard = _safeList(data['scoreCard']);
    if (scoreCard.isEmpty) {
      return _emptyCard('No scorecard data available');
    }

    // Extract match header
    final matchHeader = data['matchHeader'] as Map<String, dynamic>?;
    final matchState = matchHeader?['state'] as String? ?? '';
    final matchStatus = matchHeader?['status'] as String? ?? '';

    // Parse innings data (latest first)
    final innings = <_InningsData>[];
    for (final sc in scoreCard) {
      final innData = sc as Map<String, dynamic>?;
      if (innData == null) continue;

      final inningsScore = innData['scoreDetails'] as Map<String, dynamic>?;
      final batTeamDetails =
          innData['batTeamDetails'] as Map<String, dynamic>?;
      final batTeamName = batTeamDetails?['batTeamShortName'] as String? ??
          batTeamDetails?['batTeamName'] as String? ??
          '???';

      final runs = inningsScore?['runs'] ?? 0;
      final wickets = inningsScore?['wickets'] ?? 0;
      final overs = inningsScore?['overs'] ?? 0;

      innings.add(_InningsData(
        teamName: batTeamName,
        runs: _toInt(runs),
        wickets: _toInt(wickets),
        overs: _toDouble(overs),
      ));
    }

    final isLive = matchState == 'In Progress' || matchState == 'Innings Break';

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingLg),
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
          color: isLive
              ? AppColors.accentGreen.withValues(alpha: 0.4)
              : AppColors.divider,
          width: isLive ? 1.5 : 0.5,
        ),
        boxShadow: isLive
            ? [
                BoxShadow(
                  color: AppColors.accentGreen.withValues(alpha: 0.08),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header with LIVE badge ──────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                // API badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accentTeal.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'LIVE API',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.accentTeal,
                      fontWeight: FontWeight.w700,
                      fontSize: 9,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const Spacer(),
                if (isLive)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: AppColors.liveIndicator,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.liveIndicator.withValues(alpha: 0.5),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        matchState.toUpperCase(),
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.liveIndicator,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ─── Team scores ────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                for (int i = 0; i < innings.length; i++) ...[
                  _teamScoreRow(innings[i], isLatest: i == innings.length - 1),
                  if (i < innings.length - 1) const SizedBox(height: 10),
                ],
              ],
            ),
          ),

          // ─── Match status ───────────────────────────
          if (matchStatus.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(AppConstants.radiusMd),
                ),
              ),
              child: Text(
                matchStatus,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.accentGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ] else
            const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _teamScoreRow(_InningsData innings, {bool isLatest = false}) {
    return Row(
      children: [
        // Team name
        Expanded(
          child: Text(
            innings.teamName,
            style: AppTypography.teamName.copyWith(
              fontSize: isLatest ? 16 : 14,
              color: isLatest ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),

        // Score (Oswald bold)
        Text(
          '${innings.runs}/${innings.wickets}',
          style: AppTypography.scoreLarge.copyWith(
            fontSize: isLatest ? 28 : 22,
            color: isLatest ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),

        const SizedBox(width: 8),

        // Overs
        Text(
          '(${innings.overs} ov)',
          style: AppTypography.overLabel.copyWith(
            fontSize: isLatest ? 13 : 11,
          ),
        ),
      ],
    );
  }

  // ─── Loading Skeleton ────────────────────────────────────

  Widget _loadingSkeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingLg),
      padding: const EdgeInsets.all(16),
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shimmer header
          Container(
            width: 60,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.tertiaryContainer,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 18),
          // Team 1 shimmer
          Row(
            children: [
              Container(
                width: 80,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.tertiaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Spacer(),
              Container(
                width: 70,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.tertiaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Team 2 shimmer
          Row(
            children: [
              Container(
                width: 80,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.tertiaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Spacer(),
              Container(
                width: 70,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.tertiaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Status bar shimmer
          Container(
            width: double.infinity,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.tertiaryContainer,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Error Card ──────────────────────────────────────────

  Widget _errorCard(Object error, WidgetRef ref) {
    final message = error is Exception
        ? error.toString().replaceFirst('Exception: ', '')
        : 'Something went wrong';

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingLg),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: AppColors.alertWicket.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            color: AppColors.alertWicket.withValues(alpha: 0.6),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              // Invalidate to retry
              ref.invalidate(scorecardProvider(matchId));
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Retry',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.accentGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Empty Card ──────────────────────────────────────────

  Widget _emptyCard(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingLg),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Center(
        child: Text(
          message,
          style: AppTypography.bodySmall,
        ),
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────

  List<dynamic> _safeList(dynamic value) {
    if (value is List) return value;
    return [];
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

/// Internal data class for parsed innings info.
class _InningsData {
  final String teamName;
  final int runs;
  final int wickets;
  final double overs;

  const _InningsData({
    required this.teamName,
    required this.runs,
    required this.wickets,
    required this.overs,
  });
}
