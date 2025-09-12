import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // <— wichtig
import 'app/app.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Locale für Intl setzen & Datums-/Zeitdaten laden
  Intl.defaultLocale = 'de_DE';
  await initializeDateFormatting('de_DE'); // <— lädt Muster/Symbole

  final appState = await AppState.bootstrap();

  runApp(
    ChangeNotifierProvider(
      create: (_) => appState,
      child: const BackgammonApp(),
    ),
  );
}