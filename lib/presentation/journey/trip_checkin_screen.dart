import 'dart:io' as io;
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'tabs/trip_tab.dart';
import 'trip_camera_checkin_screen.dart';
export 'trip_camera_checkin_screen.dart';

/// Camera check-in screen shown after clicking "Start Exploring".
/// Uses mascot_checkin (Trippy in explorer gear with camera) as the full-screen background.
/// Features:
/// - Top header text: "Trippy says", "Let's capture this moment! 📸",
///   "Take a photo to check in at [PlaceName]".
/// - Top-left subtle back/close button.
/// - Bottom camera controls: Flash toggle, circular shutter button, flip camera button.
/// - Camera flash shutter animation and celebratory check-in confirmation.
/// - Option to capture a real photo via device camera or gallery.
class TripCheckinScreen extends StatefulWidget {
  final String placeName;
  final String? location;
  final VoidCallback? onCheckinComplete;
  final String destination;
  final String? tripType;
  final DateTime? startDate;
  final DateTime? endDate;

  const TripCheckinScreen({
    super.key,
    required this.placeName,
    this.location,
    this.onCheckinComplete,
    this.destination = 'Tokyo, Japan',
    this.tripType = 'Group Trip',
    this.startDate,
    this.endDate,
  });

  /// Static helper to launch TripCheckinScreen
  static Future<T?> show<T>(
    BuildContext context, {
    required String placeName,
    String? location,
    bool replaceCurrent = true,
    VoidCallback? onCheckinComplete,
    String destination = 'Tokyo, Japan',
    String? tripType = 'Group Trip',
    DateTime? startDate,
    DateTime? endDate,
  }) {
    HapticFeedback.mediumImpact();
    final route = PageRouteBuilder<T>(
      pageBuilder: (ctx, anim, secAnim) => TripCheckinScreen(
        placeName: placeName,
        location: location,
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
      transitionDuration: const Duration(milliseconds: 320),
    );

    return replaceCurrent
        ? Navigator.of(context).pushReplacement<T, dynamic>(route)
        : Navigator.of(context).push<T>(route);
  }

  @override
  State<TripCheckinScreen> createState() => _TripCheckinScreenState();
}

class _TripCheckinScreenState extends State<TripCheckinScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flipController;
  late final Animation<double> _flipAnimation;

  int _flashModeIndex = 0; // 0: Auto, 1: On, 2: Off
  bool _isShutterPressed = false;
  bool _isFlashing = false;
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

  String get _cleanPlaceName {
    final clean = widget.placeName.replaceAll('!', '').trim();
    if (clean.isNotEmpty) return clean;
    return TripTab.getFirstPlace()?.name ?? 'Meiji Shrine';
  }

