import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'trip_arrival_screen.dart';

/// Screen displayed after submitting feedback for the departed stop.
/// Follows the TripArrivalScreen layout structure:
/// - Full-bleed soft warm cream gradient background
/// - Centered layout with generous breathing room
/// - Header: Close '✕' on top-left, "Your next location:\n[Next Location Name]!"
/// - Location Square Card: 1:1 Aspect Ratio (maxWidth: 350) with photography, top badges, and details
/// - Proximity info: "It's just a xxx-min away,\nReady to Explore?"
/// - Bottom buttons: "Yes, let's go! 🏃" pill button (maxWidth: 360, height: 54) & "Not now"
class TripNextLocationScreen extends StatelessWidget {
  final String placeName;
  final String? location;
  final String? imageAsset;
  final String? walkTime;
  final String? category;
  final String? description;
  final int? stopNumber;
  final VoidCallback? onLetsGo;
  final VoidCallback? onNotNow;

  const TripNextLocationScreen({
    super.key,
    required this.placeName,
    this.location,
    this.imageAsset,
    this.walkTime,
    this.category,
    this.description,
    this.stopNumber,
    this.onLetsGo,
    this.onNotNow,
  });

  /// Presents the TripNextLocationScreen with a smooth fade & slide transition.
  static Future<bool?> show(
    BuildContext context, {
    required String placeName,
    String? location,
    String? imageAsset,
    String? walkTime,
    String? category,
    String? description,
    int? stopNumber,
    VoidCallback? onLetsGo,
    VoidCallback? onNotNow,
  }) {
    HapticFeedback.mediumImpact();
    return Navigator.of(context).push<bool>(
      PageRouteBuilder<bool>(
        pageBuilder: (ctx, anim, secAnim) => TripNextLocationScreen(
          placeName: placeName,
          location: location,
          imageAsset: imageAsset,
          walkTime: walkTime,
          category: category,
          description: description,
          stopNumber: stopNumber,
          onLetsGo: onLetsGo,
          onNotNow: onNotNow,
        ),
        transitionsBuilder: (ctx, anim, secAnim, child) {
          final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.06),
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

  String get _formattedPlaceName {
    final clean = placeName.replaceAll('!', '').trim();
    return '$clean!';
  }

  String get _cleanPlaceName {
    return placeName.replaceAll('!', '').trim();
  }

  String get _effectiveLocation {
    return location ?? TripArrivalScreen.getLocationForPlace(placeName);
  }

  String get _effectiveCategory {
    return category ?? TripArrivalScreen.getCategoryForPlace(placeName);
  }

  String get _effectiveImageAsset {
    return imageAsset ?? TripArrivalScreen.getImageForPlace(placeName);
  }

  String get _effectiveDescription {
    return description ?? TripArrivalScreen.getDescriptionForPlace(placeName);
  }

  String get _transitSubtitle {
    final wt = (walkTime ?? '10 min').trim();
    final lower = wt.toLowerCase();
    if (lower.contains('walk') || lower.contains('metro') || lower.contains('train') || lower.contains('bus') || lower.contains('drive')) {
      return "It's just a $wt away,";
    }
    return "It's just a $wt walk away,";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EF),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF7EF),
              Color(0xFFFCF2E9),
              Color(0xFFF5EBE0),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Center content container following TripArrivalScreen layout structure
            Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),

                    // 1. Header (Subtitle + Main Title)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Your next location:',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.fredoka(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF38271F),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            _formattedPlaceName,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.fredoka(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF26160F),
                              height: 1.18,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // 2. Location Square Card (1:1 Aspect Ratio, maxWidth: 350)
                    _buildLocationSquareCard(),

                    const SizedBox(height: 24),

                    // 3. Proximity text & Ready to Explore?
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _transitSubtitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.fredoka(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF5E493E),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Ready to Explore?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.fredoka(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF26160F),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // 4. "Yes, let's go! 🏃" Primary Button (maxWidth: 360, height: 54)
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
                          onLetsGo?.call();
                          Navigator.of(context).pop(true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27),
                          ),
                        ),
                        child: Text(
                          "Yes, let's go! 🏃",
                          style: GoogleFonts.fredoka(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 5. "Not now" Secondary Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onNotNow?.call();
                          Navigator.of(context).pop(false);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            'Not now',
                            style: GoogleFonts.fredoka(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF4A382F),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // Top-left Close '✕' Button overlay (in SafeArea, identical to TripArrivalScreen)
            Positioned(
              top: 6,
              left: 10,
              child: SafeArea(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onNotNow?.call();
                      Navigator.of(context).pop(false);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 22,
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

  /// 1:1 Aspect Ratio Location Square Card (identical to TripArrivalScreen's _buildLocationCard)
  Widget _buildLocationSquareCard() {
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
                  _effectiveImageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, st) {
                    return Container(
                      color: const Color(0xFF2E1C14),
                      child: const Center(
                        child: Icon(
                          Icons.landscape_rounded,
                          color: Colors.white54,
                          size: 44,
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

                // Top Badges: Spot Badge + Category Chip
                Positioned(
                  top: 14,
                  left: 14,
                  right: 14,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Next Stop Badge
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
                              stopNumber != null ? 'Stop $stopNumber' : 'Next Stop',
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
                            _effectiveCategory,
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

                // Bottom Place Details: Location Pin & Place Name
                Positioned(
                  left: 18,
                  right: 18,
                  bottom: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Location Pin & District
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: Color(0xFFFFB300),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _effectiveLocation,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.fredoka(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFFFE0B2),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Place Name
                      Text(
                        _cleanPlaceName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.fredoka(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.1,
                        ),
                      ),

                      if (_effectiveDescription.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          _effectiveDescription,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.fredoka(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.85),
                            height: 1.25,
                          ),
                        ),
                      ],
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
