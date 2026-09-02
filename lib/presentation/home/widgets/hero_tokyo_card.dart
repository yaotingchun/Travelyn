import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Full-bleed Tokyo Hero Card matching the Travelyn design reference.
///
/// Displays Tokyo travel illustration, live ticking countdown, and passport reminder.
class HeroTokyoCard extends StatelessWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onSignOutTap;
  final VoidCallback? onPassportViewTap;
  final DateTime? targetDate;

  const HeroTokyoCard({
    super.key,
    this.onNotificationTap,
    this.onProfileTap,
    this.onSignOutTap,
    this.onPassportViewTap,
    this.targetDate,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final statusBarHeight = mediaQuery.padding.top;

    // Viewable area height for hero section
    final imageHeight = (statusBarHeight + 300.0).clamp(340.0, 420.0);
    final heroHeight = imageHeight + 42.0;

    const brandOrange = Color(0xFFE65100);
    const darkBrown = Color(0xFF2E1C14);
    const textMuted = Color(0xFF7A6860);

    return SizedBox(
      height: heroHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Hero Image - Longer in height with top-right framing
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: imageHeight,
            child: ClipRect(
              child: Image.asset(
                'assets/home/hero_tokyo.jpg',
                fit: BoxFit.cover,
                alignment: const Alignment(0.88, -1.0),
              ),
            ),
          ),

          // 2. Top Overlay Actions (Logo, Notification, Profile Avatar)
          Positioned(
            top: statusBarHeight + 6,
            left: 16,
            right: 16,
            child: Row(
              children: [
                // Travelyn Logo
                Image.asset(
                  'assets/logo/travelyn_logo.png',
                  height: 26,
                  fit: BoxFit.contain,
                ),

                const Spacer(),

                // Frosted Bell Button with unread indicator
                GestureDetector(
                  onTap: onNotificationTap ??
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('No new notifications'),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.32),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.45),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: darkBrown.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            const Icon(
                              Icons.notifications_none_rounded,
                              color: darkBrown,
                              size: 19,
                            ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: brandOrange,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.0,
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

                const SizedBox(width: 8),

                // Profile Avatar with dropdown options
                PopupMenuButton<String>(
                  tooltip: 'Profile',
                  offset: const Offset(0, 42),
                  constraints: const BoxConstraints(minWidth: 160),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white,
                  elevation: 5,
                  shadowColor: const Color(0x2E2E1C14),
                  onSelected: (value) {
                    if (value == 'profile') {
                      onProfileTap?.call();
                    } else if (value == 'logout') {
                      onSignOutTap?.call();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: 'profile',
                      height: 44,
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            color: darkBrown,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Profile',
                            style: TextStyle(
                              color: darkBrown,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(height: 1),
                    const PopupMenuItem<String>(
                      value: 'logout',
                      height: 44,
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            color: brandOrange,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Sign Out',
                            style: TextStyle(
                              color: brandOrange,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: darkBrown.withValues(alpha: 0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/home/avatar_badge.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 5. Main Hero Content (Greeting, Title, Underline, Subtitle, Countdowns)
          Positioned(
            left: 16,
            top: statusBarHeight + 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Greeting with waving celebration icon
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Good morning, Explorer!',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF3E2723),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const _WavingHandIcon(),
                  ],
                ),

                const SizedBox(height: 3),

                // Destination Headline: "Tokyo is"
                Text(
                  'Tokyo is',
                  style: GoogleFonts.fredoka(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    color: darkBrown,
                    letterSpacing: -0.3,
                    height: 1.15,
                  ),
                ),

                // Headline Second Line: "waiting for you! 🇯🇵" + curved orange underline
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Text(
                          'waiting for you!',
                          style: GoogleFonts.fredoka(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            color: darkBrown,
                            letterSpacing: -0.3,
                            height: 1.15,
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: -3,
                          height: 5,
                          child: CustomPaint(
                            painter: _CurvedUnderlinePainter(
                              color: const Color(0xFFF57C28),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      '🇯🇵',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Adventure subtitle
                Text(
                  'Your next adventure begins soon',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textMuted,
                    letterSpacing: -0.1,
                  ),
                ),

                const SizedBox(height: 11),

                // Translucent Frosted Live Countdown Cards
                _LiveCountdownRow(targetDate: targetDate),
              ],
            ),
          ),

          // 4. Subtle Rounded Bottom Transition Sheet
          Positioned(
            top: imageHeight - 20,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFDF7F0),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
              ),
            ),
          ),

          // 5. Overlapping Action Card: "Check your passport"
          Positioned(
            top: imageHeight - 48,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6ED),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white,
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: darkBrown.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: darkBrown.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Passport Illustration
                  Image.asset(
                    'assets/home/passport_illus.png',
                    width: 58,
                    height: 58,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(width: 12),

                  // Center Information
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              '✦',
                              style: TextStyle(
                                fontSize: 10,
                                color: brandOrange,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'One thing to do',
                              style: GoogleFonts.nunito(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: brandOrange,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '✦',
                              style: TextStyle(
                                fontSize: 10,
                                color: brandOrange,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Check your passport',
                          style: GoogleFonts.fredoka(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: darkBrown,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Expires in 4 months. Renew before your trip!',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: textMuted,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // "View ->" Pill Action Button
                  GestureDetector(
                    onTap: onPassportViewTap ??
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  const Text('Passport details coming soon!'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDECDA),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View',
                            style: GoogleFonts.fredoka(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: darkBrown,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: darkBrown,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Live ticking countdown timer row calculating days, hours, and minutes remaining until target date.
class _LiveCountdownRow extends StatefulWidget {
  final DateTime? targetDate;

  const _LiveCountdownRow({this.targetDate});

  @override
  State<_LiveCountdownRow> createState() => _LiveCountdownRowState();
}

class _LiveCountdownRowState extends State<_LiveCountdownRow> {
  Timer? _timer;
  late DateTime _target;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _target = widget.targetDate ??
        DateTime.now().add(
          const Duration(days: 12, hours: 4, minutes: 21),
        );
    _calculateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        _calculateRemaining();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _LiveCountdownRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.targetDate != oldWidget.targetDate) {
      _target = widget.targetDate ??
          DateTime.now().add(
            const Duration(days: 12, hours: 4, minutes: 21),
          );
      _calculateRemaining();
    }
  }

  void _calculateRemaining() {
    final now = DateTime.now();
    if (_target.isAfter(now)) {
      setState(() {
        _remaining = _target.difference(now);
      });
    } else {
      setState(() {
        _remaining = Duration.zero;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = _remaining.inDays.toString().padLeft(2, '0');
    final hours = (_remaining.inHours % 24).toString().padLeft(2, '0');
    final mins = (_remaining.inMinutes % 60).toString().padLeft(2, '0');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CountdownBox(number: days, label: 'Days'),
        const SizedBox(width: 6),
        _CountdownBox(number: hours, label: 'Hours'),
        const SizedBox(width: 6),
        _CountdownBox(number: mins, label: 'Mins'),
      ],
    );
  }
}

/// Frosted glass translucent countdown box.
class _CountdownBox extends StatelessWidget {
  final String number;
  final String label;

  const _CountdownBox({
    required this.number,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    const darkBrown = Color(0xFF2E1C14);
    const textMuted = Color(0xFF5E4E46);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 48,
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.90),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: darkBrown.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                number,
                style: GoogleFonts.fredoka(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: darkBrown,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Curved warm orange swoosh underline under destination text.
class _CurvedUnderlinePainter extends CustomPainter {
  final Color color;

  const _CurvedUnderlinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.4);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height,
      size.width,
      size.height * 0.25,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CurvedUnderlinePainter oldDelegate) =>
      color != oldDelegate.color;
}

/// Outline celebration / waving paw icon matching the design mockup.
class _WavingHandIcon extends StatelessWidget {
  const _WavingHandIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(16, 16),
      painter: _WavingHandPainter(),
    );
  }
}

class _WavingHandPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF57C28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Small celebration burst arcs on top right
    canvas.drawLine(
      Offset(size.width * 0.65, size.height * 0.15),
      Offset(size.width * 0.75, 0),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.85, size.height * 0.25),
      Offset(size.width * 0.98, size.height * 0.18),
      paint,
    );

    // Hand / paw outline
    final path = Path();
    path.moveTo(size.width * 0.25, size.height * 0.4);
    path.quadraticBezierTo(
      size.width * 0.15,
      size.height * 0.65,
      size.width * 0.35,
      size.height * 0.85,
    );
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.95,
      size.width * 0.75,
      size.height * 0.75,
    );
    path.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.55,
      size.width * 0.7,
      size.height * 0.35,
    );
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.25,
      size.width * 0.25,
      size.height * 0.4,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
