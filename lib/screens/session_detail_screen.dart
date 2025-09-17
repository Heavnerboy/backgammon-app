import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../state/app_state.dart';
import '../models/models.dart';
import '../widgets/doubling_cube.dart';
import '../widgets/avatar_with_name.dart';
import '../l10n/generated/app_localizations.dart';
import '../widgets/settings_sheet.dart'; // wichtig: nutzt denselben Drawer wie im Root
import '_new_game_sheet.dart';

class SessionDetailScreen extends StatelessWidget {
  final String sessionId;
  final bool showSettingsAction; // optionaler Toggle für Settings-Icon

  const SessionDetailScreen({
    super.key,
    required this.sessionId,
    this.showSettingsAction = true,
  });

  @override
  Widget build(BuildContext context) {
    final l      = AppLocalizations.of(context)!;
    final state  = context.watch<AppState>();
    final scheme = Theme.of(context).colorScheme;
    final text   = Theme.of(context).textTheme;

    final session = state.sessions.firstWhere((s) => s.id == sessionId);
    final games   = state.gamesForSession(sessionId).reversed.toList();

    final me  = state.user;
    final opp = state.opponents.firstWhere(
      (o) => o.id == session.opponentId,
      orElse: () => Opponent(id: '', name: l.opponent, avatar: '❓', createdAt: DateTime.now()),
    );

    final myTotal  = state.sessionMyTotal(sessionId);
    final oppTotal = state.sessionOppTotal(sessionId);

    final locale = Localizations.localeOf(context).toLanguageTag();

    return SafeArea(
      child: Scaffold(
        backgroundColor: scheme.surface,

        // Selbes Settings-Panel wie im Root (pro Route hat Scaffold sein eigenes Drawer-Objekt)
        endDrawer: const SettingsSheet(),

        body: CustomScrollView(
          slivers: [
            // AppBar
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
                    l.sessionTitle,
                    style: text.titleMedium?.copyWith(color: scheme.onSecondaryContainer),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    state.formatDate(session.startedAt),
                    style: text.bodyMedium?.copyWith(
                      color: scheme.onSecondaryContainer.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              actions: [
                if (showSettingsAction)
                  // Gleiches Styling wie im Root (halbtransparenter Surface-Hintergrund)
                  Builder(
                    builder: (ctx) => Padding(
                      padding: const EdgeInsets.only(right: 8, bottom: 6),
                      child: Material(
                        color: Colors.transparent,
                        child: IconButton(
                          tooltip: l.settings,
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(ctx)
                                .colorScheme
                                .surface
                                .withOpacity(0.6),
                          ),
                          icon: const Icon(Icons.settings),
                          onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // VS-Header
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

            // Spieleliste
            if (games.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text(l.noGamesYet)),
              )
            else
              SliverList.builder(
                itemCount: games.length,
                itemBuilder: (context, index) {
                  final g = games[index];

                  final winnerName   = g.winner == Winner.me ? (me?.name ?? l.me) : opp.name;
                  final winKindLabel = _labelForWinKind(g.winKind, l);

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
                    child: Card(
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
                              // Links: Sieger, Siegart, Cube
                              Expanded(
                                child: Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
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
                                    DoublingCube(value: g.cube, size: 28),
                                  ],
                                ),
                              ),
                              // Rechts: Punkte + Uhrzeit
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    g.winner == Winner.me ? '+${g.myPoints}' : '+${g.opponentPoints}',
                                    style: text.titleMedium?.copyWith(
                                      color: g.winner == Winner.me ? Colors.green : scheme.error,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateFormat.Hm(locale).format(g.timestamp),
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
          label: Text(l.addGameFab),
        ),
      ),
    );
  }

  String _labelForWinKind(WinKind kind, AppLocalizations l) {
    switch (kind) {
      case WinKind.single:      return l.winKindSingle;
      case WinKind.gammon:      return l.winKindGammon;
      case WinKind.backgammon:  return l.winKindBackgammon;
      case WinKind.passDouble:  return l.winKindPassDouble;
    }
  }
}

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
    final l      = AppLocalizations.of(context)!;

    return Container(
      key: ValueKey<Brightness>(Theme.of(context).brightness),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (me != null)
                    AvatarWithName(name: me!.name, emojiOrInitial: me!.avatar, avatarSize: 44),

                  Expanded(
                    child: Row(
                      children: [
                        const Expanded(child: _Line()),
                        _VsChip(text: l.vs),
                        const Expanded(child: _Line()),
                      ],
                    ),
                  ),

                  AvatarWithName(name: opp.name, emojiOrInitial: opp.avatar, avatarSize: 44),
                ],
              ),
              const SizedBox(height: 10),

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
  bool shouldRebuild(covariant _VsHeaderFixed old) => true;
}

class _VsChip extends StatelessWidget {
  final String text;
  const _VsChip({required this.text});

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
        text,
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