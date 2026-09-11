import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Navigation section for Account & Preferences links.
class AccountPreferencesSection extends StatelessWidget {
  final VoidCallback onEditProfileTap;
  final VoidCallback onTravelPreferencesTap;
  final VoidCallback onTravelInsightsTap;
  final VoidCallback onAchievementsTap;

  const AccountPreferencesSection({
    super.key,
    required this.onEditProfileTap,
    required this.onTravelPreferencesTap,
    required this.onTravelInsightsTap,
    required this.onAchievementsTap,
  });

  @override
  Widget build(BuildContext context) {
    const darkBrown = Color(0xFF2E1C14);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
            child: Row(
              children: [
                const Icon(
                  Icons.person_pin_circle_outlined,
                  size: 18,
                  color: Color(0xFFE65100),
                ),
                const SizedBox(width: 8),
                Text(
                  'Account & Preferences',
                  style: GoogleFonts.fredoka(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: darkBrown,
                  ),
                ),
              ],
            ),
          ),
          _buildItem(
            icon: Icons.badge_outlined,
            iconColor: const Color(0xFFE65100),
            title: 'Edit Profile',
            subtitle: 'Name, bio, home city, avatar',
            onTap: onEditProfileTap,
            showDivider: true,
          ),
          _buildItem(
            icon: Icons.tune_rounded,
            iconColor: const Color(0xFF2E7D32),
            title: 'Travel Preferences',
            subtitle: 'Pace, styles, food & crowd choices',
            onTap: onTravelPreferencesTap,
            showDivider: true,
          ),
          _buildItem(
            icon: Icons.auto_awesome_rounded,
            iconColor: const Color(0xFFEF6C00),
            title: 'Travel Insights',
            subtitle: 'What Trippy has learned about you',
            onTap: onTravelInsightsTap,
            showDivider: true,
          ),
          _buildItem(
            icon: Icons.military_tech_outlined,
            iconColor: const Color(0xFFF9A825),
            title: 'Travel Achievements',
            subtitle: 'Milestones, badges & exploration records',
            onTap: onAchievementsTap,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool showDivider,
  }) {
    const darkBrown = Color(0xFF2E1C14);
    const textMuted = Color(0xFF7A6860);

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.fredoka(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: darkBrown,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Color(0xFFBCAAA4),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Divider(
              height: 1,
              thickness: 0.8,
              color: Color(0xFFF0EAE1),
            ),
          ),
      ],
    );
  }
}
