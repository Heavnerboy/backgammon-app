import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../widgets/doubling_cube.dart';
import '../widgets/avatar_with_name.dart';
import '_new_game_sheet.dart';

// Einheitliches Grau wie in den Übersichten
const kChromeBg = Color(0xFFF2F3F5);

class SessionDetailScreen extends StatelessWidget {
  final String sessionId;
  const SessionDetailScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    final state   = context.watch<AppState>();
    final session = state.sessions.firstWhere((s) => s.id == sessionId);
    final games   = state.gamesForSession(sessionId).reversed.toList();

    final me  = state.user;
    final opp = state.opponents.firstWhere(
      (o) => o.id == session.opponentId,
      orElse: () => Opponent(id: '', name: 'Gegner', avatar: '❓', createdAt: DateTime.now()),
    );

    final myTotal  = state.sessionMyTotal(sessionId);
    final oppTotal = state.sessionOppTotal(sessionId);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white, // Seitenhintergrund: weiß
        body: CustomScrollView(
          slivers: [
            // ▸ Graue AppBar mit Zurück + Datum (bleibt grau beim Scrollen)
            SliverAppBar(
              pinned: true,
              backgroundColor: kChromeBg,
              surfaceTintColor: Colors.transparent,
              scrolledUnderElevation: 0,
              elevation: 0,
              automaticallyImplyLeading: true,
              title: Row(
                children: [
                  const Text('Session'),
                  const SizedBox(width: 8),
                  Text(
                    state.formatDate(session.startedAt),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            // ▸ VS-Header (weiß, pinned, fixe Höhe) mit fester Bottom-Border
            SliverPersistentHeader(
              pinned: true,
              delegate: _VsHeaderFixed(
                me: me,
                opp: opp,
                myTotal: myTotal,
                oppTotal: oppTotal,
                extent: 168,
              ),
            ),

            // (Divider entfällt – Border ist jetzt am Header selbst dran)

            // ▸ Spieleliste im Sessions-Look: Card statt Container (Material-Shadow)
            if (games.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('Noch keine Spiele')),
              )
            else
              SliverList.builder(
                itemCount: games.length,
                itemBuilder: (context, index) {
                  final g = games[index];
                  final winnerName   = g.winner == Winner.me ? (me?.name ?? 'Ich') : opp.name;
                  final winKindLabel = state.labelForWinKind(g.winKind);

                  return Padding(
                    // näher zusammenrücken: vertikal kleiner
                    padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
                    child: Card(
                      color: kChromeBg,
                      elevation: Theme.of(context).cardTheme.elevation ?? 2,
                      shadowColor: Theme.of(context).shadowColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 75), // etwas kompakter
                        child: Padding(
                          // innen ebenfalls leicht reduzieren
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center, // vertikal mittig
                            children: [
                              // LINKS: Sieger, Siegart, Cube
                              Expanded(
                                child: Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    // Sieger-Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        winnerName,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                    ),

                                    // Siegart-Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.black26, width: 1),
                                      ),
                                      child: Text(
                                        winKindLabel,
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                      ),
                                    ),

                                    // Verdopplungswürfel
                                    DoublingCube(value: g.cube, size: 24),
                                  ],
                                ),
                              ),

                              // RECHTS: +Punkte oben, Uhrzeit darunter
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    g.winner == Winner.me ? '+${g.myPoints}' : '+${g.opponentPoints}',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: g.winner == Winner.me
                                              ? Colors.green
                                              : Theme.of(context).colorScheme.error,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateFormat('HH:mm', 'de_DE').format(g.timestamp),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 80)), // Platz für FAB
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
          label: const Text('Spiel hinzufügen'),
        ),
      ),
    );
  }
}

/// Weißer, angepinnter VS-Header mit fixer Höhe und fester Bottom-Border
class _VsHeaderFixed extends SliverPersistentHeaderDelegate {
  final UserProfile? me;
  final Opponent opp;
  final int myTotal;
  final int oppTotal;
  final double extent;

  _VsHeaderFixed({
    required this.me,
    required this.opp,
    required this.myTotal,
    required this.oppTotal,
    this.extent = 168,
  });

  @override
  double get minExtent => extent;
  @override
  double get maxExtent => extent;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      // fester weißer Header mit unterer Border, die beim Scrollen sichtbar bleibt
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0x1F000000), width: 1), // ≈ Colors.black12
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Center(
        child: SizedBox(
          height: extent - 24,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatare – Linien – VS – Linien
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (me != null)
                    AvatarWithName(
                      name: me!.name,
                      emojiOrInitial: me!.avatar,
                      avatarSize: 44,
                    ),

                  const Expanded(
                    child: Row(
                      children: [
                        Expanded(child: _Line()),
                        _VsChip(),
                        Expanded(child: _Line()),
                      ],
                    ),
                  ),

                  AvatarWithName(
                    name: opp.name,
                    emojiOrInitial: opp.avatar,
                    avatarSize: 44,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Gesamtstand
              Text(
                '$myTotal : $oppTotal',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _VsHeaderFixed old) {
    return old.me != me ||
        old.opp != opp ||
        old.myTotal != myTotal ||
        old.oppTotal != oppTotal ||
        old.extent != extent;
  }
}

// ------- kleine UI-Bausteine -------

class _VsChip extends StatelessWidget {
  const _VsChip();

  @override
  Widget build(BuildContext context) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: kChromeBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: onSurfaceVariant.withOpacity(0.2)),
      ),
      child: Text('VS', style: Theme.of(context).textTheme.labelLarge),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
    );
  }
}