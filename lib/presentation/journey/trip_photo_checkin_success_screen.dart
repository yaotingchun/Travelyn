import 'dart:io' as io;
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'trip_details_screen.dart';

/// Screen displayed immediately after snapping a photo in the camera viewfinder.
/// Matches the reference design:
/// - Atmospheric falling sakura cherry blossom petals & golden glow background
/// - Top-left circular 'X' close button
/// - Header: "Nice shot!", "We've checked you in!"
/// - Realistic vintage tilted Polaroid card with:
///   - Top-right washi tape
///   - Location photo (Meiji Shrine / custom photo)
///   - Location title & formatted timestamp
///   - Hand-stamped vintage Trippy postal seal stamp
/// - 3-dot carousel indicator
/// - Vibrant "Keep Going! ✨" action button
class TripPhotoCheckinSuccessScreen extends StatelessWidget {
  final String placeName;
  final String? location;
  final String? imageAsset;
  final XFile? customPhoto;
  final DateTime? checkinTime;
  final VoidCallback? onContinue;
  final String destination;
  final String? tripType;
  final DateTime? startDate;
  final DateTime? endDate;

  const TripPhotoCheckinSuccessScreen({
    super.key,
    required this.placeName,
    this.location,
    this.imageAsset,
    this.customPhoto,
    this.checkinTime,
    this.onContinue,
    this.destination = 'Tokyo, Japan',
    this.tripType = 'Group Trip',
    this.startDate,
    this.endDate,
  });

  /// Static helper to navigate to this screen
  static Future<T?> show<T>(
    BuildContext context, {
    required String placeName,
    String? location,
    String? imageAsset,
    XFile? customPhoto,
    DateTime? checkinTime,
    VoidCallback? onContinue,
    String destination = 'Tokyo, Japan',
    String? tripType = 'Group Trip',
    DateTime? startDate,
    DateTime? endDate,
    bool replaceCurrent = true,
  }) {
    HapticFeedback.mediumImpact();
    final route = PageRouteBuilder<T>(
      pageBuilder: (ctx, anim, secAnim) => TripPhotoCheckinSuccessScreen(
        placeName: placeName,
        location: location,
        imageAsset: imageAsset,
        customPhoto: customPhoto,
        checkinTime: checkinTime,
        onContinue: onContinue,
        destination: destination,
        tripType: tripType,
        startDate: startDate,
        endDate: endDate,
      ),
      transitionsBuilder: (ctx, anim, secAnim, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 320),
    );

    return replaceCurrent
        ? Navigator.of(context).pushReplacement<T, dynamic>(route)
        : Navigator.of(context).push<T>(route);
  }

  String get _effectivePlaceName {
    final clean = placeName.replaceAll('!', '').trim();
    if (clean.isNotEmpty) return clean;
    final first = TripTab.getFirstPlace();
    return first?.name ?? 'Meiji Shrine';
  }

  String get _effectiveImageAsset {
    if (imageAsset != null && imageAsset!.isNotEmpty) {
      return imageAsset!;
    }
    final first = TripTab.getFirstPlace();
    if (first?.imageAsset != null && first!.imageAsset.isNotEmpty) {
      return first.imageAsset;
    }
    return 'assets/journey/place_meiji_shrine.jpg';
  }

