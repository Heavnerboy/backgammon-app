import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../l10n/generated/app_localizations.dart';
import '../widgets/avatar_picker.dart';
import '../state/theme_provider.dart';

class PlayersScreen extends StatefulWidget {
  const PlayersScreen({super.key});
  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  final _meNameCtrl = TextEditingController();
  String _meAvatar = '🐶';

  @override
  void dispose() {
    _meNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final state = context.watch<AppState>();
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    context.watch<ThemeProvider>();

    final savedUser = state.user;
    if (savedUser != null && _meNameCtrl.text.isEmpty) {
      _meNameCtrl.text = savedUser.name;
      _meAvatar = savedUser.avatar;
    }

    final sessionsByStart = [...state.sessions]..sort((a, b) => a.startedAt.compareTo(b.startedAt));
    final firstSession = sessionsByStart.isNotEmpty ? sessionsByStart.first : null;
    final String mySinceLabel = firstSession != null
        ? l.sinceDate(state.formatDate(firstSession.startedAt))
        : l.sinceDash;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.secondaryContainer,
        foregroundColor: scheme.onSecondaryContainer,
        elevation: 0,
        title: Text(l.playersTitle, style: textTheme.headlineSmall?.copyWith(color: scheme.onSecondaryContainer)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12, bottom: 6),
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Mein Profil ---
          Text(l.myProfile, style: textTheme.titleLarge),
          const SizedBox(height: 8),

          Card(
            child: ListTile(
              leading: Text(savedUser?.avatar ?? _meAvatar, style: const TextStyle(fontSize: 28)),
              title: Text(savedUser?.name ?? l.me),
              subtitle: Text(mySinceLabel),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Edit: Profil bearbeiten
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: l.editProfile,
                    onPressed: () async {
                      await _showUserEditor(
                        context,
                        initialName: savedUser?.name ?? _meNameCtrl.text,
                        initialAvatar: savedUser?.avatar ?? _meAvatar,
                        onSaved: (name, avatar) {
                          context.read<AppState>().upsertUser(
                                name: name.trim().isEmpty ? l.me : name.trim(),
                                avatar: avatar,
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l.profileSaved)),
                          );
                          setState(() {
                            _meNameCtrl.text = name;
                            _meAvatar = avatar;
                          });
                        },
                      );
                    },
                  ),

                  // Delete: Profil zurücksetzen
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: l.deleteProfile,
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(l.confirmDeleteProfileTitle),
                              content: Text(l.confirmDeleteProfileBody),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text(l.cancel),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text(l.delete),
                                ),
                              ],
                            ),
                          ) ??
                          false;

                      if (confirmed) {
                        context.read<AppState>().upsertUser(name: l.me, avatar: '🙂');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l.profileReset)),
                        );
                        setState(() {
                          _meNameCtrl.text = l.me;
                          _meAvatar = '🙂';
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 32),

          // --- Gegner ---
          Text(l.opponents, style: textTheme.titleLarge),
          const SizedBox(height: 8),

          if (state.opponents.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                l.noOpponentsHint,
                style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),

          for (final o in state.opponents)
            Card(
              child: ListTile(
                leading: Text(o.avatar, style: const TextStyle(fontSize: 28)),
                title: Text(o.name),
                subtitle: Text(l.sinceDate(state.formatDate(o.createdAt))),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Edit-Button für Gegner
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: l.editOpponent,
                      onPressed: () async {
                        await _showOpponentEditor(
                          context,
                          initialName: o.name,
                          initialAvatar: o.avatar,
                          onSaved: (name, avatar) {
                            // TODO: Wenn vorhanden, lieber AppState.updateOpponent(...) verwenden
                            try {
                              context.read<AppState>().removeOpponent(o.id);
                              context.read<AppState>().addOpponent(name.trim().isEmpty ? l.opponent : name.trim(), avatar);
                            } catch (_) {
                              // falls du bereits ein echtes update hast, stelle hier um
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l.opponentUpdated(name.trim().isEmpty ? l.opponent : name.trim()))),
                            );
                          },
                        );
                      },
                    ),

                    // Delete-Button für Gegner
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: l.deleteOpponent,
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(l.confirmDeleteOpponentTitle),
                                content: Text(l.confirmDeleteOpponentBody),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: Text(l.cancel),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: Text(l.delete),
                                  ),
                                ],
                              ),
                            ) ??
                            false;

                        if (confirmed) {
                          context.read<AppState>().removeOpponent(o.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l.opponentDeleted(o.name))),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 80), // Platz für FAB
        ],
      ),

      // FAB: Gegner hinzufügen (Bottom Sheet)
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add_alt_1),
        label: Text(l.opponentAddedFAB),
        onPressed: () async {
          await _showOpponentEditor(
            context,
            onSaved: (name, avatar) {
              final n = name.trim().isEmpty ? l.opponent : name.trim();
              context.read<AppState>().addOpponent(n, avatar);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l.opponentAddedSnackbar(n))),
              );
            },
          );
        },
      ),
    );
  }

  // ===== Bottom Sheet: Mein Profil bearbeiten =====
  Future<void> _showUserEditor(
    BuildContext context, {
    required String initialName,
    required String initialAvatar,
    required void Function(String name, String avatar) onSaved,
  }) async {
    final l = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController(text: initialName);
    String avatar = initialAvatar;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.editProfile, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(labelText: l.yourNameLabel),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('${l.avatarLabel} ', style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(width: 8),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AvatarPicker(
                      initial: avatar,
                      onChanged: (v) => avatar = v,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                onSaved(nameCtrl.text, avatar);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.save_outlined),
              label: Text(l.save),
            ),
          ],
        ),
      ),
    );
  }

  // ===== Bottom Sheet: Gegner hinzufügen/bearbeiten =====
  Future<void> _showOpponentEditor(
    BuildContext context, {
    String initialName = '',
    String initialAvatar = '🦊',
    required void Function(String name, String avatar) onSaved,
  }) async {
    final l = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController(text: initialName);
    String avatar = initialAvatar;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
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
              initialName.isEmpty ? l.opponentEditorTitleAdd : l.opponentEditorTitleEdit,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(labelText: l.opponentNameLabel),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('${l.avatarLabel} ', style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(width: 8),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AvatarPicker(
                      initial: avatar,
                      onChanged: (v) => avatar = v,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                onSaved(nameCtrl.text, avatar);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.save_outlined),
              label: Text(l.save),
            ),
          ],
        ),
      ),
    );
  }
}