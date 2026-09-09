import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/achievement_item.dart';

/// Compact preview card for personal travel achievements.
class AchievementsPreviewCard extends StatelessWidget {
  final List<AchievementItem> achievements;
  final VoidCallback onViewAllTap;

  const AchievementsPreviewCard({
    super.key,
    required this.achievements,
    required this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    const brandOrange = Color(0xFFE65100);
    const darkBrown = Color(0xFF2E1C14);
    const textMuted = Color(0xFF7A6860);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFEDE4DA),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E1C14).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    'Travel Achievements',
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: darkBrown,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onViewAllTap,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        'View All',
                        style: GoogleFonts.fredoka(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: brandOrange,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: brandOrange,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Horizontal Badges Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: achievements.take(4).map((ach) {
                return Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: ach.isUnlocked
                        ? const Color(0xFFFFF8E7)
                        : const Color(0xFFF5F3EF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: ach.isUnlocked
                          ? const Color(0xFFFFE082)
                          : const Color(0xFFE5DFD7),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ach.icon,
                        style: TextStyle(
                          fontSize: 16,
                          color: ach.isUnlocked ? null : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        ach.title,
                        style: GoogleFonts.fredoka(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ach.isUnlocked ? darkBrown : textMuted,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
