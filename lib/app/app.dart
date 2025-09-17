import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/sessions_screen.dart';
import '../screens/player_screen.dart';
import '../screens/stats_screen.dart';
import '../screens/splash_screen.dart';
import '../widgets/settings_sheet.dart';
import '../l10n/generated/app_localizations.dart'; // <— NEU

class BackgammonApp extends StatefulWidget {
  const BackgammonApp({super.key});
  @override
  State<BackgammonApp> createState() => _BackgammonAppState();
}

class _BackgammonAppState extends State<BackgammonApp> {
  int _index = 0;
  bool _ready = false;

  // Key, um den endDrawer zu öffnen
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(onStartNewSession: () => setState(() => _index = 1)),
      const SessionsScreen(),
      const PlayersScreen(),
      const StatsScreen(),
    ];

    if (!_ready) {
      return SplashScreen(onDone: () => setState(() => _ready = true));
    }

    final loc = AppLocalizations.of(context)!; // <— Lokalisierung

    return Scaffold(
      key: _scaffoldKey,

      // 👉 Settings Drawer (kommt von rechts rein)
      endDrawer: const SettingsSheet(),

      body: Stack(
        children: [
          IndexedStack(index: _index, children: pages),

          // Zahnrad oben rechts
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                // Position anpassen (z. B. top: 0 höher / 24 tiefer)
                padding: const EdgeInsets.only(top: 0, right: 8),
                child: Material(
                  color: Colors.transparent,
                  child: IconButton(
                    tooltip: loc.settings, // <— lokalisiert
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .surface
                          .withOpacity(0.6),
                    ),
                    icon: const Icon(Icons.settings),
                    onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        destinations: [
          // nicht const, weil lokalisierte Strings
          NavigationDestination(icon: const Icon(Icons.home), label: loc.navHome),
          NavigationDestination(icon: const Icon(Icons.event_note), label: loc.navSessions),
          NavigationDestination(icon: const Icon(Icons.people), label: loc.navPlayers),
          NavigationDestination(icon: const Icon(Icons.show_chart), label: loc.navStats),
        ],
        onDestinationSelected: (i) => setState(() => _index = i),
      ),
    );
  }
}