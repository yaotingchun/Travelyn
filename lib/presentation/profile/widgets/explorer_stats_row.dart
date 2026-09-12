import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Horizontal 3-statistic row highlighting Trips, Saved places, and Countries explored.
class ExplorerStatsRow extends StatelessWidget {
  final int tripsCount;
  final int savedCount;
  final int countriesCount;
  final VoidCallback? onTripsTap;
  final VoidCallback? onSavedTap;
  final VoidCallback? onCountriesTap;

  const ExplorerStatsRow({
    super.key,
    required this.tripsCount,
    required this.savedCount,
    required this.countriesCount,
    this.onTripsTap,
    this.onSavedTap,
    this.onCountriesTap,
  });

  @override
  Widget build(BuildContext context) {
    const darkBrown = Color(0xFF2E1C14);
    const textMuted = Color(0xFF7A6860);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6F0),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFEBE0D2),
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
          Expanded(
            child: _buildStatItem(
              emoji: '🧳',
              value: '$tripsCount',
              label: 'Trips',
              onTap: onTripsTap,
              darkBrown: darkBrown,
              textMuted: textMuted,
            ),
          ),
          _buildDivider(),
          Expanded(
            child: _buildStatItem(
              emoji: '🔖',
              value: '$savedCount',
              label: 'Saved',
              onTap: onSavedTap,
              darkBrown: darkBrown,
              textMuted: textMuted,
            ),
          ),
          _buildDivider(),
          Expanded(
            child: _buildStatItem(
              emoji: '🌍',
              value: '$countriesCount',
              label: 'Countries',
              onTap: onCountriesTap,
              darkBrown: darkBrown,
              textMuted: textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String emoji,
    required String value,
    required String label,
    VoidCallback? onTap,
    required Color darkBrown,
    required Color textMuted,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.fredoka(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: darkBrown,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: textMuted,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 38,
      color: const Color(0xFFE5D9CC),
    );
  }
}
