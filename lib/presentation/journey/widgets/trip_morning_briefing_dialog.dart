import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Morning Briefing Popup Dialog triggered when starting a trip (Simulation 1).
/// Matches the reference design with:
/// - Warm cream rounded card with top sparkle decoration
/// - "Good morning, Explorer! ☀️" greeting and Day header
/// - Section 1: Weather in destination with stylized 3D glowing sun
/// - Section 2: Today's Tips (Light clothing, photos, stay hydrated)
/// - Section 3: Today's Game Plan (stops count, walking distance, encouragement)
/// - Action Button: "Let's Go! ✈️"
class TripMorningBriefingDialog extends StatelessWidget {
  final String destination;
  final int dayNumber;
  final String dateLabel;
  final int stopCount;
  final String walkDistance;
  final VoidCallback? onLetsGo;

  const TripMorningBriefingDialog({
    super.key,
    this.destination = 'Tokyo',
    this.dayNumber = 1,
    this.dateLabel = '15 Sep 🇯🇵',
    this.stopCount = 4,
    this.walkDistance = '~4.8 km',
    this.onLetsGo,
  });

  /// Displays the dialog with a smooth scale-in transition
  static Future<void> show(
    BuildContext context, {
    String destination = 'Tokyo',
    int dayNumber = 1,
    String? dateLabel,
    int stopCount = 4,
    String walkDistance = '~4.8 km',
    VoidCallback? onLetsGo,
  }) {
    HapticFeedback.mediumImpact();
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'MorningBriefing',
      barrierColor: Colors.black.withValues(alpha: 0.60),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (ctx, anim1, anim2) {
        return TripMorningBriefingDialog(
          destination: destination.split(',').first.trim(),
          dayNumber: dayNumber,
          dateLabel: dateLabel ?? '15 Sep 🇯🇵',
          stopCount: stopCount,
          walkDistance: walkDistance,
          onLetsGo: onLetsGo,
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curve = Curves.easeOutBack.transform(anim1.value);
        return Transform.scale(
          scale: 0.88 + (curve * 0.12),
          child: Opacity(
            opacity: anim1.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const brandOrange = Color(0xFFE65100);
    const darkBrown = Color(0xFF2E1C14);
    const textMuted = Color(0xFF6E5E56);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: math.min(MediaQuery.of(context).size.width - 36, 365.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFF9F3),
                Color(0xFFFBF2E7),
              ],
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: const Color(0xFFF0E5D8),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E1C14).withValues(alpha: 0.22),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Background subtle celebratory sparkles
              Positioned(
                top: 14,
                left: 18,
                child: CustomPaint(
                  size: const Size(32, 28),
                  painter: _SparkleDecoPainter(),
                ),
              ),

              // Close 'X' Button on top-right
              Positioned(
                top: 14,
                right: 14,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFEADBCE),
                        width: 1.0,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.close_rounded,
                        size: 17,
                        color: Color(0xFF5A4A42),
                      ),
                    ),
                  ),
                ),
              ),

              // Main Dialog Content
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title: Good morning, Explorer! ☀️
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Good morning, Explorer!',
                          style: GoogleFonts.fredoka(
                            fontSize: 21.5,
                            fontWeight: FontWeight.w700,
                            color: darkBrown,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text('☀️', style: TextStyle(fontSize: 20)),
                      ],
                    ),

                    const SizedBox(height: 3),

                    // Subtitle: Here's your briefing for
                    Text(
                      "Here's your briefing for",
                      style: GoogleFonts.fredoka(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: textMuted,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Day Badge Header: Day 1 • 15 Sep 🇯🇵
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Day $dayNumber',
                          style: GoogleFonts.fredoka(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w700,
                            color: darkBrown,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: brandOrange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          dateLabel,
                          style: GoogleFonts.fredoka(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: darkBrown,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // CARD 1: Weather in Tokyo
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFEDE2D5),
                          width: 1.1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2E1C14).withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Left weather info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Weather in $destination',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: darkBrown,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '26°C',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1E1410),
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Mostly Sunny',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    color: textMuted,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Feels like 28°C • 10% rain',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF9E8E82),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Right 3D Stylized Glowing Sun
                          const SizedBox(
                            width: 68,
                            height: 68,
                            child: _StylizedGlowingSun(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // CARD 2: Today's Tips
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFEDE2D5),
                          width: 1.1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2E1C14).withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Today's Tips",
                            style: GoogleFonts.fredoka(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: darkBrown,
                            ),
                          ),
                          const SizedBox(height: 7),
                          _buildTipBullet('Light clothing & sunscreen'),
                          const SizedBox(height: 5),
                          _buildTipBullet('Best time for photos: 4–6 PM'),
                          const SizedBox(height: 5),
                          _buildTipBullet('Stay hydrated!'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // CARD 3: Today's Game Plan
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFEDE2D5),
                          width: 1.1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2E1C14).withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Today's Game Plan",
                            style: GoogleFonts.fredoka(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: darkBrown,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "You've got $stopCount exciting stops!",
                            style: GoogleFonts.fredoka(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF4A3E38),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Total walk: $walkDistance',
                            style: GoogleFonts.fredoka(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: brandOrange,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Text(
                                "Keep it up, you've got this! ",
                                style: GoogleFonts.fredoka(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF4A3E38),
                                ),
                              ),
                              const Text('💪', style: TextStyle(fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // BOTTOM BUTTON: Let's Go! ✈️
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        Navigator.of(context).pop();
                        if (onLetsGo != null) {
                          onLetsGo!();
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFF6200),
                              Color(0xFFE65100),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: brandOrange.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Let's Go! ",
                                style: GoogleFonts.fredoka(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const Text(
                                '✈️',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipBullet(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2.5, right: 6.0),
          child: Icon(
            Icons.star_rate_rounded,
            size: 13,
            color: const Color(0xFFE65100),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.fredoka(
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF4A3E38),
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter for the top-left sparkle decorative flourish
class _SparkleDecoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFA000)
      ..style = PaintingStyle.fill;

    // 4-point star sparkle
    final path = Path();
    const cx = 10.0;
    const cy = 12.0;
    const rOuter = 8.0;
    const rInner = 2.5;

    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4.0) - (math.pi / 2.0);
      final r = (i % 2 == 0) ? rOuter : rInner;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);

    // Mini dots
    canvas.drawCircle(const Offset(22, 6), 2.2, paint..color = const Color(0xFFFFB74D));
    canvas.drawCircle(const Offset(24, 18), 1.6, paint..color = const Color(0xFFFF8F00));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Stylized glowing sun with sunbeams matching the design
class _StylizedGlowingSun extends StatelessWidget {
  const _StylizedGlowingSun();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SunPainter(),
    );
  }
}

class _SunPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2.0, size.height / 2.0);
    final radius = size.width * 0.28;

    // 1. Soft glowing outer halo
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFB300).withValues(alpha: 0.35),
          const Color(0xFFFFE082).withValues(alpha: 0.12),
          Colors.transparent,
        ],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.48));

    canvas.drawCircle(center, size.width * 0.48, glowPaint);

    // 2. Triangular/diamond sunbeams around the perimeter
    final rayPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFB74D), Color(0xFFFF9800)],
      ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.45))
      ..style = PaintingStyle.fill;

    const numRays = 8;
    for (int i = 0; i < numRays; i++) {
      final angle = (i * 2 * math.pi / numRays) - (math.pi / 8.0);
      final rayBaseAngle1 = angle - 0.14;
      final rayBaseAngle2 = angle + 0.14;
      final innerR = radius + 2.0;
      final outerR = size.width * 0.44;

      final p1 = Offset(center.dx + innerR * math.cos(rayBaseAngle1), center.dy + innerR * math.sin(rayBaseAngle1));
      final p2 = Offset(center.dx + outerR * math.cos(angle), center.dy + outerR * math.sin(angle));
      final p3 = Offset(center.dx + innerR * math.cos(rayBaseAngle2), center.dy + innerR * math.sin(rayBaseAngle2));

      final rayPath = Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..lineTo(p3.dx, p3.dy)
        ..close();

      canvas.drawPath(rayPath, rayPaint);
    }

    // 3. Central Sun disc with warm radial gradient
    final sunDiscPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.25, -0.25),
        colors: [
          Color(0xFFFFD54F),
          Color(0xFFFF9800),
          Color(0xFFF57C00),
        ],
        stops: [0.0, 0.68, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, sunDiscPaint);

    // 4. Subtle glossy top highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.38)
      ..style = PaintingStyle.fill;

    final highlightPath = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(center.dx - 2.5, center.dy - radius * 0.35),
        width: radius * 0.9,
        height: radius * 0.5,
      ));

    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
