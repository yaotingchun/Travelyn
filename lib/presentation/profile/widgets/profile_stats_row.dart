import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_profile.dart';

/// Compact lifetime travel statistics row.
/// Shows: Trips, Places, Countries, Memories.
class ProfileStatsRow extends StatelessWidget {
  final UserProfile profile;

  const ProfileStatsRow({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFEDE4DA),
          width: 1.0,
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
          _buildStatItem(
            count: _formatCount(profile.tripsCount),
            label: 'Trips',
            icon: '✈️',
          ),
          _buildDivider(),
          _buildStatItem(
            count: _formatCount(profile.placesCount),
            label: 'Places',
            icon: '📍',
          ),
          _buildDivider(),
          _buildStatItem(
            count: _formatCount(profile.countriesCount),
            label: 'Countries',
            icon: '🌏',
          ),
          _buildDivider(),
          _buildStatItem(
            count: _formatCount(profile.memoriesCount),
            label: 'Memories',
            icon: '📸',
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count < 10) {
      return '0$count';
    }
    return '$count';
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 32,
      color: const Color(0xFFE5DDD3),
    );
  }

  Widget _buildStatItem({
    required String count,
    required String label,
    required String icon,
  }) {
    const darkBrown = Color(0xFF2E1C14);
    const textMuted = Color(0xFF7A6860);

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count,
            style: GoogleFonts.fredoka(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: darkBrown,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
