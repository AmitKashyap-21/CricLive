import '../models/match.dart';

/// Static sample data for CricLive.
///
/// Provides realistic IPL-style match data for the mock WebSocket
/// service and initial UI rendering.
abstract final class MockData {
  // ─── Teams ───────────────────────────────────────────────

  static const Team csk = Team(
    id: 'csk',
    name: 'Chennai Super Kings',
    shortName: 'CSK',
    flagEmoji: '🦁',
    primaryColor: '#FFC107',
  );

  static const Team mi = Team(
    id: 'mi',
    name: 'Mumbai Indians',
    shortName: 'MI',
    flagEmoji: '🏏',
    primaryColor: '#004BA0',
  );

  static const Team rcb = Team(
    id: 'rcb',
    name: 'Royal Challengers Bengaluru',
    shortName: 'RCB',
    flagEmoji: '🔴',
    primaryColor: '#D32F2F',
  );

  static const Team kkr = Team(
    id: 'kkr',
    name: 'Kolkata Knight Riders',
    shortName: 'KKR',
    flagEmoji: '💜',
    primaryColor: '#6A1B9A',
  );

  static const Team dc = Team(
    id: 'dc',
    name: 'Delhi Capitals',
    shortName: 'DC',
    flagEmoji: '🦅',
    primaryColor: '#1565C0',
  );

  static const Team rr = Team(
    id: 'rr',
    name: 'Rajasthan Royals',
    shortName: 'RR',
    flagEmoji: '👑',
    primaryColor: '#E91E63',
  );

  static const Team srh = Team(
    id: 'srh',
    name: 'Sunrisers Hyderabad',
    shortName: 'SRH',
    flagEmoji: '🌅',
    primaryColor: '#FF6F00',
  );

  static const Team pbks = Team(
    id: 'pbks',
    name: 'Punjab Kings',
    shortName: 'PBKS',
    flagEmoji: '🦁',
    primaryColor: '#E53935',
  );

  static const Team gt = Team(
    id: 'gt',
    name: 'Gujarat Titans',
    shortName: 'GT',
    flagEmoji: '🏔️',
    primaryColor: '#1A237E',
  );

  static const Team lsg = Team(
    id: 'lsg',
    name: 'Lucknow Super Giants',
    shortName: 'LSG',
    flagEmoji: '🩵',
    primaryColor: '#00ACC1',
  );

  static List<Team> get allTeams =>
      [csk, mi, rcb, kkr, dc, rr, srh, pbks, gt, lsg];

  // ─── Sample Batsmen ──────────────────────────────────────

  static const List<BatsmanInnings> sampleCskBatsmen = [
    BatsmanInnings(
      name: 'Ruturaj Gaikwad',
      runs: 45,
      balls: 32,
      fours: 5,
      sixes: 2,
      isOnStrike: false,
    ),
    BatsmanInnings(
      name: 'Devon Conway',
      runs: 62,
      balls: 41,
      fours: 7,
      sixes: 3,
      isOnStrike: true,
    ),
    BatsmanInnings(
      name: 'Ajinkya Rahane',
      runs: 18,
      balls: 14,
      fours: 2,
      sixes: 0,
      isOut: true,
      dismissal: 'c Rohit b Bumrah',
    ),
    BatsmanInnings(
      name: 'Shivam Dube',
      runs: 8,
      balls: 5,
      fours: 1,
      sixes: 0,
      isOut: true,
      dismissal: 'lbw b Pandya',
    ),
  ];

  static const List<BowlerInnings> sampleMiBowlers = [
    BowlerInnings(
      name: 'Jasprit Bumrah',
      overs: 4,
      maidens: 1,
      runs: 24,
      wickets: 1,
    ),
    BowlerInnings(
      name: 'Trent Boult',
      overs: 3.2,
      maidens: 0,
      runs: 31,
      wickets: 0,
    ),
    BowlerInnings(
      name: 'Hardik Pandya',
      overs: 3,
      maidens: 0,
      runs: 28,
      wickets: 1,
    ),
    BowlerInnings(
      name: 'Piyush Chawla',
      overs: 4,
      maidens: 0,
      runs: 38,
      wickets: 0,
    ),
  ];

