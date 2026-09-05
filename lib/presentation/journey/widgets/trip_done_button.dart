import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The warm sunset orange "I'm Done! ✨" CTA button used across
/// TripVotingScreen and TripPlacesInputScreen.
///
/// Features:
/// - Pill shape (height 54, radius 27)
/// - Sunset orange gradient (0xFFFF7236 to 0xFFE84E18)
/// - Clean rounded ambient glow shadow (no rectangular clipping artifacts)
/// - Curved top gloss reflection sheen
/// - Centered label + sparkle icon
/// - Optional readiness count badge (e.g. "3/4")
/// - Subtle decorative mascot paw mark on the far right
class TripDoneButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final String? countText;
  final IconData? icon;
  final bool showPaw;
  final bool showGloss;

  const TripDoneButton({
    super.key,
    required this.onPressed,
    this.label = "I'm Done!",
    this.countText,
    this.icon,
    this.showPaw = false,
    this.showGloss = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE84E18).withValues(alpha: 0.38),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(27),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Ink(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFF7236),
                  Color(0xFFE84E18),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Stack(
              children: [
                // Subtle top gloss sheen (optional)
                if (showGloss)
                  Positioned(
                    top: 1,
                    left: 20,
                    right: 20,
                    height: 25,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(26),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.28),
                            Colors.transparent,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                // Button Label & Icon & Natural Readiness Count
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.fredoka(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (countText != null && countText!.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Text(
                          countText!.startsWith('(')
                              ? countText!
                              : '($countText)',
                          style: GoogleFonts.fredoka(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.92),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                      const SizedBox(width: 8),
                      Icon(
                        icon ?? Icons.auto_awesome_rounded,
                        size: 19,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),

                // Subtle decorative mark on far right (only when showPaw is true)
                if (showPaw)
                  Positioned(
                    right: 18,
                    top: 18,
                    child: Opacity(
                      opacity: 0.22,
                      child: const Icon(
                        Icons.pets_rounded,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
