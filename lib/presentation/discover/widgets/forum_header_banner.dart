import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForumHeaderBanner extends StatelessWidget {
  final VoidCallback? onBackTap;

  const ForumHeaderBanner({
    super.key,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    const darkBrown = Color(0xFF2E1C14);
    const subtitleBrown = Color(0xFF5C4A42);

    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background scenic illustration
          Positioned.fill(
            child: ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Colors.black87,
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.65, 1.0],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: Opacity(
                opacity: 0.82,
                child: Image.asset(
                  'assets/home/tokyo_pagoda_blossom.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFFE7D6), Color(0xFFFDF7F0)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Warm tint overlay to match the reference cream pastel aesthetic
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFFDF7F0).withValues(alpha: 0.35),
                    const Color(0xFFFDF7F0).withValues(alpha: 0.85),
                    const Color(0xFFFDF7F0),
                  ],
                  stops: const [0.0, 0.72, 1.0],
                ),
              ),
            ),
          ),

          // Header Mascot on Right
          Positioned(
            top: 28,
            right: 8,
            child: SizedBox(
              width: 124,
              height: 124,
              child: Image.asset(
                'assets/journey/mascot_adventure.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/mascot/avatar.png',
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) => const SizedBox(),
                  );
                },
              ),
            ),
          ),

          // Header Content (Brand, Titles, Subtitle)
          Positioned(
            top: 10,
            left: 16,
            right: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Brand Row (Back pill + Travelyn)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onBackTap != null)
                      GestureDetector(
                        onTap: onBackTap,
                        child: Container(
                          width: 32,
                          height: 32,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: darkBrown.withValues(alpha: 0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 1.5),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 14,
                            color: darkBrown,
                          ),
                        ),
                      ),
                    Text(
                      'Travelyn',
                      style: GoogleFonts.fredoka(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF9E4822),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Main Title: Travel Forum
                Text(
                  'Travel Forum',
                  style: GoogleFonts.fredoka(
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    color: darkBrown,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),

                // Subtitle: Real travellers. Real stories. Better journeys. 🐾
                Text(
                  'Real travellers. Real stories.\nBetter journeys. 🐾',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: subtitleBrown,
                    height: 1.25,
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
