/// Classifies Cricbuzz API match state into UI-friendly categories.
///
/// Handles the nuanced states for multi-day cricket:
///   • Stumps / Lunch / Tea / Drink / Rain Delay → still "live" (day break)
///   • Only truly live matches shown first in the Live tab
///
/// Works on raw Cricbuzz JSON — no model changes needed.
///
/// UI classification for tab filtering.
enum UiMatchState {
  /// Match is actively being played right now.
  live,

  /// Match is in a break (stumps, lunch, tea, etc.) but still in progress.
  /// Appears in the Live tab but sorted after actively live matches.
  dayBreak,

  /// Match has not started yet.
  upcoming,

  /// Match has finished (completed, abandoned, no result).
  completed,
}

/// Resolve the raw Cricbuzz `state` and `matchFormat` fields
/// into a [UiMatchState] for tab filtering and badge display.
///
/// Prioritizes the `state` field from Cricbuzz API match info.
UiMatchState classifyMatchState(Map<String, dynamic> matchInfo) {
  final state = (matchInfo['state'] as String? ?? '').trim();
  final status = (matchInfo['status'] as String? ?? '').toLowerCase();

  // ─── Completed states ──────────────────────────────
  if (state == 'Complete' || state == 'Abandon' || state == 'No Result') {
    return UiMatchState.completed;
  }
  if (status.contains('won') || status.contains('drawn') ||
      status.contains('tied') || status.contains('abandoned')) {
    return UiMatchState.completed;
  }

  // ─── Actively live ─────────────────────────────────
  if (state == 'In Progress' || state == 'Toss') {
    return UiMatchState.live;
  }

  // ─── Day breaks (multi-day or session breaks) ──────
  // These matches ARE in progress but paused for the day/session.
  if (state == 'Stumps' ||
      state == 'Lunch' ||
      state == 'Tea' ||
      state == 'Drink' ||
      state == 'Innings Break' ||
      state == 'Rain Delay' ||
      state == 'Bad Light' ||
      state == 'Wet Outfield') {
    return UiMatchState.dayBreak;
  }

  // ─── Upcoming states ───────────────────────────────
  if (state == 'Upcoming' || state == 'Preview') {
    return UiMatchState.upcoming;
  }

  // ─── Fallback: use status text ─────────────────────
  if (status.contains('live') || status.contains('trail') ||
      status.contains('lead') || status.contains('need')) {
    return UiMatchState.live;
  }
  if (status.contains('stumps') || status.contains('day')) {
    return UiMatchState.dayBreak;
  }

  // If state is empty, treat as upcoming (match not started)
  return UiMatchState.upcoming;
}

/// Returns the badge label for a match based on its Cricbuzz state.
///
/// Multi-day breaks get descriptive labels (STUMPS, LUNCH, TEA)
/// instead of generic "LIVE".
String matchBadgeLabel(Map<String, dynamic> matchInfo) {
  final state = (matchInfo['state'] as String? ?? '').trim();

  switch (state) {
    case 'In Progress':
      return 'LIVE';
    case 'Stumps':
      return 'STUMPS';
    case 'Lunch':
      return 'LUNCH';
    case 'Tea':
      return 'TEA';
    case 'Drink':
      return 'DRINKS';
    case 'Innings Break':
      return 'INN. BREAK';
    case 'Rain Delay':
      return 'RAIN';
    case 'Bad Light':
      return 'BAD LIGHT';
    case 'Wet Outfield':
      return 'DELAYED';
    case 'Toss':
      return 'TOSS';
    case 'Complete':
      return 'DONE';
    case 'Abandon':
      return 'ABANDONED';
    case 'No Result':
      return 'NO RESULT';
    case 'Upcoming':
    case 'Preview':
      return 'UPCOMING';
    default:
      return state.isNotEmpty ? state.toUpperCase() : 'UPCOMING';
  }
}

/// Sort priority within the Live tab.
///
/// Lower = shown first.
///   0 = actively live (ball by ball)
///   1 = toss / innings break (about to resume)
///   2 = stumps / lunch / tea (paused)
///   3 = rain / bad light (unknown resume)
int liveSortPriority(Map<String, dynamic> matchInfo) {
  final state = (matchInfo['state'] as String? ?? '').trim();

  switch (state) {
    case 'In Progress':
      return 0;
    case 'Toss':
    case 'Innings Break':
      return 1;
    case 'Stumps':
    case 'Lunch':
    case 'Tea':
    case 'Drink':
      return 2;
    case 'Rain Delay':
    case 'Bad Light':
    case 'Wet Outfield':
      return 3;
    default:
      return 4;
  }
}
