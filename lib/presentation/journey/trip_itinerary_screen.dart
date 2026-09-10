import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'trip_details_screen.dart';
import 'widgets/trip_done_button.dart';
import '../../services/mapbox_config.dart';

/// Data model for an itinerary stop (kept for compatibility with DayPlan / TripTab)
class ItineraryStop {
  final String id;
  final String title;
  final String time;
  final String category;
  final String duration;
  final String description;
  final IconData icon;
  final Offset mapRelativePosition; // Normalized 0.0 - 1.0 on map image

  const ItineraryStop({
    required this.id,
    required this.title,
    required this.time,
    required this.category,
    required this.duration,
    required this.description,
    required this.icon,
    required this.mapRelativePosition,
  });
}

/// Data model for a daily plan
class DayPlan {
  final int dayNumber;
  final String title;
  final String subtitle;
  final List<ItineraryStop> stops;

  const DayPlan({
    required this.dayNumber,
    required this.title,
    required this.subtitle,
    required this.stops,
  });
}

/// Data model for a featured travel place in the square carousel
class TravelPlace {
  final String id;
  final String name;
  final String location;
  final String category;
  final String imageAsset;
  final String description;

  const TravelPlace({
    required this.id,
    required this.name,
    required this.location,
    required this.category,
    required this.imageAsset,
    required this.description,
  });
}

/// Screen displayed after the planning transition ("Ta-da! Here's your Tokyo adventure!").
/// Displays the curated itinerary with celebration atmosphere, a high-aesthetic square carousel
/// showcasing 5 images of the travelled spots auto-swapping every few seconds, and a direct CTA.
class TripItineraryScreen extends StatefulWidget {
  final String destination;
  final String planDuration;
  final TripPlacesResult? placesResult;
  final VoidCallback? onOpenTripHub;

  const TripItineraryScreen({
    super.key,
    this.destination = 'Tokyo, Japan',
    this.planDuration = '5D4N',
    this.placesResult,
    this.onOpenTripHub,
  });

  @override
  State<TripItineraryScreen> createState() => _TripItineraryScreenState();
}

class _TripItineraryScreenState extends State<TripItineraryScreen> {
  final ScrollController _scrollController = ScrollController();
  late final PageController _pageController = PageController();
  Timer? _carouselTimer;
  int _currentCardIndex = 0;

  // 5 travelled places with high-aesthetic photography
  final List<TravelPlace> _travelPlaces = const [
    TravelPlace(
      id: 'tokyo_tower',
      name: 'Tokyo Tower',
      location: 'Minato, Tokyo',
      category: 'Sightseeing',
      imageAsset: 'assets/journey/place_tokyo_tower.jpg',
      description: 'Iconic communications tower offering sweeping 360° views across the Tokyo skyline.',
    ),
    TravelPlace(
      id: 'senso_ji',
      name: 'Sensō-ji Temple',
      location: 'Asakusa, Tokyo',
      category: 'Culture & Heritage',
      imageAsset: 'assets/journey/place_sensoji.jpg',
      description: 'Tokyo’s oldest Buddhist sanctuary framed by towering pagodas and traditional market stalls.',
    ),
    TravelPlace(
      id: 'harajuku',
      name: 'Harajuku Takeshita St.',
      location: 'Harajuku, Tokyo',
      category: 'Fashion & Vibes',
      imageAsset: 'assets/journey/place_harajuku.jpg',
      description: 'Vibrant epicenter of youth culture, colorful boutique shopping, and artisan street desserts.',
    ),
    TravelPlace(
      id: 'shibuya',
      name: 'Shibuya Scramble',
      location: 'Shibuya, Tokyo',
      category: 'Iconic Landmark',
      imageAsset: 'assets/journey/place_shibuya.jpg',
      description: 'The world’s most celebrated pedestrian scramble crossing surrounded by electric neon.',
    ),
    TravelPlace(
      id: 'teamlab',
      name: 'teamLab Planets',
      location: 'Toyosu, Tokyo',
      category: 'Digital Art',
      imageAsset: 'assets/journey/place_teamlab.jpg',
      description: 'Immersive light universe featuring infinity crystal mirrors, flowing water, and floral art.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _ensureTimerRunning();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    MapboxConfig.precacheTokyoDays(context);
  }

  void _ensureTimerRunning() {
    if (_carouselTimer != null) return;
    // Swapping to next card after a certain duration (not moving constantly)
    final isRunningInTest =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isRunningInTest) {
      _startCarouselTimer();
    }
  }

