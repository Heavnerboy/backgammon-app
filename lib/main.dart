import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'state/app_state.dart';
import 'app/app.dart';
Future<void> main() async { WidgetsFlutterBinding.ensureInitialized();
Intl.defaultLocale = 'de_DE'; await initializeDateFormatting('de_DE');
final appState = await AppState.bootstrap();
 runApp(
  ChangeNotifierProvider(
    create: (_) => appState,
    child: const BackgammonApp(),
    ),
  );
}