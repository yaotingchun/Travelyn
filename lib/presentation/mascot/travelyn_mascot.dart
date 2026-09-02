import 'package:flutter/material.dart';

/// The animated mascot for Travelyn.
///
/// Features:
/// - 5 cleanly segmented transparent PNG layers assembled via [Stack]:
///   1. `backpack.png` (Backpack, bedroll & straps)
///   2. `body.png` (Torso, white belly, tail, legs, feet & left arm)
///   3. `accessories.png` (Orange knit scarf, camera & adventure map)
///   4. `head.png` (Safari hat, goggles, fox ears & winking smile)
///   5. `arm.png` (Raised waving paw with pads)
/// - Ultra-smooth continuous harmonic arm waving with zero body bounce.
/// - Configurable [isWaving] flag (if false, the arm remains at rest).
class TravelynMascot extends StatefulWidget {
  final double? width;
  final double? height;
  final bool isWaving;

  const TravelynMascot({
    super.key,
    this.width = 240,
    this.height = 288,
    this.isWaving = true,
  });

  @override
  State<TravelynMascot> createState() => _TravelynMascotState();
}

class _TravelynMascotState extends State<TravelynMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;
  late final Animation<double> _armWaveAnimation;

  // Shoulder pivot point normalized in the 520x624 canvas coordinate space:
  // X = 395 / 520 ≈ 0.7596, Y = 338 / 624 ≈ 0.5417
  static const FractionalOffset _shoulderPivot =
      FractionalOffset(0.7596, 0.5417);

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    _armWaveAnimation = Tween<double>(
      begin: -0.12, // ~ -7 degrees
      end: 0.18,   // ~ +10.3 degrees
    ).animate(
      CurvedAnimation(
        parent: _waveController,
        curve: Curves.easeInOutSine,
      ),
    );

    if (widget.isWaving) {
      _waveController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant TravelynMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isWaving != oldWidget.isWaving) {
      if (widget.isWaving) {
        _waveController.repeat(reverse: true);
      } else {
        _waveController.stop();
        _waveController.animateTo(0.0);
      }
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Soft Ground Contact Shadow (static, grounded)
          Positioned(
            bottom: (widget.height ?? 288) * 0.02,
            child: Container(
              width: (widget.width ?? 240) * 0.52,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5D4037).withValues(alpha: 0.16),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),

          // Mascot Stack (Static body, only the arm waves if isWaving is true)
          AspectRatio(
            aspectRatio: 520 / 624,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Layer 1: Backpack (Behind body)
                Image.asset(
                  'assets/mascot/backpack.png',
                  fit: BoxFit.contain,
                ),

                // Layer 2: Body (Torso, white belly, legs, tail, left arm)
                Image.asset(
                  'assets/mascot/body.png',
                  fit: BoxFit.contain,
                ),

                // Layer 3: Accessories (Scarf, camera, adventure map)
                Image.asset(
                  'assets/mascot/accessories.png',
                  fit: BoxFit.contain,
                ),

                // Layer 4: Head (Safari hat, goggles, fox ears, winking smile)
                Image.asset(
                  'assets/mascot/head.png',
                  fit: BoxFit.contain,
                ),

                // Layer 5: Arm (Waving when isWaving is true, static when false)
                AnimatedBuilder(
                  animation: _armWaveAnimation,
                  builder: (context, child) {
                    final angle = widget.isWaving ? _armWaveAnimation.value : 0.0;
                    return Transform.rotate(
                      alignment: _shoulderPivot,
                      angle: angle,
                      child: child,
                    );
                  },
                  child: Image.asset(
                    'assets/mascot/arm.png',
                    fit: BoxFit.contain,
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
