import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'tabs/trip_tab.dart';
import 'trip_photo_checkin_success_screen.dart';
export 'trip_photo_checkin_success_screen.dart';

/// Live Camera Viewfinder screen for checking in at a location.
/// Matches the reference design:
/// - Top-left: Circular "X" close button
/// - Top-center: Location badge pill with thumbnail + location name (e.g. "Meiji Shrine")
/// - Viewfinder: Full view of the first location with camera focus reticle + Trippy sticker
/// - Bottom bar:
///   - "Photo" / "Video" mode switcher
///   - Gallery thumbnail preview on left
///   - Large circular shutter button in center
///   - Camera flip icon on right
/// - Interactive snap animation with celebratory check-in confirmation
class TripCameraCheckinScreen extends StatefulWidget {
  final String placeName;
  final String? location;
  final String? imageAsset;
  final VoidCallback? onCheckinComplete;
  final String destination;
  final String? tripType;
  final DateTime? startDate;
  final DateTime? endDate;

  const TripCameraCheckinScreen({
    super.key,
    required this.placeName,
    this.location,
    this.imageAsset,
    this.onCheckinComplete,
    this.destination = 'Tokyo, Japan',
    this.tripType = 'Group Trip',
    this.startDate,
    this.endDate,
  });

  /// Static helper to navigate to TripCameraCheckinScreen
  static Future<T?> show<T>(
    BuildContext context, {
    required String placeName,
    String? location,
    String? imageAsset,
    VoidCallback? onCheckinComplete,
    String destination = 'Tokyo, Japan',
    String? tripType = 'Group Trip',
    DateTime? startDate,
    DateTime? endDate,
  }) {
    HapticFeedback.mediumImpact();
    return Navigator.of(context).push<T>(
      PageRouteBuilder<T>(
        pageBuilder: (ctx, anim, secAnim) => TripCameraCheckinScreen(
          placeName: placeName,
          location: location,
          imageAsset: imageAsset,
          onCheckinComplete: onCheckinComplete,
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
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
  }

  @override
  State<TripCameraCheckinScreen> createState() => _TripCameraCheckinScreenState();
}

class _TripCameraCheckinScreenState extends State<TripCameraCheckinScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flipController;
  late final Animation<double> _flipAnimation;

  bool _isShutterPressed = false;
  bool _isFlashing = false;
  bool _isVideoMode = false;
  XFile? _selectedPhoto;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnimation = CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOutBack,
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  String get _effectivePlaceName {
    final clean = widget.placeName.replaceAll('!', '').trim();
    if (clean.isNotEmpty) return clean;
    final first = TripTab.getFirstPlace();
    return first?.name ?? 'Meiji Shrine';
  }

  String get _effectiveImageAsset {
    if (widget.imageAsset != null && widget.imageAsset!.isNotEmpty) {
      return widget.imageAsset!;
    }
    final first = TripTab.getFirstPlace();
    if (first?.imageAsset != null && first!.imageAsset.isNotEmpty) {
      return first.imageAsset;
    }
    return 'assets/journey/place_meiji_shrine.jpg';
  }

  Future<void> _handleShutterSnap() async {
    HapticFeedback.heavyImpact();

    // 1. Shutter camera white flash animation
    setState(() => _isFlashing = true);
    await Future.delayed(const Duration(milliseconds: 140));
    if (!mounted) return;
    setState(() => _isFlashing = false);

    // 2. Redirect to Polaroid check-in success screen
    TripPhotoCheckinSuccessScreen.show(
      context,
      placeName: _effectivePlaceName,
      location: widget.location,
      imageAsset: _effectiveImageAsset,
      customPhoto: _selectedPhoto,
      checkinTime: DateTime.now(),
      onContinue: widget.onCheckinComplete,
      destination: widget.destination,
      tripType: widget.tripType,
      startDate: widget.startDate,
      endDate: widget.endDate,
      replaceCurrent: true,
    );
  }

  Future<void> _pickFromGallery() async {
    try {
      final photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (photo != null && mounted) {
        setState(() => _selectedPhoto = photo);
        TripPhotoCheckinSuccessScreen.show(
          context,
          placeName: _effectivePlaceName,
          location: widget.location,
          imageAsset: _effectiveImageAsset,
          customPhoto: photo,
          checkinTime: DateTime.now(),
          onContinue: widget.onCheckinComplete,
          destination: widget.destination,
          tripType: widget.tripType,
          startDate: widget.startDate,
          endDate: widget.endDate,
          replaceCurrent: true,
        );
      }
    } catch (_) {}
  }



  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final placeTitle = _effectivePlaceName;
    final imagePath = _effectiveImageAsset;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Viewfinder image + Black bottom panel column
          Column(
            children: [
              // Viewfinder Photo
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Location Photography
                    Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      errorBuilder: (ctx, err, st) {
                        return Container(
                          color: const Color(0xFF1E140F),
                          child: const Center(
                            child: Icon(Icons.image, size: 64, color: Colors.white38),
                          ),
                        );
                      },
                    ),

                    // Center camera focus brackets reticle
                    Center(
                      child: SizedBox(
                        width: 90,
                        height: 90,
                        child: CustomPaint(
                          painter: const _CameraFocusReticlePainter(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Black bottom camera controls panel
              Container(
                color: Colors.black,
                padding: EdgeInsets.only(
                  top: 14,
                  bottom: bottomPadding > 0 ? bottomPadding + 8 : 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mode Switcher: Photo / Video
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Photo mode
                        GestureDetector(
                          onTap: () {
                            if (_isVideoMode) {
                              HapticFeedback.selectionClick();
                              setState(() => _isVideoMode = false);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: !_isVideoMode
                                  ? const Color(0xFF2E1C14)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Text(
                              'Photo',
                              style: GoogleFonts.fredoka(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: !_isVideoMode
                                    ? const Color(0xFFFFF9F3)
                                    : Colors.white60,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Video mode
                        GestureDetector(
                          onTap: () {
                            if (!_isVideoMode) {
                              HapticFeedback.selectionClick();
                              setState(() => _isVideoMode = true);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _isVideoMode
                                  ? const Color(0xFF2E1C14)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Text(
                              'Video',
                              style: GoogleFonts.fredoka(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: _isVideoMode
                                    ? const Color(0xFFFFF9F3)
                                    : Colors.white60,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Controls Row: Gallery thumbnail, Shutter Button, Flip Camera
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Gallery Thumbnail on left
                          GestureDetector(
                            onTap: _pickFromGallery,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.65),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  imagePath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: const Color(0xFF2E1C14),
                                    child: const Icon(Icons.photo_library_rounded,
                                        color: Colors.white70, size: 24),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Large Circular Shutter Button
                          _buildShutterButton(),

                          // Camera Flip Button on right
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              _flipController.forward(from: 0.0);
                            },
                            child: AnimatedBuilder(
                              animation: _flipAnimation,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _flipAnimation.value * math.pi,
                                  child: child,
                                );
                              },
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.15),
                                ),
                                child: const Icon(
                                  Icons.sync_rounded,
                                  color: Colors.white,
                                  size: 28,
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
            ],
          ),

          // 3. Top Header Bar: Close "X" button + Location Chip Pill
          Positioned(
            top: topPadding + 10,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Circular "X" close button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF3EB).withValues(alpha: 0.90),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.20),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.close_rounded,
                        size: 21,
                        color: Color(0xFF281812),
                      ),
                    ),
                  ),
                ),

                // Center Location Pill (e.g. Meiji Shrine)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF3EB).withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: const Color(0xFFEFE5DA),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // Thumbnail
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Image.asset(
                            imagePath,
                            width: 22,
                            height: 22,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox(
                              width: 22,
                              height: 22,
                              child: Icon(Icons.place_rounded,
                                  size: 14, color: Color(0xFFE24A08)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Location Title
                        Flexible(
                          child: Text(
                            placeTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.fredoka(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF281812),
                              letterSpacing: -0.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Balanced spacer
                const SizedBox(width: 40),
              ],
            ),
          ),

          // 4. White Flash Overlay on Shutter Press
          IgnorePointer(
            ignoring: !_isFlashing,
            child: AnimatedOpacity(
              opacity: _isFlashing ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOut,
              child: Container(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Shutter Button: thick white outer ring + vibrant orange circular inner button
  Widget _buildShutterButton() {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isShutterPressed = true);
      },
      onTapUp: (_) {
        setState(() => _isShutterPressed = false);
        _handleShutterSnap();
      },
      onTapCancel: () {
        setState(() => _isShutterPressed = false);
      },
      child: AnimatedScale(
        scale: _isShutterPressed ? 0.91 : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 4.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 63,
              height: 63,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF3632B),
                    Color(0xFFE24A08),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE24A08).withValues(alpha: 0.45),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for the camera focus reticle corner brackets
class _CameraFocusReticlePainter extends CustomPainter {
  final Color color;
  const _CameraFocusReticlePainter({this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    const corner = 18.0;

    // Top-left
    canvas.drawLine(const Offset(0, 0), const Offset(corner, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, corner), paint);

    // Top-right
    canvas.drawLine(Offset(w, 0), Offset(w - corner, 0), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, corner), paint);

    // Bottom-left
    canvas.drawLine(Offset(0, h), Offset(corner, h), paint);
    canvas.drawLine(Offset(0, h), Offset(0, h - corner), paint);

    // Bottom-right
    canvas.drawLine(Offset(w, h), Offset(w - corner, h), paint);
    canvas.drawLine(Offset(w, h), Offset(w, h - corner), paint);

    // Center crosshair subtle dot
    canvas.drawCircle(Offset(w / 2, h / 2), 2.0, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
