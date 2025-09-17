import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../state/theme_provider.dart';
import '../models/models.dart';
import 'session_detail_screen.dart';
import '../l10n/generated/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onStartNewSession; // Callback aus app.dart
  const HomeScreen({super.key, this.onStartNewSession});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    context.watch<ThemeProvider>(); // damit Theme-Wechsel den Screen neu baut
    final loc = AppLocalizations.of(context)!;

    // Neueste 3 Sessions
    final recent = [...state.sessions]..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    final lastThree = recent.take(3).toList();

    // Alle Spiele (für Win-Rate & Progress)
    final List<Game> allGames = [];
    for (final s in state.sessions) {
      allGames.addAll(state.gamesForSession(s.id));
    }
    final totalGames = allGames.length;
    final winsMe = allGames.where((g) => g.winner == Winner.me).length;
    final winRate = totalGames == 0 ? 0.0 : (winsMe / totalGames) * 100.0;

    IconData _trendIcon(String sessionId) {
      final my = state.sessionMyTotal(sessionId);
      final opp = state.sessionOppTotal(sessionId);
      if (my > opp) return Icons.trending_up;
      if (my < opp) return Icons.trending_down;
      return Icons.trending_flat;
    }

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.secondaryContainer,
        foregroundColor: scheme.onSurfaceVariant,
        elevation: 0,
        title: Text(loc.welcome, style: textTheme.headlineSmall),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                state.user != null
                    ? loc.signedInAs(state.user!.name, state.user!.avatar)
                    : loc.createProfileHint,
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- Win-Rate Sektion ----
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(loc.winRate, style: textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Text(
                          totalGames == 0
                              ? loc.noGamesYet
                              : '${winRate.toStringAsFixed(1)} %   •   ${loc.winRateDetail(winsMe, totalGames)}',
                          style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            minHeight: 10,
                            value: totalGames == 0 ? 0 : winsMe / totalGames,
                            backgroundColor: scheme.surfaceVariant,
                            valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // kleiner Kreis mit großer Prozentzahl
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      totalGames == 0 ? '0%' : '${winRate.toStringAsFixed(0)}%',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ---- Zuletzt gestartet ----
          if (lastThree.isNotEmpty) ...[
            Text(loc.recentSessions, style: textTheme.titleLarge),
            const SizedBox(height: 8),
            for (final s in lastThree)
              Card(
                child: ListTile(
                  title: Text('${loc.session} • ${state.formatDate(s.startedAt)}'),
                  subtitle: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _trendIcon(s.id),
                        color: scheme.onSurfaceVariant,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        loc.opponentName(() {
                          final match = state.opponents.where((o) => o.id == s.opponentId);
                          return match.isNotEmpty ? match.first.name : '—';
                        }()),
                      ),
                    ],
                  ),
                  trailing: Text(
                    '${state.sessionMyTotal(s.id)} : ${state.sessionOppTotal(s.id)}',
                    style: textTheme.titleMedium,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SessionDetailScreen(sessionId: s.id),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),
          ],

          // ---- Neue Session Starten (nach der Zuletzt-Sektion) ----
          FilledButton.icon(
            onPressed: state.opponents.isEmpty ? null : onStartNewSession,
            icon: const Icon(Icons.play_circle_fill_rounded),
            label: Text(loc.newSession),
          ),
          const SizedBox(height: 16),

          // ---- Progress: Spiele 0/100 ----
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc.progress, style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            minHeight: 10,
                            value: (totalGames % 100) / 100.0,
                            backgroundColor: scheme.surfaceVariant,
                            valueColor: AlwaysStoppedAnimation<Color>(scheme.tertiary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('${totalGames % 100}/100', style: textTheme.labelLarge),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    loc.totalGamesPlayed(totalGames),
                    style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ---- Spaßiges Würfel-Widget ----
          _DiceWidget(),
        ],
      ),
    );
  }
}

/// Kleines, spaßiges Würfel-Widget (zwei Würfel, Tippen = würfeln + Mini-Animation)
class _DiceWidget extends StatefulWidget {
  @override
  State<_DiceWidget> createState() => _DiceWidgetState();
}

class _DiceWidgetState extends State<_DiceWidget> with SingleTickerProviderStateMixin {
  final _rand = Random();
  int _a = 1;
  int _b = 1;
  late final AnimationController _ctrl;
  late final Animation<double> _spin;

  static const _diceChars = ['\u2680', '\u2681', '\u2682', '\u2683', '\u2684', '\u2685'];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 260));
    _spin = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _roll() {
    _ctrl.forward(from: 0);
    setState(() {
      _a = _rand.nextInt(6) + 1;
      _b = _rand.nextInt(6) + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final loc = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.dice, style: text.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: AnimatedBuilder(
                    animation: _spin,
                    builder: (_, child) {
                      final angle = _spin.value * 2 * pi;
                      final scale = 1.0 + 0.08 * (_spin.value < 0.5 ? _spin.value * 2 : (1 - _spin.value) * 2);
                      return Transform.rotate(
                        angle: angle,
                        child: Transform.scale(
                          scale: scale,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _DieFace(value: _a),
                              const SizedBox(width: 12),
                              _DieFace(value: _b),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _roll,
                  icon: const Icon(Icons.casino),
                  label: Text(loc.roll),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              loc.sumWithNumber(_a + _b),
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _DieFace extends StatelessWidget {
  final int value; // 1..6
  const _DieFace({required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: scheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
      ),
      alignment: Alignment.center,
      child: Text(
        String.fromCharCode(0x2680 + (value - 1)), // Unicode Dice
        style: const TextStyle(fontSize: 28),
      ),
    );
  }
}