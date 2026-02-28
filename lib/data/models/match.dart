/// Represents a cricket match with full state.
class Match {
  final String id;
  final String series;
  final String venue;
  final String format; // T20, ODI, Test
  final MatchStatus status;
  final Team teamA;
  final Team teamB;
  final Innings? currentInnings;
  final List<Innings> innings;
  final String? result;
  final DateTime startTime;
  final double? winProbabilityTeamA;
  final List<String> recentBalls;

  const Match({
    required this.id,
    required this.series,
    required this.venue,
    required this.format,
    required this.status,
    required this.teamA,
    required this.teamB,
    this.currentInnings,
    this.innings = const [],
    this.result,
    required this.startTime,
    this.winProbabilityTeamA,
    this.recentBalls = const [],
  });

  bool get isLive => status == MatchStatus.live;
  bool get isUpcoming => status == MatchStatus.upcoming;
  bool get isCompleted => status == MatchStatus.completed;

  /// The team currently batting.
  Team? get battingTeam {
    if (currentInnings == null) return null;
    return currentInnings!.battingTeamId == teamA.id ? teamA : teamB;
  }

  /// The team currently bowling.
  Team? get bowlingTeam {
    if (currentInnings == null) return null;
    return currentInnings!.battingTeamId == teamA.id ? teamB : teamA;
  }

  Match copyWith({
    String? id,
    String? series,
    String? venue,
    String? format,
    MatchStatus? status,
    Team? teamA,
    Team? teamB,
    Innings? currentInnings,
    List<Innings>? innings,
    String? result,
    DateTime? startTime,
    double? winProbabilityTeamA,
    List<String>? recentBalls,
  }) {
    return Match(
      id: id ?? this.id,
      series: series ?? this.series,
      venue: venue ?? this.venue,
      format: format ?? this.format,
      status: status ?? this.status,
      teamA: teamA ?? this.teamA,
      teamB: teamB ?? this.teamB,
      currentInnings: currentInnings ?? this.currentInnings,
      innings: innings ?? this.innings,
      result: result ?? this.result,
      startTime: startTime ?? this.startTime,
      winProbabilityTeamA: winProbabilityTeamA ?? this.winProbabilityTeamA,
      recentBalls: recentBalls ?? this.recentBalls,
    );
  }
}

/// Team information.
class Team {
  final String id;
  final String name;
  final String shortName;
  final String flagEmoji;
  final String primaryColor;

  const Team({
    required this.id,
    required this.name,
    required this.shortName,
    required this.flagEmoji,
    this.primaryColor = '#7ED957',
  });
}

/// An innings in a match.
class Innings {
  final String battingTeamId;
  final int runs;
  final int wickets;
  final double overs;
  final int extras;
  final double? runRate;
  final double? requiredRunRate;
  final int? target;
  final List<BatsmanInnings> batsmen;
  final List<BowlerInnings> bowlers;
  final List<FallOfWicket> fallOfWickets;

  const Innings({
    required this.battingTeamId,
    this.runs = 0,
    this.wickets = 0,
    this.overs = 0.0,
    this.extras = 0,
    this.runRate,
    this.requiredRunRate,
    this.target,
    this.batsmen = const [],
    this.bowlers = const [],
    this.fallOfWickets = const [],
  });

  String get scoreString => '$runs/$wickets';
  String get oversString => '($overs ov)';

  Innings copyWith({
    String? battingTeamId,
    int? runs,
    int? wickets,
    double? overs,
    int? extras,
    double? runRate,
    double? requiredRunRate,
    int? target,
    List<BatsmanInnings>? batsmen,
    List<BowlerInnings>? bowlers,
    List<FallOfWicket>? fallOfWickets,
  }) {
    return Innings(
      battingTeamId: battingTeamId ?? this.battingTeamId,
      runs: runs ?? this.runs,
      wickets: wickets ?? this.wickets,
      overs: overs ?? this.overs,
      extras: extras ?? this.extras,
      runRate: runRate ?? this.runRate,
      requiredRunRate: requiredRunRate ?? this.requiredRunRate,
      target: target ?? this.target,
      batsmen: batsmen ?? this.batsmen,
      bowlers: bowlers ?? this.bowlers,
      fallOfWickets: fallOfWickets ?? this.fallOfWickets,
    );
  }
}

/// Individual batsman's innings data.
class BatsmanInnings {
  final String name;
  final int runs;
  final int balls;
  final int fours;
  final int sixes;
  final bool isOnStrike;
  final bool isOut;
  final String? dismissal;

  const BatsmanInnings({
    required this.name,
    this.runs = 0,
    this.balls = 0,
    this.fours = 0,
    this.sixes = 0,
    this.isOnStrike = false,
    this.isOut = false,
    this.dismissal,
  });

  double get strikeRate => balls > 0 ? (runs / balls) * 100 : 0.0;

  BatsmanInnings copyWith({
    String? name,
    int? runs,
    int? balls,
    int? fours,
    int? sixes,
    bool? isOnStrike,
    bool? isOut,
    String? dismissal,
  }) {
    return BatsmanInnings(
      name: name ?? this.name,
      runs: runs ?? this.runs,
      balls: balls ?? this.balls,
      fours: fours ?? this.fours,
      sixes: sixes ?? this.sixes,
      isOnStrike: isOnStrike ?? this.isOnStrike,
      isOut: isOut ?? this.isOut,
      dismissal: dismissal ?? this.dismissal,
    );
  }
}

/// Individual bowler's innings data.
class BowlerInnings {
  final String name;
  final double overs;
  final int maidens;
  final int runs;
  final int wickets;
  final int noBalls;
  final int wides;

  const BowlerInnings({
    required this.name,
    this.overs = 0,
    this.maidens = 0,
    this.runs = 0,
    this.wickets = 0,
    this.noBalls = 0,
    this.wides = 0,
  });

  double get economy => overs > 0 ? runs / overs : 0.0;
}

/// Fall of wicket record.
class FallOfWicket {
  final int wicketNumber;
  final int runs;
  final double overs;
  final String batsmanName;

  const FallOfWicket({
    required this.wicketNumber,
    required this.runs,
    required this.overs,
    required this.batsmanName,
  });
}

/// Match status enum.
enum MatchStatus {
  upcoming,
  live,
  completed,
  abandoned,
}
