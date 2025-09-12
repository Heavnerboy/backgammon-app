import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/avatar_with_name.dart';
import '../models/models.dart';
import '../state/theme_provider.dart';
import 'session_detail_screen.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});
  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  String? _selectedOpponentId;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Theme-Status
    final isDark = context.watch<ThemeProvider>().themeMode == ThemeMode.dark;

    final UserProfile? me = state.user;

    // Gegnerobjekt zur VS-Darstellung (safe lookup)
    Opponent? opp;
    if (_selectedOpponentId != null) {
      for (final o in state.opponents) {
        if (o.id == _selectedOpponentId) {
          opp = o;
          break;
        }
      }
    }

    // Filter + Sort
    final filtered = state.sessions
        .where((s) => _selectedOpponentId != null && s.opponentId == _selectedOpponentId)
        .toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

    IconData _trendIcon(String sessionId) {
      final my = state.sessionMyTotal(sessionId);
      final opp = state.sessionOppTotal(sessionId);
      if (my > opp) return Icons.trending_up;
      if (my < opp) return Icons.trending_down;
      return Icons.trending_flat;
    }

    String _opponentNameById(String id) {
      for (final o in state.opponents) {
        if (o.id == id) return o.name;
      }
      return '—';
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.secondaryContainer,
        foregroundColor: scheme.onSecondaryContainer,
        elevation: 0,
        title: Text('Sessions', style: textTheme.headlineSmall?.copyWith(color: scheme.onSecondaryContainer)),
        actions: [
          Padding(
            // leichte Korrektur, damit nichts abgeschnitten wirkt
            padding: const EdgeInsets.only(right: 12, bottom: 6),
            child: _ThemeModeToggle(
              isDark: isDark,
              onToggle: () => context.read<ThemeProvider>().toggleTheme(),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          // VS-Sektion
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (me != null)
                AvatarWithName(name: me.name, emojiOrInitial: me.avatar, avatarSize: 44),
              Expanded(
                child: Row(
                  children: const [
                    Expanded(child: _Line()),
                    _VsChip(),
                    Expanded(child: _Line()),
                  ],
                ),
              ),
              if (opp != null)
                AvatarWithName(name: opp.name, emojiOrInitial: opp.avatar, avatarSize: 44),
            ],
          ),

          const SizedBox(height: 16),

          // Gegnerauswahl + neue Session
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedOpponentId,
                  decoration: const InputDecoration(labelText: 'Gegner'),
                  items: state.opponents
                      .map((o) => DropdownMenuItem(value: o.id, child: Text('${o.avatar}  ${o.name}')))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedOpponentId = v),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: (_selectedOpponentId == null)
                    ? null
                    : () {
                        final sessionId = state.newSession(_selectedOpponentId!);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SessionDetailScreen(sessionId: sessionId)),
                        );
                      },
                child: const Text('Neue Session'),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          if (state.opponents.isEmpty)
            const Center(child: Text('Lege zuerst einen Gegner unter „Spieler“ an.'))
          else if (_selectedOpponentId == null)
            const Center(child: Text('Bitte Gegner auswählen.'))
          else if (filtered.isEmpty)
            const Center(child: Text('Keine Sessions mit diesem Gegner.'))
          else
            ...[
              for (final s in filtered)
                Card(
                  child: ListTile(
                    title: Text('Session • ${state.formatDate(s.startedAt)}'),
                    subtitle: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_trendIcon(s.id), color: scheme.onSurfaceVariant, size: 20),
                        const SizedBox(width: 6),
                        Text('Gegner: ${_opponentNameById(s.opponentId)}'),
                      ],
                    ),
                    trailing: Text(
                      '${state.sessionMyTotal(s.id)} : ${state.sessionOppTotal(s.id)}',
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SessionDetailScreen(sessionId: s.id)),
                    ),
                  ),
                ),
            ],
        ],
      ),
    );
  }
}

// ------- kleine, eigenständige UI-Bausteine -------

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

/// Stylischer, animierter Theme-Toggle (Sun/Moon + gleitender Knopf)
/// Hinweis: Falls du dieses Widget bereits in einer gemeinsamen Datei hast,
/// entferne die Duplikate hier und importiere die zentrale Variante.
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