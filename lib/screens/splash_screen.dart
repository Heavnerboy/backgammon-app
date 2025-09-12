import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onDone;
  const SplashScreen({super.key, required this.onDone});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), widget.onDone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Radialer Verlauf in Blau
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.4),
            radius: 1.2,
            colors: [Color(0xFF1E2A78), Color(0xFF0A1247)],
            stops: [0.2, 1.0],
          ),
        ),
        child: Center(
          // Stapel Backgammon-Steine (runde Checker) mit Schatten
          child: Stack(
            clipBehavior: Clip.none,
            children: List.generate(6, (i) {
              final offset = i * 14.0;
              return Transform.translate(
                offset: Offset(0, -offset),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i.isEven ? const Color(0xFFEDE7F6) : const Color(0xFFB39DDB),
                    boxShadow: const [BoxShadow(blurRadius: 16, spreadRadius: 0, offset: Offset(0, 8), color: Colors.black26)],
                    border: Border.all(color: Colors.black26, width: 1),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}