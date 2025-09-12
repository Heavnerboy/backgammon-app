import 'package:flutter/material.dart';

class DoublingCube extends StatelessWidget {
  final int value;
  final double size;

  const DoublingCube({
    super.key,
    required this.value,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(6);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: radius,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
        boxShadow: kElevationToShadow[1],
      ),
      child: Text(
        '$value',
        style: TextStyle(
          fontSize: size * 0.55,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}