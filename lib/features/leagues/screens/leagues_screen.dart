import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/match.dart';
import '../../../data/services/mock_data.dart';

/// Leagues tab showing IPL standings table.
class LeaguesScreen extends StatelessWidget {
  const LeaguesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final standings = MockData.iplStandings;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: AppColors.primaryBackground,
              elevation: 0,
              title: Text('Leagues', style: AppTypography.displayMedium),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingLg,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // League header
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingLg),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.secondarySurface,
                          AppColors.tertiaryContainer,
                        ],
                      ),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMd),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.accentGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text('🏏', style: TextStyle(fontSize: 24)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'IPL 2026',
                              style: AppTypography.headlineLarge,
                            ),
                            Text(
                              'Indian Premier League',
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingLg),

                  // Points table
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.secondarySurface,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMd),
                      border: Border.all(
                        color: AppColors.divider,
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Table header
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingLg,
                            vertical: AppConstants.spacingMd,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBackground
                                .withValues(alpha: 0.5),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(AppConstants.radiusMd),
                            ),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 28),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text('Team',
                                    style: AppTypography.labelSmall),
                              ),
                              _headerCell('P'),
                              _headerCell('W'),
                              _headerCell('L'),
                              SizedBox(
                                width: 48,
                                child: Text('NRR',
                                    style: AppTypography.labelSmall,
                                    textAlign: TextAlign.center),
                              ),
                              SizedBox(
                                width: 30,
                                child: Text('Pts',
                                    style: AppTypography.labelSmall
                                        .copyWith(
                                          color: AppColors.accentGreen,
                                        ),
                                    textAlign: TextAlign.center),
                              ),
                            ],
                          ),
                        ),

                        // Team rows
                        for (int i = 0; i < standings.length; i++)
                          _teamRow(
                            position: i + 1,
                            team: standings[i]['team'] as Team,
                            played: standings[i]['played'] as int,
                            won: standings[i]['won'] as int,
                            lost: standings[i]['lost'] as int,
                            nrr: standings[i]['nrr'] as String,
                            points: standings[i]['points'] as int,
                            isQualified: i < 4,
                            isLast: i == standings.length - 1,
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(String text) {
    return SizedBox(
      width: 25,
      child: Text(
        text,
        style: AppTypography.labelSmall,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _teamRow({
    required int position,
    required Team team,
    required int played,
    required int won,
    required int lost,
    required String nrr,
    required int points,
    required bool isQualified,
    required bool isLast,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingLg,
        vertical: AppConstants.spacingMd,
      ),
      decoration: BoxDecoration(
        color: isQualified
            ? AppColors.accentGreen.withValues(alpha: 0.04)
            : Colors.transparent,
        border: !isLast
            ? Border(
                bottom: BorderSide(
                  color: AppColors.divider.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              )
            : null,
        borderRadius: isLast
            ? const BorderRadius.vertical(
                bottom: Radius.circular(AppConstants.radiusMd),
              )
            : null,
      ),
      child: Row(
        children: [
          // Position
          SizedBox(
            width: 20,
            child: Text(
              '$position',
              style: AppTypography.scoreCompact.copyWith(
                color: isQualified
                    ? AppColors.accentGreen
                    : AppColors.textTertiary,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          // Team emoji + name
          Text(team.flagEmoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              team.shortName,
              style: AppTypography.labelLarge.copyWith(fontSize: 13),
            ),
          ),
          // Stats
          _statCell('$played'),
          _statCell('$won', color: AppColors.accentGreen),
          _statCell('$lost', color: AppColors.liveIndicator),
          SizedBox(
            width: 48,
            child: Text(
              nrr,
              style: AppTypography.bodySmall.copyWith(
                fontSize: 11,
                color: nrr.startsWith('+')
                    ? AppColors.accentGreen
                    : AppColors.liveIndicator,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 30,
            child: Text(
              '$points',
              style: AppTypography.scoreCompact.copyWith(
                color: AppColors.accentGreen,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCell(String text, {Color? color}) {
    return SizedBox(
      width: 25,
      child: Text(
        text,
        style: AppTypography.bodySmall.copyWith(
          fontSize: 12,
          color: color ?? AppColors.textSecondary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
