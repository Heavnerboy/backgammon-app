import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../widgets/doubling_cube.dart';
import '../widgets/avatar_with_name.dart';
import '_new_game_sheet.dart';

class SessionDetailScreen extends StatelessWidget {
  final String sessionId;
  const SessionDetailScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    final state   = context.watch<AppState>();
    final scheme  = Theme.of(context).colorScheme;
    final text    = Theme.of(context).textTheme;

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
        backgroundColor: scheme.surface,
        body: CustomScrollView(
          slivers: [
            // Oberer Header wie in den anderen Screens
            SliverAppBar(
              pinned: true,
              backgroundColor: scheme.secondaryContainer,
              foregroundColor: scheme.onSecondaryContainer,
              surfaceTintColor: Colors.transparent,
              scrolledUnderElevation: 0,
              elevation: 0,
              automaticallyImplyLeading: true,
              title: Row(
                children: [
                  Text(
                    'Session',
                    style: text.titleMedium?.copyWith(color: scheme.onSecondaryContainer),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    state.formatDate(session.startedAt),
                    style: text.bodyMedium?.copyWith(color: scheme.onSecondaryContainer.withOpacity(0.9)),
                  ),
                ],
              ),
            ),

            // VS-Header (neutral, mit Border)
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

            // Spieleliste – neutral wie in SessionsScreen (Card ohne explizite Farbe)
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
                    padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
                    child: Card(
                      // keine feste Farbe -> folgt Theme (wie SessionsScreen)
                      elevation: Theme.of(context).cardTheme.elevation ?? 2,
                      shadowColor: Theme.of(context).shadowColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 75),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // LINKS: Sieger, Siegart, Cube (neutralere Badges)
                              Expanded(
                                child: Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    // Sieger-Badge – neutral (surfaceVariant)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: scheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        winnerName,
                                        style: text.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: scheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),

                                    // Siegart-Badge – neutraler Chip mit Outline
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: scheme.surface,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: scheme.outlineVariant, width: 1),
                                      ),
                                      child: Text(
                                        winKindLabel,
                                        style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                      ),
                                    ),

                                    // Verdopplungswürfel
                                    DoublingCube(value: g.cube, size: 28),
                                  ],
                                ),
                              ),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        g.winner == Winner.me ? '+${g.myPoints}' : '+${g.opponentPoints}',
                        style: text.titleMedium?.copyWith(
                          color: g.winner == Winner.me 
                              ? Colors.green       // eher grün/blau (Gewinn)
                              : scheme.error,        // rot (Verlust)
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('HH:mm', 'de_DE').format(g.timestamp),
                        style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
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

/// Pinned VS-Header mit thematischem Hintergrund & Border
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
    final scheme = Theme.of(context).colorScheme;
    final text   = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(bottom: BorderSide(color: scheme.outlineVariant, width: 1)),
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
                    AvatarWithName(name: me!.name, emojiOrInitial: me!.avatar, avatarSize: 44),

                  const Expanded(
                    child: Row(
                      children: [
                        Expanded(child: _Line()),
                        _VsChip(),
                        Expanded(child: _Line()),
                      ],
                    ),
                  ),

                  AvatarWithName(name: opp.name, emojiOrInitial: opp.avatar, avatarSize: 44),
                ],
              ),
              const SizedBox(height: 10),

              // Gesamtstand
              Text(
                '$myTotal : $oppTotal',
                style: text.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
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
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceVariant,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.onSurfaceVariant.withOpacity(0.2)),
      ),
      child: Text(
        'VS',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
      ),
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