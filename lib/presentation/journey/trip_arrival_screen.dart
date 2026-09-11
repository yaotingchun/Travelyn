import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'trip_checkin_screen.dart';
export 'trip_checkin_screen.dart';

/// Arrival celebratory screen shown when arriving at a trip location.
/// Matches the reference design:
/// - Top header: "We've arrived at\n[First Location Name]!"
/// - Center: Location card styled like the itinerary carousel card
///   (photography, top scrim, First Stop badge, Category chip, location pin, description)
/// - Below: Compact "Trippy's tip" card with local street food/activity recommendation
/// - Bottom: Vibrant pill button "Start Exploring"
class TripArrivalScreen extends StatefulWidget {
  final String placeName;
  final String preTitle;
  final String? location;
  final String? category;
  final String? imageAsset;
  final String? description;
  final String spotBadge;
  final String tipTitle;
  final String tipText;
  final String buttonText;
  final VoidCallback? onStartExploring;
  final String destination;
  final String? tripType;
  final DateTime? startDate;
  final DateTime? endDate;

  const TripArrivalScreen({
    super.key,
    required this.placeName,
    this.preTitle = "We've arrived at",
    this.location,
    this.category,
    this.imageAsset,
    this.description,
    this.spotBadge = 'First Stop',
    this.tipTitle = "Trippy's tip",
    this.tipText = "Try the melon pan and\nyakitori – local favorites!",
    this.buttonText = "Start Exploring",
    this.onStartExploring,
    this.destination = 'Tokyo, Japan',
    this.tripType = 'Group Trip',
    this.startDate,
    this.endDate,
  });

  /// Provides tailored tips for given location names
  static String getTipForPlace(String placeName) {
    final lower = placeName.toLowerCase();
    if (lower.contains('meiji') || lower.contains('shrine')) {
      return 'Try the traditional green tea and\nwrite an ema prayer wish!';
    } else if (lower.contains('nakamise') || lower.contains('shopping') || lower.contains('asakusa')) {
      return 'Try the melon pan and\nyakitori – local favorites!';
    } else if (lower.contains('harajuku') || lower.contains('takeshita')) {
      return 'Try the famous rainbow crepes and\nfluffy Japanese pancakes!';
    } else if (lower.contains('shibuya')) {
      return 'Grab a matcha latte and watch the\ncrowd from the rooftop sky deck!';
    } else if (lower.contains('teamlab')) {
      return 'Explore barefoot and capture stunning\nlight crystal reflections!';
    } else if (lower.contains('ueno')) {
      return 'Visit the giant pandas and enjoy\nsweet sakura mochi treats!';
    }
    return 'Try the melon pan and\nyakitori – local favorites!';
  }

  /// Provides category tag for given location
  static String getCategoryForPlace(String placeName) {
    final lower = placeName.toLowerCase();
    if (lower.contains('meiji') || lower.contains('shrine') || lower.contains('temple') || lower.contains('senso')) {
      return 'Culture & Heritage';
    } else if (lower.contains('nakamise') || lower.contains('shopping') || lower.contains('market') || lower.contains('tsukiji') || lower.contains('ginza')) {
      return 'Historic Market';
    } else if (lower.contains('harajuku') || lower.contains('takeshita')) {
      return 'Fashion & Vibes';
    } else if (lower.contains('shibuya')) {
      return 'Iconic Landmark';
    } else if (lower.contains('teamlab')) {
      return 'Digital Art';
    } else if (lower.contains('tower') || lower.contains('skytree')) {
      return 'Sightseeing';
    } else if (lower.contains('ueno') || lower.contains('park')) {
      return 'Nature & Culture';
    }
    return 'Must-Visit Spot';
  }

  /// Provides district/neighborhood string
  static String getLocationForPlace(String placeName) {
    final lower = placeName.toLowerCase();
    if (lower.contains('meiji') || lower.contains('shibuya') || lower.contains('harajuku') || lower.contains('takeshita')) {
      return 'Shibuya, Tokyo';
    } else if (lower.contains('senso') || lower.contains('nakamise') || lower.contains('asakusa') || lower.contains('ueno')) {
      return 'Taito City, Tokyo';
    } else if (lower.contains('teamlab') || lower.contains('odaiba')) {
      return 'Koto City, Tokyo';
    } else if (lower.contains('tower') || lower.contains('roppongi')) {
      return 'Minato, Tokyo';
    } else if (lower.contains('tsukiji') || lower.contains('ginza')) {
      return 'Chuo City, Tokyo';
    } else if (lower.contains('akihabara') || lower.contains('tokyo station')) {
      return 'Chiyoda City, Tokyo';
    }
    return 'Tokyo, Japan';
  }

