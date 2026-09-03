import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Screen displayed when user navigates to the 'Journey' tab.
/// Matches the reference UI with the 3D Fox Adventurer illustration,
/// notification bell header, empty-state messaging, and interactive "+ Create Trip" CTA.
class JourneyScreen extends StatefulWidget {
  final VoidCallback? onCreateTripTap;

  const JourneyScreen({
    super.key,
    this.onCreateTripTap,
  });

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _showNotificationSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFFFDF7F0),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDBC9B8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notifications',
                  style: GoogleFonts.fredoka(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2E1C14),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF7A6860)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEFE6DC)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1E6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.tips_and_updates_rounded,
                      color: Color(0xFFE65100),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ready for an adventure?',
                          style: GoogleFonts.fredoka(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2E1C14),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Plan your first trip to get personalized recommendations and itinerary packing lists.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: const Color(0xFF7A6860),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showCreateTripSheet() {
    final TextEditingController destinationController = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          decoration: const BoxDecoration(
            color: Color(0xFFFDF7F0),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBC9B8),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Plan New Journey',
                    style: GoogleFonts.fredoka(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2E1C14),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1EAE0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Color(0xFF7A6860),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Where would you like to explore next?',
                style: TextStyle(
                  fontSize: 13.5,
                  color: const Color(0xFF7A6860),
                ),
              ),
              const SizedBox(height: 20),

              // Destination input
              TextField(
                controller: destinationController,
                autofocus: true,
                style: GoogleFonts.fredoka(
                  fontSize: 16,
                  color: const Color(0xFF2E1C14),
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Kyoto, Japan or Swiss Alps',
                  hintStyle: TextStyle(
                    color: const Color(0xFFB5A69D),
                    fontSize: 14.5,
                  ),
                  prefixIcon: const Icon(
                    Icons.location_on_rounded,
                    color: Color(0xFFE65100),
                    size: 22,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFEFE6DC)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFEFE6DC)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFFE65100),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Quick destination chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'Tokyo, Japan',
                  'Mount Fuji',
                  'Kyoto',
                  'Seoul, Korea',
                ].map((dest) {
                  return GestureDetector(
                    onTap: () {
                      destinationController.text = dest;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF2E9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE8DACB),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        dest,
                        style: GoogleFonts.fredoka(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF634D41),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Start Journey Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final dest = destinationController.text.trim();
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          dest.isNotEmpty
                              ? 'Journey to "$dest" created!'
                              : 'Adventure created! Happy travels!',
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: const Color(0xFF2E1C14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE65100),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.flight_takeoff_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Start Journey',
                        style: GoogleFonts.fredoka(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const darkBrown = Color(0xFF2E1C14);
    const textMuted = Color(0xFF7A6860);
    const brandOrange = Color(0xFFE65100);

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F0),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Stack(
            children: [
              // 1. Scrollable Content with Full-Bleed Artwork
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 3D Fox Adventurer Mascot Illustration - Bleeding edge-to-edge from top
                    SizedBox(
                      width: double.infinity,
                      child: ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white,
                              Colors.white,
                              Colors.transparent,
                            ],
                            stops: [0.0, 0.88, 1.0],
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.dstIn,
                        child: Image.asset(
                          'assets/journey/empty_journey_fox.jpg',
                          width: double.infinity,
                          fit: BoxFit.fitWidth,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback to assets/home/ copy
                            return Image.asset(
                              'assets/home/empty_journey_fox.jpg',
                              width: double.infinity,
                              fit: BoxFit.fitWidth,
                              errorBuilder: (ctx, err, st) {
                                return Image.asset(
                                  'assets/journey/journey_fox_empty.jpg',
                                  width: double.infinity,
                                  fit: BoxFit.fitWidth,
                                  errorBuilder: (c, e, s) {
                                    return const SizedBox(
                                      height: 280,
                                      child: Center(
                                        child: Icon(
                                          Icons.explore_rounded,
                                          size: 80,
                                          color: brandOrange,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Headline: "You have no trips yet!"
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          Text(
                            'You have no trips yet!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.fredoka(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: darkBrown,
                              letterSpacing: -0.2,
                            ),
                          ),

                          const SizedBox(height: 7),

                          // Subtitle: "Every adventure starts with a single step."
                          Text(
                            'Every adventure starts\nwith a single step.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.fredoka(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w400,
                              color: textMuted,
                              height: 1.35,
                              letterSpacing: 0.1,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // "+ Create Trip" Pill Button
                          GestureDetector(
                            onTap: widget.onCreateTripTap ??
                                _showCreateTripSheet,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 42,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: brandOrange,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: brandOrange
                                        .withValues(alpha: 0.35),
                                    blurRadius: 14,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.add_rounded,
                                    color: Colors.white,
                                    size: 21,
                                  ),
                                  const SizedBox(width: 7),
                                  Text(
                                    'Create Trip',
                                    style: GoogleFonts.fredoka(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 36),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Fixed Top Header: "Journey" + Notification Bell Overlaid on Sky
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 12.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Journey',
                          style: GoogleFonts.fredoka(
                            fontSize: 27,
                            fontWeight: FontWeight.w700,
                            color: darkBrown,
                            letterSpacing: -0.3,
                          ),
                        ),

                        // Notification Bell Button with Orange Indicator Dot
                        GestureDetector(
                          onTap: _showNotificationSheet,
                          behavior: HitTestBehavior.opaque,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFECE4D9),
                                    width: 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: darkBrown.withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.notifications_outlined,
                                    color: darkBrown,
                                    size: 22,
                                  ),
                                ),
                              ),

                              // Small red/orange notification badge dot
                              Positioned(
                                top: 9,
                                right: 10,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE65100),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.5,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
