import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/avatar_with_name.dart';
import '../models/models.dart';
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

    final UserProfile? me = state.user;

    // ✅ Gegner sicher als Opponent? ermitteln (ohne orElse-Nullproblem)
    final Opponent? opp = (_selectedOpponentId == null)
        ? null
        : (() {
            for (final o in state.opponents) {
              if (o.id == _selectedOpponentId) return o;
            }
            return null; // nichts gefunden
          })();

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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.secondaryContainer,
        foregroundColor: scheme.onSecondaryContainer,
        elevation: 0,
        title: Text('Sessions', style: textTheme.headlineSmall?.copyWith(color: scheme.onSecondaryContainer)),
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
                        Text('Gegner: ${state.opponents.firstWhere((o) => o.id == s.opponentId).name}'),
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