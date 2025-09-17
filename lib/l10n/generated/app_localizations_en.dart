// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Backgammon Score';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get systemDefault => 'System default';

  @override
  String get german => 'German';

  @override
  String get english => 'English';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get navHome => 'Home';

  @override
  String get navSessions => 'Sessions';

  @override
  String get navPlayers => 'Players';

  @override
  String get navStats => 'Stats';

  @override
  String get welcome => 'Welcome';

  @override
  String signedInAs(Object name, Object avatar) {
    return 'Signed in as $name $avatar';
  }

  @override
  String get createProfileHint => 'Create your profile in “Players”.';

  @override
  String get winRate => 'My win rate';

  @override
  String get noGamesYet => 'No games yet';

  @override
  String winRateDetail(Object wins, Object total) {
    return '$wins of $total won';
  }

  @override
  String get recentSessions => 'Recently started';

  @override
  String get session => 'Session';

  @override
  String opponentName(Object name) {
    return 'Opponent: $name';
  }

  @override
  String get progress => 'Progress';

  @override
  String totalGamesPlayed(Object total) {
    return 'Total games played: $total';
  }

  @override
  String get dice => 'Dice';

  @override
  String get roll => 'Roll';

  @override
  String get sum => 'Sum';

  @override
  String sumWithNumber(Object n) {
    return 'Sum: $n';
  }

  @override
  String get opponentLabel => 'Opponent';

  @override
  String get newSession => 'Start new session';

  @override
  String get newSessionShort => 'New session';

  @override
  String get createOpponentHint => 'Please add an opponent in “Players” first.';

  @override
  String get pleaseSelectOpponent => 'Please select an opponent.';

  @override
  String get noSessionsWithOpponent => 'No sessions with this opponent.';

  @override
  String sessionWithDate(Object date) {
    return 'Session • $date';
  }

  @override
  String get playersTitle => 'Players';

  @override
  String get myProfile => 'My profile';

  @override
  String get me => 'Me';

  @override
  String sinceDate(String date) {
    return 'since $date';
  }

  @override
  String get sinceDash => 'since —';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get deleteProfile => 'Delete profile';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get profileReset => 'Profile reset';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get opponents => 'Opponents';

  @override
  String get opponent => 'Opponent';

  @override
  String get noOpponentsHint =>
      'No opponents yet. Use the button at the bottom right to add one.';

  @override
  String get editOpponent => 'Edit opponent';

  @override
  String get deleteOpponent => 'Delete opponent';

  @override
  String get confirmDeleteProfileTitle => 'Delete profile?';

  @override
  String get confirmDeleteProfileBody =>
      'If you delete your profile, your sessions remain, but name/avatar will be reset.';

  @override
  String get confirmDeleteOpponentTitle => 'Delete opponent?';

  @override
  String get confirmDeleteOpponentBody =>
      'Deleting this opponent will also remove related sessions and games. Continue?';

  @override
  String opponentUpdated(String name) {
    return '“$name” updated';
  }

  @override
  String opponentDeleted(String name) {
    return '“$name” deleted';
  }

  @override
  String get opponentAddedFAB => 'Add opponent';

  @override
  String opponentAddedSnackbar(String name) {
    return '“$name” added';
  }

  @override
  String get opponentEditorTitleAdd => 'Add opponent';

  @override
  String get opponentEditorTitleEdit => 'Edit opponent';

  @override
  String get opponentNameLabel => 'Opponent\'s name';

  @override
  String get avatarLabel => 'Avatar:';

  @override
  String get yourNameLabel => 'Your name';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get allOpponents => 'All opponents';

  @override
  String get allOpponentsShort => 'All';

  @override
  String get vs => 'VS';

  @override
  String get kpiWins => 'Wins';

  @override
  String get kpiTotalPoints => 'Total points';

  @override
  String get kpiWinRate => 'Win rate';

  @override
  String get kpiAvgDoubling => 'Avg. doubling';

  @override
  String get winKindsTitle => 'Win types';

  @override
  String get winKindSingle => 'Single';

  @override
  String get winKindGammon => 'Gammon';

  @override
  String get winKindBackgammon => 'Backgammon';

  @override
  String get winKindPassDouble => 'Double declined';

  @override
  String get scoreProgressTitle => 'Score progression';

  @override
  String get sessionTitle => 'Session';

  @override
  String get addGameFab => 'Add game';

  @override
  String sessionAgainstName(Object name) {
    return 'Session vs $name';
  }

  @override
  String get winTypeLabel => 'Win type';

  @override
  String get doublingLabel => 'Doubling';

  @override
  String get newGameTitle => 'New game';

  @override
  String get winnerLabel => 'Winner';

  @override
  String get doublingDieLabel => 'Doubling cube';
}
