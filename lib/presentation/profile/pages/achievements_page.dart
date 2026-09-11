import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/mock_profile_data.dart';
import '../models/achievement_item.dart';

/// Screen displaying the user's travel achievements, unlocked milestones, and progress badges.
class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const darkBrown = Color(0xFF2E1C14);

    final achievements = MockProfileData.achievements;
    final unlockedCount = achievements.where((a) => a.isUnlocked).length;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF7F0),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: darkBrown, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Travel Achievements',
          style: GoogleFonts.fredoka(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: darkBrown,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFFFD54F),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF57F17).withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('🏆', style: TextStyle(fontSize: 26)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$unlockedCount of ${achievements.length} Unlocked',
                            style: GoogleFonts.fredoka(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFE65100),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Earn badges by exploring new cities, checking into local food spots, and organizing trips!',
                            style: GoogleFonts.nunito(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: darkBrown,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Badges Grid / Cards
              ...achievements.map((ach) => _buildAchievementCard(ach)),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementCard(AchievementItem item) {
    const brandOrange = Color(0xFFE65100);
    const darkBrown = Color(0xFF2E1C14);
    const textMuted = Color(0xFF7A6860);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: item.isUnlocked
              ? const Color(0xFFFFE082)
              : const Color(0xFFEDE4DA),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E1C14).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: item.isUnlocked
                  ? const Color(0xFFFFF8E7)
                  : const Color(0xFFF5F3EF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: item.isUnlocked
                    ? const Color(0xFFFFD54F)
                    : const Color(0xFFE0DAD2),
                width: 1.0,
              ),
            ),
            child: Center(
              child: Text(
                item.icon,
                style: TextStyle(
                  fontSize: 26,
                  color: item.isUnlocked ? null : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.title,
                      style: GoogleFonts.fredoka(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: item.isUnlocked ? darkBrown : textMuted,
                      ),
                    ),
                    if (item.isUnlocked)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          item.unlockedDate ?? 'Unlocked',
                          style: GoogleFonts.fredoka(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      )
                    else
                      Text(
                        '${(item.progress * 100).toInt()}%',
                        style: GoogleFonts.fredoka(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textMuted,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  item.description,
                  style: GoogleFonts.nunito(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: textMuted,
                  ),
                ),
                if (!item.isUnlocked) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: item.progress,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFF0EAE1),
                      valueColor: const AlwaysStoppedAnimation(brandOrange),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
