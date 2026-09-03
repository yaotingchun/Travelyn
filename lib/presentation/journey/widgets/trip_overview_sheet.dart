import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modal bottom sheet displaying the Tokyo trip highlights and checklist.
class TripOverviewSheet extends StatelessWidget {
  const TripOverviewSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const TripOverviewSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFFFDF7F0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDBC9B8),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.push_pin_rounded,
                          size: 15,
                          color: Color(0xFFE65100),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Pinned by Travelyn',
                          style: GoogleFonts.fredoka(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFC85018),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tokyo Trip Overview',
                      style: GoogleFonts.fredoka(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2E1C14),
                      ),
                    ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/home/hero_tokyo.jpg',
                  width: 70,
                  height: 54,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 70,
                    height: 54,
                    color: const Color(0xFFE8DFD5),
                    child: const Icon(
                      Icons.image_outlined,
                      color: Color(0xFF6B5A50),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHighlightRow(
                    icon: Icons.wb_sunny_rounded,
                    title: 'Weather Forecast',
                    detail: '24°C Sunny & Mild • Ideal for city sightseeing',
                    iconColor: const Color(0xFFF57C00),
                  ),
                  const SizedBox(height: 12),
                  _buildHighlightRow(
                    icon: Icons.subway_rounded,
                    title: 'Transit Essentials',
                    detail: 'JR Rail Pass & Suica card recommended',
                    iconColor: const Color(0xFF1976D2),
                  ),
                  const SizedBox(height: 12),
                  _buildHighlightRow(
                    icon: Icons.star_rounded,
                    title: 'Top Group Highlights',
                    detail:
                        'Shibuya Crossing, Senso-ji Temple, Meiji Shrine & teamLab',
                    iconColor: const Color(0xFF7B1FA2),
                  ),
                  const SizedBox(height: 12),
                  _buildHighlightRow(
                    icon: Icons.restaurant_rounded,
                    title: 'Dining Hotspots',
                    detail: 'Omoide Yokocho, Tsukiji Outer Market, Ichiran Ramen',
                    iconColor: const Color(0xFF388E3C),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEDE3D7)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trip Checklist',
                          style: GoogleFonts.fredoka(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2E1C14),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildCheckItem('Valid passport (6+ months)', true),
                        _buildCheckItem('Visit Japan Web QR registration', true),
                        _buildCheckItem('eSIM or Pocket Wi-Fi reservation', false),
                        _buildCheckItem('Yen currency exchange / Wise card', false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String label, bool checked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            checked ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 18,
            color: checked ? const Color(0xFF388E3C) : const Color(0xFF9E8E84),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.fredoka(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF4A3A32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightRow({
    required IconData icon,
    required String title,
    required String detail,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE3D7)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.fredoka(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2E1C14),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF6B5A50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