  /// Provides local photography asset
  static String getImageForPlace(String placeName) {
    final lower = placeName.toLowerCase();
    if (lower.contains('meiji')) {
      return 'assets/journey/place_meiji_shrine.jpg';
    } else if (lower.contains('senso') || lower.contains('nakamise') || lower.contains('asakusa') || lower.contains('ueno') || lower.contains('tsukiji')) {
      return 'assets/journey/place_sensoji.jpg';
    } else if (lower.contains('harajuku') || lower.contains('takeshita')) {
      return 'assets/journey/place_harajuku.jpg';
    } else if (lower.contains('shibuya')) {
      return 'assets/journey/place_shibuya.jpg';
    } else if (lower.contains('teamlab')) {
      return 'assets/journey/place_teamlab.jpg';
    } else if (lower.contains('tower') || lower.contains('skytree') || lower.contains('ginza')) {
      return 'assets/journey/place_tokyo_tower.jpg';
    }
    return 'assets/journey/place_meiji_shrine.jpg';
  }

  /// Provides brief description for location
  static String getDescriptionForPlace(String placeName) {
    final lower = placeName.toLowerCase();
    if (lower.contains('meiji')) {
      return 'Serene Shinto sanctuary nestled in a 170-acre evergreen forest with towering wooden torii gates.';
    } else if (lower.contains('nakamise') || lower.contains('senso')) {
      return 'Tokyo’s oldest Buddhist sanctuary framed by towering pagodas and traditional Edo market stalls.';
    } else if (lower.contains('harajuku') || lower.contains('takeshita')) {
      return 'Vibrant epicenter of youth culture, colorful boutique shopping, and artisan street desserts.';
    } else if (lower.contains('shibuya')) {
      return 'The world’s most celebrated pedestrian scramble crossing surrounded by electric neon.';
    } else if (lower.contains('teamlab')) {
      return 'Immersive light universe featuring infinity crystal mirrors, flowing water, and floral art.';
    } else if (lower.contains('tower')) {
      return 'Iconic communications tower offering sweeping 360° views across the Tokyo skyline.';
    }
    return 'Iconic travel destination filled with vibrant atmosphere, rich history, and local culture.';
  }

  /// Convenience helper to present this screen with smooth fade/slide transition
  static Future<T?> show<T>(
    BuildContext context, {
    required String placeName,
    String preTitle = "We've arrived at",
    String? location,
    String? category,
    String? imageAsset,
    String? description,
    String spotBadge = 'First Stop',
    String tipTitle = "Trippy's tip",
    String? tipText,
    String buttonText = "Start Exploring",
    VoidCallback? onStartExploring,
    String destination = 'Tokyo, Japan',
    String? tripType = 'Group Trip',
    DateTime? startDate,
    DateTime? endDate,
  }) {
    HapticFeedback.mediumImpact();
    final effectiveTip = tipText ?? getTipForPlace(placeName);
    final effectiveLoc = location ?? getLocationForPlace(placeName);
    final effectiveCat = category ?? getCategoryForPlace(placeName);
    final effectiveImg = imageAsset ?? getImageForPlace(placeName);
    final effectiveDesc = description ?? getDescriptionForPlace(placeName);

    return Navigator.of(context).push<T>(
      PageRouteBuilder<T>(
        pageBuilder: (ctx, anim, secAnim) => TripArrivalScreen(
          placeName: placeName,
          preTitle: preTitle,
          location: effectiveLoc,
          category: effectiveCat,
          imageAsset: effectiveImg,
          description: effectiveDesc,
          spotBadge: spotBadge,
          tipTitle: tipTitle,
          tipText: effectiveTip,
          buttonText: buttonText,
          onStartExploring: onStartExploring,
          destination: destination,
          tripType: tripType,
          startDate: startDate,
          endDate: endDate,
        ),
        transitionsBuilder: (ctx, anim, secAnim, child) {
          final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.05),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 320),
      ),
    );
  }

  @override
  State<TripArrivalScreen> createState() => _TripArrivalScreenState();
}

