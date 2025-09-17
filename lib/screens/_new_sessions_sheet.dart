import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/doubling_cube.dart';
import '../l10n/generated/app_localizations.dart';

class NewSessionSheet extends StatefulWidget {
  final Opponent opponent;
  const NewSessionSheet({super.key, required this.opponent});

  @override
  State<NewSessionSheet> createState() => _NewSessionSheetState();
}

class _NewSessionSheetState extends State<NewSessionSheet> {
  WinKind _winKind = WinKind.single;
  int _cube = 1;
  static const _cubeOptions = [1, 2, 4, 8, 16, 32, 64];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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
          Text(
            l.sessionAgainstName(widget.opponent.name),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          // Siegart
          DropdownButtonFormField<WinKind>(
            value: _winKind,
            decoration: InputDecoration(labelText: l.winTypeLabel),
            items: [
              DropdownMenuItem(value: WinKind.single, child: Text(l.winKindSingle)),
              DropdownMenuItem(value: WinKind.gammon, child: Text(l.winKindGammon)),
              DropdownMenuItem(value: WinKind.backgammon, child: Text(l.winKindBackgammon)),
            ],
            onChanged: (v) => setState(() {
              if (v != null) _winKind = v;
            }),
          ),
          const SizedBox(height: 12),

          // Verdopplungswürfel
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _cube,
                  decoration: InputDecoration(labelText: l.doublingLabel),
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
            icon: const Icon(Icons.save_outlined),
            onPressed: () {
              // 1) Session anlegen
              final sessionId = state.newSession(widget.opponent.id);

              // 2) Optional direkt erstes Spiel erfassen
              state.addGameScored(
                sessionId: sessionId,
                winner: Winner.me, // ggf. anpassen
                winKind: _winKind,
                cube: _cube,
              );

              Navigator.pop(context);
            },
            label: Text(l.save),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}