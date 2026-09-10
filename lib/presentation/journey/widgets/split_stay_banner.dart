import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../services/booking_models.dart';

/// Intelligent banner that surfaces split-stay arrangements for multi-day itineraries,
/// quantifying commute time saved vs additional cost.
class SplitStayBanner extends StatelessWidget {
  final SplitStaySuggestion suggestion;
  final Color brandOrange;
  final Color darkBrown;
  final Color textMuted;

  const SplitStayBanner({
    super.key,
    required this.suggestion,
    this.brandOrange = const Color(0xFFE65100),
    this.darkBrown = const Color(0xFF2E1C14),
    this.textMuted = const Color(0xFF6B5A50),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFDEC4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: brandOrange.withValues(alpha: 0.05),
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
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: brandOrange.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.alt_route_rounded,
                  size: 18,
                  color: brandOrange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Smart Arrangement Suggestion',
                  style: GoogleFonts.fredoka(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: brandOrange,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Context explanation
          Text(
            'Staying in ${suggestion.primaryCity} for all ${suggestion.primaryNights + suggestion.secondaryNights} nights is cheaper, but you\'ll spend ~2h 10m commuting on your ${suggestion.secondaryCity} days.',
            style: GoogleFonts.fredoka(
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              height: 1.35,
              color: darkBrown.withValues(alpha: 0.85),
            ),
          ),

          const SizedBox(height: 12),

          // Suggested Split Pills
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEDE3D7)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.hotel_rounded, size: 16, color: Color(0xFFE65100)),
                      const SizedBox(width: 6),
                      Text(
                        '${suggestion.primaryCity} · ${suggestion.primaryNights}n',
                        style: GoogleFonts.fredoka(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: darkBrown,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '+',
                  style: GoogleFonts.fredoka(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: brandOrange,
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(Icons.hotel_rounded, size: 16, color: Color(0xFF2E7D32)),
                      const SizedBox(width: 6),
                      Text(
                        '${suggestion.secondaryCity} · ${suggestion.secondaryNights}n',
                        style: GoogleFonts.fredoka(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: darkBrown,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Measurable Trade-offs (Time saved & Additional cost)
          Row(
            children: [
              // Time Saved
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 14,
                      color: Color(0xFF2E7D32),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Save ${suggestion.travelTimeSaved} commute',
                      style: GoogleFonts.fredoka(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Extra Cost
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1E6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.payments_outlined,
                      size: 14,
                      color: brandOrange,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '+RM${suggestion.additionalCostRm} est. cost',
                      style: GoogleFonts.fredoka(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: brandOrange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
