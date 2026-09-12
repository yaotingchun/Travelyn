import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/explorer_badge.dart';
import 'circular_achievement_badge.dart';

/// Clean passport achievements row displaying the top 4 collectible badges fitted
/// evenly across the screen with zero overflow or clipping.
class AchievementsSection extends StatelessWidget {
  final List<ExplorerBadge> badges;
  final VoidCallback onViewAllTap;
  final ValueChanged<ExplorerBadge>? onBadgeTap;

  const AchievementsSection({
    super.key,
    required this.badges,
    required this.onViewAllTap,
    this.onBadgeTap,
  });

  @override
  Widget build(BuildContext context) {
    const darkBrown = Color(0xFF2E1C14);
    const brandOrange = Color(0xFFE87516);
    const textMuted = Color(0xFF7A6860);

    // Display the first 4 badges cleanly fitted without any partial cutoffs
    final displayBadges = badges.take(4).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header Row: "✦ My Achievements" and "View all →"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  const Text(
                    '✦',
                    style: TextStyle(
                      color: brandOrange,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'My Achievements',
                    style: GoogleFonts.fredoka(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: darkBrown,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onViewAllTap,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View all',
                        style: GoogleFonts.fredoka(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: textMuted,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: textMuted,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 4 Badges Fitted Evenly Across the Row with Zero Clipping
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: displayBadges.map((badge) {
              return CircularAchievementBadge(
                badge: badge,
                onTap: () {
                  if (onBadgeTap != null) {
                    onBadgeTap!(badge);
                  } else {
                    onViewAllTap();
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
