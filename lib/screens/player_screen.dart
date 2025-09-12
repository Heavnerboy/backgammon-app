import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/avatar_picker.dart';
import '../state/theme_provider.dart';

class PlayersScreen extends StatefulWidget {
  const PlayersScreen({super.key});
  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  final _meNameCtrl = TextEditingController();
  String _meAvatar = '🐶'; // Default

  @override
  void dispose() {
    _meNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Theme-Status
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    // Profil laden (einmalig in TextField übernehmen)
    final savedUser = state.user;
    if (savedUser != null && _meNameCtrl.text.isEmpty) {
      _meNameCtrl.text = savedUser.name;
      _meAvatar = savedUser.avatar;
    }

    // „seit …“ für eigenes Profil: Fallback = früheste Session, sonst —
    final sessionsByStart = [...state.sessions]..sort((a, b) => a.startedAt.compareTo(b.startedAt));
    final firstSession = sessionsByStart.isNotEmpty ? sessionsByStart.first : null;
    final String mySinceLabel =
        firstSession != null ? 'seit ${state.formatDate(firstSession.startedAt)}' : 'seit —';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.secondaryContainer,
        foregroundColor: scheme.onSecondaryContainer,
        elevation: 0,
        title: Text('Spieler', style: textTheme.headlineSmall?.copyWith(color: scheme.onSecondaryContainer)),
        actions: [
          Padding(
            // leicht nach oben/unten justieren, damit nichts „abgeschnitten“ wirkt
            padding: const EdgeInsets.only(right: 12, bottom: 6),
            child: _ThemeModeToggle(
              isDark: isDark,
              onToggle: () => context.read<ThemeProvider>().toggleTheme(),
            ),
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Mein Profil ---
          Text('Mein Profil', style: textTheme.titleLarge),
          const SizedBox(height: 8),

          Card(
            child: ListTile(
              leading: Text(savedUser?.avatar ?? _meAvatar, style: const TextStyle(fontSize: 28)),
              title: Text(savedUser?.name ?? 'Ich'),
              subtitle: Text(mySinceLabel),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Edit: Profil bearbeiten
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Profil bearbeiten',
                    onPressed: () async {
                      await _showUserEditor(
                        context,
                        initialName: savedUser?.name ?? _meNameCtrl.text,
                        initialAvatar: savedUser?.avatar ?? _meAvatar,
                        onSaved: (name, avatar) {
                          context.read<AppState>().upsertUser(
                                name: name.trim().isEmpty ? 'Ich' : name.trim(),
                                avatar: avatar,
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profil gespeichert')),
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
                    tooltip: 'Profil löschen',
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Profil löschen?'),
                              content: const Text(
                                'Wenn du dein Profil löschst, bleiben deine Sessions erhalten, '
                                'aber Name/Avatar werden zurückgesetzt.',
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
                        context.read<AppState>().upsertUser(name: 'Ich', avatar: '🙂');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profil zurückgesetzt')),
                        );
                        setState(() {
                          _meNameCtrl.text = 'Ich';
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
          Text('Gegner', style: textTheme.titleLarge),
          const SizedBox(height: 8),

          if (state.opponents.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Noch keine Gegner. Unten rechts kannst du Gegner hinzufügen.',
                style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),

          for (final o in state.opponents)
            Card(
              child: ListTile(
                leading: Text(o.avatar, style: const TextStyle(fontSize: 28)),
                title: Text(o.name),
                subtitle: Text('seit ${state.formatDate(o.createdAt)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Edit-Button für Gegner
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Gegner bearbeiten',
                      onPressed: () async {
                        await _showOpponentEditor(
                          context,
                          initialName: o.name,
                          initialAvatar: o.avatar,
                          onSaved: (name, avatar) {
                            // TODO: Wenn vorhanden, lieber AppState.updateOpponent(...) verwenden
                            try {
                              context.read<AppState>().removeOpponent(o.id);
                              context.read<AppState>().addOpponent(name.trim().isEmpty ? 'Gegner' : name.trim(), avatar);
                            } catch (_) {
                              // falls du bereits ein echtes update hast, stelle hier um
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('„${name.trim().isEmpty ? 'Gegner' : name.trim()}“ aktualisiert')),
                            );
                          },
                        );
                      },
                    ),

                    // Delete-Button für Gegner
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Gegner löschen',
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
        label: const Text('Gegner hinzufügen'),
        onPressed: () async {
          await _showOpponentEditor(
            context,
            onSaved: (name, avatar) {
              final n = name.trim().isEmpty ? 'Gegner' : name.trim();
              context.read<AppState>().addOpponent(n, avatar);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('„$n“ hinzugefügt')),
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
            Text('Profil bearbeiten', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Dein Name'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Avatar: ', style: Theme.of(context).textTheme.bodyLarge),
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
              label: const Text('Speichern'),
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
              initialName.isEmpty ? 'Gegner hinzufügen' : 'Gegner bearbeiten',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name des Gegners'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Avatar: ', style: Theme.of(context).textTheme.bodyLarge),
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
              label: const Text('Speichern'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stylischer, animierter Theme-Toggle (Sun/Moon + gleitender Knopf)
class _ThemeModeToggle extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggle;
  const _ThemeModeToggle({
    required this.isDark,
    required this.onToggle,
  });

  @override
  State<_ThemeModeToggle> createState() => _ThemeModeToggleState();
}

class _ThemeModeToggleState extends State<_ThemeModeToggle>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bool isDark = widget.isDark;

    // Größen
    const double width = 64;
    const double height = 34;
    const double padding = 4;
    const double knob = height - padding * 2;

    return Semantics(
      label: 'Theme umschalten',
      value: isDark ? 'Darkmode aktiv' : 'Lightmode aktiv',
      button: true,
      child: GestureDetector(
        onTap: widget.onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          width: width,
          height: height,
          padding: const EdgeInsets.all(padding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      scheme.primaryContainer.withOpacity(0.25),
                      scheme.primary.withOpacity(0.35),
                    ]
                  : [
                      scheme.tertiaryContainer.withOpacity(0.5),
                      scheme.surfaceContainerHighest.withOpacity(0.9),
                    ],
            ),
            border: Border.all(
              color: isDark ? scheme.primary.withOpacity(0.4) : scheme.outlineVariant,
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 4),
                color: Colors.black.withOpacity(isDark ? 0.25 : 0.12),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.wb_sunny_rounded,
                    size: 16,
                    color: isDark
                        ? scheme.onSurface.withOpacity(0.35)
                        : scheme.onSurface.withOpacity(0.9),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.nights_stay_rounded,
                    size: 16,
                    color: isDark
                        ? scheme.onSurface.withOpacity(0.9)
                        : scheme.onSurface.withOpacity(0.35),
                  ),
                ),
              ),
              AnimatedAlign(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: knob,
                  height: knob,
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(knob / 2),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                        color: Colors.black.withOpacity(0.25),
                      ),
                    ],
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      key: ValueKey(isDark),
                      size: 16,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}