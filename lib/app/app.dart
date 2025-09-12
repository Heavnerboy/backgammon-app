import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/sessions_screen.dart';
import '../screens/player_screen.dart';
import '../screens/stats_screen.dart';
import '../screens/splash_screen.dart';

class BackgammonApp extends StatefulWidget {
  const BackgammonApp({super.key});
  @override
  State<BackgammonApp> createState() => _BackgammonAppState();
}

class _BackgammonAppState extends State<BackgammonApp> {
  int _index = 0;
  bool _ready = false;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(onStartNewSession: () => setState(() => _index = 1)), // Tab-Wechsel
      const SessionsScreen(),
      const PlayersScreen(),
      const StatsScreen(),
    ];

    // WICHTIG: Hier KEIN MaterialApp mehr!
    if (!_ready) {
      return SplashScreen(onDone: () => setState(() => _ready = true));
    }

    return Scaffold(
      body: IndexedStack( // hält Zustand und verhindert Overlay-Routen für Tabs
        index: _index,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.event_note), label: 'Sessions'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Spieler'),
          NavigationDestination(icon: Icon(Icons.show_chart), label: 'Stats'),
        ],
        onDestinationSelected: (i) => setState(() => _index = i),
      ),
    );
  }
}