  void _startCarouselTimer() {
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(milliseconds: 3800), (timer) {
      if (!mounted || !_pageController.hasClients) return;
      final nextIndex = (_currentCardIndex + 1) % _travelPlaces.length;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onProceedToTripHub() {
    HapticFeedback.mediumImpact();
    if (widget.onOpenTripHub != null) {
      widget.onOpenTripHub!();
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) =>
            TripDetailsScreen(
          destination: widget.destination,
          tripType: 'Group Trip',
          initialTabIndex: 1, // Redirects directly to Trip tab
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    _ensureTimerRunning();
    const darkBrown = Color(0xFF231815);
    const textMuted = Color(0xFF8A786E);
    const sunsetOrange = Color(0xFFFF5B22);
    const creamBg = Color(0xFFFFF9F3);

    final cityName = widget.destination.split(',').first.trim();

    return Scaffold(
      backgroundColor: creamBg,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: Stack(
          children: [
            // 1. Atmospheric Confetti, Sakura Petals & Golden Sparkle Canvas
            Positioned.fill(
              child: CustomPaint(
                painter: _CelebrationAtmospherePainter(),
              ),
            ),

            // 2. Sakura Blossom Branch in Top Right corner
            Positioned(
              top: 0,
              right: 0,
              width: 140,
              height: 170,
              child: IgnorePointer(
                child: Image.asset(
                  'assets/journey/vote_sakura.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.topRight,
                  errorBuilder: (ctx, err, st) => const SizedBox(),
                ),
              ),
            ),

            // 3. Main Scrollable Content
            SafeArea(
              bottom: false,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Top Back button
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 4.0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).maybePop(),
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.85),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFE8DFD5),
                                  width: 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: darkBrown.withValues(alpha: 0.04),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 16,
                                color: darkBrown,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Header: "✦ Ta-da! 🎉" + "Here's your Tokyo adventure!"
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // "✦ Ta-da! 🎉"
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildFourPointStar(
                                size: 14,
                                color: const Color(0xFFFFB300),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Ta-da!',
                                style: GoogleFonts.fredoka(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF381F13),
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '🎉',
                                style: TextStyle(fontSize: 26),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Main bold headline: "Here's your Tokyo adventure!"
                          Text(
                            "Here's your $cityName adventure!",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.fredoka(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: darkBrown,
                              letterSpacing: -0.3,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Subtitle
                          Text(
                            'A ${widget.planDuration} plan crafted just for your gang',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.fredoka(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Square Card Carousel with 5 Travelled Places & Action Button
                  SliverToBoxAdapter(
                    child: _buildSquareCarouselSection(sunsetOrange, darkBrown, textMuted),
                  ),

                  // Bottom padding
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 32),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Square Carousel section displaying 5 travelled spots in 1:1 aspect ratio
  Widget _buildSquareCarouselSection(Color sunsetOrange, Color darkBrown, Color textMuted) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1:1 Square Card Container
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: darkBrown.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: sunsetOrange.withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _travelPlaces.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentCardIndex = index;
                    });
                    // Reset auto-advance timer on manual swipe
                    final isRunningInTest = WidgetsBinding.instance.runtimeType
                        .toString()
                        .contains('Test');
                    if (!isRunningInTest) {
                      _startCarouselTimer();
                    }
                  },
                  itemBuilder: (context, index) {
                    final place = _travelPlaces[index];
                    return _buildPlaceCardItem(place, index, sunsetOrange);
                  },
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Carousel Dot Indicators below the card
        _buildCarouselIndicators(sunsetOrange, darkBrown),

        const SizedBox(height: 32),

        // "View Full Plan!" Action Button (slightly narrower & refined)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 42.0),
          child: TripDoneButton(
            label: 'View Full Plan!',
            icon: Icons.arrow_forward_rounded,
            showPaw: false,
            showGloss: false,
            onPressed: _onProceedToTripHub,
          ),
        ),

        const SizedBox(height: 12),

        // Subtle guide caption
        Text(
          'Swipe cards to explore all 5 spots',
          style: GoogleFonts.fredoka(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: textMuted.withValues(alpha: 0.80),
          ),
        ),
      ],
    );
  }

  /// Individual slide inside the square carousel
  Widget _buildPlaceCardItem(TravelPlace place, int index, Color sunsetOrange) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Square Image
        Image.asset(
          place.imageAsset,
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

        // Top Scrim Gradient (ensures top badges are easily readable)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 85,
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

        // Bottom Atmospheric Gradient (ensures title & description pop out)
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
                  Colors.black.withValues(alpha: 0.40),
                  Colors.black.withValues(alpha: 0.88),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
        ),

        // Top Badges: Spot Counter + Category Tag
        Positioned(
          top: 14,
          left: 14,
          right: 14,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Spot Number Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.50),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.28),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.place_rounded,
                      size: 12,
                      color: Color(0xFFFFB300),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${index + 1} / ${_travelPlaces.length}',
                      style: GoogleFonts.fredoka(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Category Chip
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: sunsetOrange.withValues(alpha: 0.90),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.20),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    place.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.fredoka(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Bottom Place Details
        Positioned(
          left: 18,
          right: 18,
          bottom: 18,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Location Tag
              Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: Color(0xFFFFB300),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    place.location,
                    style: GoogleFonts.fredoka(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Place Title
              Text(
                place.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.fredoka(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 5),

              // Description
              Text(
                place.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.fredoka(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.85),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Interactive Dot Indicators below the card
  Widget _buildCarouselIndicators(Color sunsetOrange, Color darkBrown) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_travelPlaces.length, (index) {
        final isActive = _currentCardIndex == index;
        return GestureDetector(
          key: ValueKey('carousel_indicator_$index'),
          onTap: () {
            HapticFeedback.selectionClick();
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
            );
          },
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            width: isActive ? 22.0 : 8.0,
            height: 8.0,
            decoration: BoxDecoration(
              color: isActive ? sunsetOrange : const Color(0xFFE4D7CC),
              borderRadius: BorderRadius.circular(4.0),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: sunsetOrange.withValues(alpha: 0.40),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }


  /// Helper to draw a 4-pointed golden sparkle star
  Widget _buildFourPointStar({required double size, required Color color}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _FourPointStarPainter(color: color),
    );
  }
}

/// 4-pointed star painter
class _FourPointStarPainter extends CustomPainter {
  final Color color;

  _FourPointStarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final w = size.width / 2;
    final h = size.height / 2;

    final path = Path()
      ..moveTo(center.dx, center.dy - h)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + w, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + h)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - w, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - h)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Atmospheric Celebration Painter: Falling Sakura Petals, Confetti & Sparkles
class _CelebrationAtmospherePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final confettiColors = [
      const Color(0xFFFF5252).withValues(alpha: 0.65), // Coral Red
      const Color(0xFF4CAF50).withValues(alpha: 0.65), // Mint Green
      const Color(0xFFFFB300).withValues(alpha: 0.70), // Golden Yellow
      const Color(0xFFFF7043).withValues(alpha: 0.65), // Sunset Orange
      const Color(0xFF42A5F5).withValues(alpha: 0.55), // Soft Cyan Blue
      const Color(0xFFEC407A).withValues(alpha: 0.60), // Pink
    ];

    // Floating confetti flakes
    final confettiFlakes = [
      _ConfettiData(Offset(size.width * 0.15, size.height * 0.05), 8, 4, 0.4, confettiColors[0]),
      _ConfettiData(Offset(size.width * 0.25, size.height * 0.06), 7, 5, -0.6, confettiColors[1]),
      _ConfettiData(Offset(size.width * 0.35, size.height * 0.04), 6, 4, 0.8, confettiColors[2]),
      _ConfettiData(Offset(size.width * 0.45, size.height * 0.07), 8, 4, -0.3, confettiColors[3]),
      _ConfettiData(Offset(size.width * 0.68, size.height * 0.04), 6, 5, 0.5, confettiColors[0]),
      _ConfettiData(Offset(size.width * 0.78, size.height * 0.08), 8, 4, 0.2, confettiColors[4]),
      _ConfettiData(Offset(size.width * 0.90, size.height * 0.06), 7, 4, -0.7, confettiColors[1]),
      _ConfettiData(Offset(size.width * 0.08, size.height * 0.11), 6, 5, 0.6, confettiColors[2]),
      _ConfettiData(Offset(size.width * 0.93, size.height * 0.14), 7, 4, -0.4, confettiColors[3]),
      _ConfettiData(Offset(size.width * 0.05, size.height * 0.18), 8, 4, 0.5, confettiColors[5]),
      _ConfettiData(Offset(size.width * 0.88, size.height * 0.19), 6, 4, -0.3, confettiColors[0]),
      _ConfettiData(Offset(size.width * 0.14, size.height * 0.88), 7, 4, 0.4, confettiColors[1]),
      _ConfettiData(Offset(size.width * 0.92, size.height * 0.92), 6, 5, -0.5, confettiColors[2]),
    ];

    for (final flake in confettiFlakes) {
      canvas.save();
      canvas.translate(flake.center.dx, flake.center.dy);
      canvas.rotate(flake.rotation);
      final paint = Paint()
        ..color = flake.color
        ..style = PaintingStyle.fill;
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: flake.width,
        height: flake.height,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(1.5)),
        paint,
      );
      canvas.restore();
    }

    // Floating sakura petals
    final petalPaint = Paint()
      ..color = const Color(0xFFFFB7B2).withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;

    final petals = [
      _PetalData(Offset(size.width * 0.10, size.height * 0.09), 5.5, 0.4),
      _PetalData(Offset(size.width * 0.82, size.height * 0.07), 5.0, -0.5),
      _PetalData(Offset(size.width * 0.74, size.height * 0.12), 4.2, 0.7),
      _PetalData(Offset(size.width * 0.92, size.height * 0.16), 4.8, -0.3),
      _PetalData(Offset(size.width * 0.06, size.height * 0.14), 4.0, 0.6),
    ];

    for (final p in petals) {
      canvas.save();
      canvas.translate(p.center.dx, p.center.dy);
      canvas.rotate(p.rotation);
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: p.radius * 2,
        height: p.radius * 1.3,
      );
      canvas.drawOval(rect, petalPaint);
      canvas.restore();
    }

    // Sparkle diamond stars
    final goldSparklePaint = Paint()
      ..color = const Color(0xFFFFB300).withValues(alpha: 0.60)
      ..style = PaintingStyle.fill;

    final sparkles = [
      Offset(size.width * 0.08, size.height * 0.15),
      Offset(size.width * 0.92, size.height * 0.15),
      Offset(size.width * 0.30, size.height * 0.09),
      Offset(size.width * 0.62, size.height * 0.08),
    ];

    for (final sp in sparkles) {
      _drawDiamondSparkle(canvas, sp, 4.0, goldSparklePaint);
    }
  }

  void _drawDiamondSparkle(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + size * 0.7, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + size)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - size * 0.7, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - size)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ConfettiData {
  final Offset center;
  final double width;
  final double height;
  final double rotation;
  final Color color;

  _ConfettiData(this.center, this.width, this.height, this.rotation, this.color);
}

class _PetalData {
  final Offset center;
  final double radius;
  final double rotation;

  _PetalData(this.center, this.radius, this.rotation);
}
