import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import 'doubling_cube.dart';

class SessionListItem extends StatelessWidget {
  final Session session;
  final VoidCallback? onTap;

  const SessionListItem({
    super.key,
    required this.session,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    // Totals bestimmen
    final myTotal  = state.sessionMyTotal(session.id);
    final oppTotal = state.sessionOppTotal(session.id);

    final didWin  = myTotal > oppTotal;
    final didLose = myTotal < oppTotal;

    // Schräges „Trend“-Icon in GRAU
    final IconData icon = didWin
        ? Icons.trending_up
        : (didLose ? Icons.trending_down : Icons.trending_flat);
    final Color iconColor = Theme.of(context).colorScheme.onSurfaceVariant;

    // Letztes Game (für Siegart + Würfel)
    final games = state.gamesForSession(session.id)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final Game? lastGame = games.isNotEmpty ? games.last : null;

    final String resultLabel = lastGame == null
        ? '—'
        : state.labelForWinKind(lastGame.winKind); // Single/Gammon/Backgammon
    final int cubeVal = lastGame?.cube ?? 1;

    // Datum: dd.MM.yy
    final String dateStr = state.formatDate(session.startedAt);

    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(resultLabel, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(dateStr),
      trailing: DoublingCube(value: cubeVal),
      onTap: onTap,
    );
  }
}