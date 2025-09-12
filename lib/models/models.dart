import 'dart:convert';

class UserProfile {
  final String id;
  final String name;
  final String avatar; // Emoji/Key
  UserProfile({required this.id, required this.name, required this.avatar});
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'avatar': avatar};
  factory UserProfile.fromJson(Map<String, dynamic> j) =>
      UserProfile(id: j['id'], name: j['name'], avatar: j['avatar']);
}

class Opponent {
  final String id;
  final String name;
  final String avatar;
  final DateTime createdAt;
  Opponent({required this.id, required this.name, required this.avatar, required this.createdAt});
  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'avatar': avatar, 'createdAt': createdAt.toIso8601String()};
  factory Opponent.fromJson(Map<String, dynamic> j) => Opponent(
        id: j['id'],
        name: j['name'],
        avatar: j['avatar'],
        createdAt: DateTime.parse(j['createdAt']),
      );
}

enum GameResult { win, lose, draw } // bleibt für Anzeige alter Spiele
enum Winner { me, opponent }

/// Siegarten inklusive „Passen der Verdopplung“ (Ablehnung eines Doubles)
enum WinKind { single, gammon, backgammon, passDouble }

/// Multiplikator für die Siegart (wird mit dem Cube multipliziert)
int winKindMultiplier(WinKind k) {
  switch (k) {
    case WinKind.single:
      return 1;
    case WinKind.gammon:
      return 2;
    case WinKind.backgammon:
      return 3;
    case WinKind.passDouble:
      return 1; // Ablehnung zählt den aktuellen Cube -> 1×cube
  }
}

/// Spieleintrag mit gespeicherten Matchpunkten (Gewinnerpunkte vs Verlierer = 0)
class Game {
  final String id;
  final String sessionId;
  final DateTime timestamp;

  // gespeicherte Matchpunkte
  final int myPoints;        // ich
  final int opponentPoints;  // gegner

  // Meta
  final Winner winner;
  final WinKind winKind;
  final int cube; // 1,2,4,8,...

  Game({
    required this.id,
    required this.sessionId,
    required this.timestamp,
    required this.myPoints,
    required this.opponentPoints,
    required this.winner,
    required this.winKind,
    required this.cube,
  });

  GameResult get result {
    if (myPoints > opponentPoints) return GameResult.win;
    if (myPoints < opponentPoints) return GameResult.lose;
    return GameResult.draw; // sollte eig. nicht vorkommen
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sessionId': sessionId,
        'timestamp': timestamp.toIso8601String(),
        'myPoints': myPoints,
        'opponentPoints': opponentPoints,
        'winner': winner.name,
        'winKind': winKind.name,
        'cube': cube,
      };

  factory Game.fromJson(Map<String, dynamic> j) => Game(
        id: j['id'],
        sessionId: j['sessionId'],
        timestamp: DateTime.parse(j['timestamp']),
        myPoints: j['myPoints'],
        opponentPoints: j['opponentPoints'],
        winner: Winner.values.firstWhere(
          (e) => e.name == (j['winner'] ?? 'me'),
          orElse: () => Winner.me,
        ),
        winKind: WinKind.values.firstWhere(
          (e) => e.name == (j['winKind'] ?? 'single'),
          orElse: () => WinKind.single,
        ),
        cube: (j['cube'] ?? 1),
      );
}

/// Eine Session bündelt mehrere Games gegen EINEN Gegner.
class Session {
  final String id;
  final String opponentId;
  final DateTime startedAt;
  final String? note;
  Session({required this.id, required this.opponentId, required this.startedAt, this.note});
  Map<String, dynamic> toJson() =>
      {'id': id, 'opponentId': opponentId, 'startedAt': startedAt.toIso8601String(), 'note': note};
  factory Session.fromJson(Map<String, dynamic> j) => Session(
        id: j['id'],
        opponentId: j['opponentId'],
        startedAt: DateTime.parse(j['startedAt']),
        note: j['note'],
      );
}

// Helpers
String encodeList(List<Map<String, dynamic>> list) => jsonEncode(list);
List<Map<String, dynamic>> decodeList(String s) =>
    (jsonDecode(s) as List).cast<Map<String, dynamic>>();