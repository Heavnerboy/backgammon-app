import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onDone;
  const SplashScreen({super.key, required this.onDone});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.4),
            radius: 1.2,
            colors: [Color(0xFF1E2A78), Color(0xFF0A1247)],
            stops: [0.2, 1.0],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            final center = Offset(size.width / 2, size.height / 2);
            final arcRadius = 150.0;
            final arcYOffset = -20.0;

            return Stack(
              // ⬇️ WICHTIG: fülle die komplette Fläche
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                // die Chips
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: List.generate(6, (i) {
                      final offset = i * 14.0;
                      return Transform.translate(
                        offset: Offset(0, -offset),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i.isEven
                                ? const Color(0xFFEDE7F6)
                                : const Color(0xFFB39DDB),
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 16,
                                offset: Offset(0, 8),
                                color: Colors.black26,
                              )
                            ],
                            border: Border.all(color: Colors.black26, width: 1),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // Gebogener Schriftzug
                Positioned.fill(
                  child: IgnorePointer(
                    child: FadeTransition(
                      opacity: _fade,
                      child: CustomPaint(
                        painter: _CurvedTextPainter(
                          text: "Backgammon Score",
                          textStyle: GoogleFonts.baloo2(
                            textStyle: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.0,
                              shadows: [
                                Shadow(
                                  blurRadius: 12,
                                  offset: Offset(0, 3),
                                  color: Colors.black45,
                                ),
                              ],
                            ),
                          ),
                          // leicht unter die Chips versetzt
                          center: center.translate(0, arcYOffset),
                          radius: arcRadius,
                          startAngleDeg: 200,
                          endAngleDeg: 340,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CurvedTextPainter extends CustomPainter {
  final String text;
  final TextStyle textStyle;
  final Offset center;
  final double radius;
  final double startAngleDeg;
  final double endAngleDeg;

  _CurvedTextPainter({
    required this.text,
    required this.textStyle,
    required this.center,
    required this.radius,
    this.startAngleDeg = 200,
    this.endAngleDeg = 340,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (text.isEmpty) return;

    double startAngle = startAngleDeg * (math.pi / 180.0);
    double endAngle = endAngleDeg * (math.pi / 180.0);
    if (endAngle < startAngle) {
      final tmp = startAngle;
      startAngle = endAngle;
      endAngle = tmp;
    }

    final totalArcAngle = endAngle - startAngle;

    final glyphPainters = <TextPainter>[];
    double totalTextWidth = 0.0;
    for (final ch in text.characters) {
      final tp = TextPainter(
        text: TextSpan(text: ch, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout(minWidth: 0, maxWidth: double.infinity);
      glyphPainters.add(tp);
      totalTextWidth += tp.width;
    }

    if (totalTextWidth == 0) return;

    final widthToAngle = 1.0 / radius;
    final neededAngle = totalTextWidth * widthToAngle;

    double scale = 1.0;
    if (neededAngle > totalArcAngle) {
      scale = totalArcAngle / neededAngle;
    }

    final actualAngleSpan = neededAngle * scale;
    double angle = startAngle + (totalArcAngle - actualAngleSpan) / 2;

    for (final tp in glyphPainters) {
      final charAngle = (tp.width * widthToAngle) * scale;
      final midAngle = angle + charAngle / 2;

      final px = center.dx + radius * math.cos(midAngle);
      final py = center.dy + radius * math.sin(midAngle);
      final pos = Offset(px, py);

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(midAngle + math.pi / 2);

      final dx = -tp.width / 2;
      final dy = -tp.height;
      tp.paint(canvas, Offset(dx, dy));

      canvas.restore();

      angle += charAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _CurvedTextPainter oldDelegate) {
    return text != oldDelegate.text ||
        textStyle != oldDelegate.textStyle ||
        center != oldDelegate.center ||
        radius != oldDelegate.radius ||
        startAngleDeg != oldDelegate.startAngleDeg ||
        endAngleDeg != oldDelegate.endAngleDeg;
  }
}