import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/auto_refresh_controller.dart';
import '../../../core/utils/match_state_classifier.dart';
import '../../../providers/providers.dart';

/// Full match details screen — opens when tapping any ApiMatchCard.
///
/// Auto-refresh: Live matches refresh scorecard every 20s.
/// Timer pauses on app background, stops on dispose.
class ApiMatchDetailsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> matchInfo;
  final Map<String, dynamic>? matchScore;

  const ApiMatchDetailsScreen({
    super.key,
    required this.matchInfo,
    this.matchScore,
  });

  @override
  ConsumerState<ApiMatchDetailsScreen> createState() =>
      _ApiMatchDetailsScreenState();
}

class _ApiMatchDetailsScreenState extends ConsumerState<ApiMatchDetailsScreen>
    with WidgetsBindingObserver {
  final AutoRefreshController _autoRefresh = AutoRefreshController();
  static const _liveRefreshInterval = Duration(seconds: 20);

  Map<String, dynamic> get matchInfo => widget.matchInfo;
  Map<String, dynamic>? get matchScore => widget.matchScore;

  bool get _isLive {
    final uiState = classifyMatchState(matchInfo);
    return uiState == UiMatchState.live || uiState == UiMatchState.dayBreak;
  }

  String get _matchId => matchInfo['matchId']?.toString() ?? '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startAutoRefreshIfLive();
  }

  @override
  void dispose() {
    _autoRefresh.stop();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _autoRefresh.stop();
    } else if (state == AppLifecycleState.resumed) {
      _startAutoRefreshIfLive();
    }
  }

  void _startAutoRefreshIfLive() {
    if (_isLive && _matchId.isNotEmpty) {
      _autoRefresh.start(
        interval: _liveRefreshInterval,
        onRefresh: () {
          if (!mounted) return;
          ref.invalidate(scorecardProvider(_matchId));
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scorecardAsync =
        _matchId.isNotEmpty ? ref.watch(scorecardProvider(_matchId)) : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.all(AppConstants.spacingLg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildScoreCard(),
                const SizedBox(height: AppConstants.spacingLg),
                _buildStatusSection(),
                const SizedBox(height: AppConstants.spacingLg),
                _buildVenueSection(),
                const SizedBox(height: AppConstants.spacingXl),
                _buildScorecardSection(scorecardAsync),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ─── App Bar ──────────────────────────────────────────────

  Widget _buildSliverAppBar(BuildContext context) {
    final seriesName = matchInfo['seriesName'] as String? ?? '';
    final matchDesc = matchInfo['matchDesc'] as String? ?? '';
    
    final uiState = classifyMatchState(matchInfo);
    final badgeLabel = matchBadgeLabel(matchInfo);
    final isLiveActive = uiState == UiMatchState.live;

    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            seriesName.isNotEmpty ? seriesName : 'Match Details',
            style: AppTypography.labelLarge.copyWith(fontSize: 15),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (matchDesc.isNotEmpty)
            Text(
              matchDesc,
              style: AppTypography.labelSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      actions: [
        if (isLiveActive)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _statusBadge(uiState, badgeLabel),
          ),
      ],
    );
  }

  // ─── Score Card (main) ────────────────────────────────────

  Widget _buildScoreCard() {
    final team1 = matchInfo['team1'] as Map<String, dynamic>? ?? {};
    final team2 = matchInfo['team2'] as Map<String, dynamic>? ?? {};
    final team1Name =
        team1['teamSName'] as String? ?? team1['teamName'] as String? ?? '???';
    final team2Name =
        team2['teamSName'] as String? ?? team2['teamName'] as String? ?? '???';
    final team1Full = team1['teamName'] as String? ?? team1Name;
    final team2Full = team2['teamName'] as String? ?? team2Name;

    final team1Score = _getTeamScoreStr(matchScore, 'team1Score');
    final team2Score = _getTeamScoreStr(matchScore, 'team2Score');

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _scoreRow(team1Name, team1Full, team1Score),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Divider(
                    color: AppColors.border,
                    thickness: 0.5,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'VS',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textDisabled,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: AppColors.border,
                    thickness: 0.5,
                  ),
                ),
              ],
            ),
          ),
          _scoreRow(team2Name, team2Full, team2Score),
        ],
      ),
    );
  }

  Widget _scoreRow(String shortName, String fullName, String? score) {
    return Row(
      children: [
        // Team icon circle
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.elevated,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            shortName.length >= 2
                ? shortName.substring(0, 2)
                : shortName,
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullName,
                style: AppTypography.labelLarge.copyWith(fontSize: 15),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (score != null)
                Text(
                  score,
                  style: AppTypography.scoreMedium.copyWith(
                    fontSize: 26,
                    color: AppColors.textPrimary,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Status Section ───────────────────────────────────────

  Widget _buildStatusSection() {
    final status = matchInfo['status'] as String? ?? '';

    if (status.isEmpty) return const SizedBox.shrink();

    final uiState = classifyMatchState(matchInfo);
    final badgeLabel = matchBadgeLabel(matchInfo);
    
    final isLiveActive = uiState == UiMatchState.live;
    final isDayBreak = uiState == UiMatchState.dayBreak;
    final isComplete = uiState == UiMatchState.completed;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: (isLiveActive 
                ? AppColors.live
                : isDayBreak
                    ? AppColors.upcoming
                    : isComplete
                        ? AppColors.completed
                        : AppColors.upcoming)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isLiveActive
                  ? AppColors.live
                  : isDayBreak
                      ? AppColors.upcoming
                      : isComplete
                          ? AppColors.completed
                          : AppColors.upcoming)
              .withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          _statusBadge(uiState, badgeLabel),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              status,
              style: AppTypography.bodyMedium.copyWith(
                color: isLiveActive || isDayBreak
                    ? AppColors.secondary
                    : isComplete
                        ? AppColors.completed
                        : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(UiMatchState uiState, String badgeLabel) {
    final isLiveActive = uiState == UiMatchState.live;
    final isComplete = uiState == UiMatchState.completed;

    final color = isLiveActive
        ? AppColors.live
        : isComplete
            ? AppColors.completed
            : AppColors.upcoming;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isLiveActive ? color : color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: isLiveActive
            ? null
            : Border.all(color: color.withValues(alpha: 0.4), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLiveActive) ...[
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            badgeLabel,
            style: TextStyle(
              color: isLiveActive ? Colors.white : color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Venue Section ────────────────────────────────────────

  Widget _buildVenueSection() {
    final venueInfo =
        matchInfo['venueInfo'] as Map<String, dynamic>?;
    if (venueInfo == null) return const SizedBox.shrink();

    final ground = venueInfo['ground'] as String? ?? '';
    final city = venueInfo['city'] as String? ?? '';
    final country = venueInfo['country'] as String? ?? '';

    if (ground.isEmpty && city.isEmpty) return const SizedBox.shrink();

    final locationParts = [city, country].where((s) => s.isNotEmpty);
    final locationStr = locationParts.join(', ');

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(
            Icons.stadium_outlined,
            color: AppColors.textTertiary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (ground.isNotEmpty)
                  Text(
                    ground,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                if (locationStr.isNotEmpty)
                  Text(
                    locationStr,
                    style: AppTypography.labelSmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Scorecard Section (fetched from API) ─────────────────

  Widget _buildScorecardSection(
      AsyncValue<Map<String, dynamic>>? scorecardAsync) {
    if (scorecardAsync == null) {
      return _infoMessage('Match scorecard not available');
    }

    // Silent refresh: keep showing old data during background re-fetch
    if (scorecardAsync.isLoading && !scorecardAsync.hasValue) {
      return _scorecardLoading();
    }
    if (scorecardAsync.hasError && !scorecardAsync.hasValue) {
      return _infoMessage(
        'Could not load scorecard: ${scorecardAsync.error.toString().replaceFirst("Exception: ", "")}',
      );
    }
    final data = scorecardAsync.value;
    if (data == null) return _scorecardLoading();
    return _buildScorecardTabs(data);
  }

  Widget _buildScorecardTabs(Map<String, dynamic> scorecardData) {
    // Parse innings from scorecard
    final scoreCard = scorecardData['scoreCard'] as List<dynamic>? ?? [];

    if (scoreCard.isEmpty) {
      return _infoMessage('Scorecard data will appear once play begins');
    }

    return DefaultTabController(
      length: scoreCard.length + 1, // innings + Info tab
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Section header
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Scorecard',
              style: AppTypography.headlineSmall,
            ),
          ),
          const SizedBox(height: AppConstants.spacingSm),

          // Tab bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: AppColors.secondary,
              labelColor: AppColors.secondary,
              unselectedLabelColor: AppColors.textTertiary,
              labelStyle: AppTypography.labelMedium
                  .copyWith(fontWeight: FontWeight.w600),
              unselectedLabelStyle: AppTypography.labelSmall,
              dividerColor: Colors.transparent,
              tabs: [
                for (int i = 0; i < scoreCard.length; i++)
                  Tab(text: _inningsTabLabel(scoreCard[i], i)),
                const Tab(text: 'Match Info'),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingSm),

          // Tab content — use SizedBox with intrinsic or fixed height
          SizedBox(
            height: 500,
            child: TabBarView(
              children: [
                for (final innings in scoreCard)
                  _InningsTab(
                    innings: innings as Map<String, dynamic>? ?? {},
                  ),
                _MatchInfoTab(matchInfo: matchInfo),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _inningsTabLabel(dynamic innings, int index) {
    final map = innings as Map<String, dynamic>? ?? {};
    final batTeamName = map['batTeamDetails'] as Map<String, dynamic>?;
    final shortName =
        batTeamName?['batTeamShortName'] as String? ?? 'Inn ${index + 1}';
    return shortName;
  }

  Widget _scorecardLoading() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Scorecard', style: AppTypography.headlineSmall),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        for (int i = 0; i < 4; i++)
          Container(
            height: 40,
            margin:
                const EdgeInsets.only(bottom: AppConstants.spacingSm),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
      ],
    );
  }

  Widget _infoMessage(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.textDisabled,
            size: 24,
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: AppTypography.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── Score helpers ────────────────────────────────────────

  String? _getTeamScoreStr(Map<String, dynamic>? ms, String key) {
    if (ms == null) return null;
    final teamScore = ms[key] as Map<String, dynamic>?;
    if (teamScore == null) return null;

    final inngs1 = teamScore['inngs1'] as Map<String, dynamic>?;
    final inngs2 = teamScore['inngs2'] as Map<String, dynamic>?;

    String? scoreStr;
    if (inngs2 != null) {
      scoreStr = _fmtInnings(inngs2);
      final inngs1Str = _fmtInnings(inngs1);
      if (inngs1Str != null && scoreStr != null) {
        scoreStr = '$inngs1Str & $scoreStr';
      }
    } else if (inngs1 != null) {
      scoreStr = _fmtInnings(inngs1);
    }
    return scoreStr;
  }

  String? _fmtInnings(Map<String, dynamic>? innings) {
    if (innings == null) return null;
    final runs = innings['runs'];
    final wickets = innings['wickets'];
    final overs = innings['overs'];
    if (runs == null) return null;
    final w = wickets != null ? '/$wickets' : '';
    final o = overs != null ? ' ($overs)' : '';
    return '$runs$w$o';
  }
}

// ═══════════════════════════════════════════════════════════
// ─── Innings Tab (Batting + Bowling) ──────────────────────
// ═══════════════════════════════════════════════════════════

class _InningsTab extends StatelessWidget {
  final Map<String, dynamic> innings;

  const _InningsTab({required this.innings});

  @override
  Widget build(BuildContext context) {
    final batsmen =
        innings['batTeamDetails']?['batsmenData'] as Map<String, dynamic>? ??
            {};
    final bowlers =
        innings['bowlTeamDetails']?['bowlersData'] as Map<String, dynamic>? ??
            {};

    // Filter out non-player keys
    final batList = batsmen.entries
        .where((e) => e.key.startsWith('bat_'))
        .map((e) => e.value as Map<String, dynamic>)
        .toList();
    final bowlList = bowlers.entries
        .where((e) => e.key.startsWith('bowl_'))
        .map((e) => e.value as Map<String, dynamic>)
        .toList();

    // Innings score summary
    final scoreDetails =
        innings['scoreDetails'] as Map<String, dynamic>? ?? {};
    final runs = scoreDetails['runs'] ?? '';
    final wickets = scoreDetails['wickets'] ?? '';
    final overs = scoreDetails['overs'] ?? '';

    return ListView(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingXl),
      children: [
        // Innings summary
        Container(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          decoration: BoxDecoration(
            color: AppColors.elevated,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$runs/$wickets ($overs ov)',
            style: AppTypography.scoreMedium.copyWith(fontSize: 24),
          ),
        ),
        const SizedBox(height: AppConstants.spacingMd),

        // ─── Batting Header ──────
        _sectionLabel('Batting'),
        _battingHeader(),
        for (final bat in batList) _battingRow(bat),
        const SizedBox(height: AppConstants.spacingLg),

        // ─── Bowling Header ──────
        _sectionLabel('Bowling'),
        _bowlingHeader(),
        for (final bowl in bowlList) _bowlingRow(bowl),
      ],
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(label, style: AppTypography.labelLarge),
    );
  }

  // ─── Batting rows ────────────────────────────────────────

  Widget _battingHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text('Batter',
                style: AppTypography.labelSmall
                    .copyWith(fontWeight: FontWeight.w600)),
          ),
          _statHeader('R', flex: 1),
          _statHeader('B', flex: 1),
          _statHeader('4s', flex: 1),
          _statHeader('6s', flex: 1),
          _statHeader('SR', flex: 2),
        ],
      ),
    );
  }

  Widget _battingRow(Map<String, dynamic> bat) {
    final name = bat['batName'] as String? ?? '';
    final runs = bat['runs'] ?? '-';
    final balls = bat['balls'] ?? '-';
    final fours = bat['fours'] ?? '-';
    final sixes = bat['sixes'] ?? '-';
    final sr = bat['strikeRate'] ?? '-';
    final outDesc = bat['outDesc'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  name,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _statValue('$runs', flex: 1, bold: true),
              _statValue('$balls', flex: 1),
              _statValue('$fours', flex: 1),
              _statValue('$sixes', flex: 1),
              _statValue('$sr', flex: 2),
            ],
          ),
          if (outDesc.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                outDesc,
                style: AppTypography.labelSmall.copyWith(fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  // ─── Bowling rows ────────────────────────────────────────

  Widget _bowlingHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text('Bowler',
                style: AppTypography.labelSmall
                    .copyWith(fontWeight: FontWeight.w600)),
          ),
          _statHeader('O', flex: 1),
          _statHeader('R', flex: 1),
          _statHeader('W', flex: 1),
          _statHeader('Eco', flex: 2),
        ],
      ),
    );
  }

  Widget _bowlingRow(Map<String, dynamic> bowl) {
    final name = bowl['bowlName'] as String? ?? '';
    final overs = bowl['overs'] ?? '-';
    final runs = bowl['runs'] ?? '-';
    final wickets = bowl['wickets'] ?? '-';
    final economy = bowl['economy'] ?? '-';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              name,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _statValue('$overs', flex: 1),
          _statValue('$runs', flex: 1),
          _statValue('$wickets', flex: 1, bold: true),
          _statValue('$economy', flex: 2),
        ],
      ),
    );
  }

  // ─── Stat helpers ────────────────────────────────────────

  Widget _statHeader(String label, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w600),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _statValue(String value, {int flex = 1, bool bold = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        value,
        style: AppTypography.labelMedium.copyWith(
          color: AppColors.textPrimary,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// ─── Match Info Tab ───────────────────────────────────────
// ═══════════════════════════════════════════════════════════

class _MatchInfoTab extends StatelessWidget {
  final Map<String, dynamic> matchInfo;

  const _MatchInfoTab({required this.matchInfo});

  @override
  Widget build(BuildContext context) {
    final seriesName = matchInfo['seriesName'] as String? ?? '';
    final matchDesc = matchInfo['matchDesc'] as String? ?? '';
    final matchFormat = matchInfo['matchFormat'] as String? ?? '';
    final state = matchInfo['state'] as String? ?? '';
    final status = matchInfo['status'] as String? ?? '';
    final tossResults = matchInfo['tossResults'] as Map<String, dynamic>?;
    final venueInfo = matchInfo['venueInfo'] as Map<String, dynamic>?;

    return ListView(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingXl),
      children: [
        if (seriesName.isNotEmpty)
          _infoRow(Icons.emoji_events_outlined, 'Series', seriesName),
        if (matchDesc.isNotEmpty)
          _infoRow(Icons.description_outlined, 'Match', matchDesc),
        if (matchFormat.isNotEmpty)
          _infoRow(Icons.category_outlined, 'Format', matchFormat),
        if (state.isNotEmpty)
          _infoRow(Icons.flag_outlined, 'State', state),
        if (status.isNotEmpty)
          _infoRow(Icons.info_outline, 'Status', status),
        if (tossResults != null) ...[
          _infoRow(
            Icons.compare_arrows,
            'Toss',
            '${tossResults['tossWinnerName'] ?? ''} ${tossResults['decision'] ?? ''}',
          ),
        ],
        if (venueInfo != null) ...[
          _infoRow(
            Icons.stadium_outlined,
            'Venue',
            venueInfo['ground'] as String? ?? '',
          ),
          _infoRow(
            Icons.location_on_outlined,
            'Location',
            '${venueInfo['city'] ?? ''}, ${venueInfo['country'] ?? ''}',
          ),
        ],
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    if (value.trim().isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSm),
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 0.3),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textTertiary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.labelSmall
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
