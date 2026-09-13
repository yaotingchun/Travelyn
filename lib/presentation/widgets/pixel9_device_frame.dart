import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A realistic Google Pixel 9 frame for web and desktop viewports.
/// On mobile screen widths, it renders fullscreen without the frame.
class Pixel9DeviceFrame extends StatelessWidget {
  final Widget child;
  final bool enableFrame;
  final double screenWidth;
  final double screenHeight;
  final double bezelThickness;
  final double frameRadius;
  final double screenRadius;
  final double statusBarHeight;
  final double navBarHeight;

  const Pixel9DeviceFrame({
    super.key,
    required this.child,
    this.enableFrame = true,
    this.screenWidth = 420.0,
    this.screenHeight = 915.0,
    this.bezelThickness = 10.0,
    this.frameRadius = 48.0,
    this.screenRadius = 38.0,
    this.statusBarHeight = 28.0,
    this.navBarHeight = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // If on small mobile screen or frame is disabled, render native full screen
        final isWideScreen = constraints.maxWidth > (screenWidth + 30) &&
            constraints.maxHeight > 500;

        if (!enableFrame || !isWideScreen) {
          return child;
        }

        final totalFrameHeight = screenHeight + (bezelThickness * 2);
        final totalFrameWidth = screenWidth + (bezelThickness * 2);

        return Scaffold(
          backgroundColor: const Color(0xFF141210),
          body: Stack(
            children: [
              // Ambient gradient backdrop
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.15,
                      colors: [
                        Color(0xFF28221D),
                        Color(0xFF181412),
                        Color(0xFF0C0B0A),
                      ],
                    ),
                  ),
                ),
              ),

              // Centered Google Pixel 9 Phone Frame (Clean, unclipped, entire phone in view)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: totalFrameWidth,
                      height: totalFrameHeight,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                        // Hardware Buttons (Right edge: Power & Volume)
                        // Power Button (Pixel 9 style: above volume rocker)
                        Positioned(
                          right: -3.5,
                          top: 195,
                          child: Container(
                            width: 4.5,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFF383533),
                              borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(3),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  blurRadius: 2,
                                  offset: const Offset(1, 0),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Volume Rocker
                        Positioned(
                          right: -3.5,
                          top: 255,
                          child: Container(
                            width: 4.5,
                            height: 88,
                            decoration: BoxDecoration(
                              color: const Color(0xFF383533),
                              borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(3),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  blurRadius: 2,
                                  offset: const Offset(1, 0),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Outer Aluminum / Satin Chassis
                        Container(
                          width: totalFrameWidth,
                          height: totalFrameHeight,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF3E3A37),
                                Color(0xFF262321),
                                Color(0xFF1B1918),
                                Color(0xFF2B2825),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(frameRadius),
                            border: Border.all(
                              color: const Color(0xFF4C4743),
                              width: 1.2,
                            ),
                            boxShadow: [
                              // Deep multi-layered ambient shadows
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.55),
                                blurRadius: 45,
                                spreadRadius: 4,
                                offset: const Offset(0, 22),
                              ),
                              BoxShadow(
                                color: const Color(0xFFE65100).withValues(alpha: 0.08),
                                blurRadius: 60,
                                spreadRadius: -10,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(bezelThickness),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(screenRadius),
                              border: Border.all(
                                color: const Color(0xFF121110),
                                width: 1.0,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(screenRadius - 1),
                              child: Stack(
                                children: [
                                  // App Screen Content with safe area adjustments
                                  Positioned.fill(
                                    child: MediaQuery(
                                      data: MediaQuery.of(context).copyWith(
                                        size: Size(screenWidth, screenHeight),
                                        padding: EdgeInsets.only(
                                          top: statusBarHeight,
                                          bottom: navBarHeight,
                                        ),
                                        viewPadding: EdgeInsets.only(
                                          top: statusBarHeight,
                                          bottom: navBarHeight,
                                        ),
                                      ),
                                      child: child,
                                    ),
                                  ),

                                  // Android Pixel 9 Status Bar Overlay
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    height: statusBarHeight,
                                    child: IgnorePointer(
                                      child: _buildPixel9StatusBar(),
                                    ),
                                  ),

                                  // Android Gesture Navigation Pill Overlay
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    height: navBarHeight,
                                    child: IgnorePointer(
                                      child: Center(
                                        child: Container(
                                          width: 120,
                                          height: 4.0,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2E1C14).withValues(alpha: 0.45),
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Top Earpiece Speaker Slit (Pixel 9 style)
                        Positioned(
                          top: 3.5,
                          child: Container(
                            width: 48,
                            height: 3.0,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1C1A18),
                              borderRadius: BorderRadius.circular(2),
                              border: Border.all(
                                color: const Color(0xFF33302D),
                                width: 0.5,
                              ),
                            ),
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
      );
      },
    );
  }

  /// Pixel 9 Status Bar with Centered Punch Hole Camera & Android Icons
  Widget _buildPixel9StatusBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Left: Clock & Android Status Icons (4:27, G, Shield)
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "4:27",
                  style: GoogleFonts.fredoka(
                    color: const Color(0xFF1F1C1A),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(width: 6),
                // Google "G" logo
                Container(
                  width: 13,
                  height: 13,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1F1C1A),
                  ),
                  child: Center(
                    child: Text(
                      "G",
                      style: GoogleFonts.fredoka(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.shield_outlined,
                  size: 13,
                  color: Color(0xFF1F1C1A),
                ),
              ],
            ),
          ),

          // Center: Pixel 9 Front Camera Punch Hole (14px circle with lens reflection)
          Center(
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF080808),
                border: Border.all(
                  color: const Color(0xFF202020),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 3,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1B2B38),
                  ),
                ),
              ),
            ),
          ),

          // Right: Cellular Signal Bars, Wi-Fi, and Battery
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.signal_cellular_alt_rounded,
                  size: 14,
                  color: Color(0xFF1F1C1A),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.wifi_rounded,
                  size: 14,
                  color: Color(0xFF1F1C1A),
                ),
                const SizedBox(width: 4),
                // Battery Icon with fill
                Container(
                  width: 20,
                  height: 10.5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: const Color(0xFF1F1C1A),
                      width: 1.2,
                    ),
                  ),
                  padding: const EdgeInsets.all(1.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F1C1A),
                            borderRadius: BorderRadius.circular(1.2),
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
    );
  }
}
