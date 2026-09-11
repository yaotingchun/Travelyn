import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Legend display under the vintage world map showing Explored, Wishlist, and Someday states.
class MapLegend extends StatelessWidget {
  const MapLegend({super.key});

  @override
  Widget build(BuildContext context) {
    const textMuted = Color(0xFF7A6860);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(
          color: const Color(0xFFE87516),
          borderColor: const Color(0xFFB54D00),
          label: 'Explored',
          textMuted: textMuted,
        ),
        const SizedBox(width: 20),
        _buildLegendItem(
          color: const Color(0xFFE6C58B),
          borderColor: const Color(0xFFD8A24A),
          label: 'Wishlist',
          textMuted: textMuted,
        ),
        const SizedBox(width: 20),
        _buildLegendItem(
          color: const Color(0xFFE5DAC7),
          borderColor: const Color(0xFFC4B29E),
          label: 'Someday',
          textMuted: textMuted,
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required Color borderColor,
    required String label,
    required Color textMuted,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor,
              width: 1.0,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: textMuted,
          ),
        ),
      ],
    );
  }
}
