import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';

/// Animated win probability bar showing both teams' chances.
class WinProbabilityBar extends StatelessWidget {
  final double teamAProbability; // 0.0 to 1.0
  final String teamALabel;
  final String teamBLabel;

  const WinProbabilityBar({
    super.key,
    required this.teamAProbability,
    required this.teamALabel,
    required this.teamBLabel,
  });

  @override
  Widget build(BuildContext context) {
    final teamB = 1.0 - teamAProbability;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingLg,
      ),
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Win Probability', style: AppTypography.headlineSmall),
          const SizedBox(height: AppConstants.spacingMd),

          // Probability percentages
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(teamALabel, style: AppTypography.labelMedium),
                  Text(
                    '${(teamAProbability * 100).toStringAsFixed(0)}%',
                    style: AppTypography.scoreMedium.copyWith(
                      color: AppColors.accentGreen,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(teamBLabel, style: AppTypography.labelMedium),
                  Text(
                    '${(teamB * 100).toStringAsFixed(0)}%',
                    style: AppTypography.scoreMedium.copyWith(
                      color: AppColors.accentTeal,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingSm),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  Flexible(
                    flex: (teamAProbability * 100).round(),
                    child: AnimatedContainer(
                      duration: AppConstants.animMedium,
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accentGreen,
                            AppColors.accentGreen.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(width: 2, color: AppColors.primaryBackground),
                  Flexible(
                    flex: (teamB * 100).round(),
                    child: AnimatedContainer(
                      duration: AppConstants.animMedium,
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accentTeal.withValues(alpha: 0.7),
                            AppColors.accentTeal,
                          ],
                        ),
                      ),
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
}
