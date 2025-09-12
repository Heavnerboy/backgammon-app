import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

class AppState extends ChangeNotifier {
  AppState._(this.storage);
  final StorageService storage;
  final _uuid = const Uuid();

  UserProfile? user;
  List<Opponent> opponents = [];
  List<Session> sessions = [];
  List<Game> games = [];

  // Erlaubte Doubling-Cube-Werte (nur Anzeige 1,2,4,8,16,32,64)
  static const List<int> allowedCubeValues = [1, 2, 4, 8, 16, 32, 64];

  static Future<AppState> bootstrap() async {
    final storage = await StorageService.create();
    final state = AppState._(storage);
    await state._loadAll();
    return state;
  }

  Future<void> _loadAll() async {
    final userStr = storage.getString(StorageKeys.user);
    if (userStr != null) user = UserProfile.fromJson(jsonDecode(userStr));

    final oppStr = storage.getString(StorageKeys.opponents);
    if (oppStr != null) {
      opponents = decodeList(oppStr).map(Opponent.fromJson).toList();
    }

    final sesStr = storage.getString(StorageKeys.sessions);
    if (sesStr != null) {
      sessions = decodeList(sesStr).map(Session.fromJson).toList();
    }

    final gameStr = storage.getString(StorageKeys.games);
    if (gameStr != null) {
      games = decodeList(gameStr).map(Game.fromJson).toList();
    }

    notifyListeners();
  }

  Future<void> _persistUser() async =>
      user == null
          ? storage.remove(StorageKeys.user)
          : storage.setString(StorageKeys.user, jsonEncode(user!.toJson()));
  Future<void> _persistOpponents() async =>
      storage.setString(StorageKeys.opponents, encodeList(opponents.map((e) => e.toJson()).toList()));
  Future<void> _persistSessions() async =>
      storage.setString(StorageKeys.sessions, encodeList(sessions.map((e) => e.toJson()).toList()));
  Future<void> _persistGames() async =>
      storage.setString(StorageKeys.games, encodeList(games.map((e) => e.toJson()).toList()));

  // ===== User =====
  void upsertUser({required String name, required String avatar}) {
    user = UserProfile(id: user?.id ?? _uuid.v4(), name: name, avatar: avatar);
    _persistUser();
    notifyListeners();
  }

  // ===== Opponents =====
  void addOpponent(String name, String avatar) {
    opponents.add(Opponent(id: _uuid.v4(), name: name, avatar: avatar, createdAt: DateTime.now()));
    _persistOpponents();
    notifyListeners();
  }

  void removeOpponent(String id) {
    opponents.removeWhere((o) => o.id == id);
    // Kaskade sauber aufräumen
    final sesIds = sessions.where((s) => s.opponentId == id).map((s) => s.id).toSet();
    sessions.removeWhere((s) => sesIds.contains(s.id));
    games.removeWhere((g) => sesIds.contains(g.sessionId));
    _persistOpponents();
    _persistSessions();
    _persistGames();
    notifyListeners();
  }

  // ===== Sessions =====
  String newSession(String opponentId, {String? note}) {
    final s = Session(
      id: _uuid.v4(),
      opponentId: opponentId,
      startedAt: DateTime.now(),
      note: note,
    );
    sessions.add(s);
    _persistSessions();
    notifyListeners();
    return s.id;
  }

  Future<void> deleteSession(String sessionId) async {
    sessions.removeWhere((s) => s.id == sessionId);
    games.removeWhere((g) => g.sessionId == sessionId);
    await _persistSessions();
    await _persistGames();
    notifyListeners();
  }

  // ===== Games =====
  void addGameScored({
    required String sessionId,
    required Winner winner,
    required WinKind winKind,
    required int cube, // 1,2,4,8,16,32,64
  }) {
    // Validierung der erlaubten Doubling-Cube-Werte
    assert(allowedCubeValues.contains(cube), 'Cube muss 1,2,4,8,16,32 oder 64 sein');

    // Punkteberechnung: Single(1) / Gammon(2) / Backgammon(3) / Pass(1) × Cube
    final mult = winKindMultiplier(winKind) * cube;
    final myPts = (winner == Winner.me) ? mult : 0;
    final oppPts = (winner == Winner.opponent) ? mult : 0;

    games.add(
      Game(
        id: _uuid.v4(),
        sessionId: sessionId,
        timestamp: DateTime.now(),
        myPoints: myPts,
        opponentPoints: oppPts,
        winner: winner,
        winKind: winKind,
        cube: cube,
      ),
    );
    _persistGames();
    notifyListeners();
  }

  Future<void> deleteGame(String gameId) async {
    games.removeWhere((g) => g.id == gameId);
    await _persistGames();
    notifyListeners();
  }

  // ===== Helpers (Anzeige) =====

  /// Datumsformat für die Liste: z.B. 08.09.25 (ohne Uhrzeit)
  String formatDate(DateTime dt) => DateFormat('dd.MM.yy').format(dt);

  /// Für UI-Labels inkl. „Passen der Verdopplung“
  String labelForWinKind(WinKind k) {
    switch (k) {
      case WinKind.single:
        return 'Single';
      case WinKind.gammon:
        return 'Gammon';
      case WinKind.backgammon:
        return 'Backgammon';
      case WinKind.passDouble:
        return 'Doppelung abgelehnt';
    }
  }

  List<Game> gamesForSession(String sessionId) =>
      games.where((g) => g.sessionId == sessionId).toList();

  int sessionMyTotal(String sessionId) =>
      gamesForSession(sessionId).fold(0, (s, g) => s + g.myPoints);

  int sessionOppTotal(String sessionId) =>
      gamesForSession(sessionId).fold(0, (s, g) => s + g.opponentPoints);

  // ---- Optional: einmalig „Cache“ (Sessions & Games) leeren ----
  Future<void> clearAllSessionsAndGames() async {
    sessions.clear();
    games.clear();
    await _persistSessions();
    await _persistGames();
    notifyListeners();
  }
}