  // ─── Sample Matches ──────────────────────────────────────

  static List<Match> get sampleMatches => [
        // LIVE: CSK vs MI
        Match(
          id: 'match_1',
          series: 'IPL 2026',
          venue: 'M.A. Chidambaram Stadium, Chennai',
          format: 'T20',
          status: MatchStatus.live,
          teamA: csk,
          teamB: mi,
          currentInnings: Innings(
            battingTeamId: 'csk',
            runs: 156,
            wickets: 3,
            overs: 16.2,
            extras: 8,
            runRate: 9.55,
            target: 186,
            requiredRunRate: 8.11,
            batsmen: sampleCskBatsmen,
            bowlers: sampleMiBowlers,
            fallOfWickets: const [
              FallOfWicket(
                  wicketNumber: 1,
                  runs: 42,
                  overs: 5.3,
                  batsmanName: 'Ajinkya Rahane'),
              FallOfWicket(
                  wicketNumber: 2,
                  runs: 89,
                  overs: 10.1,
                  batsmanName: 'Shivam Dube'),
              FallOfWicket(
                  wicketNumber: 3,
                  runs: 112,
                  overs: 12.4,
                  batsmanName: 'Moeen Ali'),
            ],
          ),
          innings: [
            const Innings(
              battingTeamId: 'mi',
              runs: 185,
              wickets: 6,
              overs: 20.0,
              extras: 12,
              runRate: 9.25,
            ),
          ],
          startTime: DateTime.now().subtract(const Duration(hours: 2)),
          winProbabilityTeamA: 0.58,
          recentBalls: ['1', '4', '0', '2', '6', 'W'],
        ),

        // LIVE: RCB vs KKR
        Match(
          id: 'match_2',
          series: 'IPL 2026',
          venue: 'M. Chinnaswamy Stadium, Bengaluru',
          format: 'T20',
          status: MatchStatus.live,
          teamA: rcb,
          teamB: kkr,
          currentInnings: const Innings(
            battingTeamId: 'rcb',
            runs: 89,
            wickets: 2,
            overs: 11.4,
            runRate: 7.63,
          ),
          startTime: DateTime.now().subtract(const Duration(hours: 1)),
          winProbabilityTeamA: 0.45,
          recentBalls: ['0', '1', '1', '4', '0', '2'],
        ),

        // UPCOMING: DC vs RR
        Match(
          id: 'match_3',
          series: 'IPL 2026',
          venue: 'Arun Jaitley Stadium, Delhi',
          format: 'T20',
          status: MatchStatus.upcoming,
          teamA: dc,
          teamB: rr,
          startTime: DateTime.now().add(const Duration(hours: 3)),
        ),

        // UPCOMING: SRH vs PBKS
        Match(
          id: 'match_4',
          series: 'IPL 2026',
          venue: 'Rajiv Gandhi Intl. Stadium, Hyderabad',
          format: 'T20',
          status: MatchStatus.upcoming,
          teamA: srh,
          teamB: pbks,
          startTime: DateTime.now().add(const Duration(hours: 6)),
        ),

        // COMPLETED: GT vs LSG
        Match(
          id: 'match_5',
          series: 'IPL 2026',
          venue: 'Narendra Modi Stadium, Ahmedabad',
          format: 'T20',
          status: MatchStatus.completed,
          teamA: gt,
          teamB: lsg,
          innings: const [
            Innings(
              battingTeamId: 'gt',
              runs: 198,
              wickets: 5,
              overs: 20.0,
              runRate: 9.9,
            ),
            Innings(
              battingTeamId: 'lsg',
              runs: 172,
              wickets: 8,
              overs: 20.0,
              runRate: 8.6,
            ),
          ],
          result: 'GT won by 26 runs',
          startTime: DateTime.now().subtract(const Duration(days: 1)),
        ),

        // COMPLETED: MI vs PBKS
        Match(
          id: 'match_6',
          series: 'IPL 2026',
          venue: 'Wankhede Stadium, Mumbai',
          format: 'T20',
          status: MatchStatus.completed,
          teamA: mi,
          teamB: pbks,
          innings: const [
            Innings(
              battingTeamId: 'mi',
              runs: 214,
              wickets: 4,
              overs: 20.0,
              runRate: 10.7,
            ),
            Innings(
              battingTeamId: 'pbks',
              runs: 201,
              wickets: 7,
              overs: 20.0,
              runRate: 10.05,
            ),
          ],
          result: 'MI won by 13 runs',
          startTime: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];

  // ─── Worm Chart Sample Data ──────────────────────────────

  static List<double> get sampleWormTeamA => [
        0, 6, 12, 18, 28, 35, 42, 51, 58, 67,
        78, 85, 93, 105, 112, 125, 138, 148, 156, 160,
      ];

  static List<double> get sampleWormTeamB => [
        0, 8, 15, 22, 30, 38, 48, 55, 62, 70,
        79, 88, 98, 108, 118, 130, 142, 155, 168, 185,
      ];

  // ─── News Sample Data ────────────────────────────────────

  static List<Map<String, String>> get sampleNews => [
        {
          'title': 'Bumrah\'s Masterclass Stuns CSK in Chennai',
          'summary':
              'Jasprit Bumrah bowled a match-defining spell of 4-24 to restrict CSK in a thrilling IPL encounter.',
          'source': 'ESPN Cricinfo',
          'time': '2h ago',
          'imageTag': 'bumrah',
        },
        {
          'title': 'IPL 2026 Mid-Season Transfer Window Opens',
          'summary':
              'Teams can now swap uncapped players as the BCCI introduces the mid-season transfer window for IPL 2026.',
          'source': 'Cricket Buzz',
          'time': '4h ago',
          'imageTag': 'ipl',
        },
        {
          'title': 'Virat Kohli Crosses 8000 IPL Runs',
          'summary':
              'The RCB legend became the first player to score 8000 runs in IPL history during his knock against KKR.',
          'source': 'NDTV Sports',
          'time': '6h ago',
          'imageTag': 'kohli',
        },
        {
          'title': 'Impact Player Rule Gets Modified for 2026',
          'summary':
              'The BCCI has announced changes to the Impact Player rule, allowing substitutions until the 10th over.',
          'source': 'Times of India',
          'time': '8h ago',
          'imageTag': 'bcci',
        },
        {
          'title': 'Gujarat Titans Unveil New Home Jersey',
          'summary':
              'The defending champions have revealed their new navy and gold home jersey for the 2026 season.',
          'source': 'SportStar',
          'time': '12h ago',
          'imageTag': 'gt',
        },
      ];

  // ─── League Standings ────────────────────────────────────

  static List<Map<String, dynamic>> get iplStandings => [
        {
          'team': csk,
          'played': 8,
          'won': 6,
          'lost': 2,
          'nrr': '+1.245',
          'points': 12
        },
        {
          'team': mi,
          'played': 8,
          'won': 5,
          'lost': 3,
          'nrr': '+0.876',
          'points': 10
        },
        {
          'team': rcb,
          'played': 7,
          'won': 5,
          'lost': 2,
          'nrr': '+0.654',
          'points': 10
        },
        {
          'team': gt,
          'played': 8,
          'won': 4,
          'lost': 4,
          'nrr': '+0.234',
          'points': 8
        },
        {
          'team': kkr,
          'played': 7,
          'won': 4,
          'lost': 3,
          'nrr': '+0.112',
          'points': 8
        },
        {
          'team': dc,
          'played': 8,
          'won': 4,
          'lost': 4,
          'nrr': '-0.123',
          'points': 8
        },
        {
          'team': rr,
          'played': 7,
          'won': 3,
          'lost': 4,
          'nrr': '-0.345',
          'points': 6
        },
        {
          'team': srh,
          'played': 8,
          'won': 3,
          'lost': 5,
          'nrr': '-0.567',
          'points': 6
        },
        {
          'team': lsg,
          'played': 7,
          'won': 2,
          'lost': 5,
          'nrr': '-0.789',
          'points': 4
        },
        {
          'team': pbks,
          'played': 8,
          'won': 1,
          'lost': 7,
          'nrr': '-1.234',
          'points': 2
        },
      ];
}
