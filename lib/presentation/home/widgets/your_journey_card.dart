import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../journey/trip_details_screen.dart';

/// "Your Journey" section with visual flight map card matching Travelyn design.
class YourJourneyCard extends StatelessWidget {
  final VoidCallback? onViewFullTripTap;

  const YourJourneyCard({
    super.key,
    this.onViewFullTripTap,
  });

  @override
  Widget build(BuildContext context) {
    const darkBrown = Color(0xFF2E1C14);
    const brandOrange = Color(0xFFE65100);
    const textMuted = Color(0xFF7A6860);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row: "Your Journey" + dashed flight trail + "View Full Trip ->"
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Your Journey',
              style: GoogleFonts.fredoka(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: darkBrown,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(width: 8),

            // Dashed orange flight trail with mini plane
            CustomPaint(
              size: const Size(60, 16),
              painter: _DashedFlightPathPainter(),
            ),
            const SizedBox(width: 2),
            Transform.rotate(
              angle: 0.35,
              child: const Icon(
                Icons.flight_rounded,
                size: 16,
                color: brandOrange,
              ),
            ),

            const Spacer(),

            // "View Full Trip ->" Action Link
            GestureDetector(
              onTap: onViewFullTripTap ??
                  () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 350),
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const TripDetailsScreen(
                          destination: 'Tokyo, Japan',
                        ),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeInOut,
                            ),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View Full Trip',
                    style: GoogleFonts.nunito(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: textMuted,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: textMuted,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Journey Map Illustrated Card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: AspectRatio(
              aspectRatio: 1910.0 / 544.0,
              child: Image.asset(
                'assets/home/journey_map.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Curved dashed line painter representing flight trajectory
class _DashedFlightPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF57C28).withValues(alpha: 0.7)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.05,
      size.width,
      size.height * 0.5,
    );

    // Draw dashed path
    const dashWidth = 4.0;
    const dashSpace = 3.5;
    double distance = 0.0;
    final pathMetrics = path.computeMetrics().first;
    final pathLength = pathMetrics.length;

    while (distance < pathLength) {
      final extractLength = (distance + dashWidth).clamp(0.0, pathLength);
      final segment = pathMetrics.extractPath(distance, extractLength);
      canvas.drawPath(segment, paint);
      distance += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
