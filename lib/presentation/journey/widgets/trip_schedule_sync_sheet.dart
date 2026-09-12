import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Floating popout modal dialog for "Quick Sync" - Real-time Schedule Realignment
class TripScheduleSyncSheet extends StatelessWidget {
  final VoidCallback onApply;
  final VoidCallback onDecline;

  const TripScheduleSyncSheet({
    super.key,
    required this.onApply,
    required this.onDecline,
  });

  static Future<bool?> show(
    BuildContext context, {
    VoidCallback? onApply,
    VoidCallback? onDecline,
  }) async {
    HapticFeedback.mediumImpact();
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.50),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (ctx, anim1, anim2) {
        return TripScheduleSyncSheet(
          onApply: () {
            Navigator.of(ctx).pop(true);
          },
          onDecline: () {
            Navigator.of(ctx).pop(false);
          },
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curved = CurvedAnimation(
          parent: anim1,
          curve: Curves.easeOutBack,
        );
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 6 * anim1.value,
            sigmaY: 6 * anim1.value,
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.88, end: 1.0).animate(curved),
            child: FadeTransition(
              opacity: anim1,
              child: child,
            ),
          ),
        );
      },
    );

    if (result == true) {
      onApply?.call();
    } else if (result == false) {
      onDecline?.call();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    const darkBrown = Color(0xFF2E1C14);
    const brandOrange = Color(0xFFE65100);
    const textMuted = Color(0xFF6B5A50);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width.clamp(320.0, 365.0),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF7),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFFEDE3D7),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: darkBrown.withValues(alpha: 0.22),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: brandOrange.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top Mascot Avatar with Glow
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFB74D), Color(0xFFE65100)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: brandOrange.withValues(alpha: 0.30),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(2.5),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFFF7ED),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          'assets/mascot/avatar.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(
                              Icons.pets_rounded,
                              size: 28,
                              color: brandOrange,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Badge: QUICK SYNC
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFFB74D).withValues(alpha: 0.8),
                          width: 0.9,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            size: 13,
                            color: brandOrange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'QUICK SYNC',
                            style: GoogleFonts.fredoka(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                              color: brandOrange,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Title
                    Text(
                      'Running ~25m Behind',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fredoka(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: darkBrown,
                        letterSpacing: -0.2,
                      ),
                    ),

                    const SizedBox(height: 5),

                    // Subtitle Narrative
                    Text(
                      "Light rain started around Harajuku 🌧️\nI've smart-adjusted your morning timeline so all highlights remain smooth and on track ✨",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fredoka(
                        fontSize: 12.8,
                        fontWeight: FontWeight.w400,
                        color: textMuted,
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // 3 Live Context Chips
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildChip(
                          icon: Icons.hourglass_bottom_rounded,
                          label: '+25m spent',
                          bgColor: const Color(0xFFFFF3E0),
                          borderColor: const Color(0xFFFFE0B2),
                          textColor: const Color(0xFFC43800),
                          iconColor: const Color(0xFFE65100),
                        ),
                        const SizedBox(width: 6),
                        _buildChip(
                          icon: Icons.umbrella_rounded,
                          label: '19°C Rain',
                          bgColor: const Color(0xFFEFF6FF),
                          borderColor: const Color(0xFFDBEAFE),
                          textColor: const Color(0xFF1D4ED8),
                          iconColor: const Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 6),
                        _buildChip(
                          icon: Icons.check_circle_rounded,
                          label: 'Sky Safe',
                          bgColor: const Color(0xFFECFDF5),
                          borderColor: const Color(0xFFD1FAE5),
                          textColor: const Color(0xFF047857),
                          iconColor: const Color(0xFF059669),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Sleek Timeline Stepper Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF8F2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFEFE5DA),
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTimelineStep(
                            icon: '⛩️',
                            title: 'Meiji Jingu Shrine',
                            timeText: '09:25 - 10:50 (+25m buffer absorbed)',
                            isHighlight: true,
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: SizedBox(
                              height: 10,
                              child: VerticalDivider(
                                color: Color(0xFFD8CCC0),
                                thickness: 1.2,
                              ),
                            ),
                          ),
                          _buildTimelineStep(
                            icon: '🚶',
                            title: 'Takeshita Street Stroll',
                            timeText: '11:00 - 11:45 (Covered route)',
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: SizedBox(
                              height: 10,
                              child: VerticalDivider(
                                color: Color(0xFFD8CCC0),
                                thickness: 1.2,
                              ),
                            ),
                          ),
                          _buildTimelineStep(
                            icon: '🍜',
                            title: 'AFURI Harajuku Ramen',
                            timeText: '12:00 - 12:45 (Lunch on track)',
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: SizedBox(
                              height: 10,
                              child: VerticalDivider(
                                color: Color(0xFFD8CCC0),
                                thickness: 1.2,
                              ),
                            ),
                          ),
                          _buildTimelineStep(
                            icon: '🏙️',
                            title: 'Shibuya Sky Observatory',
                            timeText: '13:00 (100% On Schedule ✨)',
                            isLast: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Action Buttons (Full width primary & subtle secondary)
                    Column(
                      children: [
                        // Primary: Apply Adjustment
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            onPressed: onApply,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE65100),
                              foregroundColor: Colors.white,
                              elevation: 3,
                              shadowColor: brandOrange.withValues(alpha: 0.35),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 17,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  'Apply Smart Adjustment',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Secondary: Keep Original
                        TextButton(
                          onPressed: onDecline,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                          ),
                          child: Text(
                            'Keep Original Pace',
                            style: GoogleFonts.fredoka(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF8C7A6B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Close (X) Icon Button in Top-Right
              Positioned(
                top: 14,
                right: 14,
                child: GestureDetector(
                  onTap: onDecline,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3EBE1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: Color(0xFF743414),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.fredoka(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required String icon,
    required String title,
    required String timeText,
    bool isHighlight = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.fredoka(
                  fontSize: 13,
                  fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
                  color: const Color(0xFF2E1C14),
                ),
              ),
              Text(
                timeText,
                style: GoogleFonts.fredoka(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w400,
                  color: isHighlight
                      ? const Color(0xFFE65100)
                      : const Color(0xFF8C7A6B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
