import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// An illustrated, interactive travel pill button displaying "We're All Set!"
/// featuring Trippy the mascot, warm parchment tones, and smooth spring physics.
///
/// Blends naturally with the Japanese clipboard and traveler's journal aesthetic.
class TripAllSetButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;

  const TripAllSetButton({
    super.key,
    required this.onPressed,
    this.label = "We're All Set!",
  });

  @override
  State<TripAllSetButton> createState() => _TripAllSetButtonState();
}

class _TripAllSetButtonState extends State<TripAllSetButton> {
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
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          padding: const EdgeInsets.fromLTRB(6, 6, 8, 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFFFDF9),
                Color(0xFFFFF3E7),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: const Color(0xFFE89A60).withValues(alpha: 0.45),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E1C14).withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: const Color(0xFFE65100).withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mascot badge (Trippy the fox adventurer)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFCEDE0),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE65100).withValues(alpha: 0.40),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE65100).withValues(alpha: 0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 1.5),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/mascot/avatar.png',
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, st) => const Center(
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        size: 16,
                        color: Color(0xFFE65100),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 9),

              // Button Label + Celebration Sparkle
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.label,
                    style: GoogleFonts.fredoka(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2E1C14),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.auto_awesome_rounded,
                    size: 14,
                    color: Color(0xFFE65100),
                  ),
                ],
              ),

              const SizedBox(width: 9),

              // Forward action circle badge
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE85A1C), Color(0xFFF2742E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE85A1C).withValues(alpha: 0.35),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
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
