import 'dart:developer' as dev;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/score_guard.dart';
import '../data/models/ball_event.dart';
import '../data/models/match.dart';
import '../data/services/mock_data.dart';
import '../data/services/mock_websocket_service.dart';
import '../features/matches/data/cricket_api_service.dart';

// ─── Cricket API Service ───────────────────────────────────

final cricketApiServiceProvider = Provider<CricketApiService>((ref) {
  return CricketApiService();
});

// ─── Live Matches from Cricbuzz API ────────────────────────

final liveMatchesApiProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(cricketApiServiceProvider);
  dev.log('liveMatchesApiProvider ▶ fetching', name: 'Providers');
  final data = await service.fetchLiveMatches();
  dev.log('liveMatchesApiProvider ◀ received', name: 'Providers');
  // Guard against score rollback
  return ScoreGuard.instance.guardMatchList(data);
});

// ─── Recent Matches from Cricbuzz API ──────────────────────

final recentMatchesApiProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(cricketApiServiceProvider);
  dev.log('recentMatchesApiProvider ▶ fetching', name: 'Providers');
  final data = await service.fetchRecentMatches();
  dev.log('recentMatchesApiProvider ◀ received', name: 'Providers');
  return data;
});

// ─── Upcoming Matches from Cricbuzz API ────────────────────

final upcomingMatchesApiProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(cricketApiServiceProvider);
  dev.log('upcomingMatchesApiProvider ▶ fetching', name: 'Providers');
  final data = await service.fetchUpcomingMatches();
  dev.log('upcomingMatchesApiProvider ◀ received', name: 'Providers');
  return data;
});

// ─── Live Scorecard from Cricbuzz API ──────────────────────

final scorecardProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, matchId) async {
  final service = ref.watch(cricketApiServiceProvider);
  dev.log(
    'scorecardProvider ▶ fetching matchId=$matchId',
    name: 'Providers',
  );
  final data = await service.fetchScorecard(matchId);
  dev.log(
    'scorecardProvider ◀ received data for matchId=$matchId',
    name: 'Providers',
  );
  return data;
});

// ─── WebSocket Service (kept for demo/future use) ──────────

final mockWebSocketServiceProvider = Provider<MockWebSocketService>((ref) {
  final service = MockWebSocketService();
  ref.onDispose(() => service.dispose());
  return service;
});

final liveScoreStreamProvider = StreamProvider<MatchUpdate>((ref) {
  final service = ref.watch(mockWebSocketServiceProvider);
  return service.scoreStream;
});

// ─── Mock Matches (kept as fallback) ───────────────────────

final matchesProvider =
    NotifierProvider<MatchesNotifier, List<Match>>(MatchesNotifier.new);

class MatchesNotifier extends Notifier<List<Match>> {
  @override
  List<Match> build() {
    ref.listen<AsyncValue<MatchUpdate>>(liveScoreStreamProvider,
        (previous, next) {
      next.whenData((update) {
        applyUpdate(update);
      });
    });
    return MockData.sampleMatches;
  }

  void applyUpdate(MatchUpdate update) {
    state = [
      for (final match in state)
        if (match.id == update.matchId)
          match.copyWith(
            status: update.matchStatus == 'completed'
                ? MatchStatus.completed
                : MatchStatus.live,
            result: update.result,
            winProbabilityTeamA: update.winProbabilityTeamA,
            recentBalls: update.recentBalls,
            currentInnings: match.currentInnings?.copyWith(
              runs: update.totalRuns,
              wickets: update.totalWickets,
              overs: update.overs,
              runRate: update.currentRunRate,
              requiredRunRate: update.requiredRunRate,
              target: update.target,
            ),
          )
        else
          match,
    ];
  }
}

final liveMatchesProvider = Provider<List<Match>>((ref) {
  return ref.watch(matchesProvider).where((m) => m.isLive).toList();
});

final upcomingMatchesProvider = Provider<List<Match>>((ref) {
  return ref.watch(matchesProvider).where((m) => m.isUpcoming).toList();
});

final completedMatchesProvider = Provider<List<Match>>((ref) {
  return ref.watch(matchesProvider).where((m) => m.isCompleted).toList();
});

final matchByIdProvider =
    Provider.family<Match?, String>((ref, matchId) {
  final matches = ref.watch(matchesProvider);
  try {
    return matches.firstWhere((m) => m.id == matchId);
  } catch (_) {
    return null;
  }
});

final latestBallEventProvider = Provider<BallEvent?>((ref) {
  final scoreUpdate = ref.watch(liveScoreStreamProvider);
  return scoreUpdate.value?.latestBall;
});

// ─── Navigation ────────────────────────────────────────────

final currentTabProvider = NotifierProvider<CurrentTabNotifier, int>(
    CurrentTabNotifier.new);

class CurrentTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setTab(int index) {
    state = index;
  }
}

// ─── Notification Preferences ──────────────────────────────

final notificationPrefsProvider =
    NotifierProvider<NotificationPrefsNotifier, NotificationPrefs>(
        NotificationPrefsNotifier.new);

class NotificationPrefs {
  final Set<String> favoriteTeamIds;
  final bool wicketAlerts;
  final bool milestoneAlerts;
  final bool matchStartAlerts;
  final bool boundaryAlerts;

  const NotificationPrefs({
    this.favoriteTeamIds = const {},
    this.wicketAlerts = true,
    this.milestoneAlerts = true,
    this.matchStartAlerts = true,
    this.boundaryAlerts = false,
  });

  NotificationPrefs copyWith({
    Set<String>? favoriteTeamIds,
    bool? wicketAlerts,
    bool? milestoneAlerts,
    bool? matchStartAlerts,
    bool? boundaryAlerts,
  }) {
    return NotificationPrefs(
      favoriteTeamIds: favoriteTeamIds ?? this.favoriteTeamIds,
      wicketAlerts: wicketAlerts ?? this.wicketAlerts,
      milestoneAlerts: milestoneAlerts ?? this.milestoneAlerts,
      matchStartAlerts: matchStartAlerts ?? this.matchStartAlerts,
      boundaryAlerts: boundaryAlerts ?? this.boundaryAlerts,
    );
  }
}

class NotificationPrefsNotifier extends Notifier<NotificationPrefs> {
  @override
  NotificationPrefs build() => const NotificationPrefs();

  void toggleFavoriteTeam(String teamId) {
    final updated = Set<String>.from(state.favoriteTeamIds);
    if (updated.contains(teamId)) {
      updated.remove(teamId);
    } else {
      updated.add(teamId);
    }
    state = state.copyWith(favoriteTeamIds: updated);
  }

  void toggleWicketAlerts() {
    state = state.copyWith(wicketAlerts: !state.wicketAlerts);
  }

  void toggleMilestoneAlerts() {
    state = state.copyWith(milestoneAlerts: !state.milestoneAlerts);
  }

  void toggleMatchStartAlerts() {
    state = state.copyWith(matchStartAlerts: !state.matchStartAlerts);
  }

  void toggleBoundaryAlerts() {
    state = state.copyWith(boundaryAlerts: !state.boundaryAlerts);
  }
}
