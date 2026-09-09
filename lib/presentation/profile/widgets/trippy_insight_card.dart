import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AI Personalization Card showing what Trippy has learned about the user.
class TrippyInsightCard extends StatelessWidget {
  final String quote;
  final VoidCallback onSeeInsightsTap;

  const TrippyInsightCard({
    super.key,
    required this.quote,
    required this.onSeeInsightsTap,
  });

  @override
  Widget build(BuildContext context) {
    const brandOrange = Color(0xFFE65100);
    const darkBrown = Color(0xFF2E1C14);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF6),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFFFDEC9),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: brandOrange.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Mascot Avatar Badge & Title
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFFCC80),
                    width: 1.2,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/mascot/avatar.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Text('🦊', style: TextStyle(fontSize: 18))),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Trippy knows you',
                        style: GoogleFonts.fredoka(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: darkBrown,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEDE0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'AI DNA',
                          style: GoogleFonts.fredoka(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: brandOrange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Personalized from your travels',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF8D6E63),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Speech Bubble / Quote Container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFF1E6DA),
                width: 1.0,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '“',
                  style: TextStyle(
                    fontSize: 26,
                    height: 0.9,
                    color: Color(0xFFFFB74D),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    quote,
                    style: GoogleFonts.nunito(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: darkBrown,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // CTA: See Travel Insights →
          Center(
            child: TextButton.icon(
              onPressed: onSeeInsightsTap,
              icon: const SizedBox.shrink(),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'See Travel Insights',
                    style: GoogleFonts.fredoka(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: brandOrange,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 15,
                    color: brandOrange,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
