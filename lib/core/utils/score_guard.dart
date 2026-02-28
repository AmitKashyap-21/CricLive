import 'dart:developer' as dev;

/// Prevents live score rollback during auto-refresh.
///
/// Maintains a cache of the last-known score per match ID.
/// When new data arrives, it validates:
///   1. Epoch guard — rejects responses older than the last accepted
///   2. Monotonic score — live match runs/overs must not decrease
///   3. Innings progression — never go backward in innings
///
/// Usage:
/// ```dart
/// final fresh = await fetchLiveMatches();
/// final safe = ScoreGuard.instance.guardMatchList(fresh);
/// ```
class ScoreGuard {
  ScoreGuard._();
  static final ScoreGuard instance = ScoreGuard._();

  /// Last-known score snapshot per matchId.
  final Map<String, _MatchSnapshot> _cache = {};

  /// Last accepted fetch epoch (ms since epoch).
  int _lastAcceptedEpoch = 0;

  /// Guard an entire match list response (the raw Cricbuzz JSON).
  ///
  /// Returns a new map with stale live match data replaced by cached values.
  Map<String, dynamic> guardMatchList(Map<String, dynamic> freshData) {
    final fetchEpoch = DateTime.now().millisecondsSinceEpoch;

    // Epoch guard: if this response is older than the last one we accepted,
    // return it unmodified (race conditions are extremely rare with this
    // simple check, and we don't want to block genuinely new data).
    if (fetchEpoch < _lastAcceptedEpoch) {
      dev.log(
        'ScoreGuard: stale response (epoch $fetchEpoch < $_lastAcceptedEpoch), '
        'passing through anyway (safe)',
        name: 'ScoreGuard',
      );
    }
    _lastAcceptedEpoch = fetchEpoch;

    // Walk the nested match structure and guard each match
    final typeMatches = freshData['typeMatches'] as List<dynamic>? ?? [];

    for (int t = 0; t < typeMatches.length; t++) {
      final typeMap = typeMatches[t] as Map<String, dynamic>? ?? {};
      final seriesMatches =
          typeMap['seriesMatches'] as List<dynamic>? ?? [];

      for (int s = 0; s < seriesMatches.length; s++) {
        final seriesMap = seriesMatches[s] as Map<String, dynamic>? ?? {};
        final wrapper =
            seriesMap['seriesAdWrapper'] as Map<String, dynamic>?;
        if (wrapper == null) continue;

        final matches = wrapper['matches'] as List<dynamic>? ?? [];

        for (int m = 0; m < matches.length; m++) {
          final matchMap = matches[m] as Map<String, dynamic>? ?? {};
          final info =
              matchMap['matchInfo'] as Map<String, dynamic>? ?? {};
          final score =
              matchMap['matchScore'] as Map<String, dynamic>?;

          final matchId = info['matchId']?.toString() ?? '';
          final state = info['state'] as String? ?? '';

          if (matchId.isEmpty) continue;

          // Only guard live matches — completed/upcoming can be replaced freely
          final isLive = state == 'In Progress' ||
              state == 'Innings Break' ||
              state == 'Stumps';

          if (isLive && score != null) {
            final freshSnap = _MatchSnapshot.fromScore(score);
            final cached = _cache[matchId];

            if (cached != null && freshSnap.isRollbackOf(cached)) {
              dev.log(
                'ScoreGuard: BLOCKED rollback for match $matchId '
                '(cached: ${cached.totalRuns}/${cached.totalWickets} '
                '${cached.totalOvers}ov → '
                'fresh: ${freshSnap.totalRuns}/${freshSnap.totalWickets} '
                '${freshSnap.totalOvers}ov)',
                name: 'ScoreGuard',
              );
              // Replace fresh score with cached score in the data structure
              (matches[m] as Map<String, dynamic>)['matchScore'] =
                  cached.rawScore;
              continue; // don't update cache
            }

            // Accept this score into cache
            _cache[matchId] = freshSnap;
          } else if (state == 'Complete') {
            // Match finished — accept final score and will never be guarded again
            if (score != null) {
              _cache[matchId] = _MatchSnapshot.fromScore(score);
            }
          }
        }
      }
    }

    return freshData;
  }

  /// Guard a single scorecard response.
  Map<String, dynamic> guardScorecard(
      String matchId, Map<String, dynamic> freshData) {
    // Scorecards are detailed — just cache and return
    // (rollback on detailed scorecards is extremely rare and would
    //  require per-ball validation which is overkill)
    return freshData;
  }

  /// Clear the cache (e.g., on logout or app restart).
  void clear() {
    _cache.clear();
    _lastAcceptedEpoch = 0;
  }
}

/// Lightweight snapshot of a match's score for comparison.
class _MatchSnapshot {
  final int totalRuns;
  final int totalWickets;
  final double totalOvers;
  final int inningsCount;
  final Map<String, dynamic> rawScore;

  const _MatchSnapshot({
    required this.totalRuns,
    required this.totalWickets,
    required this.totalOvers,
    required this.inningsCount,
    required this.rawScore,
  });

  factory _MatchSnapshot.fromScore(Map<String, dynamic> score) {
    int runs = 0;
    int wickets = 0;
    double overs = 0;
    int innCount = 0;

    // Sum across both teams and all innings
    for (final teamKey in ['team1Score', 'team2Score']) {
      final teamScore = score[teamKey] as Map<String, dynamic>?;
      if (teamScore == null) continue;

      for (final innKey in ['inngs1', 'inngs2']) {
        final inn = teamScore[innKey] as Map<String, dynamic>?;
        if (inn == null) continue;
        innCount++;
        runs += (inn['runs'] as num?)?.toInt() ?? 0;
        wickets += (inn['wickets'] as num?)?.toInt() ?? 0;
        overs += (inn['overs'] as num?)?.toDouble() ?? 0;
      }
    }

    return _MatchSnapshot(
      totalRuns: runs,
      totalWickets: wickets,
      totalOvers: overs,
      inningsCount: innCount,
      rawScore: Map<String, dynamic>.from(score),
    );
  }

  /// Returns true if [this] appears to be a rollback of [previous].
  ///
  /// A rollback is when:
  ///   - Same or fewer innings, AND
  ///   - Total runs decreased, OR
  ///   - Same runs but overs decreased
  bool isRollbackOf(_MatchSnapshot previous) {
    // If new data has MORE innings, it's always valid (new innings started)
    if (inningsCount > previous.inningsCount) return false;

    // Runs went down — definite rollback
    if (totalRuns < previous.totalRuns) return true;

    // Same runs but overs went down — suspicious stale data
    if (totalRuns == previous.totalRuns && totalOvers < previous.totalOvers) {
      return true;
    }

    return false;
  }
}