  Future<void> _handleShutterSnap() async {
    HapticFeedback.heavyImpact();

    // 1. Shutter camera flash animation
    setState(() => _isFlashing = true);
    await Future.delayed(const Duration(milliseconds: 140));
    if (!mounted) return;
    setState(() => _isFlashing = false);

    // 2. Redirect to TripCameraCheckinScreen with first location image and details
    final firstPlace = TripTab.getFirstPlace();
    final dynamic result = await TripCameraCheckinScreen.show(
      context,
      placeName: _cleanPlaceName,
      location: widget.location ?? firstPlace?.location,
      imageAsset: firstPlace?.imageAsset ?? 'assets/journey/place_meiji_shrine.jpg',
      onCheckinComplete: widget.onCheckinComplete,
      destination: widget.destination,
      tripType: widget.tripType,
      startDate: widget.startDate,
      endDate: widget.endDate,
    );

    if (result == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _pickRealPhoto(ImageSource source) async {
    try {
      final photo = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (photo != null && mounted) {
        setState(() {
          _selectedPhoto = photo;
        });
        Navigator.of(context).pop(); // Close bottom sheet if open
        _showCheckinCelebration(hasCustomPhoto: true);
      }
    } catch (_) {
      // Gracefully ignore camera unavailability on emulators
    }
  }

  void _showCheckinCelebration({bool hasCustomPhoto = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFAF3EB),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x332B1810),
                blurRadius: 24,
                offset: Offset(0, -6),
              ),
            ],
          ),
          padding: EdgeInsets.only(
            top: 14,
            left: 22,
            right: 22,
            bottom: MediaQuery.of(modalContext).padding.bottom + 22,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top drag pill handle
              Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6C6B6),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 18),

              // Celebratory Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1EB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFFFCCB7),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        size: 17, color: Color(0xFFE24A08)),
                    const SizedBox(width: 6),
                    Text(
                      'Check-in Complete! 🎉',
                      style: GoogleFonts.fredoka(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE24A08),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Title
              Text(
                'Moment Captured! 📸✨',
                textAlign: TextAlign.center,
                style: GoogleFonts.fredoka(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2B1810),
                  letterSpacing: -0.2,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'You\'ve checked in at $_cleanPlaceName',
                textAlign: TextAlign.center,
                style: GoogleFonts.fredoka(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6E584D),
                ),
              ),

              if (_selectedPhoto != null && !kIsWeb) ...[
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    io.File(_selectedPhoto!.path),
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],

              const SizedBox(height: 18),

              // Trippy Mascot commentary card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFEFE5DA),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E1C14).withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Cute avatar badge
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFE8D6),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '🦊',
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Trippy says:',
                            style: GoogleFonts.fredoka(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFC4511D),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Awesome shot! Memory stamp added to your trip log. You earned +50 Explorer XP!',
                            style: GoogleFonts.fredoka(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF38271F),
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Primary Action: Return to Trip
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
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
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.of(modalContext).pop(); // dismiss sheet
                    Navigator.of(context).pop(); // dismiss checkin screen back to trip
                    widget.onCheckinComplete?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: Text(
                    'Continue Exploring',
                    style: GoogleFonts.fredoka(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Optional real camera action
              TextButton.icon(
                onPressed: () {
                  _pickRealPhoto(ImageSource.camera);
                },
                icon: const Icon(Icons.camera_alt_outlined,
                    size: 18, color: Color(0xFF8C5335)),
                label: Text(
                  'Take Another Photo with Camera',
                  style: GoogleFonts.fredoka(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8C5335),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF281812),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Full-screen mascot_checkin background
          Image.asset(
            'assets/journey/mascot_checkin.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (ctx, err, st) {
              return Container(
                color: const Color(0xFFF7ECE4),
                child: const Center(
                  child: Icon(Icons.camera_alt, size: 64, color: Color(0xFFE24A08)),
                ),
              );
            },
          ),

          // 2. Soft top scrim so text is readable over sky
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topPadding + 220,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.40),
                    Colors.white.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // 3. Top Header Text Section (matching reference screenshot)
          Positioned(
            top: topPadding + 14,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // "Trippy says"
                Text(
                  'Trippy says',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFC4511D),
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 5),

                // "Let's capture this moment! 📸"
                Text(
                  "Let's capture\nthis moment! 📸",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF281812),
                    height: 1.16,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),

                // "Take a photo to check in at"
                Text(
                  'Take a photo to check in at',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6E584D),
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 3),

                // "[Location Name]" (e.g. Meiji Shrine / Senso-ji Temple)
                Text(
                  _cleanPlaceName,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE24A08),
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),

          // 4. Subtle Top-Left Back Button
          Positioned(
            top: topPadding + 10,
            left: 16,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.65),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 17,
                      color: Color(0xFF38271F),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 5. Bottom Camera Controls (Flash, Shutter Button, Flip Camera)
          Positioned(
            bottom: bottomPadding + 26,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Flash Toggle
                _buildFlashButton(),

                const SizedBox(width: 44),

                // Large Circular Shutter Button
                _buildShutterButton(),

                const SizedBox(width: 44),

                // Camera Flip
                _buildFlipButton(),
              ],
            ),
          ),

          // 6. Shutter Camera White Flash Overlay Effect
          IgnorePointer(
            ignoring: !_isFlashing,
            child: AnimatedOpacity(
              opacity: _isFlashing ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              child: Container(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Flash mode toggle button
  Widget _buildFlashButton() {
    final icons = [
      Icons.bolt_rounded,
      Icons.flash_on_rounded,
      Icons.flash_off_rounded,
    ];
    final labels = ['Auto', 'On', 'Off'];

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _flashModeIndex = (_flashModeIndex + 1) % 3;
        });
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Flash: ${labels[_flashModeIndex]}',
              style: GoogleFonts.fredoka(fontWeight: FontWeight.w600),
            ),
            duration: const Duration(milliseconds: 700),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: const Color(0xFF281812).withValues(alpha: 0.85),
          ),
        );
      },
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(
          icons[_flashModeIndex],
          color: Colors.white,
          size: 26,
          shadows: const [
            Shadow(
              color: Colors.black45,
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }

  /// Rotating camera switch / flip button
  Widget _buildFlipButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _flipController.forward(from: 0.0);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Switched camera',
              style: GoogleFonts.fredoka(fontWeight: FontWeight.w600),
            ),
            duration: const Duration(milliseconds: 700),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: const Color(0xFF281812).withValues(alpha: 0.85),
          ),
        );
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
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Icon(
            Icons.flip_camera_ios_rounded,
            color: Colors.white,
            size: 25,
            shadows: [
              Shadow(
                color: Colors.black45,
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shutter Button: thick light-cream outer ring + vibrant orange inner button
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
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFF7EFE8).withValues(alpha: 0.90),
              width: 4.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.30),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 64,
              height: 64,
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
