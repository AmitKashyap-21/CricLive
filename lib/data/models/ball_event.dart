/// Represents a ball-by-ball event update from the live stream.
class BallEvent {
  final String matchId;
  final int overNumber;
  final int ballNumber;
  final int runs;
  final bool isWicket;
  final bool isFour;
  final bool isSix;
  final bool isWide;
  final bool isNoBall;
  final bool isBye;
  final bool isLegBye;
  final String? batsmanName;
  final String? bowlerName;
  final String? dismissalType;
  final String? dismissedBatsman;
  final String commentary;
  final DateTime timestamp;

  const BallEvent({
    required this.matchId,
    required this.overNumber,
    required this.ballNumber,
    required this.runs,
    this.isWicket = false,
    this.isFour = false,
    this.isSix = false,
    this.isWide = false,
    this.isNoBall = false,
    this.isBye = false,
    this.isLegBye = false,
    this.batsmanName,
    this.bowlerName,
    this.dismissalType,
    this.dismissedBatsman,
    required this.commentary,
    required this.timestamp,
  });

  /// Short label for recent balls display: "0", "1", "4", "6", "W", "Wd", etc.
  String get shortLabel {
    if (isWicket) return 'W';
    if (isWide) return 'Wd';
    if (isNoBall) return 'Nb';
    if (isSix) return '6';
    if (isFour) return '4';
    return '$runs';
  }

  /// Over string like "12.3"
  String get overString => '$overNumber.$ballNumber';
}

/// Aggregated match update pushed via WebSocket.
class MatchUpdate {
  final String matchId;
  final int totalRuns;
  final int totalWickets;
  final double overs;
  final double currentRunRate;
  final double? requiredRunRate;
  final String? matchStatus;
  final String? result;
  final double? winProbabilityTeamA;
  final BallEvent? latestBall;
  final List<String> recentBalls;
  final int? target;

  const MatchUpdate({
    required this.matchId,
    required this.totalRuns,
    required this.totalWickets,
    required this.overs,
    required this.currentRunRate,
    this.requiredRunRate,
    this.matchStatus,
    this.result,
    this.winProbabilityTeamA,
    this.latestBall,
    this.recentBalls = const [],
    this.target,
  });
}

/// Commentary entry for ball-by-ball feed.
class CommentaryEntry {
  final String overBall; // e.g. "12.3"
  final String text;
  final CommentaryType type;
  final DateTime timestamp;

  const CommentaryEntry({
    required this.overBall,
    required this.text,
    required this.type,
    required this.timestamp,
  });
}

/// Commentary event type for visual styling.
enum CommentaryType {
  normal,
  four,
  six,
  wicket,
  milestone,
  overEnd,
}
