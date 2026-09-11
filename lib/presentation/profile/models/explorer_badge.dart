import 'package:flutter/material.dart';

/// Model representing a collectible travel badge stamp for the passport achievements section.
class ExplorerBadge {
  final String id;
  final String title;
  final String requirement;
  final String icon;
  final String? imageAsset;
  final bool isUnlocked;
  final String? unlockedDate;
  final Color accentColor;
  final double progress; // 0.0 to 1.0

  const ExplorerBadge({
    required this.id,
    required this.title,
    required this.requirement,
    required this.icon,
    this.imageAsset,
    this.isUnlocked = true,
    this.unlockedDate,
    this.accentColor = const Color(0xFFE65100),
    this.progress = 1.0,
  });
}
