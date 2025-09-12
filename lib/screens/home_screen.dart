import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../state/theme_provider.dart';
import '../models/models.dart'; // für Winner
import 'session_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onStartNewSession; // Callback aus app.dart
  const HomeScreen({super.key, this.onStartNewSession});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.themeMode == ThemeMode.dark;

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
        backgroundColor: scheme.secondaryContainer, // abgesetzter Hintergrund
        foregroundColor: scheme.onSurfaceVariant,
        elevation: 0,
        title: Text('Willkommen', style: textTheme.headlineSmall),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12, bottom: 6),
            child: _ThemeModeToggle(
              isDark: isDark,
              onToggle: () => context.read<ThemeProvider>().toggleTheme(),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                state.user != null
                    ? 'Angemeldet als ${state.user!.name} ${state.user!.avatar}'
                    : 'Lege dein Profil unter „Spieler“ an.',
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
                        Text('Meine Win-Rate', style: textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Text(
                          totalGames == 0
                              ? 'Noch keine Spiele'
                              : '${winRate.toStringAsFixed(1)} %   •   $winsMe von $totalGames gewonnen',
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
            Text('Zuletzt gestartet', style: textTheme.titleLarge),
            const SizedBox(height: 8),
            for (final s in lastThree)
              Card(
                child: ListTile(
                  title: Text('Session • ${state.formatDate(s.startedAt)}'),
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
                        'Gegner: ${(() {
                          final match = state.opponents.where((o) => o.id == s.opponentId);
                          return match.isNotEmpty ? match.first.name : '—';
                        })()}',
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

          // ---- Neue Session Starten (JETZT NACH der Zuletzt-Sektion) ----
          FilledButton.icon(
            onPressed: state.opponents.isEmpty ? null : onStartNewSession,
            icon: const Icon(Icons.play_circle_fill_rounded),
            label: const Text('Neue Session starten'),
          ),
          const SizedBox(height: 16),

          // ---- Progress: Spiele 0/100 ----
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fortschritt', style: textTheme.titleMedium),
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
                    'Gespielte Spiele gesamt: $totalGames',
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

  void _roll() async {
    // kleine „Shake-/Spin“-Animation
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Würfeln', style: text.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: AnimatedBuilder(
                    animation: _spin,
                    builder: (_, child) {
                      // leichter Spin + Scale beim Würfeln
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
                  label: const Text('Werfen'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Summe: ${_a + _b}',
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
        // Unicode Dice: 1..6 -> \u2680..\u2685
        String.fromCharCode(0x2680 + (value - 1)),
        style: const TextStyle(fontSize: 28),
      ),
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

    // Größen
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
            // sanfter Verlauf je nach Modus
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      scheme.primaryContainer.withOpacity(0.25),
                      scheme.primary.withOpacity(0.35),
                    ]
                  : [
                      scheme.tertiaryContainer.withOpacity(0.5),
                      scheme.surfaceContainerHighest.withOpacity(0.9),
                    ],
            ),
            border: Border.all(
              color: isDark
                  ? scheme.primary.withOpacity(0.4)
                  : scheme.outlineVariant,
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
              // Sun/Moon Icons im Hintergrund
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.wb_sunny_rounded,
                    size: 16,
                    color: isDark
                        ? scheme.onSurface.withOpacity(0.35)
                        : scheme.onSurface.withOpacity(0.9),
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
                    color: isDark
                        ? scheme.onSurface.withOpacity(0.9)
                        : scheme.onSurface.withOpacity(0.35),
                  ),
                ),
              ),

              // Knopf
              AnimatedAlign(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                alignment:
                    isDark ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: knob,
                  height: knob,
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(knob / 2),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                        color: Colors.black.withOpacity(0.25),
                      ),
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