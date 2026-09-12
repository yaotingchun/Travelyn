import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Interactive modal sheet for "Quick Sync" - Real-time Schedule Realignment (Simulation 5)
/// Matches the Simulation 3 design & visual language:
/// - Presented as an 86% height bottom modal sheet with rounded top corners (32px) on warm cream surface (#FFFDF9)
/// - Top-right circular close button (X)
/// - Centered explorer mascot using `assets/journey/mascot_adjust_plan.png` (175 x 135)
/// - "QUICK SYNC" badge
/// - "Running ~25m Behind" header & friendly narrative subtitle
/// - 3 live context chips: (+25m spent, 19°C Rain, Sky Safe)
/// - Clean white timeline adjustment card with inset horizontal margins (10px) and connected stops
/// - Dual side-by-side pill action buttons: [Apply Smart Adjustment] (orange) and [Keep Original Pace] (cream)
class TripScheduleSyncSheet extends StatelessWidget {
  final VoidCallback onApply;
  final VoidCallback onDecline;

  const TripScheduleSyncSheet({
    super.key,
    required this.onApply,
    required this.onDecline,
  });

  /// Presents the interactive modal bottom sheet with haptic feedback.
  static Future<bool?> show(
    BuildContext context, {
    VoidCallback? onApply,
    VoidCallback? onDecline,
  }) async {
    HapticFeedback.mediumImpact();

    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: const Color(0xFF2E1C14).withValues(alpha: 0.45),
      builder: (ctx) => TripScheduleSyncSheet(
        onApply: () {
          Navigator.of(ctx).pop(true);
        },
        onDecline: () {
          Navigator.of(ctx).pop(false);
        },
      ),
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
    final screenHeight = MediaQuery.of(context).size.height;
    final targetSheetHeight = (screenHeight * 0.86).clamp(640.0, 820.0);

    return Container(
      constraints: BoxConstraints(
        minHeight: targetSheetHeight,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFDF9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1F2E1C14),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top Bar with Circular Close Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: onDecline,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4ECE2),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2E1C14).withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: Color(0xFF5C4E46),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Centered Explorer Mascot from Assets (Matching Simulation 3: 175 x 135)
                  Image.asset(
                    'assets/journey/mascot_adjust_plan.png',
                    width: 175,
                    height: 135,
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, st) => Container(
                      width: 130,
                      height: 110,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.pets_rounded,
                        size: 52,
                        color: Color(0xFFE65100),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Title: "Running ~25m Behind"
                  Text(
                    'Running ~25m Behind',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.fredoka(
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF231815),
                      letterSpacing: -0.3,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Subtitle Narrative
                  Text.rich(
                    TextSpan(
                      text: "Took a little longer and light rain just started 🌧️\nNo worries! I shifted the morning times so you can enjoy everything ",
                      style: GoogleFonts.fredoka(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF5C4E46),
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text: "without rushing ✨",
                          style: GoogleFonts.fredoka(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF231815),
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 18),

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
                      const SizedBox(width: 8),
                      _buildChip(
                        icon: Icons.umbrella_rounded,
                        label: '19°C Rain',
                        bgColor: const Color(0xFFEFF6FF),
                        borderColor: const Color(0xFFDBEAFE),
                        textColor: const Color(0xFF1D4ED8),
                        iconColor: const Color(0xFF2563EB),
                      ),
                      const SizedBox(width: 8),
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

                  const SizedBox(height: 22),

                  // Timeline Card (White rounded card matching Simulation 3's card style)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFF0EAE1),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2E1C14).withValues(alpha: 0.07),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTimelineStep(
                            icon: '⛩️',
                            title: 'Meiji Jingu Shrine',
                            timeText: '09:25 - 10:50 (Stayed an extra 25 mins)',
                            isHighlight: true,
                          ),
                          _buildDivider(),
                          _buildTimelineStep(
                            icon: '🚶',
                            title: 'Takeshita Street Stroll',
                            timeText: '11:00 - 11:45 (Sheltered walk from rain)',
                          ),
                          _buildDivider(),
                          _buildTimelineStep(
                            icon: '🍜',
                            title: 'AFURI Harajuku Ramen',
                            timeText: '12:00 - 12:45 (Warm lunch as planned)',
                          ),
                          _buildDivider(),
                          _buildTimelineStep(
                            icon: '🏙️',
                            title: 'Shibuya Sky Observatory',
                            timeText: '13:00 (Still right on time ✨)',
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              // Action Buttons: [Let's go! 🦊] and [Stay on plan] (matching Simulation 3)
              Row(
                children: [
                  // Left: Primary [Let's go! 🦊]
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: onApply,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE65100),
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shadowColor: const Color(0xFFE65100).withValues(alpha: 0.35),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          "Let's go! 🦊",
                          style: GoogleFonts.fredoka(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Right: Secondary [Stay on plan]
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: onDecline,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFF5EC),
                          foregroundColor: const Color(0xFF6B5A50),
                          elevation: 0,
                          side: const BorderSide(
                            color: Color(0xFFF0E5D8),
                            width: 1.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          'Stay on plan',
                          style: GoogleFonts.fredoka(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6B5A50),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.fredoka(
              fontSize: 12,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isHighlight
                  ? const Color(0xFFFFF3E0)
                  : (isLast ? const Color(0xFFECFDF5) : const Color(0xFFF7F3EE)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              icon,
              style: const TextStyle(fontSize: 16.5),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.fredoka(
                    fontSize: 14,
                    fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
                    color: const Color(0xFF231815),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  timeText,
                  style: GoogleFonts.fredoka(
                    fontSize: 12,
                    fontWeight: (isHighlight || isLast) ? FontWeight.w600 : FontWeight.w500,
                    color: isHighlight
                        ? const Color(0xFFE65100)
                        : (isLast ? const Color(0xFF047857) : const Color(0xFF7A6A60)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.only(left: 16, top: 4, bottom: 4),
      child: SizedBox(
        height: 14,
        child: VerticalDivider(
          color: Color(0xFFE5DDD3),
          thickness: 1.2,
        ),
      ),
    );
  }
}
