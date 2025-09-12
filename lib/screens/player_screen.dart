import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/avatar_picker.dart';

class PlayersScreen extends StatefulWidget {
  const PlayersScreen({super.key});
  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  final _meNameCtrl = TextEditingController();
  String _meAvatar = '🐶'; // Default
  final _oppNameCtrl = TextEditingController();
  String _oppAvatar = '🦊'; // Default

  @override
  void dispose() {
    _meNameCtrl.dispose();
    _oppNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Bestehendes Profil übernehmen (einmalig, wenn Feld noch leer ist)
    final savedUser = state.user;
    if (savedUser != null && _meNameCtrl.text.isEmpty) {
      _meNameCtrl.text = savedUser.name;
      _meAvatar = savedUser.avatar;
    }

    return Scaffold(
      // Header nutzt M3-ColorScheme (Dark-Mode-ready)
      appBar: AppBar(
        backgroundColor: scheme.secondaryContainer,  // leicht gebrandetes Band
        foregroundColor: scheme.onSecondaryContainer,
        elevation: 0,
        title: Text('Spieler', style: textTheme.headlineSmall?.copyWith(
          color: scheme.onSecondaryContainer,
        )),
      ),

      // Inhalt (scrollbar)
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Ich ---
          Text('Ich', style: textTheme.titleLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _meNameCtrl,
            decoration: const InputDecoration(labelText: 'Dein Name'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Avatar: ', style: textTheme.bodyLarge),
              const SizedBox(width: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AvatarPicker(
                    initial: _meAvatar,
                    onChanged: (v) => setState(() => _meAvatar = v),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () {
              final name = _meNameCtrl.text.trim().isEmpty ? 'Ich' : _meNameCtrl.text.trim();
              context.read<AppState>().upsertUser(name: name, avatar: _meAvatar);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profil gespeichert')),
              );
            },
            icon: const Icon(Icons.save_outlined),
            label: const Text('Profil speichern'),
          ),

          const Divider(height: 32),

          // --- Gegner ---
          Text('Gegner', style: textTheme.titleLarge),
          const SizedBox(height: 8),

          for (final o in state.opponents)
            Card(
              child: ListTile(
                leading: Text(o.avatar, style: const TextStyle(fontSize: 24)),
                title: Text(o.name),
                subtitle: Text('seit ${state.formatDate(o.createdAt)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Gegner löschen?'),
                            content: const Text(
                              'Wenn du den Gegner löschst, werden auch zugehörige Sessions und Spiele entfernt. Fortfahren?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Abbrechen'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Löschen'),
                              ),
                            ],
                          ),
                        ) ??
                        false;

                    if (confirmed) {
                      context.read<AppState>().removeOpponent(o.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('„${o.name}“ gelöscht')),
                      );
                    }
                  },
                ),
              ),
            ),

          const SizedBox(height: 8),
          TextField(
            controller: _oppNameCtrl,
            decoration: const InputDecoration(labelText: 'Name des Gegners'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Avatar: ', style: textTheme.bodyLarge),
              const SizedBox(width: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AvatarPicker(
                    initial: _oppAvatar,
                    onChanged: (v) => setState(() => _oppAvatar = v),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () {
              final name = _oppNameCtrl.text.trim().isEmpty ? 'Gegner' : _oppNameCtrl.text.trim();
              context.read<AppState>().addOpponent(name, _oppAvatar);
              _oppNameCtrl.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gegner hinzugefügt')),
              );
            },
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Gegner hinzufügen'),
          ),
        ],
      ),
    );
  }
}