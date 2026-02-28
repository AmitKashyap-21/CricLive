import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/auto_refresh_controller.dart';
import '../../../core/utils/match_state_classifier.dart';
import '../../../providers/providers.dart';
import '../screens/api_match_details_screen.dart';
import '../widgets/api_match_card.dart';

/// Matches tab with categorized Live / Upcoming / Completed tabs.
///
/// Auto-refresh strategy:
///   • Live tab    → every 30 seconds
///   • Upcoming tab → every 2 minutes
///   • Results tab  → no auto-refresh
///   • Pauses when app is backgrounded
///   • Stops on dispose (no leaks)
///   • Manual pull-to-refresh still works
class MatchesScreen extends ConsumerStatefulWidget {
  const MatchesScreen({super.key});

  @override
  ConsumerState<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends ConsumerState<MatchesScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final TabController _tabController;
  final AutoRefreshController _autoRefresh = AutoRefreshController();

  static const _liveInterval = Duration(seconds: 30);
  static const _upcomingInterval = Duration(minutes: 2);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addObserver(this);

    // Start auto-refresh for the initial tab (Live)
    _startRefreshForTab(0);
  }

  @override
  void dispose() {
    _autoRefresh.stop();
    WidgetsBinding.instance.removeObserver(this);
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  /// Pause/resume refresh when app goes to background/foreground.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _autoRefresh.stop();
    } else if (state == AppLifecycleState.resumed) {
      _startRefreshForTab(_tabController.index);
    }
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _startRefreshForTab(_tabController.index);
    }
  }

  void _startRefreshForTab(int tabIndex) {
    switch (tabIndex) {
      case 0: // Live
        _autoRefresh.start(
          interval: _liveInterval,
          onRefresh: () {
            if (!mounted) return;
            ref.invalidate(liveMatchesApiProvider);
          },
        );
        break;
      case 1: // Upcoming
        _autoRefresh.start(
          interval: _upcomingInterval,
          onRefresh: () {
            if (!mounted) return;
            ref.invalidate(upcomingMatchesApiProvider);
          },
        );
        break;
      case 2: // Results — no auto-refresh
        _autoRefresh.stop();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxScrolled) => [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: AppColors.background,
              elevation: 0,
              title: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.accentGreen,
                          AppColors.accentTeal,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.sports_cricket,
                      color: AppColors.textOnAccent,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'CricLive',
                    style: AppTypography.displayMedium.copyWith(
                      fontSize: 22,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  onPressed: _refreshCurrentTab,
                  icon: const Icon(
                    Icons.refresh,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: _buildTabBar(),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: const [
              _LiveTab(),
              _UpcomingTab(),
              _RecentTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.secondary,
        indicatorWeight: 2.5,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: AppColors.secondary,
        unselectedLabelColor: AppColors.textTertiary,
        labelStyle: AppTypography.labelLarge.copyWith(fontSize: 13),
        unselectedLabelStyle:
            AppTypography.labelMedium.copyWith(fontSize: 13),
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.live,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                const Text('Live'),
              ],
            ),
          ),
          const Tab(text: 'Upcoming'),
          const Tab(text: 'Results'),
        ],
      ),
    );
  }

  void _refreshCurrentTab() {
    switch (_tabController.index) {
      case 0:
        ref.invalidate(liveMatchesApiProvider);
        break;
      case 1:
        ref.invalidate(upcomingMatchesApiProvider);
        break;
      case 2:
        ref.invalidate(recentMatchesApiProvider);
        break;
    }
    // Restart auto-refresh timer after manual refresh
    _startRefreshForTab(_tabController.index);
  }
}

// ═══════════════════════════════════════════════════════════
// ─── Tab: Live Matches ────────────────────────────────────
// ═══════════════════════════════════════════════════════════

class _LiveTab extends ConsumerWidget {
  const _LiveTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncVal = ref.watch(liveMatchesApiProvider);