  String _formatTimestamp(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = monthNames[dt.month - 1];
    return '${hour.toString().padLeft(2, '0')}:$minute $period • ${dt.day} $month ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final timeStr = _formatTimestamp(checkinTime ?? DateTime.now());
    final displayPlace = _effectivePlaceName;
    final photoAsset = _effectiveImageAsset;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F2),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Soft Warm Pastel Background Gradient
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFF9F5),
                  Color(0xFFFAF2EB),
                  Color(0xFFF6E8DC),
                ],
              ),
            ),
          ),

          // 2. Falling Sakura Petals Background Canvas
          CustomPaint(
            size: Size.infinite,
            painter: const _SakuraPetalsPainter(),
          ),

          // 3. Top-left Close Button
          Positioned(
            top: topPadding + 10,
            left: 16,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  TripTab.hasCheckedInFirstStop = true;
                  TripTab.currentStopIndex = 0;
                  // Return directly to the Trip Plan tab in TripDetailsScreen
                  Navigator.of(context).pushAndRemoveUntil(
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 320),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          TripDetailsScreen(
                        destination: destination,
                        tripType: tripType,
                        startDate: startDate,
                        endDate: endDate,
                        initialTabIndex: 1, // Trip plan tab!
                        isTripStarted: true,
                        hasCompletedCheckin: true,
                        currentStopIndex: 0,
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
                    (route) => route.isFirst,
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E7DC).withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: Color(0xFF38271F),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 4. Main Content: Header + Polaroid + Dots + Action Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 80),

                  // 1. Header with decorative sparkles & petals flanking both sides
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left decoration
                      const _HeaderSparkleDecoration(isLeft: true),

                      const SizedBox(width: 12),

                      // Header text column
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Nice shot!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.fredoka(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF26160F),
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "We've checked you in!",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.fredoka(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF4A3A31),
                              letterSpacing: -0.1,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(width: 12),

                      // Right decoration
                      const _HeaderSparkleDecoration(isLeft: false),
                    ],
                  ),

                  const Spacer(flex: 1),

                  // 5. Vintage Tilted Polaroid Card with Washi Tape
                  Transform.rotate(
                    angle: -0.045, // ~ -2.6 degrees playful tilt
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 320),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF6F0),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2B1810).withValues(alpha: 0.16),
                            blurRadius: 26,
                            offset: const Offset(2, 12),
                          ),
                          BoxShadow(
                            color: const Color(0xFFE24A08).withValues(alpha: 0.06),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Polaroid Frame Content
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Photo Frame
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: AspectRatio(
                                    aspectRatio: 0.78,
                                    child: customPhoto != null && !kIsWeb
                                        ? Image.file(
                                            io.File(customPhoto!.path),
                                            fit: BoxFit.cover,
                                          )
                                        : Image.asset(
                                            photoAsset,
                                            fit: BoxFit.cover,
                                            alignment: Alignment.center,
                                            errorBuilder: (ctx, err, st) {
                                              return Container(
                                                color: const Color(0xFF2E1C14),
                                                child: const Center(
                                                  child: Icon(Icons.image,
                                                      size: 48, color: Colors.white54),
                                                ),
                                              );
                                            },
                                          ),
                                  ),
                                ),

                                const SizedBox(height: 14),

                                // Bottom Label & Ink Stamp Row
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Location Name + Timestamp Column
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            displayPlace,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.fredoka(
                                              fontSize: 18.5,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF26160F),
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            timeStr,
                                            style: GoogleFonts.fredoka(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF7A685D),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 8),

                                    // Hand-stamped Postal Seal
                                    SizedBox(
                                      width: 54,
                                      height: 54,
                                      child: CustomPaint(
                                        painter: const _TravelStampPainter(),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Top-right Japanese Washi Masking Tape
                          Positioned(
                            top: -12,
                            right: -6,
                            child: Transform.rotate(
                              angle: 0.58, // ~33 degrees
                              child: Container(
                                width: 72,
                                height: 25,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE2C4A2).withValues(alpha: 0.72),
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),

                  // 6. Three-dot Carousel Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 5.5,
                        height: 5.5,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD8CAC0),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 7.5,
                        height: 7.5,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE24A08),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 5.5,
                        height: 5.5,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD8CAC0),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // 7. "Keep Going! ✨" Action Button
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 340),
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(27),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFF05A22),
                          Color(0xFFE24A08),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE24A08).withValues(alpha: 0.38),
                          blurRadius: 16,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        onContinue?.call();
                        TripTab.hasCheckedInFirstStop = true;
                        TripTab.currentStopIndex = 0;
                        // Navigate directly to the Trip Plan tab in TripDetailsScreen
                        Navigator.of(context).pushAndRemoveUntil(
                          PageRouteBuilder(
                            transitionDuration: const Duration(milliseconds: 350),
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                TripDetailsScreen(
                              destination: destination,
                              tripType: tripType,
                              startDate: startDate,
                              endDate: endDate,
                              initialTabIndex: 1, // Trip plan tab!
                              isTripStarted: true,
                              hasCompletedCheckin: true,
                              currentStopIndex: 0,
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
                          (route) => route.isFirst,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27),
                        ),
                      ),
                      child: Text(
                        'Keep Going! ✨',
                        style: GoogleFonts.fredoka(
                          fontSize: 17.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: bottomPadding > 0 ? 8 : 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter rendering a vintage Japanese station stamp / goshuin stamp
class _TravelStampPainter extends CustomPainter {
  const _TravelStampPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stampColor = const Color(0xFFB8582B).withValues(alpha: 0.88);

    final strokePaint = Paint()
      ..color = stampColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    final fillPaint = Paint()
      ..color = stampColor
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 2;

    // Outer scalloped/dashed circle
    const numDots = 24;
    for (int i = 0; i < numDots; i++) {
      final angle = (i * 2 * math.pi) / numDots;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 0.9, fillPaint);
    }

    // Inner crisp circle
    canvas.drawCircle(center, radius - 3.5, strokePaint);

    // Cute Trippy Face inside the stamp
    final faceCenter = center.translate(0, 1.5);

    // Ears
    final leftEar = Path()
      ..moveTo(faceCenter.dx - 12, faceCenter.dy - 8)
      ..lineTo(faceCenter.dx - 16, faceCenter.dy - 17)
      ..lineTo(faceCenter.dx - 7, faceCenter.dy - 12)
      ..close();
    canvas.drawPath(leftEar, strokePaint..strokeWidth = 1.4);

    final rightEar = Path()
      ..moveTo(faceCenter.dx + 12, faceCenter.dy - 8)
      ..lineTo(faceCenter.dx + 16, faceCenter.dy - 17)
      ..lineTo(faceCenter.dx + 7, faceCenter.dy - 12)
      ..close();
    canvas.drawPath(rightEar, strokePaint);

    // Head outline
    canvas.drawOval(
      Rect.fromCenter(center: faceCenter, width: 26, height: 21),
      strokePaint..strokeWidth = 1.5,
    );

    // Hat brim curve
    final hatPath = Path()
      ..moveTo(faceCenter.dx - 15, faceCenter.dy - 6)
      ..quadraticBezierTo(faceCenter.dx, faceCenter.dy - 12, faceCenter.dx + 15, faceCenter.dy - 6);
    canvas.drawPath(hatPath, strokePaint..strokeWidth = 1.3);

    // Happy eyes (curved arcs)
    final eyePaint = Paint()
      ..color = stampColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final leftEye = Path()
      ..moveTo(faceCenter.dx - 7.5, faceCenter.dy)
      ..quadraticBezierTo(faceCenter.dx - 5.5, faceCenter.dy - 2.5, faceCenter.dx - 3.5, faceCenter.dy);
    canvas.drawPath(leftEye, eyePaint);

    final rightEye = Path()
      ..moveTo(faceCenter.dx + 3.5, faceCenter.dy)
      ..quadraticBezierTo(faceCenter.dx + 5.5, faceCenter.dy - 2.5, faceCenter.dx + 7.5, faceCenter.dy);
    canvas.drawPath(rightEye, eyePaint);

    // Cute nose dot
    canvas.drawCircle(Offset(faceCenter.dx, faceCenter.dy + 2.5), 1.2, fillPaint);

    // Happy smile
    final mouthPath = Path()
      ..moveTo(faceCenter.dx - 3, faceCenter.dy + 4.5)
      ..quadraticBezierTo(faceCenter.dx, faceCenter.dy + 6.8, faceCenter.dx + 3, faceCenter.dy + 4.5);
    canvas.drawPath(mouthPath, eyePaint);

    // Paws peeking at bottom
    canvas.drawArc(
      Rect.fromCenter(center: Offset(faceCenter.dx - 5, faceCenter.dy + 10), width: 6, height: 4),
      0,
      math.pi,
      false,
      strokePaint..strokeWidth = 1.2,
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(faceCenter.dx + 5, faceCenter.dy + 10), width: 6, height: 4),
      0,
      math.pi,
      false,
      strokePaint..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter rendering atmospheric falling sakura petals across the background
class _SakuraPetalsPainter extends CustomPainter {
  const _SakuraPetalsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final petalPaint = Paint()
      ..color = const Color(0xFFFFB2A6).withValues(alpha: 0.38)
      ..style = PaintingStyle.fill;

    final petals = [
      _Petal(Offset(size.width * 0.10, size.height * 0.08), 6.5, 0.45),
      _Petal(Offset(size.width * 0.32, size.height * 0.05), 5.0, -0.60),
      _Petal(Offset(size.width * 0.76, size.height * 0.07), 6.8, 0.82),
      _Petal(Offset(size.width * 0.90, size.height * 0.12), 5.5, -0.35),
      _Petal(Offset(size.width * 0.06, size.height * 0.22), 4.8, 0.52),
      _Petal(Offset(size.width * 0.94, size.height * 0.28), 5.2, 0.70),
      _Petal(Offset(size.width * 0.08, size.height * 0.46), 6.0, -0.40),
      _Petal(Offset(size.width * 0.92, size.height * 0.54), 5.4, 0.65),
      _Petal(Offset(size.width * 0.12, size.height * 0.78), 5.0, 0.38),
      _Petal(Offset(size.width * 0.88, size.height * 0.82), 6.2, -0.55),
      _Petal(Offset(size.width * 0.22, size.height * 0.92), 4.5, 0.75),
    ];

    for (final p in petals) {
      canvas.save();
      canvas.translate(p.center.dx, p.center.dy);
      canvas.rotate(p.rotation);
      final path = Path()
        ..moveTo(0, -p.radius)
        ..quadraticBezierTo(p.radius * 0.9, 0, 0, p.radius)
        ..quadraticBezierTo(-p.radius * 0.9, 0, 0, -p.radius)
        ..close();
      canvas.drawPath(path, petalPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Petal {
  final Offset center;
  final double radius;
  final double rotation;
  const _Petal(this.center, this.radius, this.rotation);
}

/// Gently pulsing decorative sparkle & petal cluster for check-in header
class _HeaderSparkleDecoration extends StatefulWidget {
  final bool isLeft;
  const _HeaderSparkleDecoration({required this.isLeft});

  @override
  State<_HeaderSparkleDecoration> createState() => _HeaderSparkleDecorationState();
}

class _HeaderSparkleDecorationState extends State<_HeaderSparkleDecoration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );

    _pulseAnim = Tween<double>(begin: 0.88, end: 1.12).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );

    // Stagger phase slightly between left and right so they don't pulse completely in lockstep
    if (!widget.isLeft) {
      _controller.value = 0.5;
    }

    final bool isTest =
        WidgetsBinding.instance.runtimeType.toString().contains('AutomatedTestWidgetsFlutterBinding');
    if (!isTest) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnim.value,
          child: CustomPaint(
            size: const Size(34, 46),
            painter: _HeaderSparklePainter(isLeft: widget.isLeft),
          ),
        );
      },
    );
  }
}

