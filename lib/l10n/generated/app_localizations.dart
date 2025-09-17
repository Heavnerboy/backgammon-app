import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Backgammon Score'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get navSessions;

  /// No description provided for @navPlayers.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get navPlayers;

  /// No description provided for @navStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @signedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {name} {avatar}'**
  String signedInAs(Object name, Object avatar);

  /// No description provided for @createProfileHint.
  ///
  /// In en, this message translates to:
  /// **'Create your profile in “Players”.'**
  String get createProfileHint;

  /// No description provided for @winRate.
  ///
  /// In en, this message translates to:
  /// **'My win rate'**
  String get winRate;

  /// No description provided for @noGamesYet.
  ///
  /// In en, this message translates to:
  /// **'No games yet'**
  String get noGamesYet;

  /// No description provided for @winRateDetail.
  ///
  /// In en, this message translates to:
  /// **'{wins} of {total} won'**
  String winRateDetail(Object wins, Object total);

  /// No description provided for @recentSessions.
  ///
  /// In en, this message translates to:
  /// **'Recently started'**
  String get recentSessions;

  /// No description provided for @session.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get session;

  /// No description provided for @opponentName.
  ///
  /// In en, this message translates to:
  /// **'Opponent: {name}'**
  String opponentName(Object name);

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @totalGamesPlayed.
  ///
  /// In en, this message translates to:
  /// **'Total games played: {total}'**
  String totalGamesPlayed(Object total);

  /// No description provided for @dice.
  ///
  /// In en, this message translates to:
  /// **'Dice'**
  String get dice;

  /// No description provided for @roll.
  ///
  /// In en, this message translates to:
  /// **'Roll'**
  String get roll;

  /// No description provided for @sum.
  ///
  /// In en, this message translates to:
  /// **'Sum'**
  String get sum;

  /// No description provided for @sumWithNumber.
  ///
  /// In en, this message translates to:
  /// **'Sum: {n}'**
  String sumWithNumber(Object n);

  /// No description provided for @opponentLabel.
  ///
  /// In en, this message translates to:
  /// **'Opponent'**
  String get opponentLabel;

  /// No description provided for @newSession.
  ///
  /// In en, this message translates to:
  /// **'Start new session'**
  String get newSession;

  /// No description provided for @newSessionShort.
  ///
  /// In en, this message translates to:
  /// **'New session'**
  String get newSessionShort;

  /// No description provided for @createOpponentHint.
  ///
  /// In en, this message translates to:
  /// **'Please add an opponent in “Players” first.'**
  String get createOpponentHint;

  /// No description provided for @pleaseSelectOpponent.
  ///
  /// In en, this message translates to:
  /// **'Please select an opponent.'**
  String get pleaseSelectOpponent;

  /// No description provided for @noSessionsWithOpponent.
  ///
  /// In en, this message translates to:
  /// **'No sessions with this opponent.'**
  String get noSessionsWithOpponent;

  /// No description provided for @sessionWithDate.
  ///
  /// In en, this message translates to:
  /// **'Session • {date}'**
  String sessionWithDate(Object date);

  /// No description provided for @playersTitle.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get playersTitle;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My profile'**
  String get myProfile;

  /// No description provided for @me.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get me;

  /// Label 'since <date>'
  ///
  /// In en, this message translates to:
  /// **'since {date}'**
  String sinceDate(String date);

  /// No description provided for @sinceDash.
  ///
  /// In en, this message translates to:
  /// **'since —'**
  String get sinceDash;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @deleteProfile.
  ///
  /// In en, this message translates to:
  /// **'Delete profile'**
  String get deleteProfile;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSaved;

  /// No description provided for @profileReset.
  ///
  /// In en, this message translates to:
  /// **'Profile reset'**
  String get profileReset;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @opponents.
  ///
  /// In en, this message translates to:
  /// **'Opponents'**
  String get opponents;

  /// No description provided for @opponent.
  ///
  /// In en, this message translates to:
  /// **'Opponent'**
  String get opponent;

  /// No description provided for @noOpponentsHint.
  ///
  /// In en, this message translates to:
  /// **'No opponents yet. Use the button at the bottom right to add one.'**
  String get noOpponentsHint;

  /// No description provided for @editOpponent.
  ///
  /// In en, this message translates to:
  /// **'Edit opponent'**
  String get editOpponent;

  /// No description provided for @deleteOpponent.
  ///
  /// In en, this message translates to:
  /// **'Delete opponent'**
  String get deleteOpponent;

  /// No description provided for @confirmDeleteProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete profile?'**
  String get confirmDeleteProfileTitle;

  /// No description provided for @confirmDeleteProfileBody.
  ///
  /// In en, this message translates to:
  /// **'If you delete your profile, your sessions remain, but name/avatar will be reset.'**
  String get confirmDeleteProfileBody;

  /// No description provided for @confirmDeleteOpponentTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete opponent?'**
  String get confirmDeleteOpponentTitle;

  /// No description provided for @confirmDeleteOpponentBody.
  ///
  /// In en, this message translates to:
  /// **'Deleting this opponent will also remove related sessions and games. Continue?'**
  String get confirmDeleteOpponentBody;

  /// No description provided for @opponentUpdated.
  ///
  /// In en, this message translates to:
  /// **'“{name}” updated'**
  String opponentUpdated(String name);

  /// No description provided for @opponentDeleted.
  ///
  /// In en, this message translates to:
  /// **'“{name}” deleted'**
  String opponentDeleted(String name);

  /// No description provided for @opponentAddedFAB.
  ///
  /// In en, this message translates to:
  /// **'Add opponent'**
  String get opponentAddedFAB;

  /// No description provided for @opponentAddedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'“{name}” added'**
  String opponentAddedSnackbar(String name);

  /// No description provided for @opponentEditorTitleAdd.
  ///
  /// In en, this message translates to:
  /// **'Add opponent'**
  String get opponentEditorTitleAdd;

  /// No description provided for @opponentEditorTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit opponent'**
  String get opponentEditorTitleEdit;

  /// No description provided for @opponentNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Opponent\'s name'**
  String get opponentNameLabel;

  /// No description provided for @avatarLabel.
  ///
  /// In en, this message translates to:
  /// **'Avatar:'**
  String get avatarLabel;

  /// No description provided for @yourNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourNameLabel;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTitle;

  /// No description provided for @allOpponents.
  ///
  /// In en, this message translates to:
  /// **'All opponents'**
  String get allOpponents;

  /// No description provided for @allOpponentsShort.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allOpponentsShort;

  /// No description provided for @vs.
  ///
  /// In en, this message translates to:
  /// **'VS'**
  String get vs;

  /// No description provided for @kpiWins.
  ///
  /// In en, this message translates to:
  /// **'Wins'**
  String get kpiWins;

  /// No description provided for @kpiTotalPoints.
  ///
  /// In en, this message translates to:
  /// **'Total points'**
  String get kpiTotalPoints;

  /// No description provided for @kpiWinRate.
  ///
  /// In en, this message translates to:
  /// **'Win rate'**
  String get kpiWinRate;

  /// No description provided for @kpiAvgDoubling.
  ///
  /// In en, this message translates to:
  /// **'Avg. doubling'**
  String get kpiAvgDoubling;

  /// No description provided for @winKindsTitle.
  ///
  /// In en, this message translates to:
  /// **'Win types'**
  String get winKindsTitle;

  /// No description provided for @winKindSingle.
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get winKindSingle;

  /// No description provided for @winKindGammon.
  ///
  /// In en, this message translates to:
  /// **'Gammon'**
  String get winKindGammon;

  /// No description provided for @winKindBackgammon.
  ///
  /// In en, this message translates to:
  /// **'Backgammon'**
  String get winKindBackgammon;

  /// No description provided for @winKindPassDouble.
  ///
  /// In en, this message translates to:
  /// **'Double declined'**
  String get winKindPassDouble;

  /// No description provided for @scoreProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Score progression'**
  String get scoreProgressTitle;

  /// No description provided for @sessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get sessionTitle;

  /// No description provided for @addGameFab.
  ///
  /// In en, this message translates to:
  /// **'Add game'**
  String get addGameFab;

  /// No description provided for @sessionAgainstName.
  ///
  /// In en, this message translates to:
  /// **'Session vs {name}'**
  String sessionAgainstName(Object name);

  /// No description provided for @winTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Win type'**
  String get winTypeLabel;

  /// No description provided for @doublingLabel.
  ///
  /// In en, this message translates to:
  /// **'Doubling'**
  String get doublingLabel;

  /// No description provided for @newGameTitle.
  ///
  /// In en, this message translates to:
  /// **'New game'**
  String get newGameTitle;

  /// No description provided for @winnerLabel.
  ///
  /// In en, this message translates to:
  /// **'Winner'**
  String get winnerLabel;

  /// No description provided for @doublingDieLabel.
  ///
  /// In en, this message translates to:
  /// **'Doubling cube'**
  String get doublingDieLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
