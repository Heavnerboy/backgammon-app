import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import 'sessions_screen.dart';
import 'session_detail_screen.dart';

// Gleiche Konstante wie in backgammon_app.dart
const kChromeBg = Color(0xFFF2F3F5);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final recent = [...state.sessions]..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    final lastThree = recent.take(3).toList();

    IconData _trendIcon(String sessionId) {
      final my = state.sessionMyTotal(sessionId);
      final opp = state.sessionOppTotal(sessionId);
      if (my > opp) return Icons.trending_up;
      if (my < opp) return Icons.trending_down;
      return Icons.trending_flat;
    }

    return Scaffold(
      body: Column(
        children: [
          // Header über die volle Breite, gleiches Grau wie Navigation
          Container(
            width: double.infinity,
            color: kChromeBg,
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Willkommen', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 4),
                Text(
                  state.user != null
                      ? 'Angemeldet als ${state.user!.name} ${state.user!.avatar}'
                      : 'Lege dein Profil unter „Spieler“ an.',
                ),
              ],
            ),
          ),

          // Inhalt
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                FilledButton.icon(
                  onPressed: state.opponents.isEmpty
                      ? null
                      : () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SessionsScreen()),
                          ),
                  icon: const Icon(Icons.play_circle_fill_rounded),
                  label: const Text('Neue Session starten'),
                ),
                const SizedBox(height: 16),

                if (lastThree.isNotEmpty) ...[
                  Text('Zuletzt gestartet', style: Theme.of(context).textTheme.titleLarge),
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
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                          style: Theme.of(context).textTheme.titleMedium,
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
          ),
        ],
      ),
    );
  }
}