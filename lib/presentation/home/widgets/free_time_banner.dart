import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Interactive bottom banner with peeking Shiba mascot and "Surprise Me" action.
class FreeTimeBanner extends StatelessWidget {
  final VoidCallback? onSurpriseMeTap;

  const FreeTimeBanner({
    super.key,
    this.onSurpriseMeTap,
  });

  @override
  Widget build(BuildContext context) {
    const darkBrown = Color(0xFF2E1C14);
    const brandOrange = Color(0xFFE65100);
    const textMuted = Color(0xFF7A6860);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6ED),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white,
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: darkBrown.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: darkBrown.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Cute Peeking Shiba Mascot
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/home/mascot_peek.png',
              width: 64,
              height: 64,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(width: 8),

          // Message
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Need ideas for free time?',
                  style: GoogleFonts.fredoka(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: darkBrown,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'I can plan a mini adventure for you! ✨',
                  style: GoogleFonts.nunito(
                    fontSize: 10.8,
                    fontWeight: FontWeight.w600,
                    color: textMuted,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // "✨ Surprise Me" Button
          GestureDetector(
            onTap: onSurpriseMeTap ??
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Generating a fun mini adventure in Tokyo! ✨',
                      ),
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
                horizontal: 14,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF26A21),
                    Color(0xFFE65100),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: brandOrange.withValues(alpha: 0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('✨', style: TextStyle(fontSize: 11)),
                  const SizedBox(width: 4),
                  Text(
                    'Surprise Me',
                    style: GoogleFonts.fredoka(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
}
