import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/doubling_cube.dart';

class NewSessionSheet extends StatefulWidget {
  final Opponent opponent;
  const NewSessionSheet({super.key, required this.opponent});

  @override
  State<NewSessionSheet> createState() => _NewSessionSheetState();
}

class _NewSessionSheetState extends State<NewSessionSheet> {
  // Du hattest den Rest schon umgesetzt – hier nur Minimalbeispiel
  // Wenn du die Dropdowns (Siegart/Würfel) bereits in einer anderen Datei hast, kannst du dieses Sheet weglassen.
  WinKind _winKind = WinKind.single;
  int _cube = 1;
  static const _cubeOptions = [1, 2, 4, 8, 16, 32, 64];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Session gegen ${widget.opponent.name}',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),

          // Siegart (nur Single/Gammon/Backgammon)
          DropdownButtonFormField<WinKind>(
            value: _winKind,
            decoration: const InputDecoration(labelText: 'Siegart'),
            items: const [
              DropdownMenuItem(value: WinKind.single, child: Text('Single')),
              DropdownMenuItem(value: WinKind.gammon, child: Text('Gammon')),
              DropdownMenuItem(value: WinKind.backgammon, child: Text('Backgammon')),
            ],
            onChanged: (v) => setState(() {
              if (v != null) _winKind = v;
            }),
          ),
          const SizedBox(height: 12),

          // Würfel (nur Zahlen)
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _cube,
                  decoration: const InputDecoration(labelText: 'Verdoppelung'),
                  items: _cubeOptions
                      .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                      .toList(),
                  onChanged: (v) => setState(() {
                    if (v != null) _cube = v;
                  }),
                ),
              ),
              const SizedBox(width: 12),
              DoublingCube(value: _cube, size: 28),
            ],
          ),

          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Icons.save),
            onPressed: () {
              // 1) Session anlegen
              final sessionId = state.newSession(widget.opponent.id);

              // 2) Sofort ein Game erfassen (optional — falls du das so möchtest)
              //    Oder diesen Schritt entfernen, wenn du Games separat erfasst.
              state.addGameScored(
                sessionId: sessionId,
                winner: Winner.me, // oder Winner.opponent – nach Bedarf anpassen
                winKind: _winKind,
                cube: _cube,
              );

              Navigator.pop(context);
            },
            label: const Text('Speichern'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}