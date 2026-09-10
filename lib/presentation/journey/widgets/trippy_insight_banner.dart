import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../services/booking_models.dart';

/// Contextual AI insight banner featuring the Trippy mascot avatar.
/// Gives smart travel planning tips specifically tied to the active booking segment and trip details.
class TrippyInsightBanner extends StatelessWidget {
  final BookingType bookingType;
  final String destination;
  final int travellerCount;
  final Color brandOrange;
  final Color darkBrown;
  final Color textMuted;

  const TrippyInsightBanner({
    super.key,
    required this.bookingType,
    required this.destination,
    required this.travellerCount,
    this.brandOrange = const Color(0xFFE65100),
    this.darkBrown = const Color(0xFF2E1C14),
    this.textMuted = const Color(0xFF6B5A50),
  });

  @override
  Widget build(BuildContext context) {
    final isStays = bookingType == BookingType.stays;
    final cleanCity = destination.split(',').first.trim();

    final insightText = isStays
        ? 'Staying near Yamanote / central stations saves your group (~$travellerCount travellers) over 45 minutes of daily subway transfers!'
        : 'Trippy recommends daytime arrivals before 5:00 PM so you can check in, unpack, and enjoy the first evening in $cleanCity without rush.';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7EF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFFDEC4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: brandOrange.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trippy Mascot Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFE0B2),
              border: Border.all(
                color: const Color(0xFFFFB74D),
                width: 1.5,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/mascot/avatar.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFFE65100),
                  size: 20,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Message Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Trippy\'s Smart Pick',
                      style: GoogleFonts.fredoka(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: brandOrange,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: brandOrange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'AI INSIGHT',
                        style: GoogleFonts.fredoka(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: brandOrange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  insightText,
                  style: GoogleFonts.fredoka(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.35,
                    color: textMuted,
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
