import 'dart:async';
import 'dart:math';

import '../models/ball_event.dart';
import 'mock_data.dart';

/// In-memory mock WebSocket service that simulates realistic
/// live cricket match events.
///
/// Emits [MatchUpdate] events every 3–8 seconds with randomized
/// runs, boundaries, wickets, and extras — mimicking a real
/// ball-by-ball data feed.
class MockWebSocketService {
  MockWebSocketService();

  final _random = Random();
  final _controller = StreamController<MatchUpdate>.broadcast();
  Timer? _timer;

  // ─── Mutable match state ─────────────────────────────────
  int _runs = 156;
  int _wickets = 3;
  int _overNumber = 16;
  int _ballNumber = 2;
  double _winProb = 0.58;
  final List<String> _recentBalls = ['1', '4', '0', '2', '6', 'W'];
  final int _target = 186;

  /// The live score stream. Subscribe to receive [MatchUpdate]s.
  Stream<MatchUpdate> get scoreStream => _controller.stream;

  /// Start emitting mock events.
  void connect() {
    _scheduleNextEvent();
  }

  /// Stop emitting and clean up.
  void disconnect() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    disconnect();
    _controller.close();
  }

  // ─── Event Generation ────────────────────────────────────

  void _scheduleNextEvent() {
    final delay = Duration(
      milliseconds: 3000 + _random.nextInt(5000), // 3–8s
    );
    _timer = Timer(delay, _emitEvent);
  }

  void _emitEvent() {
    if (_controller.isClosed) return;

    // Determine what happens on this ball
    final event = _generateBallEvent();

    // Update running totals
    _runs += event.runs + (event.isWide || event.isNoBall ? 1 : 0);
    if (event.isWicket) _wickets++;

    // Advance ball count (wides/no-balls don't count)
    if (!event.isWide && !event.isNoBall) {
      _ballNumber++;
      if (_ballNumber > 6) {
        _ballNumber = 1;
        _overNumber++;
      }
    }

    // Update recent balls
    _recentBalls.add(event.shortLabel);
    if (_recentBalls.length > 6) _recentBalls.removeAt(0);

    // Adjust win probability
    _winProb = (_winProb + (_random.nextDouble() * 0.08 - 0.04))
        .clamp(0.05, 0.95);

    final overs = _overNumber + (_ballNumber - 1) / 10;
    final crr = overs > 0 ? _runs / overs : 0.0;
    final oversRemaining = 20.0 - overs;
    final rrr =
        oversRemaining > 0 ? (_target - _runs) / oversRemaining : 0.0;

    // Check for match completion
    final isChaseComplete = _runs >= _target;
    final isAllOut = _wickets >= 10;
    final isOversFinished = _overNumber >= 20;
    final matchEnded = isChaseComplete || isAllOut || isOversFinished;

    String? result;
    if (isChaseComplete) {
      result =
          '${MockData.csk.shortName} won by ${10 - _wickets} wickets';
    } else if (isAllOut || isOversFinished) {
      final margin = _target - _runs - 1;
      result = '${MockData.mi.shortName} won by $margin runs';
    }

    _controller.add(MatchUpdate(
      matchId: 'match_1',
      totalRuns: _runs,
      totalWickets: _wickets,
      overs: overs,
      currentRunRate: crr,
      requiredRunRate: rrr > 0 ? rrr : null,
      matchStatus: matchEnded ? 'completed' : 'live',
      result: result,
      winProbabilityTeamA: _winProb,
      latestBall: event,
      recentBalls: List.from(_recentBalls),
      target: _target,
    ));

    // Continue or stop
    if (!matchEnded) {
      _scheduleNextEvent();
    }
  }

  BallEvent _generateBallEvent() {
    // Weighted random outcomes
    final roll = _random.nextInt(100);

    if (roll < 3 && _wickets < 10) {
      // 3% — Wicket
      return BallEvent(
        matchId: 'match_1',
        overNumber: _overNumber,
        ballNumber: _ballNumber,
        runs: 0,
        isWicket: true,
        commentary:
            'WICKET! Big breakthrough for ${MockData.mi.shortName}!',
        timestamp: DateTime.now(),
      );
    } else if (roll < 8) {
      // 5% — Six
      return BallEvent(
        matchId: 'match_1',
        overNumber: _overNumber,
        ballNumber: _ballNumber,
        runs: 6,
        isSix: true,
        commentary: 'SIX! Massive hit into the stands!',
        timestamp: DateTime.now(),
      );
    } else if (roll < 18) {
      // 10% — Four
      return BallEvent(
        matchId: 'match_1',
        overNumber: _overNumber,
        ballNumber: _ballNumber,
        runs: 4,
        isFour: true,
        commentary: 'FOUR! Beautiful shot through the covers.',
        timestamp: DateTime.now(),
      );
    } else if (roll < 23) {
      // 5% — Wide
      return BallEvent(
        matchId: 'match_1',
        overNumber: _overNumber,
        ballNumber: _ballNumber,
        runs: 0,
        isWide: true,
        commentary: 'Wide ball, straying down the leg side.',
        timestamp: DateTime.now(),
      );
    } else if (roll < 25) {
      // 2% — No ball
      return BallEvent(
        matchId: 'match_1',
        overNumber: _overNumber,
        ballNumber: _ballNumber,
        runs: _random.nextInt(2),
        isNoBall: true,
        commentary: 'No ball! Overstepped the crease.',
        timestamp: DateTime.now(),
      );
    } else if (roll < 50) {
      // 25% — Dot ball
      return BallEvent(
        matchId: 'match_1',
        overNumber: _overNumber,
        ballNumber: _ballNumber,
        runs: 0,
        commentary: 'Good delivery, dot ball.',
        timestamp: DateTime.now(),
      );
    } else if (roll < 75) {
      // 25% — Single
      return BallEvent(
        matchId: 'match_1',
        overNumber: _overNumber,
        ballNumber: _ballNumber,
        runs: 1,
        commentary: 'Single taken, quick running.',
        timestamp: DateTime.now(),
      );
    } else if (roll < 90) {
      // 15% — Two runs
      return BallEvent(
        matchId: 'match_1',
        overNumber: _overNumber,
        ballNumber: _ballNumber,
        runs: 2,
        commentary: 'Pushed to the gap, two runs.',
        timestamp: DateTime.now(),
      );
    } else {
      // 10% — Three runs
      return BallEvent(
        matchId: 'match_1',
        overNumber: _overNumber,
        ballNumber: _ballNumber,
        runs: 3,
        commentary: 'Good placement, three runs taken.',
        timestamp: DateTime.now(),
      );
    }
  }
}
