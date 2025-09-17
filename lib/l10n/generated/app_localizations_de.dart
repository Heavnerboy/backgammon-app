// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Backgammon Score';

  @override
  String get settings => 'Einstellungen';

  @override
  String get language => 'Sprache';

  @override
  String get systemDefault => 'Systemstandard';

  @override
  String get german => 'Deutsch';

  @override
  String get english => 'Englisch';

  @override
  String get appearance => 'Darstellung';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get navHome => 'Home';

  @override
  String get navSessions => 'Sessions';

  @override
  String get navPlayers => 'Spieler';

  @override
  String get navStats => 'Stats';

  @override
  String get welcome => 'Willkommen';

  @override
  String signedInAs(Object name, Object avatar) {
    return 'Angemeldet als $name $avatar';
  }

  @override
  String get createProfileHint => 'Lege dein Profil unter „Spieler“ an.';

  @override
  String get winRate => 'Meine Win-Rate';

  @override
  String get noGamesYet => 'Noch keine Spiele';

  @override
  String winRateDetail(Object wins, Object total) {
    return '$wins von $total gewonnen';
  }

  @override
  String get recentSessions => 'Zuletzt gestartet';

  @override
  String get session => 'Session';

  @override
  String opponentName(Object name) {
    return 'Gegner: $name';
  }

  @override
  String get progress => 'Fortschritt';

  @override
  String totalGamesPlayed(Object total) {
    return 'Gespielte Spiele gesamt: $total';
  }

  @override
  String get dice => 'Würfeln';

  @override
  String get roll => 'Werfen';

  @override
  String get sum => 'Summe';

  @override
  String sumWithNumber(Object n) {
    return 'Summe: $n';
  }

  @override
  String get opponentLabel => 'Gegner';

  @override
  String get newSession => 'Neue Session starten';

  @override
  String get newSessionShort => 'Neue Session';

  @override
  String get createOpponentHint =>
      'Lege zuerst einen Gegner unter „Spieler“ an.';

  @override
  String get pleaseSelectOpponent => 'Bitte Gegner auswählen.';

  @override
  String get noSessionsWithOpponent => 'Keine Sessions mit diesem Gegner.';

  @override
  String sessionWithDate(Object date) {
    return 'Session • $date';
  }

  @override
  String get playersTitle => 'Spieler';

  @override
  String get myProfile => 'Mein Profil';

  @override
  String get me => 'Ich';

  @override
  String sinceDate(String date) {
    return 'seit $date';
  }

  @override
  String get sinceDash => 'seit —';

  @override
  String get editProfile => 'Profil bearbeiten';

  @override
  String get deleteProfile => 'Profil löschen';

  @override
  String get profileSaved => 'Profil gespeichert';

  @override
  String get profileReset => 'Profil zurückgesetzt';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get save => 'Speichern';

  @override
  String get opponents => 'Gegner';

  @override
  String get opponent => 'Gegner';

  @override
  String get noOpponentsHint =>
      'Noch keine Gegner. Unten rechts kannst du Gegner hinzufügen.';

  @override
  String get editOpponent => 'Gegner bearbeiten';

  @override
  String get deleteOpponent => 'Gegner löschen';

  @override
  String get confirmDeleteProfileTitle => 'Profil löschen?';

  @override
  String get confirmDeleteProfileBody =>
      'Wenn du dein Profil löschst, bleiben deine Sessions erhalten, aber Name/Avatar werden zurückgesetzt.';

  @override
  String get confirmDeleteOpponentTitle => 'Gegner löschen?';

  @override
  String get confirmDeleteOpponentBody =>
      'Wenn du den Gegner löschst, werden auch zugehörige Sessions und Spiele entfernt. Fortfahren?';

  @override
  String opponentUpdated(String name) {
    return '„$name“ aktualisiert';
  }

  @override
  String opponentDeleted(String name) {
    return '„$name“ gelöscht';
  }

  @override
  String get opponentAddedFAB => 'Gegner hinzufügen';

  @override
  String opponentAddedSnackbar(String name) {
    return '„$name“ hinzugefügt';
  }

  @override
  String get opponentEditorTitleAdd => 'Gegner hinzufügen';

  @override
  String get opponentEditorTitleEdit => 'Gegner bearbeiten';

  @override
  String get opponentNameLabel => 'Name des Gegners';

  @override
  String get avatarLabel => 'Avatar:';

  @override
  String get yourNameLabel => 'Dein Name';

  @override
  String get statsTitle => 'Statistiken';

  @override
  String get allOpponents => 'Alle Gegner';

  @override
  String get allOpponentsShort => 'Alle';

  @override
  String get vs => 'VS';

  @override
  String get kpiWins => 'Siege';

  @override
  String get kpiTotalPoints => 'Gesamtpunkte';

  @override
  String get kpiWinRate => 'Win-Rate';

  @override
  String get kpiAvgDoubling => 'Ø Verdopplung';

  @override
  String get winKindsTitle => 'Siegarten';

  @override
  String get winKindSingle => 'Single';

  @override
  String get winKindGammon => 'Gammon';

  @override
  String get winKindBackgammon => 'Backgammon';

  @override
  String get winKindPassDouble => 'Doppelung abgelehnt';

  @override
  String get scoreProgressTitle => 'Score-Verlauf';

  @override
  String get sessionTitle => 'Session';

  @override
  String get addGameFab => 'Spiel hinzufügen';

  @override
  String sessionAgainstName(Object name) {
    return 'Session gegen $name';
  }

  @override
  String get winTypeLabel => 'Siegart';

  @override
  String get doublingLabel => 'Verdoppelung';

  @override
  String get newGameTitle => 'Neues Spiel';

  @override
  String get winnerLabel => 'Gewinner';

  @override
  String get doublingDieLabel => 'Verdopplungswürfel';
}
