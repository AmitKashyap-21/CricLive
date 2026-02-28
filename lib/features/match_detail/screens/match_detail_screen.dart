import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../data/models/ball_event.dart';
import '../../../data/models/match.dart' as models;
import '../../../data/services/mock_data.dart';
import '../../../providers/providers.dart';
import '../../../shared/widgets/wicket_flash.dart';
import '../widgets/summary_tab.dart';
import '../widgets/scorecard_tab.dart';
import '../widgets/commentary_tab.dart';
import '../widgets/worm_chart.dart';
import '../widgets/win_probability_bar.dart';

/// Match detail screen with tabbed views:
/// Summary, Scorecard, Commentary, Stats.
class MatchDetailScreen extends ConsumerStatefulWidget {
  final String matchId;

  const MatchDetailScreen({super.key, required this.matchId});

  @override
  ConsumerState<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends ConsumerState<MatchDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _wicketFlash = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final match = ref.watch(matchByIdProvider(widget.matchId));

    // Listen for wickets to trigger haptic + flash
    ref.listen<AsyncValue<MatchUpdate>>(liveScoreStreamProvider,
        (prev, next) {
      next.whenData((update) {
        if (update.matchId == widget.matchId &&
            update.latestBall != null) {
          final ball = update.latestBall!;
          if (ball.isWicket) {
            HapticUtils.wicket();
            setState(() => _wicketFlash = true);
            Future.delayed(const Duration(milliseconds: 400), () {
              if (mounted) setState(() => _wicketFlash = false);
            });
          } else if (ball.isSix) {
            HapticUtils.six();
          } else if (ball.isFour) {
            HapticUtils.boundary();
          }
        }
      });
    });

    if (match == null) {
      return Scaffold(
        backgroundColor: AppColors.primaryBackground,
        appBar: AppBar(title: const Text('Match')),
        body: const Center(child: Text('Match not found')),
      );
    }

    return WicketFlash(
      trigger: _wicketFlash,
      child: Scaffold(
        backgroundColor: AppColors.primaryBackground,
        appBar: AppBar(
          backgroundColor: AppColors.primaryBackground,
          title: Text(
            '${match.teamA.shortName} vs ${match.teamB.shortName}',
            style: AppTypography.headlineMedium,
          ),
          actions: [
            if (match.isLive)
              Container(
                margin: const EdgeInsets.only(right: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.liveIndicator.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.liveIndicator,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'LIVE',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.liveIndicator,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Summary'),
              Tab(text: 'Scorecard'),
              Tab(text: 'Commentary'),
              Tab(text: 'Stats'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Summary tab
            SummaryTab(match: match),

            // Scorecard tab
            ScorecardTab(match: match),

            // Commentary tab
            CommentaryTab(entries: _sampleCommentary()),

            // Stats tab (Worm chart + Win probability)
            _statsTab(match),
          ],
        ),
      ),
    );
  }

  Widget _statsTab(models.Match match) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingLg),
      child: Column(
        children: [
          // Win Probability
          if (match.winProbabilityTeamA != null)
            WinProbabilityBar(
              teamAProbability: match.winProbabilityTeamA!,
              teamALabel: match.teamA.shortName,
              teamBLabel: match.teamB.shortName,
            ),
          const SizedBox(height: AppConstants.spacingLg),

          // Worm Chart
          WormChart(
            teamAData: MockData.sampleWormTeamA,
            teamBData: MockData.sampleWormTeamB,
            teamALabel: match.teamA.shortName,
            teamBLabel: match.teamB.shortName,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  List<CommentaryEntry> _sampleCommentary() {
    return [
      CommentaryEntry(
        overBall: '16.2',
        text:
            'Conway drives through the covers for a single. CSK need 30 runs from 22 balls.',
        type: CommentaryType.normal,
        timestamp: DateTime.now(),
      ),
      CommentaryEntry(
        overBall: '16.1',
        text:
            'SIX! Conway launches Bumrah over long-on! What a shot under pressure!',
        type: CommentaryType.six,
        timestamp: DateTime.now().subtract(const Duration(seconds: 30)),
      ),
      CommentaryEntry(
        overBall: '15.6',
        text: 'End of over 15. CSK 149/3. RR: 9.93',
        type: CommentaryType.overEnd,
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
      CommentaryEntry(
        overBall: '15.5',
        text:
            'FOUR! Guided past the keeper, races to the boundary! Fine touch from Conway.',
        type: CommentaryType.four,
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
      CommentaryEntry(
        overBall: '15.4',
        text: 'Dot ball. Good yorker from Boult, Conway digs it out.',
        type: CommentaryType.normal,
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      CommentaryEntry(
        overBall: '15.3',
        text:
            'WICKET! Moeen Ali departs! Caught at deep midwicket. CSK 112/3.',
        type: CommentaryType.wicket,
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
      CommentaryEntry(
        overBall: '15.2',
        text: 'Two runs. Pushed through midwicket, easy running.',
        type: CommentaryType.normal,
        timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
      ),
      CommentaryEntry(
        overBall: '15.1',
        text: 'Single to start the over. Nudged to the legside.',
        type: CommentaryType.normal,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      CommentaryEntry(
        overBall: '14.6',
        text:
            'FIFTY for Conway! 50* off 34 balls. What an innings!',
        type: CommentaryType.milestone,
        timestamp: DateTime.now().subtract(const Duration(minutes: 6)),
      ),
    ];
  }
}
