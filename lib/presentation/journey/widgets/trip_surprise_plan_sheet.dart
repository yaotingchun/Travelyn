import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../tabs/trip_tab.dart';
import 'trip_location_overview_sheet.dart';

/// Interactive modal sheet for "Moments" - Surprise Plan Event (Simulation 3)
/// Matches the reference design:
/// - Centered `mascot_adjust_plan.png` explorer dog with winking face & sparkles
/// - Top right circular close button (X)
/// - "Tiny detour?" header
/// - Friendly reasoning explaining nearby local market matching group's interest in local food
/// - Place card with banner photo, orange location pin, distance info, and dashed connector to tags
/// - Dual pill buttons: [Let's go! 🦊] (primary orange) and [Stay on plan] (soft cream)
class TripSurprisePlanSheet extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final String placeName;
  final String distanceText;
  final String imageAsset;
  final List<String> tags;
  final String? reasoningText;

  const TripSurprisePlanSheet({
    super.key,
    required this.onAccept,
    required this.onDecline,
    this.placeName = 'Ura-Harajuku Local Market',
    this.distanceText = '300m from you • +12 min',
    this.imageAsset = 'assets/journey/food_ameyoko_stalls.jpg',
    this.tags = const ['Local Food', 'Hidden Gem'],
    this.reasoningText,
  });

  /// Provides geocoded nearby detour recommendations tailored to the trip's starting location.
  static ({String name, String distance, String image, List<String> tags, String reasoning})
      getDetailsForNearbyDetour({String? firstPlaceName}) {
    final first = (firstPlaceName ?? '').toLowerCase();

    if (first.contains('senso') || first.contains('asakusa')) {
      return (
        name: 'Asakusa Nishi-sando Food Alley',
        distance: '250m from you • +10 min',
        image: 'assets/journey/food_ameyoko_stalls.jpg',
        tags: const ['Local Food', 'Traditional'],
        reasoning:
            "I found a traditional food lane nearby.\nIt's not in your itinerary, but it matches your\ngroup's interest in local food. 🍜",
      );
    } else if (first.contains('ueno') || first.contains('yanaka')) {
      return (
        name: 'Yanaka Ginza Market',
        distance: '300m from you • +12 min',
        image: 'assets/journey/food_ameyoko_stalls.jpg',
        tags: const ['Local Food', 'Hidden Gem'],
        reasoning:
            "I found a local market nearby.\nIt's not in your itinerary, but it matches your\ngroup's interest in local food. 🍜",
      );
    }

    // Default for Day 1 (Meiji Shrine / Harajuku / Shibuya):
    // Ura-Harajuku is directly adjacent to Meiji Shrine and Takeshita Street (300m away, 12 min stroll)
    return (
      name: 'Ura-Harajuku Local Market',
      distance: '300m from you • +12 min',
      image: 'assets/journey/food_ameyoko_stalls.jpg',
      tags: const ['Local Food', 'Hidden Gem'],
      reasoning:
          "I found a local market nearby.\nIt's not in your itinerary, but it matches your\ngroup's interest in local food. 🍜",
    );
  }

  /// Presents the interactive modal bottom sheet with haptic feedback.
  static Future<bool?> show(
    BuildContext context, {
    VoidCallback? onAccept,
    VoidCallback? onDecline,
    String? placeName,
    String? distanceText,
    String? imageAsset,
    List<String>? tags,
    String? reasoningText,
  }) async {
    HapticFeedback.mediumImpact();

    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: const Color(0xFF2E1C14).withValues(alpha: 0.45),
      builder: (ctx) => TripSurprisePlanSheet(
        onAccept: () {
          Navigator.of(ctx).pop(true);
        },
        onDecline: () {
          Navigator.of(ctx).pop(false);
        },
        placeName: placeName ?? 'Ura-Harajuku Local Market',
        distanceText: distanceText ?? '300m from you • +12 min',
        imageAsset: imageAsset ?? 'assets/journey/food_ameyoko_stalls.jpg',
        tags: tags ?? const ['Local Food', 'Hidden Gem'],
        reasoningText: reasoningText,
      ),
    );

    if (result == true) {
      onAccept?.call();
    } else if (result == false) {
      onDecline?.call();
    }
    return result;
  }

  void _openLocationOverview(BuildContext context) {
    HapticFeedback.lightImpact();
    final place = ItineraryCardItem(
      id: placeName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_'),
      time: '11:35',
      name: placeName,
      location: 'Cat Street, Harajuku',
      walkTime: distanceText,
      imageAsset: imageAsset,
      latitude: 35.6680,
      longitude: 139.7042,
      category: tags.isNotEmpty ? tags.first : 'Local Food',
      tag: tags.length > 1 ? tags[1] : null,
    );
    TripLocationOverviewSheet.show(context, place: place);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final targetSheetHeight = (screenHeight * 0.86).clamp(640.0, 820.0);

    return Container(
      constraints: BoxConstraints(
        minHeight: targetSheetHeight,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFDF9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1F2E1C14),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top Bar with Circular Close Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: onDecline,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4ECE2),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2E1C14).withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: Color(0xFF5C4E46),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Centered Explorer Mascot from Assets (Bigger: 175 x 135)
                  Image.asset(
                    'assets/journey/mascot_adjust_plan.png',
                    width: 175,
                    height: 135,
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, st) => Container(
                      width: 130,
                      height: 110,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.pets_rounded,
                        size: 52,
                        color: Color(0xFFE65100),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Title: "Tiny detour?"
                  Text(
                    'Tiny detour?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.fredoka(
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF231815),
                      letterSpacing: -0.3,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtitle & Reasoning
                  Text.rich(
                    TextSpan(
                      text: "I found a local market nearby.\nIt's not in your itinerary, but it matches your\ngroup's interest in ",
                      style: GoogleFonts.fredoka(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF5C4E46),
                        height: 1.38,
                      ),
                      children: [
                        TextSpan(
                          text: "local food. 🍜",
                          style: GoogleFonts.fredoka(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF231815),
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  // Place Card with Image Banner & Tag Connectors (Interactive: Tap to view overview)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Material(
                      color: Colors.transparent,
                      child: Ink(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFF0EAE1),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2E1C14).withValues(alpha: 0.07),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => _openLocationOverview(context),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Photo Banner with "View overview" badge
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                                    child: SizedBox(
                                      height: 210,
                                      width: double.infinity,
                                      child: Image.asset(
                                        imageAsset,
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, err, st) => Container(
                                          height: 210,
                                          color: const Color(0xFFF4EDE4),
                                          child: const Center(
                                            child: Icon(
                                              Icons.landscape_rounded,
                                              color: Color(0xFFC5BDB7),
                                              size: 36,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Subtle floating "View overview" chip
                                  Positioned(
                                    bottom: 10,
                                    right: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF231815).withValues(alpha: 0.68),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.25),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.info_outline_rounded,
                                            size: 13,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 4.5),
                                          Text(
                                            'View overview',
                                            style: GoogleFonts.fredoka(
                                              fontSize: 11.5,
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

                              // Information Area
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Orange Location Pin Icon
                                        const Padding(
                                          padding: EdgeInsets.only(top: 2.0),
                                          child: Icon(
                                            Icons.location_on_rounded,
                                            color: Color(0xFFE65100),
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                placeName,
                                                style: GoogleFonts.fredoka(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(0xFF231815),
                                                  height: 1.15,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                distanceText,
                                                style: GoogleFonts.fredoka(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: const Color(0xFF7A6A60),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Subtle right chevron indicating tappable card
                                        const Padding(
                                          padding: EdgeInsets.only(top: 4.0, left: 6.0),
                                          child: Icon(
                                            Icons.chevron_right_rounded,
                                            size: 20,
                                            color: Color(0xFF9E8E82),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    // Dotted L-shape connector and tag chips
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        // Route Connector
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10.0, right: 8.0),
                                          child: CustomPaint(
                                            size: const Size(20, 16),
                                            painter: _DashedRouteConnectorPainter(
                                              const Color(0xFFFFCCAA),
                                            ),
                                          ),
                                        ),
                                        // Category / Vibe Pills
                                        Wrap(
                                          spacing: 8,
                                          children: tags.map((tag) {
                                            return Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFFF3E5),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                tag,
                                                style: GoogleFonts.fredoka(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF8D4B00),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          ],
        ),

              const SizedBox(height: 24),

              // Action Buttons: [Let's go! 🦊] and [Stay on plan]
              Row(
                children: [
                  // Left: Primary [Let's go! 🦊]
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: onAccept,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE65100),
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shadowColor: const Color(0xFFE65100).withValues(alpha: 0.35),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          "Let's go! 🦊",
                          style: GoogleFonts.fredoka(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Right: Secondary [Stay on plan]
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: onDecline,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFF5EC),
                          foregroundColor: const Color(0xFF6B5A50),
                          elevation: 0,
                          side: const BorderSide(
                            color: Color(0xFFF0E5D8),
                            width: 1.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          'Stay on plan',
                          style: GoogleFonts.fredoka(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6B5A50),
                          ),
                        ),
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

/// Custom painter rendering a dashed L-shaped connecting line between the pin and tags
class _DashedRouteConnectorPainter extends CustomPainter {
  final Color color;
  const _DashedRouteConnectorPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(2, 0)
      ..lineTo(2, size.height - 5)
      ..quadraticBezierTo(2, size.height, 6, size.height)
      ..lineTo(size.width, size.height);

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      const dashWidth = 3.0;
      const dashSpace = 2.5;
      while (distance < metric.length) {
        final len = (distance + dashWidth < metric.length)
            ? dashWidth
            : metric.length - distance;
        final extractPath = metric.extractPath(distance, distance + len);
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
