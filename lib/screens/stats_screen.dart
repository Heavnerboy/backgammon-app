import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../models/models.dart';
import '../l10n/generated/app_localizations.dart';
import '../widgets/avatar_with_name.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String? _selectedOpponentId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final state     = context.watch<AppState>();
    final scheme    = Theme.of(context).colorScheme;
    final text      = Theme.of(context).textTheme;
    final opponents = state.opponents;
    final sessions = (_selectedOpponentId == null)
        ? state.sessions
        : state.sessions.where((s) => s.opponentId == _selectedOpponentId).toList();

    final List<Game> games = [];
    for (final s in sessions) {
      games.addAll(state.gamesForSession(s.id));
    }
    games.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final myName = state.user?.name ?? l.me;
    final Opponent? opp = (_selectedOpponentId == null)
        ? null
        : (() {
            final m = opponents.where((o) => o.id == _selectedOpponentId);
            return m.isNotEmpty ? m.first : null;
          })();
    final oppName = opp?.name ?? l.allOpponentsShort;

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
          SliverAppBar(
            pinned: true,
            backgroundColor: scheme.secondaryContainer,
            foregroundColor: scheme.onSecondaryContainer,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              l.statsTitle,
              style: text.headlineSmall?.copyWith(color: scheme.onSecondaryContainer),
            ),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 12, bottom: 6),
              ),
            ],
          ),

          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeader(
              minHeight: 156,
              maxHeight: 156,
              child: Container(
                color: scheme.surface,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String?>(
                      value: _selectedOpponentId,
                      decoration: InputDecoration(labelText: l.opponentLabel),
                      items: <DropdownMenuItem<String?>>[
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(l.allOpponents),
                        ),
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

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                          _StatCard(label: l.kpiWins, value: '$winsMe : $winsOpp'),
                          _StatCard(label: l.kpiTotalPoints, value: '$sumMyPoints : $sumOppPoints'),
                          _StatCard(label: l.kpiWinRate, value: '${winRate.toStringAsFixed(1)} %'),
                          _StatCard(label: l.kpiAvgDoubling, value: avgDoubling.toStringAsFixed(2)),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.winKindsTitle, style: text.titleMedium),
                          const SizedBox(height: 8),
                          _KindsRow(header: true, myLabel: myName, oppLabel: oppName),
                          const Divider(),
                          _KindsRow(kind: l.winKindSingle, my: meSingle, opp: oppSingle),
                          _KindsRow(kind: l.winKindGammon, my: meGammon, opp: oppGammon),
                          _KindsRow(kind: l.winKindBackgammon, my: meBackgammon, opp: oppBackgammon),
                          _KindsRow(kind: l.winKindPassDouble, my: mePass, opp: oppPass),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.scoreProgressTitle, style: text.titleMedium),
                          const SizedBox(height: 8),
                          if (myCum.isEmpty)
                            SizedBox(height: 220, child: Center(child: Text(l.noGamesYet)))
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

class _VsChip extends StatelessWidget {
  const _VsChip();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceVariant,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.onSurfaceVariant.withOpacity(0.2)),
      ),
      child: Text(
        l.vs,
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
    final l = AppLocalizations.of(context)!;

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
            child: Text(header ? (myLabel ?? l.me) : '${my ?? 0}',
                textAlign: TextAlign.center, style: header ? styleHead : styleVal),
          ),
          Expanded(
            flex: 2,
            child: Text(header ? (oppLabel ?? l.opponent) : '${opp ?? 0}',
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

    double maxY = 1.0;
    for (final v in [...me, ...opp]) {
      if (v > maxY) maxY = v;
    }
    if (maxY < 1) maxY = 1;

    double yFor(double v) {
      final t = v / maxY; // 0..1
      return origin.dy + h * (1 - t);
    }

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

    double xFor(int i, int n) {
      final denom = (n - 1 == 0) ? 1 : (n - 1);
      return origin.dx + w * (i / denom);
    }

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