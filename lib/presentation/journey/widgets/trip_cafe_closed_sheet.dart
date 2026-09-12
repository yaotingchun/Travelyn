import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Interactive modal sheet for "Cafe Closed" Simulation Event
/// Triggered when scheduled cafe is closed; Travelyn immediately suggests a nearby replacement.
class TripCafeClosedSheet extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const TripCafeClosedSheet({
    super.key,
    required this.onAccept,
    required this.onDecline,
  });

  static Future<bool?> show(
    BuildContext context, {
    VoidCallback? onAccept,
    VoidCallback? onDecline,
  }) async {
    HapticFeedback.mediumImpact();
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => TripCafeClosedSheet(
        onAccept: () {
          Navigator.of(ctx).pop(true);
        },
        onDecline: () {
          Navigator.of(ctx).pop(false);
        },
      ),
    );

    if (result == true) {
      onAccept?.call();
    } else if (result == false) {
      onDecline?.call();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    const darkBrown = Color(0xFF2E1C14);
    const brandOrange = Color(0xFFE65100);
    const textMuted = Color(0xFF6B5A50);

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 28),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF7F0),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFEDE3D7), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: darkBrown.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 38,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4CDC5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Header: "⚠️ CAFE CLOSED" badge & Close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFEEF0), Color(0xFFFFD1D8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFF43F5E).withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 15,
                          color: Color(0xFFE11D48),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'SPOT CLOSED • SMART REROUTE',
                          style: GoogleFonts.fredoka(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: const Color(0xFFE11D48),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Navigator.of(context).pop(false);
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE3D7).withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: darkBrown,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Mascot Advice Speech Bubble
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFEFE6DC), width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: darkBrown.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFFFE0B2),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/mascot/avatar.png',
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, st) => const Icon(
                            Icons.pets_rounded,
                            color: brandOrange,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "🦊 Lyn to the rescue!",
                            style: GoogleFonts.fredoka(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: darkBrown,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Bread, Espresso & is temporarily closed today. No worries! I found a charming artisan cafe just 180m away.",
                            style: GoogleFonts.fredoka(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF4A3E38),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Alternative Recommendation Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFFDF9), Color(0xFFFFF7EF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFFFD9BD), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: brandOrange.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status row: Distance pill + Open status
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1E6),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFFDEC4), width: 0.8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.directions_walk_rounded,
                                size: 13.5,
                                color: Color(0xFFE65100),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '2 min walk (180m away)',
                                style: GoogleFonts.fredoka(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF8A3B00),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFD1FAE5), width: 0.8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF059669),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Open Now',
                                style: GoogleFonts.fredoka(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF047857),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Place Title & Rating
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chatei Hatou (茶亭 羽當)',
                                style: GoogleFonts.fredoka(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: darkBrown,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Shibuya / Omotesando, Tokyo',
                                style: GoogleFonts.fredoka(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w400,
                                  color: textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFEF3C7), width: 0.8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 14,
                                color: Color(0xFFD97706),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '4.8 (1.4k)',
                                style: GoogleFonts.fredoka(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFB45309),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Food specialty highlight pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEDE3D7), width: 0.8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.coffee_rounded,
                            size: 15,
                            color: Color(0xFFB45309),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Hand-drip siphon coffee & fresh matcha chiffon cake ☕🍰',
                              style: GoogleFonts.fredoka(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF4A3E38),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Action Buttons: [Swap to this Cafe] & [Skip Cafe & Continue]
              Row(
                children: [
                  // [Skip Cafe & Continue]
                  Expanded(
                    flex: 4,
                    child: OutlinedButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        onDecline();
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFD4CDC5), width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Skip Cafe',
                        style: GoogleFonts.fredoka(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B5A50),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // [Swap to this Cafe]
                  Expanded(
                    flex: 6,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        onAccept();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandOrange,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shadowColor: brandOrange.withValues(alpha: 0.4),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.swap_horiz_rounded, size: 18, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            'Swap to This Cafe',
                            style: GoogleFonts.fredoka(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
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
      ),
    );
  }
}
