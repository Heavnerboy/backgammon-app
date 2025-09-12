import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../widgets/doubling_cube.dart';
import '../widgets/avatar_with_name.dart';
import '../state/theme_provider.dart';
import '_new_game_sheet.dart';

class SessionDetailScreen extends StatelessWidget {
  final String sessionId;
  const SessionDetailScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    final state  = context.watch<AppState>();
    final scheme = Theme.of(context).colorScheme;
    final text   = Theme.of(context).textTheme;

    // triggert Rebuild bei Theme-Wechsel
    final isDark = context.watch<ThemeProvider>().themeMode == ThemeMode.dark;

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
            // AppBar mit Toggle
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
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12, bottom: 6),
                  child: _ThemeModeToggle(
                    isDark: isDark,
                    onToggle: () => context.read<ThemeProvider>().toggleTheme(),
                  ),
                ),
              ],
            ),

            // VS-Header – jetzt "hard refresh"-sicher beim Theme-Wechsel
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
      // 🔑 bei Theme-Wechsel (Brightness) wird das Element ausgetauscht
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

                  // ⚠️ keine consts in dieser Zeile → garantiertes Rebuild
                  Expanded(
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

  // 💡 Ultrasicher: immer rebuilden (ein paar Extrabuilds sind hier okay)
  @override
  bool shouldRebuild(covariant _VsHeaderFixed old) => true;
}

// ------- kleine UI-Bausteine -------

class _VsChip extends StatelessWidget {
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
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
    );
  }
}

/// Stylischer, animierter Theme-Toggle (Sun/Moon + gleitender Knopf)
class _ThemeModeToggle extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggle;
  const _ThemeModeToggle({
    required this.isDark,
    required this.onToggle,
  });

  @override
  State<_ThemeModeToggle> createState() => _ThemeModeToggleState();
}

class _ThemeModeToggleState extends State<_ThemeModeToggle>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bool isDark = widget.isDark;

    const double width = 64;
    const double height = 34;
    const double padding = 4;
    const double knob = height - padding * 2;

    return Semantics(
      label: 'Theme umschalten',
      value: isDark ? 'Darkmode aktiv' : 'Lightmode aktiv',
      button: true,
      child: GestureDetector(
        onTap: widget.onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          width: width,
          height: height,
          padding: const EdgeInsets.all(padding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [scheme.primaryContainer.withOpacity(0.25), scheme.primary.withOpacity(0.35)]
                  : [scheme.tertiaryContainer.withOpacity(0.5), scheme.surfaceContainerHighest.withOpacity(0.9)],
            ),
            border: Border.all(
              color: isDark ? scheme.primary.withOpacity(0.4) : scheme.outlineVariant,
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 4),
                color: Colors.black.withOpacity(isDark ? 0.25 : 0.12),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.wb_sunny_rounded,
                    size: 16,
                    color: isDark ? scheme.onSurface.withOpacity(0.35) : scheme.onSurface.withOpacity(0.9),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.nights_stay_rounded,
                    size: 16,
                    color: isDark ? scheme.onSurface.withOpacity(0.9) : scheme.onSurface.withOpacity(0.35),
                  ),
                ),
              ),
              AnimatedAlign(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: knob,
                  height: knob,
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(knob / 2),
                    boxShadow: [
                      BoxShadow(blurRadius: 6, offset: const Offset(0, 2), color: Colors.black.withOpacity(0.25)),
                    ],
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      key: ValueKey(isDark),
                      size: 16,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}