import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Screen displayed after successfully booking/creating a trip.
/// Features celebratory fox mascot artwork with confetti,
/// invite link card with copy/share actions, and "Maybe later" exit.
class TripCreatedScreen extends StatefulWidget {
  final String destination;
  final String? tripType;
  final DateTime? startDate;
  final DateTime? endDate;

  const TripCreatedScreen({
    super.key,
    this.destination = 'Tokyo, Japan',
    this.tripType = 'Solo Trip',
    this.startDate,
    this.endDate,
  });

  @override
  State<TripCreatedScreen> createState() => _TripCreatedScreenState();
}

class _TripCreatedScreenState extends State<TripCreatedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late String _inviteCode;
  late String _inviteLink;

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

    // Generate smart invite code based on destination
    final clean = widget.destination
        .replaceAll(RegExp(r'[^a-zA-Z]'), '')
        .toUpperCase();
    final prefix = clean.length >= 3 ? clean.substring(0, 3) : 'TOK';
    _inviteCode = '${prefix}925';
    _inviteLink = 'travelyn.com/invite/$_inviteCode';
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _copyInviteLink() {
    Clipboard.setData(ClipboardData(text: 'https://$_inviteLink'));
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Invite link copied to clipboard!',
                style: GoogleFonts.fredoka(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2E1C14),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  void _shareInvite() {
    _copyInviteLink();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
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
            Text(
              'Share with Friends',
              style: GoogleFonts.fredoka(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2E1C14),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Invite your travel buddies to join your journey to ${widget.destination}.',
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF7A6860),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildShareOption(
                  icon: Icons.message_rounded,
                  label: 'Messages',
                  color: const Color(0xFF34C759),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showSentFeedback('Message invite prepared!');
                  },
                ),
                _buildShareOption(
                  icon: Icons.chat_bubble_rounded,
                  label: 'WhatsApp',
                  color: const Color(0xFF25D366),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showSentFeedback('WhatsApp invite opened!');
                  },
                ),
                _buildShareOption(
                  icon: Icons.copy_rounded,
                  label: 'Copy Link',
                  color: const Color(0xFFE65100),
                  onTap: () {
                    Navigator.pop(ctx);
                  },
                ),
                _buildShareOption(
                  icon: Icons.more_horiz_rounded,
                  label: 'More',
                  color: const Color(0xFF7A6860),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showSentFeedback('Opening share sheet...');
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showSentFeedback(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.fredoka(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2E1C14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, color: color, size: 24),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.fredoka(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2E1C14),
            ),
          ),
        ],
      ),
    );
  }

  void _onMaybeLater() {
    // Navigate back to the Journey/Home screen
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    const darkBrown = Color(0xFF2E1C14);
    const textMuted = Color(0xFF7A6860);
    const brandOrange = Color(0xFFE65100);

    return Scaffold(
      backgroundColor: const Color(0xFFF9D9B2),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final screenHeight = constraints.maxHeight;
                final safeTop = MediaQuery.of(context).padding.top;

                // new_trip_fox.jpeg native resolution is 1696 x 2528 (ratio ~1.49).
                // Fox feet end at approx y = 1800 / 2528 = 0.71 of the image.
                final imageDisplayHeight = screenWidth * 1.49;
                final foxFeetY = imageDisplayHeight * 0.71;

                // Spacing from safe area top to position headline with comfortable breathing room below the mascot
                final topSpacing = (foxFeetY - safeTop + 42).clamp(
                  screenHeight * 0.40,
                  screenHeight * 0.53,
                );

                return Stack(
                  children: [
                    // 1. Top Mascot Artwork - width fits screen, NOT full-screen cover
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: imageDisplayHeight,
                      child: Image.asset(
                        'assets/journey/new_trip_fox.jpeg',
                        width: screenWidth,
                        height: imageDisplayHeight,
                        fit: BoxFit.fitWidth,
                        alignment: Alignment.topCenter,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/home/new_trip_fox.jpeg',
                            width: screenWidth,
                            height: imageDisplayHeight,
                            fit: BoxFit.fitWidth,
                            alignment: Alignment.topCenter,
                            errorBuilder: (ctx, err, st) => const SizedBox(),
                          );
                        },
                      ),
                    ),

                    // 2. Foreground Content in SafeArea
                    SafeArea(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            children: [
                              // Spacing to position content nicely below the jumping fox
                              SizedBox(height: topSpacing),

                              // Welcome & Invitation Heading
                              Text(
                                'Welcome to your\nnew adventure!',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.fredoka(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w700,
                                  color: darkBrown,
                                  height: 1.2,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Invite your friends and\nmake memories together.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.fredoka(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: textMuted,
                                  height: 1.35,
                                  letterSpacing: 0.1,
                                ),
                              ),

                              const SizedBox(height: 22),

                              // 3. Invite With Link Card
                              Container(
                                padding:
                                    const EdgeInsets.fromLTRB(18, 16, 18, 18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          darkBrown.withValues(alpha: 0.07),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Invite with link',
                                      style: GoogleFonts.fredoka(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // Link Display with Copy Icon
                                    GestureDetector(
                                      onTap: _copyInviteLink,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFAF6F0),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          border: Border.all(
                                            color: const Color(0xFFEDE3D7),
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                _inviteLink,
                                                style: GoogleFonts.fredoka(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: darkBrown,
                                                  letterSpacing: 0.2,
                                                ),
                                              ),
                                            ),
                                            const Icon(
                                              Icons.copy_rounded,
                                              size: 19,
                                              color: Color(0xFF6B584E),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 14),

                                    // "Share Invite" Button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: _shareInvite,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: brandOrange,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          shadowColor: Colors.transparent,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.share_outlined,
                                              size: 20,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Share Invite',
                                              style: GoogleFonts.fredoka(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 18),

                              // 4. "Maybe later" Action Button
                              GestureDetector(
                                onTap: _onMaybeLater,
                                behavior: HitTestBehavior.opaque,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                    vertical: 8.0,
                                  ),
                                  child: Text(
                                    'Maybe later',
                                    style: GoogleFonts.fredoka(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF6D5A50),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
