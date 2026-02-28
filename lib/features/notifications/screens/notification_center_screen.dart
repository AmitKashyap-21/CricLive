import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';

/// In-app notification center showing recent alerts.
class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: Text('Notifications', style: AppTypography.headlineLarge),
        backgroundColor: AppColors.primaryBackground,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        children: [
          _notificationTile(
            icon: Icons.sports_cricket,
            color: AppColors.alertWicket,
            title: 'WICKET! Moeen Ali out',
            subtitle: 'CSK vs MI · 15.3 overs · c Deep Midwicket b Boult',
            time: '3 min ago',
            isNew: true,
          ),
          _notificationTile(
            icon: Icons.star,
            color: AppColors.accentGreen,
            title: 'FIFTY! Devon Conway 50*(34)',
            subtitle: 'CSK vs MI · Conway reaches his half-century',
            time: '8 min ago',
            isNew: true,
          ),
          _notificationTile(
            icon: Icons.flash_on,
            color: AppColors.eventSix,
            title: 'SIX! Conway smashes Bumrah',
            subtitle: 'CSK vs MI · Over long-on, what a shot!',
            time: '12 min ago',
            isNew: false,
          ),
          _notificationTile(
            icon: Icons.play_circle_filled,
            color: AppColors.accentTeal,
            title: 'Match Started: RCB vs KKR',
            subtitle: 'IPL 2026 · M. Chinnaswamy Stadium, Bengaluru',
            time: '1h ago',
            isNew: false,
          ),
          _notificationTile(
            icon: Icons.emoji_events,
            color: AppColors.eventSix,
            title: 'GT won by 26 runs',
            subtitle: 'GT vs LSG · IPL 2026 · Match completed',
            time: '1d ago',
            isNew: false,
          ),
          _notificationTile(
            icon: Icons.sports_cricket,
            color: AppColors.alertWicket,
            title: 'HAT-TRICK! Rashid Khan',
            subtitle: 'GT vs LSG · First hat-trick of IPL 2026!',
            time: '1d ago',
            isNew: false,
          ),
        ],
      ),
    );
  }

  Widget _notificationTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String time,
    required bool isNew,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSm),
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: isNew
            ? color.withValues(alpha: 0.06)
            : AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: isNew
              ? color.withValues(alpha: 0.2)
              : AppColors.divider,
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight:
                              isNew ? FontWeight.w700 : FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isNew)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: AppTypography.labelSmall.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
