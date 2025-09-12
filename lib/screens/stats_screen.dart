import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/models.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String? _selectedOpponentId; // null = Alle Gegner

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final opponents = state.opponents;

    // Sessions nach Gegner filtern (null => alle)
    final sessions = (_selectedOpponentId == null)
        ? state.sessions
        : state.sessions.where((s) => s.opponentId == _selectedOpponentId).toList();

    // Alle Spiele der gefilterten Sessions einsammeln
    final List<Game> games = [];
    for (final s in sessions) {
      games.addAll(state.gamesForSession(s.id));
    }
    games.sort((a, b) => a.timestamp.compareTo(b.timestamp)); // chronologisch

    // Namen + Avatare
    final myName = state.user?.name ?? 'Ich';
    final myAvatar = state.user?.avatar ?? '🙂';
    final oppName = (_selectedOpponentId == null)
        ? 'Alle'
        : opponents.firstWhere((o) => o.id == _selectedOpponentId).name;
    final oppAvatar = (_selectedOpponentId == null)
        ? '👥'
        : opponents.firstWhere((o) => o.id == _selectedOpponentId).avatar;

    // KPIs
    final winsMe = games.where((g) => g.winner == Winner.me).length;
    final winsOpp = games.where((g) => g.winner == Winner.opponent).length;

    int sumMyPoints = 0, sumOppPoints = 0;
    int meSingle = 0, meGammon = 0, meBackgammon = 0, mePass = 0;
    int oppSingle = 0, oppGammon = 0, oppBackgammon = 0, oppPass = 0;

    int cubeSumAll = 0; // Ø Verdopplung über alle Spiele
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

    final totalGames = games.length;
    final winRate = totalGames == 0 ? 0.0 : (winsMe / totalGames) * 100.0;
    final avgDoubling = totalGames == 0 ? 0.0 : cubeSumAll / totalGames;

    // Score-Verlauf (2 Linien)
    final List<double> myCum = [];
    final List<double> oppCum = [];
    double myAcc = 0, oppAcc = 0;
    for (final g in games) {
      myAcc += g.myPoints.toDouble();
      oppAcc += g.opponentPoints.toDouble();
      myCum.add(myAcc);
      oppCum.add(oppAcc);
    }

    // Chart-Farben (für Legende)
    final meColor = Theme.of(context).colorScheme.primary;
    final oppColor = Theme.of(context).colorScheme.tertiary;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Gegnerauswahl
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedOpponentId,
                    decoration: const InputDecoration(labelText: 'Gegner'),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Alle Gegner'),
                      ),
                      ...opponents.map((o) => DropdownMenuItem<String>(
                            value: o.id,
                            child: Text('${o.avatar}  ${o.name}'),
                          )),
                    ],
                    onChanged: (v) => setState(() => _selectedOpponentId = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Kopfzeile mit Avataren
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(myAvatar, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Text(myName, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(width: 12),
                Text('vs', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(width: 12),
                Text(oppAvatar, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Text(oppName, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 12),

            // KPI-Karten
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StatCard(label: 'Siege', value: '$winsMe : $winsOpp'),
                _StatCard(label: 'Gesamtpunkte', value: '$sumMyPoints : $sumOppPoints'),
                _StatCard(label: 'Win-Rate', value: '${winRate.toStringAsFixed(1)} %'),
                _StatCard(label: 'Ø Verdopplung', value: avgDoubling.toStringAsFixed(2)),
              ],
            ),
            const SizedBox(height: 16),

            // Tabelle Siegarten (inkl. Passen der Verdopplung)
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Siegarten', style: Theme.of(context).textTheme.titleMedium),
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

            // Score-Verlauf (2 Linien) + Legende
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Score-Verlauf', style: Theme.of(context).textTheme.titleMedium),
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
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      )),
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
    final styleHead = Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
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

// ===== Charts & Legende =====

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
        if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
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