    return RefreshIndicator(
      color: AppColors.accentGreen,
      backgroundColor: AppColors.secondarySurface,
      onRefresh: () async {
        ref.invalidate(liveMatchesApiProvider);
        await ref
            .read(liveMatchesApiProvider.future)
            .catchError((_) => <String, dynamic>{});
      },
      child: _buildContent(context, asyncVal),
    );
  }

  Widget _buildContent(
      BuildContext context, AsyncValue<Map<String, dynamic>> asyncVal) {
    // Silent refresh: keep showing old data during background re-fetch
    if (asyncVal.isLoading && !asyncVal.hasValue) {
      return const _MatchListShimmer();
    }
    if (asyncVal.hasError && !asyncVal.hasValue) {
      return _ErrorView(
        error: asyncVal.error!,
        onRetry: () {},
      );
    }
    final data = asyncVal.value;
    if (data == null) return const _MatchListShimmer();

    final matches = _parseMatches(data, stateFilter: UiMatchState.live);
    // Sort so truly live matches show before breaks (stumps/lunch/tea)
    matches.sort((a, b) {
      final infoA = a['matchInfo'] as Map<String, dynamic>? ?? {};
      final infoB = b['matchInfo'] as Map<String, dynamic>? ?? {};
      return liveSortPriority(infoA).compareTo(liveSortPriority(infoB));
    });
    if (matches.isEmpty) {
      return const _EmptyView(
        icon: Icons.sports_cricket_outlined,
        message: 'No live matches right now',
        subtitle: 'Pull down to refresh',
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacingLg,
        AppConstants.spacingSm,
        AppConstants.spacingLg,
        100,
      ),
      itemCount: matches.length,
      itemBuilder: (ctx, i) {
        final info =
            matches[i]['matchInfo'] as Map<String, dynamic>? ?? {};
        final score =
            matches[i]['matchScore'] as Map<String, dynamic>?;
        return ApiMatchCard(
          key: ValueKey(info['matchId']),
          matchInfo: info,
          matchScore: score,
          onTap: () => Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => ApiMatchDetailsScreen(
                matchInfo: info,
                matchScore: score,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
// ─── Tab: Upcoming Matches ────────────────────────────────
// ═══════════════════════════════════════════════════════════

class _UpcomingTab extends ConsumerWidget {
  const _UpcomingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncVal = ref.watch(upcomingMatchesApiProvider);

    return RefreshIndicator(
      color: AppColors.accentGreen,
      backgroundColor: AppColors.secondarySurface,
      onRefresh: () async {
        ref.invalidate(upcomingMatchesApiProvider);
        await ref
            .read(upcomingMatchesApiProvider.future)
            .catchError((_) => <String, dynamic>{});
      },
      child: _buildContent(context, asyncVal),
    );
  }

  Widget _buildContent(
      BuildContext context, AsyncValue<Map<String, dynamic>> asyncVal) {
    if (asyncVal.isLoading && !asyncVal.hasValue) {
      return const _MatchListShimmer();
    }
    if (asyncVal.hasError && !asyncVal.hasValue) {
      return _ErrorView(
        error: asyncVal.error!,
        onRetry: () {},
      );
    }
    final data = asyncVal.value;
    if (data == null) return const _MatchListShimmer();

    final matches = _parseMatches(data, stateFilter: UiMatchState.upcoming);
    if (matches.isEmpty) {
      return const _EmptyView(
        icon: Icons.event_outlined,
        message: 'No upcoming matches scheduled',
        subtitle: 'Pull down to refresh',
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacingLg,
        AppConstants.spacingSm,
        AppConstants.spacingLg,
        100,
      ),
      itemCount: matches.length,
      itemBuilder: (ctx, i) {
        final info =
            matches[i]['matchInfo'] as Map<String, dynamic>? ?? {};
        final score =
            matches[i]['matchScore'] as Map<String, dynamic>?;
        return ApiMatchCard(
          key: ValueKey(info['matchId']),
          matchInfo: info,
          matchScore: score,
          onTap: () => Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => ApiMatchDetailsScreen(
                matchInfo: info,
                matchScore: score,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
// ─── Tab: Recent / Completed Matches ──────────────────────
// ═══════════════════════════════════════════════════════════

class _RecentTab extends ConsumerWidget {
  const _RecentTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncVal = ref.watch(recentMatchesApiProvider);

    return RefreshIndicator(
      color: AppColors.accentGreen,
      backgroundColor: AppColors.secondarySurface,
      onRefresh: () async {
        ref.invalidate(recentMatchesApiProvider);
        await ref
            .read(recentMatchesApiProvider.future)
            .catchError((_) => <String, dynamic>{});
      },
      child: _buildContent(context, asyncVal),
    );
  }

  Widget _buildContent(
      BuildContext context, AsyncValue<Map<String, dynamic>> asyncVal) {
    if (asyncVal.isLoading && !asyncVal.hasValue) {
      return const _MatchListShimmer();
    }
    if (asyncVal.hasError && !asyncVal.hasValue) {
      return _ErrorView(
        error: asyncVal.error!,
        onRetry: () {},
      );
    }
    final data = asyncVal.value;
    if (data == null) return const _MatchListShimmer();

    final matches = _parseMatches(data, stateFilter: UiMatchState.completed);
    if (matches.isEmpty) {
      return const _EmptyView(
        icon: Icons.history,
        message: 'No recent results',
        subtitle: 'Pull down to refresh',
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacingLg,
        AppConstants.spacingSm,
        AppConstants.spacingLg,
        100,
      ),
      itemCount: matches.length,
      itemBuilder: (ctx, i) {
        final info =
            matches[i]['matchInfo'] as Map<String, dynamic>? ?? {};
        final score =
            matches[i]['matchScore'] as Map<String, dynamic>?;
        return ApiMatchCard(
          key: ValueKey(info['matchId']),
          matchInfo: info,
          matchScore: score,
          onTap: () => Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => ApiMatchDetailsScreen(
                matchInfo: info,
                matchScore: score,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
// ─── Shared Helpers ───────────────────────────────────────
// ═══════════════════════════════════════════════════════════

List<Map<String, dynamic>> _parseMatches(
  Map<String, dynamic> data, {
  UiMatchState? stateFilter,
}) {
  final allMatches = <Map<String, dynamic>>[];
  final typeMatches = data['typeMatches'] as List<dynamic>? ?? [];
  for (final type in typeMatches) {
    final typeMap = type as Map<String, dynamic>? ?? {};
    final seriesMatches = typeMap['seriesMatches'] as List<dynamic>? ?? [];
    for (final series in seriesMatches) {
      final seriesMap = series as Map<String, dynamic>? ?? {};
      final wrapper =
          seriesMap['seriesAdWrapper'] as Map<String, dynamic>?;
      if (wrapper == null) continue;
      final matches = wrapper['matches'] as List<dynamic>? ?? [];
      for (final match in matches) {
        final matchMap = match as Map<String, dynamic>? ?? {};
        if (stateFilter != null) {
          final info = matchMap['matchInfo'] as Map<String, dynamic>? ?? {};
          final uiState = classifyMatchState(info);
          if (uiState != stateFilter) continue;
        }
        allMatches.add(matchMap);
      }
    }
  }
  return allMatches;
}

// ─── Loading Shimmer ───────────────────────────────────────

class _MatchListShimmer extends StatelessWidget {
  const _MatchListShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacingLg,
        AppConstants.spacingSm,
        AppConstants.spacingLg,
        100,
      ),
      itemCount: 5,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: AppConstants.spacingSm),
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 120,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.elevated,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 80,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.elevated,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    width: 50,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.elevated,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 80,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.elevated,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    width: 50,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.elevated,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Error View ────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final message = error.toString().replaceFirst('Exception: ', '');
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      children: [
        const SizedBox(height: 60),
        Icon(
          Icons.cloud_off_rounded,
          color: AppColors.alertWicket.withValues(alpha: 0.5),
          size: 48,
        ),
        const SizedBox(height: 12),
        Text(
          message,
          style: AppTypography.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Center(
          child: GestureDetector(
            onTap: onRetry,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Retry',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.accentGreen,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Empty View ────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final IconData icon;
  final String message;
  final String subtitle;

  const _EmptyView({
    required this.icon,
    required this.message,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Icon(
          icon,
          color: AppColors.textTertiary.withValues(alpha: 0.4),
          size: 56,
        ),
        const SizedBox(height: 12),
        Text(
          message,
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: AppTypography.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
