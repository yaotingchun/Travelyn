import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// An illustrated, interactive action button displaying "Let's Go!"
/// embedded inside Travelyn's voting prompt message.
///
/// Features warm sunset terracotta gradient, top-edge glass highlight,
/// circular icon badge, "Vote on trip vibes" subtitle, and spring physics.
class TripLetsGoButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final String subtitle;

  const TripLetsGoButton({
    super.key,
    required this.onPressed,
    this.label = "Let's Go!",
    this.subtitle = "Vote on trip vibes",
  });

  @override
  State<TripLetsGoButton> createState() => _TripLetsGoButtonState();
}

class _TripLetsGoButtonState extends State<TripLetsGoButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onPressed();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFE85A1C),
                Color(0xFFF2742E),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.30),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE85A1C).withValues(alpha: 0.36),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: const Color(0xFF2E1C14).withValues(alpha: 0.08),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left circular badge with voting/sparkle icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E1C14).withValues(alpha: 0.12),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.how_to_vote_rounded,
                    size: 17,
                    color: Color(0xFFE65100),
                  ),
                ),
              ),

              const SizedBox(width: 11),

              // Title & Subtitle column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.label,
                          style: GoogleFonts.fredoka(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.auto_awesome_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      widget.subtitle,
                      style: GoogleFonts.fredoka(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.90),
                      ),
                    ),
                  ],
                ),
              ),

              // Right arrow badge
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
