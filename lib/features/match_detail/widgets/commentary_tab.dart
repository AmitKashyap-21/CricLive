import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/ball_event.dart';

/// Ball-by-ball commentary list.
class CommentaryTab extends StatelessWidget {
  final List<CommentaryEntry> entries;

  const CommentaryTab({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              color: AppColors.textTertiary,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'Commentary will appear here',
              style: AppTypography.bodyMedium,
            ),
            Text(
              'Stay tuned for ball-by-ball updates',
              style: AppTypography.bodySmall,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingLg,
        vertical: AppConstants.spacingMd,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        return _commentaryTile(entries[index]);
      },
    );
  }

  Widget _commentaryTile(CommentaryEntry entry) {
    Color accentColor;
    IconData? icon;

    switch (entry.type) {
      case CommentaryType.wicket:
        accentColor = AppColors.alertWicket;
        icon = Icons.sports_cricket;
        break;
      case CommentaryType.six:
        accentColor = AppColors.eventSix;
        icon = Icons.flash_on;
        break;
      case CommentaryType.four:
        accentColor = AppColors.eventFour;
        icon = Icons.flash_on;
        break;
      case CommentaryType.milestone:
        accentColor = AppColors.accentGreen;
        icon = Icons.star;
        break;
      case CommentaryType.overEnd:
        accentColor = AppColors.accentTeal;
        icon = Icons.refresh;
        break;
      default:
        accentColor = AppColors.textTertiary;
        icon = null;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSm),
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: entry.type != CommentaryType.normal
            ? accentColor.withValues(alpha: 0.06)
            : AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: entry.type != CommentaryType.normal
            ? Border.all(
                color: accentColor.withValues(alpha: 0.2),
                width: 0.5,
              )
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Over.ball badge
          Container(
            width: 38,
            padding: const EdgeInsets.symmetric(vertical: 3),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              entry.overBall,
              style: AppTypography.scoreCompact.copyWith(
                color: accentColor,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 10),

          // Commentary text
          Expanded(
            child: Text(
              entry.text,
              style: AppTypography.bodyMedium.copyWith(
                color: entry.type != CommentaryType.normal
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ),

          // Event icon
          if (icon != null) ...[
            const SizedBox(width: 6),
            Icon(icon, color: accentColor, size: 16),
          ],
        ],
      ),
    );
  }
}
