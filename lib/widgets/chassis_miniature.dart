import 'package:flutter/material.dart';
import '../models/chantier.dart';

class ChassisMiniature extends StatelessWidget {
  final Chassis chassis;
  final double maxSize;

  const ChassisMiniature({super.key, required this.chassis, this.maxSize = 60.0});

  @override
  Widget build(BuildContext context) {
    if (chassis.hauteur == 0 || chassis.largeur == 0 || chassis.elements.isEmpty) {
      return Icon(Icons.window, size: maxSize, color: Colors.green);
    }

    double scale = maxSize / chassis.hauteur;
    if (scale * chassis.largeur > maxSize) {
      scale = maxSize / chassis.largeur;
    }

    final double scaledWidth = chassis.largeur * scale;
    final double scaledHeight = chassis.hauteur * scale;

    return Container(
      width: scaledWidth,
      height: scaledHeight,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black54, width: 1),
        color: Colors.white,
      ),
      child: Stack(
        children: chassis.elements.map((el) {
          return Positioned(
            left: el.x * scale,
            top: el.y * scale,
            width: el.largeur * scale,
            height: el.hauteur * scale,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.brown.shade800, width: 0.5),
                color: Colors.brown.shade200.withOpacity(0.8),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