class _TripArrivalScreenState extends State<TripArrivalScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Format place title neatly with exclamation mark
    final formattedPlace = widget.placeName.trim().endsWith('!')
        ? widget.placeName.trim()
        : '${widget.placeName.trim()}!';

    final locText = widget.location ?? TripArrivalScreen.getLocationForPlace(widget.placeName);
    final catText = widget.category ?? TripArrivalScreen.getCategoryForPlace(widget.placeName);
    final imgAsset = widget.imageAsset ?? TripArrivalScreen.getImageForPlace(widget.placeName);
    final descText = widget.description ?? TripArrivalScreen.getDescriptionForPlace(widget.placeName);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF3EB),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF9F3),
              Color(0xFFFAF3EB),
              Color(0xFFF5EBE0),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Center compact content container
            Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),

                    // 1. Header with decorative sparkles flanking the left and right
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left Sparkle Decoration
                        const _HeaderSparkleDecoration(isLeft: true),

                        const SizedBox(width: 8),

                        // Header Text Column
                        Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                widget.preTitle,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.fredoka(
                                  fontSize: 18.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF38271F),
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                formattedPlace,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.fredoka(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF26160F),
                                  height: 1.15,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Right Sparkle Decoration
                        const _HeaderSparkleDecoration(isLeft: false),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // 3. Location Card (like carousel card with photography, badges, and details)
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildLocationCard(
                          imageAsset: imgAsset,
                          spotBadge: widget.spotBadge,
                          category: catText,
                          location: locText,
                          placeName: widget.placeName.trim(),
                          description: descText,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // 4. Compact "Trippy's tip" Card
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 360),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFDFB),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFEFE5DA),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2E1C14).withValues(alpha: 0.06),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Custom cute Takeout Snack Bag Icon
                          const _SnackBagIcon(),

                          const SizedBox(width: 14),

                          // Tip text column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.tipTitle,
                                  style: GoogleFonts.fredoka(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFB8582B),
                                    letterSpacing: 0.1,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  widget.tipText,
                                  style: GoogleFonts.fredoka(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF382921),
                                    height: 1.24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 5. "Start Exploring" Action Button
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 360),
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
                            color: const Color(0xFFE24A08).withValues(alpha: 0.36),
                            blurRadius: 16,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          widget.onStartExploring?.call();
                          TripCheckinScreen.show(
                            context,
                            placeName: widget.placeName,
                            location: widget.location,
                            destination: widget.destination,
                            tripType: widget.tripType,
                            startDate: widget.startDate,
                            endDate: widget.endDate,
                            replaceCurrent: true,
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
                          widget.buttonText,
                          style: GoogleFonts.fredoka(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // Top-left subtle back button overlay (does not affect vertical layout)
            Positioned(
              top: 6,
              left: 10,
              child: SafeArea(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 19,
                        color: Color(0xFF7A685D),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Location Card inspired by the carousel card style
  Widget _buildLocationCard({
    required String imageAsset,
    required String spotBadge,
    required String category,
    required String location,
    required String placeName,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 350),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E1C14).withValues(alpha: 0.14),
                blurRadius: 22,
                offset: const Offset(0, 10),
                spreadRadius: -2,
              ),
              BoxShadow(
                color: const Color(0xFFE65100).withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Stack(
              fit: StackFit.expand,
              children: [
            // Background Photography
            Image.asset(
              imageAsset,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, st) {
                return Container(
                  color: const Color(0xFF2E1C14),
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported_rounded,
                      color: Colors.white54,
                      size: 40,
                    ),
                  ),
                );
              },
            ),

            // Top Scrim Gradient for Top Badges
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 75,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.55),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Atmospheric Gradient for Place Information
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 180,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.38),
                      Colors.black.withValues(alpha: 0.88),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),

            // Top Badges: Spot Number + Category Chip
            Positioned(
              top: 14,
              left: 14,
              right: 14,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Spot Number Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.50),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.30),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.place_rounded,
                          size: 13,
                          color: Color(0xFFFFB300),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          spotBadge,
                          style: GoogleFonts.fredoka(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Category Chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE65100).withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      category,
                      style: GoogleFonts.fredoka(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Place Details (District, Place Name, Description)
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // District / Location Tag
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: Color(0xFFFFB300),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: GoogleFonts.fredoka(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFFFE0B2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Place Name
                  Text(
                    placeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.fredoka(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Description
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.fredoka(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.92),
                      height: 1.25,
                    ),
                  ),
                ],
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

/// Custom illustration widget rendering the paper take-out snack bag
/// with warm skewers/pastries sticking out and breadcrumb sparkles.
class _SnackBagIcon extends StatelessWidget {
  const _SnackBagIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: CustomPaint(
        painter: _SnackBagPainter(),
      ),
    );
  }
}

