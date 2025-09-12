import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../widgets/avatar_with_name.dart';
import '../state/theme_provider.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String? _selectedOpponentId; // null = Alle Gegner

  @override
  Widget build(BuildContext context) {
    final state     = context.watch<AppState>();
    final scheme    = Theme.of(context).colorScheme;
    final text      = Theme.of(context).textTheme;
    final opponents = state.opponents;

    // Theme-Status
    final isDark = context.watch<ThemeProvider>().themeMode == ThemeMode.dark;

    // Sessions nach Gegner filtern (null => alle)
    final sessions = (_selectedOpponentId == null)
        ? state.sessions
        : state.sessions.where((s) => s.opponentId == _selectedOpponentId).toList();

    // Alle Spiele der gefilterten Sessions
    final List<Game> games = [];
    for (final s in sessions) {
      games.addAll(state.gamesForSession(s.id));
    }
    games.sort((a, b) => a.timestamp.compareTo(b.timestamp)); // chronologisch

    // Namen
    final myName = state.user?.name ?? 'Ich';
    final Opponent? opp = (_selectedOpponentId == null)
        ? null
        : (() {
            final m = opponents.where((o) => o.id == _selectedOpponentId);
            return m.isNotEmpty ? m.first : null;
          })();
    final oppName = opp?.name ?? 'Alle';

    // KPIs
    final winsMe  = games.where((g) => g.winner == Winner.me).length;
    final winsOpp = games.where((g) => g.winner == Winner.opponent).length;

    int sumMyPoints = 0, sumOppPoints = 0;
    int meSingle = 0, meGammon = 0, meBackgammon = 0, mePass = 0;
    int oppSingle = 0, oppGammon = 0, oppBackgammon = 0, oppPass = 0;

    int cubeSumAll = 0;
    for (final g in games) {
      sumMyPoints += g.myPoints;
      sumOppPoints += g.opponentPoints;
      cubeSumAll += g.cube;

      if (g.winner == Winner.me) {
        switch (g.winKind) {
          case WinKind.single: meSingle++; break;
          case WinKind.gammon: meGammon++; break;
          case WinKind.backgammon: meBackgammon++; break;
          case WinKind.passDouble: mePass++; break;
        }
      } else {
        switch (g.winKind) {
          case WinKind.single: oppSingle++; break;
          case WinKind.gammon: oppGammon++; break;
          case WinKind.backgammon: oppBackgammon++; break;
          case WinKind.passDouble: oppPass++; break;
        }
      }
    }

    final totalGames  = games.length;
    final winRate     = totalGames == 0 ? 0.0 : (winsMe / totalGames) * 100.0;
    final avgDoubling = totalGames == 0 ? 0.0 : cubeSumAll / totalGames;

    // Score-Verlauf
    final List<double> myCum = [];
    final List<double> oppCum = [];
    double myAcc = 0, oppAcc = 0;
    for (final g in games) {
      myAcc += g.myPoints.toDouble();
      oppAcc += g.opponentPoints.toDouble();
      myCum.add(myAcc);
      oppCum.add(oppAcc);
    }

    final meColor  = scheme.primary;
    final oppColor = scheme.tertiary;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 🔹 Header mit Toggle
          SliverAppBar(
            pinned: true,
            backgroundColor: scheme.secondaryContainer,
            foregroundColor: scheme.onSecondaryContainer,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              'Statistiken',
              style: text.headlineSmall?.copyWith(color: scheme.onSecondaryContainer),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12, bottom: 6),
                child: _ThemeModeToggle(
                  isDark: isDark,
                  onToggle: () => context.read<ThemeProvider>().toggleTheme(),
                ),
              ),
            ],
          ),

          // 🔹 Sticky 2: VS-Bar + Gegnerauswahl (leicht kompakter)
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeader(
              minHeight: 156, // vorher 156
              maxHeight: 156,
              child: Container(
                color: scheme.surface,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12), // kompakter
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        AvatarWithName(
                          name: myName,
                          emojiOrInitial: state.user?.avatar ?? '🙂',
                          avatarSize: 44,
                        ),
                        const Expanded(
                          child: Row(
                            children: [
                              Expanded(child: _Line()),
                              _VsChip(),
                              Expanded(child: _Line()),
                            ],
                          ),
                        ),
                        AvatarWithName(
                          name: oppName,
                          emojiOrInitial: opp?.avatar ?? '👥',
                          avatarSize: 44,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8), // vorher 12
                    DropdownButtonFormField<String?>(
                      value: _selectedOpponentId,
                      decoration: const InputDecoration(labelText: 'Gegner'),
                      items: <DropdownMenuItem<String?>>[
                        const DropdownMenuItem<String?>(value: null, child: Text('Alle Gegner')),
                        ...opponents.map(
                          (o) => DropdownMenuItem<String?>(
                            value: o.id,
                            child: Text('${o.avatar}  ${o.name}'),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() => _selectedOpponentId = v),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 🔹 Inhalt
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), // top vorher 16 → 8
              child: Column(
                children: [
                  // KPI-Grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final double width = constraints.maxWidth;
                      const int crossAxisCount = 2;
                      const double spacing = 6;

                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                        childAspectRatio: (width / crossAxisCount) / 90,
                        children: [
                          _StatCard(label: 'Siege', value: '$winsMe : $winsOpp'),
                          _StatCard(label: 'Gesamtpunkte', value: '$sumMyPoints : $sumOppPoints'),
                          _StatCard(label: 'Win-Rate', value: '${winRate.toStringAsFixed(1)} %'),
                          _StatCard(label: 'Ø Verdopplung', value: avgDoubling.toStringAsFixed(2)),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  // Siegarten-Tabelle
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Siegarten', style: text.titleMedium),
                          const SizedBox(height: 8),
                          _KindsRow(header: true, myLabel: myName, oppLabel: oppName),
                          const Divider(),
                          _KindsRow(kind: 'Single', my: meSingle, opp: oppSingle),
                          _KindsRow(kind: 'Gammon', my: meGammon, opp: oppGammon),
                          _KindsRow(kind: 'Backgammon', my: meBackgammon, opp: oppBackgammon),
                          _KindsRow(kind: 'Doppelung abgelehnt', my: mePass, opp: oppPass),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Score-Verlauf + Legende
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Score-Verlauf', style: text.titleMedium),
                          const SizedBox(height: 8),
                          if (myCum.isEmpty)
                            const SizedBox(height: 220, child: Center(child: Text('Noch keine Spiele')))
                          else
                            Column(
                              children: [
                                SizedBox(
                                  height: 220,
                                  child: _DualLineChart(
                                    me: myCum,
                                    opp: oppCum,
                                    meLabel: myName,
                                    oppLabel: oppName,
                                    meColor: meColor,
                                    oppColor: oppColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _Legend(
                                  entries: [
                                    LegendEntry(label: myName, color: meColor),
                                    LegendEntry(label: oppName, color: oppColor),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===== Sticky Header Delegate (für VS + Dropdown) =====
class _StickyHeader extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _StickyHeader({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      elevation: overlapsContent ? 1 : 0,
      child: SizedBox.expand(child: child),
    );
    }

  @override
  bool shouldRebuild(covariant _StickyHeader old) =>
      minHeight != old.minHeight || maxHeight != old.maxHeight || child != old.child;
}

// ===== VS-Bausteine =====
class _VsChip extends StatelessWidget {
  const _VsChip();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceVariant,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.onSurfaceVariant.withOpacity(0.2)),
      ),
      child: Text(
        'VS',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
    );
  }
}

// ===== Charts & Legende (unverändert bis auf Theme-Nutzung) =====
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 160,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KindsRow extends StatelessWidget {
  final bool header;
  final String? kind;
  final int? my;
  final int? opp;
  final String? myLabel;
  final String? oppLabel;

  const _KindsRow({
    this.header = false,
    this.kind,
    this.my,
    this.opp,
    this.myLabel,
    this.oppLabel,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final styleHead = Theme.of(context).textTheme.labelMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        );
    final styleVal = Theme.of(context).textTheme.bodyLarge;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(header ? '' : (kind ?? ''), style: header ? styleHead : styleVal),
          ),
          Expanded(
            flex: 2,
            child: Text(header ? (myLabel ?? 'Ich') : '${my ?? 0}',
                textAlign: TextAlign.center, style: header ? styleHead : styleVal),
          ),
          Expanded(
            flex: 2,
            child: Text(header ? (oppLabel ?? 'Gegner') : '${opp ?? 0}',
                textAlign: TextAlign.center, style: header ? styleHead : styleVal),
          ),
        ],
      ),
    );
  }
}

class _DualLineChart extends StatelessWidget {
  final List<double> me;
  final List<double> opp;
  final String meLabel;
  final String oppLabel;
  final Color meColor;
  final Color oppColor;

  const _DualLineChart({
    required this.me,
    required this.opp,
    required this.meLabel,
    required this.oppLabel,
    required this.meColor,
    required this.oppColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DualLinePainter(
        me: me,
        opp: opp,
        meColor: meColor,
        oppColor: oppColor,
        gridColor: Theme.of(context).colorScheme.outlineVariant,
      ),
      child: Container(),
    );
  }
}

class _DualLinePainter extends CustomPainter {
  final List<double> me;
  final List<double> opp;
  final Color meColor;
  final Color oppColor;
  final Color gridColor;

  _DualLinePainter({
    required this.me,
    required this.opp,
    required this.meColor,
    required this.oppColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pad = 12.0;
    final w = size.width - pad * 2;
    final h = size.height - pad * 2;
    final origin = Offset(pad, pad);

    // max
    double maxY = 1.0;
    for (final v in [...me, ...opp]) {
      if (v > maxY) maxY = v;
    }
    if (maxY < 1) maxY = 1;

    double yFor(double v) {
      final t = v / maxY; // 0..1
      return origin.dy + h * (1 - t);
    }

    // Rahmen + horizontale Rasterlinien (4)
    final axis = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(Rect.fromLTWH(origin.dx, origin.dy, w, h), axis);

    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (int i = 1; i <= 4; i++) {
      final y = origin.dy + h * (i / 5);
      canvas.drawLine(Offset(origin.dx, y), Offset(origin.dx + w, y), grid);
    }

    // x mapping
    double xFor(int i, int n) {
      final denom = (n - 1 == 0) ? 1 : (n - 1);
      return origin.dx + w * (i / denom);
    }

    // Linien
    void drawSeries(List<double> d, Color c) {
      if (d.isEmpty) return;
      final path = Path();
      for (int i = 0; i < d.length; i++) {
        final x = xFor(i, d.length);
        final y = yFor(d[i]);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      final line = Paint()
        ..color = c
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawPath(path, line);

      final dot = Paint()..color = c;
      for (int i = 0; i < d.length; i++) {
        canvas.drawCircle(Offset(xFor(i, d.length), yFor(d[i])), 2.5, dot);
      }
    }

    drawSeries(me, meColor);
    drawSeries(opp, oppColor);
  }

  @override
  bool shouldRepaint(covariant _DualLinePainter old) =>
      old.me != me || old.opp != opp || old.meColor != meColor || old.oppColor != oppColor;
}

class LegendEntry {
  final String label;
  final Color color;
  LegendEntry({required this.label, required this.color});
}

class _Legend extends StatelessWidget {
  final List<LegendEntry> entries;
  const _Legend({required this.entries});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: entries
          .map(
            (e) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: e.color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 6),
                Text(e.label),
              ],
            ),
          )
          .toList(),
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