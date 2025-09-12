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

  final _screens = const [HomeScreen(), SessionsScreen(), PlayersScreen(), StatsScreen()];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Backgammon Scores',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: _ready
          ? Scaffold(
              body: _screens[_index],
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
            )
          : SplashScreen(onDone: () => setState(() => _ready = true)),
    );
  }
}