class _SnackBagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Skewers / Pastry sticks poking out of bag
    final stickPaint = Paint()
      ..color = const Color(0xFFE65100)
      ..style = PaintingStyle.fill;

    // Left stick
    canvas.save();
    canvas.translate(w * 0.34, h * 0.26);
    canvas.rotate(-0.14);
    final stick1 = RRect.fromRectAndRadius(
      Rect.fromLTWH(-w * 0.05, -h * 0.20, w * 0.10, h * 0.26),
      const Radius.circular(3),
    );
    canvas.drawRRect(stick1, stickPaint);
    canvas.restore();

    // Right stick
    canvas.save();
    canvas.translate(w * 0.46, h * 0.24);
    canvas.rotate(0.12);
    final stick2 = RRect.fromRectAndRadius(
      Rect.fromLTWH(-w * 0.05, -h * 0.18, w * 0.10, h * 0.24),
      const Radius.circular(3),
    );
    canvas.drawRRect(stick2, stickPaint);
    canvas.restore();

    // 2. Paper Bag body
    final bagPath = Path();
    bagPath.moveTo(w * 0.20, h * 0.33);
    bagPath.lineTo(w * 0.74, h * 0.33);
    bagPath.lineTo(w * 0.78, h * 0.88);
    bagPath.quadraticBezierTo(w * 0.78, h * 0.94, w * 0.72, h * 0.94);
    bagPath.lineTo(w * 0.24, h * 0.94);
    bagPath.quadraticBezierTo(w * 0.18, h * 0.94, w * 0.18, h * 0.88);
    bagPath.close();

    // Fill paper bag
    final bagPaint = Paint()
      ..color = const Color(0xFFF7EBDC)
      ..style = PaintingStyle.fill;
    canvas.drawPath(bagPath, bagPaint);

    // Border
    final bagBorderPaint = Paint()
      ..color = const Color(0xFFDECBBA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    canvas.drawPath(bagPath, bagBorderPaint);

    // Top folded crease line
    final foldPaint = Paint()
      ..color = const Color(0xFFCEB8A2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawLine(
      Offset(w * 0.21, h * 0.38),
      Offset(w * 0.73, h * 0.38),
      foldPaint,
    );

    // 3. Center square emblem
    final emblemRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.47, h * 0.64),
        width: w * 0.24,
        height: h * 0.24,
      ),
      const Radius.circular(4),
    );
    final emblemPaint = Paint()
      ..color = const Color(0xFFECA376).withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(emblemRect, emblemPaint);

    // Cute dot in emblem
    final dotPaint = Paint()
      ..color = const Color(0xFFB8582B)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.47, h * 0.64), 2.2, dotPaint);

    // 4. Little decorative sparkles
    final crumbPaint = Paint()
      ..color = const Color(0xFFE89A6A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.84, h * 0.85), 1.8, crumbPaint);
    canvas.drawCircle(Offset(w * 0.80, h * 0.73), 1.3, crumbPaint);
    canvas.drawCircle(Offset(w * 0.13, h * 0.48), 1.4, crumbPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Gently pulsing decorative sparkle cluster for arrival header
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
            size: const Size(32, 44),
            painter: _HeaderSparklePainter(isLeft: widget.isLeft),
          ),
        );
      },
    );
  }
}

/// Custom painter rendering 4-point magic sparkle stars and twinkle dots
class _HeaderSparklePainter extends CustomPainter {
  final bool isLeft;
  const _HeaderSparklePainter({required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()..style = PaintingStyle.fill;

    if (isLeft) {
      // Main Star (lower-left, flanking place name)
      _drawSparkleStar(
        canvas,
        center: const Offset(11, 26),
        size: 19,
        color: const Color(0xFFFFA000),
      );
      // Companion Star (upper-right, tucked near top line)
      _drawSparkleStar(
        canvas,
        center: const Offset(23, 10),
        size: 12.5,
        color: const Color(0xFFFF7A3D),
        rotationRad: math.pi / 8,
      );
      // Delicate floating sparkle dots
      canvas.drawCircle(
        const Offset(25, 36),
        2.0,
        dotPaint..color = const Color(0xFFFFB300),
      );
      canvas.drawCircle(
        const Offset(6, 9),
        1.4,
        dotPaint..color = const Color(0xFFFF9800),
      );
    } else {
      // Mirrored Right Side
      // Main Star (lower-right, flanking place name)
      _drawSparkleStar(
        canvas,
        center: const Offset(21, 26),
        size: 19,
        color: const Color(0xFFFFA000),
      );
      // Companion Star (upper-left, tucked near top line)
      _drawSparkleStar(
        canvas,
        center: const Offset(9, 10),
        size: 12.5,
        color: const Color(0xFFFF7A3D),
        rotationRad: -math.pi / 8,
      );
      // Delicate floating sparkle dots
      canvas.drawCircle(
        const Offset(7, 36),
        2.0,
        dotPaint..color = const Color(0xFFFFB300),
      );
      canvas.drawCircle(
        const Offset(26, 9),
        1.4,
        dotPaint..color = const Color(0xFFFF9800),
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
    final R = size / 2.0;
    final inner = R * 0.25;

    path.moveTo(0, -R);
    path.quadraticBezierTo(inner, -inner, R, 0);
    path.quadraticBezierTo(inner, inner, 0, R);
    path.quadraticBezierTo(-inner, inner, -R, 0);
    path.quadraticBezierTo(-inner, -inner, 0, -R);
    path.close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HeaderSparklePainter oldDelegate) =>
      oldDelegate.isLeft != isLeft;
}