/// Custom painter rendering 4-point magic sparkle stars, sakura petals, and twinkle dots
class _HeaderSparklePainter extends CustomPainter {
  final bool isLeft;
  const _HeaderSparklePainter({required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()..style = PaintingStyle.fill;
    final petalPaint = Paint()..style = PaintingStyle.fill;

    if (isLeft) {
      // Main 4-point Gold Sparkle Star
      _drawSparkleStar(
        canvas,
        center: const Offset(12, 25),
        size: 19,
        color: const Color(0xFFFFA000),
      );

      // Companion Apricot Star (tucked upper-right)
      _drawSparkleStar(
        canvas,
        center: const Offset(24, 10),
        size: 12.5,
        color: const Color(0xFFFF7A3D),
        rotationRad: math.pi / 8,
      );

      // Cute drifting Sakura Blossom Petal (lower-right)
      _drawSakuraPetal(
        canvas,
        center: const Offset(23, 37),
        radius: 4.8,
        rotationRad: 0.35,
        paint: petalPaint..color = const Color(0xFFFF9E9E).withValues(alpha: 0.88),
      );

      // Floating golden twinkle dots
      canvas.drawCircle(
        const Offset(5, 12),
        1.6,
        dotPaint..color = const Color(0xFFFFB300),
      );
      canvas.drawCircle(
        const Offset(6, 38),
        1.8,
        dotPaint..color = const Color(0xFFFFA000),
      );
    } else {
      // Mirrored Right Side
      // Main 4-point Gold Sparkle Star
      _drawSparkleStar(
        canvas,
        center: const Offset(22, 25),
        size: 19,
        color: const Color(0xFFFFA000),
      );

      // Companion Apricot Star (tucked upper-left)
      _drawSparkleStar(
        canvas,
        center: const Offset(10, 10),
        size: 12.5,
        color: const Color(0xFFFF7A3D),
        rotationRad: -math.pi / 8,
      );

      // Cute drifting Sakura Blossom Petal (lower-left)
      _drawSakuraPetal(
        canvas,
        center: const Offset(11, 37),
        radius: 4.8,
        rotationRad: -0.35,
        paint: petalPaint..color = const Color(0xFFFF9E9E).withValues(alpha: 0.88),
      );

      // Floating golden twinkle dots
      canvas.drawCircle(
        const Offset(29, 12),
        1.6,
        dotPaint..color = const Color(0xFFFFB300),
      );
      canvas.drawCircle(
        const Offset(28, 38),
        1.8,
        dotPaint..color = const Color(0xFFFFA000),
      );
    }
  }

  void _drawSparkleStar(
    Canvas canvas, {
    required Offset center,
    required double size,
    required Color color,
    double rotationRad = 0.0,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    if (rotationRad != 0.0) {
      canvas.rotate(rotationRad);
    }

    final path = Path();
    final r = size / 2.0;
    final inner = r * 0.25;

    path.moveTo(0, -r);
    path.quadraticBezierTo(inner, -inner, r, 0);
    path.quadraticBezierTo(inner, inner, 0, r);
    path.quadraticBezierTo(-inner, inner, -r, 0);
    path.quadraticBezierTo(-inner, -inner, 0, -r);
    path.close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  void _drawSakuraPetal(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required double rotationRad,
    required Paint paint,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationRad);
    final path = Path()
      ..moveTo(0, -radius)
      ..quadraticBezierTo(radius * 0.9, 0, 0, radius)
      ..quadraticBezierTo(-radius * 0.9, 0, 0, -radius)
      ..close();
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HeaderSparklePainter oldDelegate) =>
      oldDelegate.isLeft != isLeft;
}

