import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import 'session_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onStartNewSession; // Callback aus app.dart
  const HomeScreen({super.key, this.onStartNewSession});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    // Neueste 3 Sessions
    final recent = [...state.sessions]..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    final lastThree = recent.take(3).toList();

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
        backgroundColor: scheme.secondaryContainer,   // 🔹 abgesetzter Hintergrund
        foregroundColor: scheme.onSurfaceVariant,
        elevation: 0,
        title: Text('Willkommen', style: textTheme.headlineSmall),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10),
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
          // Neue Session starten → nutzt Callback aus app.dart
          FilledButton.icon(
            onPressed: state.opponents.isEmpty ? null : onStartNewSession,
            icon: const Icon(Icons.play_circle_fill_rounded),
            label: const Text('Neue Session starten'),
          ),
          const SizedBox(height: 16),

          // Zuletzt gestartete Sessions (max. 3)
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
          ],
        ],
      ),
    );
  }
}