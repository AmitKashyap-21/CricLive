import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/services/mock_data.dart';
import '../../../providers/providers.dart';
import '../../notifications/screens/notification_center_screen.dart';

/// Profile tab with user settings, notification preferences,
/// and favorite teams.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifPrefs = ref.watch(notificationPrefsProvider);

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
              title: Text('Profile', style: AppTypography.displayMedium),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingLg,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // User card
                  _userCard(),
                  const SizedBox(height: AppConstants.spacingXl),

                  // Favorite teams
                  Text('Favorite Teams',
                      style: AppTypography.headlineSmall),
                  const SizedBox(height: AppConstants.spacingSm),
                  _favoriteTeamsGrid(ref, notifPrefs),
                  const SizedBox(height: AppConstants.spacingXl),

                  // Notification preferences
                  Text('Notification Preferences',
                      style: AppTypography.headlineSmall),
                  const SizedBox(height: AppConstants.spacingSm),
                  _notificationCard(ref, notifPrefs),
                  const SizedBox(height: AppConstants.spacingLg),

                  // Notification center
                  _menuItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notification Center',
                    subtitle: 'View all alerts',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const NotificationCenterScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppConstants.spacingSm),

                  // App settings
                  _menuItem(
                    icon: Icons.palette_outlined,
                    title: 'Appearance',
                    subtitle: 'Dark Forest (Default)',
                  ),
                  const SizedBox(height: AppConstants.spacingSm),
                  _menuItem(
                    icon: Icons.info_outline,
                    title: 'About CricLive',
                    subtitle: 'Version 1.0.0',
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

  Widget _userCard() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.secondarySurface, AppColors.tertiaryContainer],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accentGreen, AppColors.accentTeal],
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '🏏',
                style: TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cricket Fan', style: AppTypography.headlineMedium),
                Text(
                  'IPL 2026 Enthusiast',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
          Icon(Icons.edit_outlined,
              color: AppColors.textTertiary, size: 20),
        ],
      ),
    );
  }

  Widget _favoriteTeamsGrid(WidgetRef ref, NotificationPrefs prefs) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: MockData.allTeams.map((team) {
        final isFavorite = prefs.favoriteTeamIds.contains(team.id);
        return GestureDetector(
          onTap: () {
            ref
                .read(notificationPrefsProvider.notifier)
                .toggleFavoriteTeam(team.id);
          },
          child: AnimatedContainer(
            duration: AppConstants.animFast,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isFavorite
                  ? AppColors.accentGreen.withValues(alpha: 0.15)
                  : AppColors.secondarySurface,
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
              border: Border.all(
                color: isFavorite
                    ? AppColors.accentGreen.withValues(alpha: 0.5)
                    : AppColors.divider,
                width: isFavorite ? 1 : 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(team.flagEmoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  team.shortName,
                  style: AppTypography.labelMedium.copyWith(
                    color: isFavorite
                        ? AppColors.accentGreen
                        : AppColors.textSecondary,
                    fontWeight:
                        isFavorite ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _notificationCard(WidgetRef ref, NotificationPrefs prefs) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        children: [
          _switchTile(
            'Wicket Alerts',
            'Get notified on every wicket',
            Icons.sports_cricket,
            prefs.wicketAlerts,
            () => ref
                .read(notificationPrefsProvider.notifier)
                .toggleWicketAlerts(),
          ),
          _divider(),
          _switchTile(
            'Milestones',
            'Fifties, centuries, hat-tricks',
            Icons.star_outline,
            prefs.milestoneAlerts,
            () => ref
                .read(notificationPrefsProvider.notifier)
                .toggleMilestoneAlerts(),
          ),
          _divider(),
          _switchTile(
            'Match Start',
            'Alert when a match begins',
            Icons.play_circle_outline,
            prefs.matchStartAlerts,
            () => ref
                .read(notificationPrefsProvider.notifier)
                .toggleMatchStartAlerts(),
          ),
          _divider(),
          _switchTile(
            'Boundaries',
            'Fours and sixes',
            Icons.flash_on,
            prefs.boundaryAlerts,
            () => ref
                .read(notificationPrefsProvider.notifier)
                .toggleBoundaryAlerts(),
          ),
        ],
      ),
    );
  }

  Widget _switchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    VoidCallback onToggle,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingLg,
        vertical: AppConstants.spacingMd,
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.labelLarge),
                Text(subtitle, style: AppTypography.bodySmall),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: (_) => onToggle(),
            activeTrackColor: AppColors.accentGreen.withValues(alpha: 0.3),
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.accentGreen;
              }
              return null;
            }),
          ),
        ],
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        decoration: BoxDecoration(
          color: AppColors.secondarySurface,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: AppColors.divider, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accentGreen, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.labelLarge),
                  Text(subtitle, style: AppTypography.bodySmall),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      indent: AppConstants.spacingLg,
      endIndent: AppConstants.spacingLg,
      color: AppColors.divider.withValues(alpha: 0.3),
    );
  }
}
