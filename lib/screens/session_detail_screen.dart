import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../widgets/doubling_cube.dart';
import '_new_game_sheet.dart';

class SessionDetailScreen extends StatelessWidget {
  final String sessionId;
  const SessionDetailScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final session = state.sessions.firstWhere((s) => s.id == sessionId);
    final games = state.gamesForSession(sessionId).reversed.toList();

    final me = state.user;
    final opp = state.opponents.firstWhere(
      (o) => o.id == session.opponentId,
      orElse: () => Opponent(
        id: '',
        name: 'Gegner',
        avatar: '❓',
        createdAt: DateTime.now(),
      ),
    );

    final myTotal = state.sessionMyTotal(sessionId);
    final oppTotal = state.sessionOppTotal(sessionId);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const Text("Session"),
              const SizedBox(width: 8),
              Text(
                state.formatDate(session.startedAt),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            // Spieler + Gesamtstand
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(me?.avatar ?? '🙂', style: const TextStyle(fontSize: 36)),
                          const SizedBox(height: 4),
                          Text(me?.name ?? 'Ich'),
                        ],
                      ),
                      Text("vs", style: Theme.of(context).textTheme.titleLarge),
                      Column(
                        children: [
                          Text(opp.avatar, style: const TextStyle(fontSize: 36)),
                          const SizedBox(height: 4),
                          Text(opp.name),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "$myTotal : $oppTotal",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Spieleliste
            Expanded(
              child: games.isEmpty
                  ? const Center(child: Text("Noch keine Spiele"))
                  : ListView.builder(
                      itemCount: games.length,
                      itemBuilder: (context, index) {
                        final g = games[index];
                        final winnerName =
                            g.winner == Winner.me ? (me?.name ?? "Ich") : opp.name;

                        final winKindLabel = state.labelForWinKind(g.winKind);

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Nur Badges: Sieger + Siegart + Würfel
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      winnerName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.secondaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      winKindLabel,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  DoublingCube(value: g.cube, size: 24),
                                ],
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                g.winner == Winner.me ? "+${g.myPoints}" : "+${g.opponentPoints}",
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: g.winner == Winner.me
                                          ? Colors.green
                                          : Theme.of(context).colorScheme.error,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('HH:mm', 'de_DE').format(g.timestamp),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => NewGameSheet(sessionId: sessionId),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text("Spiel hinzufügen"),
        ),
      ),
    );
  }
}