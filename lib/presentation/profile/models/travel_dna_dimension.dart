import 'package:flutter/material.dart';

/// Dimension model representing a specific aspect of the user's Travel DNA.
class TravelDnaDimension {
  final String name;
  final String icon;
  final double score; // 0 to 100
  final Color barColor;

  const TravelDnaDimension({
    required this.name,
    required this.icon,
    required this.score,
    this.barColor = const Color(0xFFE65100),
  });

  double get normalizedScore => (score / 100.0).clamp(0.0, 1.0);
}
