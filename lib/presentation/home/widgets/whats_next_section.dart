import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// "What's next?" upcoming activity section with Shibuya Crossing card.
class WhatsNextSection extends StatelessWidget {
  final VoidCallback? onSeeAllTap;
  final VoidCallback? onViewDetailsTap;

  const WhatsNextSection({
    super.key,
    this.onSeeAllTap,
    this.onViewDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    const darkBrown = Color(0xFF2E1C14);
    const brandOrange = Color(0xFFE65100);
    const textMuted = Color(0xFF7A6860);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row: "What's next?" + "See all"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "What's next?",
              style: GoogleFonts.fredoka(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: darkBrown,
                letterSpacing: -0.2,
              ),
            ),
            GestureDetector(
              onTap: onSeeAllTap ??
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Itinerary schedule coming soon!'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
              behavior: HitTestBehavior.opaque,
              child: Text(
                'See all',
                style: GoogleFonts.nunito(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: textMuted,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Activity Card: Shibuya Crossing (Clean, comfortable height)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF8),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white,
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: darkBrown.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
              BoxShadow(
                color: darkBrown.withValues(alpha: 0.03),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Shibuya Crossing Photo Thumbnail (Comfortable landscape rectangle)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  'assets/home/shibuya_crossing.jpg',
                  width: 82,
                  height: 62,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(width: 12),

              // Activity Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Day & Destination tag
                    Row(
                      children: [
                        const Text('⏱️', style: TextStyle(fontSize: 10)),
                        const SizedBox(width: 3),
                        Text(
                          'Day 1 • Tokyo',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 3),

                    // Attraction Title
                    Text(
                      'Shibuya Crossing',
                      style: GoogleFonts.fredoka(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: darkBrown,
                        letterSpacing: -0.2,
                        height: 1.15,
                      ),
                    ),

                    const SizedBox(height: 3.5),

                    // Time Window
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '7:00 PM – 9:00 PM',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Right Actions: Weather Badge + "View Details ->"
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Weather Badge: 🌤️ 26°C
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3.5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F6F8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFCDECEF),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🌤️', style: TextStyle(fontSize: 10)),
                        const SizedBox(width: 3),
                        Text(
                          '26°C',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1B6A75),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // "View Details ->" Button
                  GestureDetector(
                    onTap: onViewDetailsTap ??
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  const Text('Shibuya Crossing details coming soon!'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6.5,
                      ),
                      decoration: BoxDecoration(
                        color: brandOrange,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: brandOrange.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View Details',
                            style: GoogleFonts.fredoka(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 11.5,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
