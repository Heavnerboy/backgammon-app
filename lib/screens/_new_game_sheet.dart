import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../widgets/doubling_cube.dart';

class NewGameSheet extends StatefulWidget {
  final String sessionId;
  const NewGameSheet({super.key, required this.sessionId});

  @override
  State<NewGameSheet> createState() => _NewGameSheetState();
}

class _NewGameSheetState extends State<NewGameSheet> {
  Winner _winner = Winner.me;
  WinKind _winKind = WinKind.single;
  int _cube = 1;
  static const _cubeOptions = [1, 2, 4, 8, 16, 32, 64];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final session = state.sessions.firstWhere((s) => s.id == widget.sessionId);
    final myName = state.user?.name ?? 'Ich';
    final oppName = (() {
      final match = state.opponents.where((o) => o.id == session.opponentId);
      return match.isNotEmpty ? match.first.name : 'Gegner';
    })();

    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Gewinner mit echten Namen
          DropdownButtonFormField<Winner>(
            value: _winner,
            decoration: const InputDecoration(labelText: 'Gewinner'),
            items: [
              DropdownMenuItem(value: Winner.me, child: Text(myName)),
              DropdownMenuItem(value: Winner.opponent, child: Text(oppName)),
            ],
            onChanged: (v) => setState(() => _winner = v ?? Winner.me),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<WinKind>(
            value: _winKind,
            decoration: const InputDecoration(labelText: 'Siegart'),
            items: const [
              DropdownMenuItem(value: WinKind.single, child: Text('Single')),
              DropdownMenuItem(value: WinKind.gammon, child: Text('Gammon')),
              DropdownMenuItem(value: WinKind.backgammon, child: Text('Backgammon')),
              DropdownMenuItem(value: WinKind.passDouble, child: Text('Doppelung abgelehnt')),
            ],
            onChanged: (v) => setState(() => _winKind = v ?? WinKind.single),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _cube,
                  decoration: const InputDecoration(labelText: 'Würfel'),
                  items: _cubeOptions
                      .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                      .toList(),
                  onChanged: (v) => setState(() => _cube = v ?? 1),
                ),
              ),
              const SizedBox(width: 12),
              DoublingCube(value: _cube, size: 28),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Spiel hinzufügen'),
            onPressed: () {
              state.addGameScored(
                sessionId: widget.sessionId,
                winner: _winner,
                winKind: _winKind,
                cube: _cube,
              );
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}