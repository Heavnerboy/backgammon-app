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
    final UserProfile? me = state.user;

    final Opponent? opp = state.opponents.isEmpty
        ? null
        : state.opponents.firstWhere(
            (o) => o.id == _selectedOpponentId,
            orElse: () => state.opponents.first,
          );

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

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Sessions')),
        body: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (me != null)
                    AvatarWithName(name: me.name, emojiOrInitial: me.avatar, avatarSize: 44),
                  Text('vs', style: Theme.of(context).textTheme.titleMedium),
                  if (opp != null)
                    AvatarWithName(name: opp.name, emojiOrInitial: opp.avatar, avatarSize: 44),
                ],
              ),
            ),

            // Gegnerauswahl + sofort neue Session
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
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
                    onPressed: opp == null
                        ? null
                        : () {
                            final sessionId = state.newSession(opp.id);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => SessionDetailScreen(sessionId: sessionId)),
                            );
                          },
                    child: const Text('Neue Session'),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Liste
            Expanded(
              child: _selectedOpponentId == null
                  ? const Center(child: Text('Bitte Gegner auswählen.'))
                  : (filtered.isEmpty
                      ? const Center(child: Text('Keine Sessions mit diesem Gegner.'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final s = filtered[index];
                            final oppName = (() {
                              final match = state.opponents.where((o) => o.id == s.opponentId);
                              return match.isNotEmpty ? match.first.name : '—';
                            })();
                            return Card(
                              child: ListTile(
                                title: Text('Session • ${state.formatDate(s.startedAt)}'),
                                subtitle: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _trendIcon(s.id),
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 6),
                                    Text('Gegner: $oppName'),
                                  ],
                                ),
                                  trailing: Text(
                                    '${state.sessionMyTotal(s.id)} : ${state.sessionOppTotal(s.id)}',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => SessionDetailScreen(sessionId: s.id)),
                                ),
                              ),
                            );
                          },
                        )),
            ),
          ],
        ),
      ),
    );
  }
}