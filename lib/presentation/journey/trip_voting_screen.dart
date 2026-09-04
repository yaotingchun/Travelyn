import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'trip_places_input_screen.dart';
import 'widgets/trip_done_button.dart';

/// Screen displayed when collaborators vote on trip vibes/styles.
/// Features:
/// - Floating sakura cherry blossoms header with peeking 3D fox mascot
/// - "What kind of trip are we making?" prompt with "Pick up to 3!" limit
/// - 3x3 Mascot Vote Cards Grid: Foodie, Culture, Adventure, Chill, Sightseeing,
///   Photo Spots, Shopping, Hidden Gems, Theme Parks
/// - Member avatars row + "X/3 selected" counter
/// - Warm sunset orange "I'm Done! ✨" CTA button
class TripVotingScreen extends StatefulWidget {
  final String destination;
  final ValueChanged<List<String>>? onDone;
  final bool navigateToPlacesOnDone;

  const TripVotingScreen({
    super.key,
    this.destination = 'Tokyo, Japan',
    this.onDone,
    this.navigateToPlacesOnDone = true,
  });

  @override
  State<TripVotingScreen> createState() => _TripVotingScreenState();
}

class _TripVotingScreenState extends State<TripVotingScreen> {
  late Set<String> _selected;

  static const List<_VibeOption> _options = [
    _VibeOption(
      title: 'Foodie',
      subtitle: 'Eat everything',
      assetPath: 'assets/journey/mascot_foodie.png',
      bgStart: Color(0xFFFFF8F0),
      bgEnd: Color(0xFFFFF0E4),
      borderColor: Color(0xFFF2DDD0),
      highlightColor: Color(0xFFFF6422),
    ),
    _VibeOption(
      title: 'Culture',
      subtitle: 'Feel traditional vibes',
      assetPath: 'assets/journey/mascot_culture.png',
      bgStart: Color(0xFFFFF9F0),
      bgEnd: Color(0xFFFFF2E2),
      borderColor: Color(0xFFF2DDD0),
      highlightColor: Color(0xFFE58A1F),
    ),
    _VibeOption(
      title: 'Adventure',
      subtitle: 'Trek scenic trails',
      assetPath: 'assets/journey/mascot_adventure.png',
      bgStart: Color(0xFFF6F3FC),
      bgEnd: Color(0xFFEDE5F8),
      borderColor: Color(0xFFDDD5F0),
      highlightColor: Color(0xFF8B5CF6),
    ),
    _VibeOption(
      title: 'Chill',
      subtitle: 'No rushing please',
      assetPath: 'assets/journey/mascot_chill.png',
      bgStart: Color(0xFFF1F8F4),
      bgEnd: Color(0xFFE6F4EC),
      borderColor: Color(0xFFC7E2D0),
      highlightColor: Color(0xFF10B981),
    ),
    _VibeOption(
      title: 'Sightseeing',
      subtitle: 'See iconic landmarks',
      assetPath: 'assets/journey/mascot_sightseeing.png',
      bgStart: Color(0xFFFFF7F2),
      bgEnd: Color(0xFFFFF0E6),
      borderColor: Color(0xFFF2DDD0),
      highlightColor: Color(0xFFEA580C),
    ),
    _VibeOption(
      title: 'Photo Spots',
      subtitle: 'Capture memories',
      assetPath: 'assets/journey/mascot_photo.png',
      bgStart: Color(0xFFF0F7FF),
      bgEnd: Color(0xFFE4F0FD),
      borderColor: Color(0xFFCFE2F7),
      highlightColor: Color(0xFF0284C7),
    ),
    _VibeOption(
      title: 'Shopping',
      subtitle: 'Shop till you drop',
      assetPath: 'assets/journey/mascot_shopping.png',
      bgStart: Color(0xFFFFF5F4),
      bgEnd: Color(0xFFFFECEE),
      borderColor: Color(0xFFF2DDD0),
      highlightColor: Color(0xFFE11D48),
    ),
    _VibeOption(
      title: 'Hidden Gems',
      subtitle: 'Find secret spots',
      assetPath: 'assets/journey/mascot_hidden_gems.png',
      bgStart: Color(0xFFFFFBF0),
      bgEnd: Color(0xFFFFF5DE),
      borderColor: Color(0xFFEFE2C5),
      highlightColor: Color(0xFFD97706),
    ),
    _VibeOption(
      title: 'Theme Parks',
      subtitle: 'Thrilling fun & rides',
      assetPath: 'assets/journey/mascot_theme_parks.png',
      bgStart: Color(0xFFFFF4EF),
      bgEnd: Color(0xFFFFEAE1),
      borderColor: Color(0xFFF6D2C4),
      highlightColor: Color(0xFFDC2626),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selected = {'Foodie', 'Culture', 'Adventure'};
  }

  void _toggleCategory(String category) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_selected.contains(category)) {
        _selected.remove(category);
      } else {
        if (_selected.length < 3) {
          _selected.add(category);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'You can pick up to 3 vibes!',
                style: GoogleFonts.fredoka(color: Colors.white),
              ),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(milliseconds: 1500),
              backgroundColor: const Color(0xFF2E1C14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    });
  }

  void _onDonePressed() async {
    HapticFeedback.mediumImpact();

    if (!widget.navigateToPlacesOnDone) {
      if (widget.onDone != null) {
        widget.onDone!(_selected.toList());
      } else {
        Navigator.of(context).pop(_selected.toList());
      }
      return;
    }

    final result = await Navigator.of(context).push<TripPlacesResult>(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) =>
            TripPlacesInputScreen(
          destination: widget.destination,
          selectedVibes: _selected.toList(),
          onComplete: (placesResult) {
            Navigator.of(context).pop(placesResult);
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
      ),
    );

    if (result != null && mounted) {
      if (widget.onDone != null) {
        widget.onDone!(result.selectedVibes);
      } else {
        Navigator.of(context).pop(result.selectedVibes);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const darkBrown = Color(0xFF231815);
    const textMuted = Color(0xFF8A786E);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F3),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: Stack(
          children: [
            // 1. Soft Cherry Blossom Branch (Top Right)
            Positioned(
              top: 0,
              right: 0,
              width: 130,
              height: 160,
              child: Image.asset(
                'assets/journey/vote_sakura.png',
                fit: BoxFit.contain,
                alignment: Alignment.topRight,
              ),
            ),

            // 2. Floating Sakura Petals & Golden Sparkle Background Painter
            Positioned.fill(
              child: CustomPaint(
                painter: _SakuraBackgroundPainter(),
              ),
            ),

            // 3. Main Screen Layout - Responsive full-height distribution
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Top Navigation Bar (Clean Back Chevron without circle background)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                behavior: HitTestBehavior.opaque,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    size: 20,
                                    color: darkBrown,
                                  ),
                                ),
                              ),
                            ),

                            // Peeking 3D Fox Mascot Header
                            SizedBox(
                              height: 58,
                              child: Image.asset(
                                'assets/journey/vote_mascot_peek.png',
                                fit: BoxFit.contain,
                              ),
                            ),

                            const SizedBox(height: 6),

                            // Heading Prompt
                            Text(
                              'What kind of trip are we making?',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.fredoka(
                                fontSize: 22.5,
                                fontWeight: FontWeight.w700,
                                color: darkBrown,
                                letterSpacing: -0.2,
                              ),
                            ),

                            const SizedBox(height: 4),

                            // Subtitle Prompt
                            Text(
                              "Pick up to 3! Everyone's answers will be shown~",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.fredoka(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: textMuted,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // 3x3 Mascot Vote Cards Grid
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (int r = 0; r < 3; r++) ...[
                                  if (r > 0) const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      for (int c = 0; c < 3; c++) ...[
                                        if (c > 0) const SizedBox(width: 9),
                                        Expanded(
                                          child: _buildVoteCard(_options[r * 3 + c]),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Flexible space to distribute remaining screen height gracefully
                            const Spacer(),

                            // Member Avatars Row + Selection Counter
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0, bottom: 12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildAvatarCluster(),
                                  const SizedBox(width: 10),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${_selected.length}/3',
                                        style: GoogleFonts.fredoka(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFFE85A1C),
                                        ),
                                      ),
                                      Text(
                                        ' selected',
                                        style: GoogleFonts.fredoka(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Warm Sunset Orange "I'm Done! ✨" CTA Button
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: TripDoneButton(
                                onPressed: _onDonePressed,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildVoteCard(_VibeOption option) {
    final isSelected = _selected.contains(option.title);

    return AspectRatio(
      aspectRatio: 0.76,
      child: GestureDetector(
        onTap: () => _toggleCategory(option.title),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [option.bgStart, option.bgEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: isSelected ? option.highlightColor : option.borderColor,
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: option.highlightColor.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: const Color(0xFF231815).withValues(alpha: 0.04),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Content: Mascot, Label, Short description
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 7.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 3D Fox Mascot
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 2.0, bottom: 3.0),
                            child: Image.asset(
                              option.assetPath,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),

                      // Label
                      Text(
                        option.title,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.fredoka(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF231815),
                          letterSpacing: -0.2,
                        ),
                      ),

                      const SizedBox(height: 2),

                      // Short Description
                      Text(
                        option.subtitle,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.fredoka(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF8A786E),
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Top-Right Checkmark Badge when selected (follows card's highlight color)
              if (isSelected)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: option.highlightColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_rounded,
                        size: 12,
                        color: Colors.white,
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

  Widget _buildAvatarCluster() {
    final avatarPaths = [
      'assets/journey/member_avatar_1.jpg',
      'assets/journey/member_avatar_2.jpg',
      'assets/journey/member_avatar_3.jpg',
      'assets/journey/member_avatar_4.jpg',
    ];

    return SizedBox(
      height: 26,
      width: 26.0 + (3 * 16.0),
      child: Stack(
        children: List.generate(avatarPaths.length, (index) {
          return Positioned(
            left: index * 16.0,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF231815).withValues(alpha: 0.12),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  avatarPaths[index],
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, st) => Container(
                    color: const Color(0xFFE8DFD5),
                    child: const Icon(Icons.person, size: 14, color: Color(0xFF7A6860)),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _VibeOption {
  final String title;
  final String subtitle;
  final String assetPath;
  final Color bgStart;
  final Color bgEnd;
  final Color borderColor;
  final Color highlightColor;

  const _VibeOption({
    required this.title,
    required this.subtitle,
    required this.assetPath,
    required this.bgStart,
    required this.bgEnd,
    required this.borderColor,
    required this.highlightColor,
  });
}

// Helper to draw diamond sparkles
void _drawDiamond(Canvas canvas, Offset center, double size, Paint paint) {
  final path = Path()
    ..moveTo(center.dx, center.dy - size)
    ..lineTo(center.dx + size * 0.6, center.dy)
    ..lineTo(center.dx, center.dy + size)
    ..lineTo(center.dx - size * 0.6, center.dy)
    ..close();
  canvas.drawPath(path, paint);
}

// ---------------------------------------------------------------------------
// Atmospheric Background Painter: Falling Sakura Petals & Golden Sparkles
// ---------------------------------------------------------------------------

class _SakuraBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Soft pastel pink petals drifting down
    final petalPaint = Paint()
      ..color = const Color(0xFFFFB7B2).withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;

    // Golden apricot sparkle dust
    final goldPaint = Paint()
      ..color = const Color(0xFFFFA726).withValues(alpha: 0.40)
      ..style = PaintingStyle.fill;

    final petals = [
      _PetalData(Offset(size.width * 0.12, size.height * 0.08), 5.5, 0.4),
      _PetalData(Offset(size.width * 0.28, size.height * 0.05), 4.5, -0.6),
      _PetalData(Offset(size.width * 0.72, size.height * 0.06), 6.0, 0.8),
      _PetalData(Offset(size.width * 0.85, size.height * 0.11), 5.0, -0.3),
      _PetalData(Offset(size.width * 0.06, size.height * 0.15), 4.0, 0.5),
      _PetalData(Offset(size.width * 0.92, size.height * 0.18), 5.2, 0.7),
      _PetalData(Offset(size.width * 0.48, size.height * 0.13), 3.5, 0.2),
      _PetalData(Offset(size.width * 0.10, size.height * 0.86), 4.0, 0.4),
      _PetalData(Offset(size.width * 0.90, size.height * 0.89), 4.5, -0.5),
    ];

    for (final p in petals) {
      canvas.save();
      canvas.translate(p.center.dx, p.center.dy);
      canvas.rotate(p.rotation);
      final rect = Rect.fromCenter(center: Offset.zero, width: p.radius * 2, height: p.radius * 1.3);
      canvas.drawOval(rect, petalPaint);
      canvas.restore();
    }

    // Sparkle diamonds
    final sparkles = [
      Offset(size.width * 0.22, size.height * 0.04),
      Offset(size.width * 0.38, size.height * 0.07),
      Offset(size.width * 0.65, size.height * 0.05),
      Offset(size.width * 0.78, size.height * 0.09),
      Offset(size.width * 0.08, size.height * 0.82),
      Offset(size.width * 0.92, size.height * 0.85),
    ];

    for (final sp in sparkles) {
      _drawDiamond(canvas, sp, 3.5, goldPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PetalData {
  final Offset center;
  final double radius;
  final double rotation;

  _PetalData(this.center, this.radius, this.rotation);
}
