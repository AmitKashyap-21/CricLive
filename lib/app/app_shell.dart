import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/leagues/screens/leagues_screen.dart';
import '../features/matches/screens/matches_screen.dart';
import '../features/news/screens/news_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../providers/providers.dart';

/// App shell with persistent Material 3 bottom navigation.
///
/// Uses [IndexedStack] to preserve tab state across navigation,
/// preventing unnecessary rebuilds when switching tabs.
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  static const _screens = <Widget>[
    MatchesScreen(),
    NewsScreen(),
    LeaguesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentTabProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentTab,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentTab,
        onDestinationSelected: (index) {
          ref.read(currentTabProvider.notifier).setTab(index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.sports_cricket_outlined),
            selectedIcon: Icon(Icons.sports_cricket),
            label: 'Matches',
          ),
          NavigationDestination(
            icon: Icon(Icons.newspaper_outlined),
            selectedIcon: Icon(Icons.newspaper),
            label: 'News',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Leagues',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
