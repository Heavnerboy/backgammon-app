import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'state/app_state.dart';
import 'state/theme_provider.dart';
import 'app/app.dart'; // enthält BackgammonApp (ohne eigenes MaterialApp)

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lokalisierung (DE)
  Intl.defaultLocale = 'de_DE';
  await initializeDateFormatting('de_DE');

  // AppState laden (Persistenz, Seeds, usw.)
  final appState = await AppState.bootstrap();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: appState),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Backgammon Score',
      // Light Theme
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      // Dark Theme
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      // Umschaltung über ThemeProvider (per Button im HomeScreen)
      themeMode: themeProvider.themeMode,
      home: const BackgammonApp(), // <- KEIN weiteres MaterialApp darunter
    );
  }
}