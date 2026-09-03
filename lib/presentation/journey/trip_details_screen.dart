import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Screen displayed after creating a trip.
/// Matches the reference design:
/// - Fully opaque hero photo (`tokyo_pagoda_blossom.jpg`) with vibrant pagoda and cherry blossoms
/// - Naked back arrow (<) directly on the photo, aligned with destination title ("Tokyo, Japan 🇯🇵")
/// - Date range and 4 member avatars with circular '+' add button
/// - Below section is a full-width cream sheet with rounded top corners (radius: 28), overlapping the hero photo
/// - Navbar sits at the top of the below sheet (Chat, Trip, Bookings, Diary, Finance)
/// - Pinned "Tokyo Trip Overview" card with Tokyo skyline thumbnail and interactive details sheet
/// - Interactive group chat feed, Day-by-day Itinerary, Bookings, Diary, and Finance views
class TripDetailsScreen extends StatefulWidget {
  final String destination;
  final String? tripType;
  final DateTime? startDate;
  final DateTime? endDate;

  const TripDetailsScreen({
    super.key,
    this.destination = 'Tokyo, Japan',
    this.tripType = 'Group Trip',
    this.startDate,
    this.endDate,
  });

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  int _activeTabIndex = 0;
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  final List<Map<String, dynamic>> _chatMessages = [
    {
      'sender': 'Travelyn',
      'avatar': 'assets/mascot/avatar.png',
      'message':
          "Konnichiwa, explorers! 👏\nHere's a quick overview of our Tokyo adventure. Tap the card above to see day-by-day highlights, must-try food, top spots and more!",
      'time': '9:30 AM',
      'isBot': true,
      'reactionEmoji': '❤️',
      'reactionCount': '12',
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _chatController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  String _formatDateRange() {
    if (widget.startDate != null && widget.endDate != null) {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final start = widget.startDate!;
      final end = widget.endDate!;
      return '${start.day} ${months[start.month - 1]} – ${end.day} ${months[end.month - 1]} ${end.year}';
    }
    return '12 Sep – 18 Sep 2025';
  }

  String _getDestinationWithFlag() {
    final dest = widget.destination;
    if (dest.contains('🇯🇵') || dest.contains('Japan')) {
      if (!dest.contains('🇯🇵')) return '$dest 🇯🇵';
      return dest;
    }
    return '$dest ✈️';
  }

  void _sendMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour:$minute $period';

    setState(() {
      _chatMessages.add({
        'sender': 'You',
        'avatar': 'assets/journey/member_avatar_4.jpg',
        'message': text,
        'time': timeStr,
        'isBot': false,
        'reactionEmoji': null,
        'reactionCount': null,
      });
      _chatController.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showInviteSheet() {
    final clean = widget.destination
        .replaceAll(RegExp(r'[^a-zA-Z]'), '')
        .toUpperCase();
    final prefix = clean.length >= 3 ? clean.substring(0, 3) : 'TOK';
    final inviteCode = '${prefix}925';
    final inviteLink = 'travelyn.com/invite/$inviteCode';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFFFDF7F0),
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
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
              'Trip Members',
              style: GoogleFonts.fredoka(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2E1C14),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Invite travel companions to collaborate on ${widget.destination}.',
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF6B5A50),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEDE3D7)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link_rounded, color: Color(0xFFE65100), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      inviteLink,
                      style: GoogleFonts.fredoka(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF2E1C14),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: 'https://$inviteLink'));
                      HapticFeedback.lightImpact();
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Invite link copied to clipboard!',
                            style: GoogleFonts.fredoka(color: Colors.white),
                          ),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: const Color(0xFF2E1C14),
                          duration: const Duration(seconds: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1E6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Copy',
                        style: GoogleFonts.fredoka(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE65100),
                        ),
                      ),
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

  void _showOverviewSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Color(0xFFFDF7F0),
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDBC9B8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.push_pin_rounded,
                              size: 15, color: Color(0xFFE65100)),
                          const SizedBox(width: 5),
                          Text(
                            'Pinned by Travelyn',
                            style: GoogleFonts.fredoka(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFC85018),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tokyo Trip Overview',
                        style: GoogleFonts.fredoka(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2E1C14),
                        ),
                      ),
                    ],
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/home/hero_tokyo.jpg',
                    width: 70,
                    height: 54,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHighlightRow(
                      icon: Icons.wb_sunny_rounded,
                      title: 'Weather Forecast',
                      detail: '24°C Sunny & Mild • Ideal for city sightseeing',
                      iconColor: const Color(0xFFF57C00),
                    ),
                    const SizedBox(height: 12),
                    _buildHighlightRow(
                      icon: Icons.subway_rounded,
                      title: 'Transit Essentials',
                      detail: 'JR Rail Pass & Suica card recommended',
                      iconColor: const Color(0xFF1976D2),
                    ),
                    const SizedBox(height: 12),
                    _buildHighlightRow(
                      icon: Icons.star_rounded,
                      title: 'Top Group Highlights',
                      detail:
                          'Shibuya Crossing, Senso-ji Temple, Meiji Shrine & teamLab',
                      iconColor: const Color(0xFF7B1FA2),
                    ),
                    const SizedBox(height: 12),
                    _buildHighlightRow(
                      icon: Icons.restaurant_rounded,
                      title: 'Dining Hotspots',
                      detail: 'Omoide Yokocho, Tsukiji Outer Market, Ichiran Ramen',
                      iconColor: const Color(0xFF388E3C),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEDE3D7)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trip Checklist',
                            style: GoogleFonts.fredoka(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2E1C14),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildCheckItem('Valid passport (6+ months)', true),
                          _buildCheckItem('Visit Japan Web QR registration', true),
                          _buildCheckItem('eSIM or Pocket Wi-Fi reservation', false),
                          _buildCheckItem('Yen currency exchange / Wise card', false),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(String label, bool checked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            checked ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 18,
            color: checked ? const Color(0xFF388E3C) : const Color(0xFF9E8E84),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.fredoka(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF4A3A32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightRow({
    required IconData icon,
    required String title,
    required String detail,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE3D7)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
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
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2E1C14),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF6B5A50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const brandOrange = Color(0xFFE65100);
    const darkBrown = Color(0xFF2E1C14);
    const textMuted = Color(0xFF6B5A50);

    final safeTop = MediaQuery.of(context).padding.top;
    // Hero image height containing the destination header
    final heroImageHeight = (safeTop + 195.0).clamp(235.0, 265.0);
    const navbarHeight = 64.0;
    const navbarOverlap = 32.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F0),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: Stack(
          children: [
            // =================================================================
            // 1. TOP HERO CARD (Photo + destination info)
            // =================================================================
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: heroImageHeight + 30.0,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Natural, fully opaque cherry blossom & pagoda image with top sky aligned
                  Image.asset(
                    'assets/journey/tokyo_pagoda_blossom.jpg',
                    fit: BoxFit.cover,
                    alignment: const Alignment(0.25, -0.85),
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/home/tokyo_pagoda_blossom.jpg',
                        fit: BoxFit.cover,
                        alignment: const Alignment(0.25, -0.85),
                        errorBuilder: (ctx, err, st) =>
                            Container(color: const Color(0xFFF7E6DC)),
                      );
                    },
                  ),

                  // Natural soft atmospheric glow behind text area
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: heroImageHeight * 0.75,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(-0.85, -0.65),
                          radius: 1.25,
                          colors: [
                            const Color(0xFFFFF7F0).withValues(alpha: 0.58),
                            const Color(0xFFFFF7F0).withValues(alpha: 0.28),
                            const Color(0xFFFFF7F0).withValues(alpha: 0.0),
                          ],
                          stops: const [0.0, 0.52, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Header Content: Back Arrow (<), Title, Dates, Avatars
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 6.0,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Naked Back Arrow (<) matching Image 2
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 3.0, right: 10.0),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 22,
                                color: darkBrown,
                                shadows: [
                                  Shadow(
                                    color: const Color(0xFFFFF7F0).withValues(alpha: 0.70),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Destination Title, Dates, and Member Avatars
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Destination Name + Flag
                                Text(
                                  _getDestinationWithFlag(),
                                  style: GoogleFonts.fredoka(
                                    fontSize: 23,
                                    fontWeight: FontWeight.w700,
                                    color: darkBrown,
                                    letterSpacing: -0.3,
                                    shadows: [
                                      Shadow(
                                        color: const Color(0xFFFFF7F0).withValues(alpha: 0.75),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),

                                const SizedBox(height: 2),

                                // Dates subtitle
                                Text(
                                  _formatDateRange(),
                                  style: GoogleFonts.fredoka(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF382319),
                                    letterSpacing: 0.1,
                                    shadows: [
                                      Shadow(
                                        color: const Color(0xFFFFF7F0).withValues(alpha: 0.70),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 10),

                                // Member Avatars Row with '+' button
                                Row(
                                  children: [
                                    _buildAvatarCluster(),
                                    const SizedBox(width: 8),
                                    // '+' invite button
                                    GestureDetector(
                                      onTap: _showInviteSheet,
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: darkBrown
                                                  .withValues(alpha: 0.10),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                          border: Border.all(
                                            color: const Color(0xFFEDE3D7),
                                            width: 1.0,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.add_rounded,
                                            size: 18,
                                            color: darkBrown,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // =================================================================
            // 2. THE BELOW PART (Cream sheet with rounded top corners)
            // =================================================================
            Positioned.fill(
              top: heroImageHeight - 10.0,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF7F0),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: darkBrown.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: (navbarHeight - navbarOverlap) + 10.0,
                      bottom: _activeTabIndex == 0 ? 128.0 : 0.0,
                    ),
                    child: IndexedStack(
                      index: _activeTabIndex,
                      children: [
                        _buildChatTab(brandOrange, darkBrown, textMuted),
                        _buildTripTab(brandOrange, darkBrown, textMuted),
                        _buildBookingsTab(brandOrange, darkBrown, textMuted),
                        _buildDiaryTab(brandOrange, darkBrown, textMuted),
                        _buildFinanceTab(brandOrange, darkBrown, textMuted),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // =================================================================
            // 3. THE INDEPENDENT NAVBAR (Lying between below part & hero card)
            // =================================================================
            Positioned(
              top: heroImageHeight - navbarOverlap,
              left: 14,
              right: 14,
              height: navbarHeight,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF7F0),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFEDE3D7),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: darkBrown.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: darkBrown.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: _buildNavBar(brandOrange, textMuted),
              ),
            ),

            // =================================================================
            // 4. FIXED BOTTOM CHAT BOX (with base_layer_chatbox underneath)
            // =================================================================
            if (_activeTabIndex == 0)
              Positioned(
                left: 8,
                right: 8,
                bottom: 6,
                child: SafeArea(
                  top: false,
                  child: _buildBottomChatBar(brandOrange, darkBrown, textMuted),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Avatar cluster with 4 overlapping circular member portraits
  Widget _buildAvatarCluster() {
    final avatarPaths = [
      'assets/journey/member_avatar_1.jpg',
      'assets/journey/member_avatar_2.jpg',
      'assets/journey/member_avatar_3.jpg',
      'assets/journey/member_avatar_4.jpg',
    ];

    return SizedBox(
      height: 32,
      width: 32.0 + (3 * 22.0),
      child: Stack(
        children: List.generate(avatarPaths.length, (index) {
          return Positioned(
            left: index * 22.0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E1C14).withValues(alpha: 0.12),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  avatarPaths[index],
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, st) {
                    return Container(
                      color: const Color(0xFFE8DFD5),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 18,
                        color: Color(0xFF6B5A50),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Independent Navbar lying between the below part and the hero card.
  /// Features a consistent on-tab indicator line across all tabs.
  Widget _buildNavBar(Color brandOrange, Color textMuted) {
    final tabs = [
      {'label': 'Chat', 'type': 'chat'},
      {'label': 'Trip', 'icon': Icons.calendar_month_outlined},
      {'label': 'Bookings', 'icon': Icons.shopping_bag_outlined},
      {'label': 'Diary', 'icon': Icons.menu_book_rounded},
      {'label': 'Finance', 'icon': Icons.paid_outlined},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(tabs.length, (index) {
          final isSelected = _activeTabIndex == index;
          final tab = tabs[index];
          final label = tab['label'] as String;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _activeTabIndex = index;
                });
                HapticFeedback.selectionClick();
              },
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                height: 64.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // Tab Icon (fixed 22px height)
                    SizedBox(
                      height: 22,
                      child: Center(
                        child: (tab['type'] == 'chat')
                            ? _buildChatPinIcon(
                                isSelected ? brandOrange : textMuted, isSelected)
                            : Icon(
                                tab['icon'] as IconData,
                                size: 22,
                                color: isSelected ? brandOrange : textMuted,
                              ),
                      ),
                    ),

                    const SizedBox(height: 3),

                    // Tab Label (fixed 14px height)
                    SizedBox(
                      height: 14,
                      child: Center(
                        child: Text(
                          label,
                          style: GoogleFonts.fredoka(
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? brandOrange : textMuted,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 1),

                    // Consistent on-tab indicator line across all tabs
                    Container(
                      width: 34,
                      height: 2.5,
                      decoration: BoxDecoration(
                        color: isSelected ? brandOrange : Colors.transparent,
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                    const SizedBox(height: 3),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Speech bubble chat icon with white center dot matching Image 2
  Widget _buildChatPinIcon(Color color, bool isSelected) {
    return SizedBox(
      width: 22,
      height: 22,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            isSelected
                ? Icons.chat_bubble_rounded
                : Icons.chat_bubble_outline_rounded,
            size: 22,
            color: color,
          ),
          if (isSelected)
            Container(
              width: 6.0,
              height: 6.0,
              margin: const EdgeInsets.only(bottom: 2.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 0: CHAT TAB (Main reference mockup tab)
  // ===========================================================================
  Widget _buildChatTab(Color brandOrange, Color darkBrown, Color textMuted) {
    return SingleChildScrollView(
      controller: _chatScrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. "Pinned by Travelyn" Card (Narrower than navbar, aligned with chat messages)
          GestureDetector(
            onTap: _showOverviewSheet,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Card Body
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBF7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFEDE3D7),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: darkBrown.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left Column: Pinned tag, Title, Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Top Pin Tag: Orange pushpin + "Pinned by Travelyn"
                            Row(
                              children: [
                                Transform.rotate(
                                  angle: -0.4,
                                  child: const Icon(
                                    Icons.push_pin_rounded,
                                    size: 15,
                                    color: Color(0xFFE65100),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Pinned by Travelyn',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFB8582B),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 7),

                            // Title
                            Text(
                              'Tokyo Trip Overview',
                              style: GoogleFonts.fredoka(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                color: darkBrown,
                                letterSpacing: -0.3,
                              ),
                            ),

                            const SizedBox(height: 4),

                            // Subtitle
                            Text(
                              'Tap to explore your trip highlights',
                              style: GoogleFonts.fredoka(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Right Tokyo Skyline Thumbnail Image
                      Container(
                        width: 86,
                        height: 66,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: darkBrown.withValues(alpha: 0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(
                            'assets/home/hero_tokyo.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, st) {
                              return Container(
                                color: const Color(0xFFE8DFD5),
                                child: const Icon(
                                  Icons.image_outlined,
                                  color: Color(0xFF6B5A50),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Exact realistic 3D black pushpin pinning the top-right corner
                const Positioned(
                  top: -6,
                  right: -4,
                  child: RealisticPushPin(size: 32),
                ),
              ],
            ),
          ),

          // Group Chat Feed (empty initially, shows any new messages sent)
          if (_chatMessages.isNotEmpty) ...[
            const SizedBox(height: 20),
            ..._chatMessages
                .map((msg) => _buildChatMessageItem(msg, darkBrown, textMuted)),
          ],
        ],
      ),
    );
  }

  Widget _buildChatMessageItem(
      Map<String, dynamic> msg, Color darkBrown, Color textMuted) {
    final isBot = msg['isBot'] as bool? ?? false;
    final isMe = msg['sender'] == 'You';

    if (isMe) {
      return _buildOutgoingMessage(msg, darkBrown);
    }

    return _buildIncomingMessage(msg, isBot, darkBrown, textMuted);
  }

  /// Modern, compact outgoing speech bubble with warm sunset terracotta styling
  Widget _buildOutgoingMessage(Map<String, dynamic> msg, Color darkBrown) {
    final text = msg['message'] as String;
    final time = msg['time'] as String? ?? '';
    final isShort = text.length <= 22 && !text.contains('\n');

    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.74,
            minWidth: 70.0,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE85A1C), Color(0xFFF2742E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE85A1C).withValues(alpha: 0.22),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: isShort
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        text,
                        style: GoogleFonts.fredoka(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            time,
                            style: GoogleFonts.fredoka(
                              fontSize: 10.5,
                              color: Colors.white.withValues(alpha: 0.82),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Icon(
                            Icons.done_all_rounded,
                            size: 13,
                            color: Colors.white.withValues(alpha: 0.88),
                          ),
                        ],
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        text,
                        style: GoogleFonts.fredoka(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            time,
                            style: GoogleFonts.fredoka(
                              fontSize: 10.5,
                              color: Colors.white.withValues(alpha: 0.82),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Icon(
                            Icons.done_all_rounded,
                            size: 13,
                            color: Colors.white.withValues(alpha: 0.88),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  /// Incoming speech bubble matching exact Trippy reference styling and colors
  Widget _buildIncomingMessage(
      Map<String, dynamic> msg, bool isBot, Color darkBrown, Color textMuted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Mascot Avatar (42x42 circle)
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: ClipOval(
              child: Image.asset(
                msg['avatar'] as String,
                width: 42,
                height: 42,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, st) => Container(
                  width: 42,
                  height: 42,
                  color: const Color(0xFFE8DFD5),
                  child: const Icon(
                    Icons.pets_rounded,
                    size: 22,
                    color: Color(0xFF6B5A50),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Content: Sender Name + Speech Bubble Card
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.74,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Sender Name (above the bubble!)
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 5.0),
                  child: Text(
                    msg['sender'] as String,
                    style: GoogleFonts.fredoka(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: isBot
                          ? const Color(0xFFE65100)
                          : const Color(0xFF2E1C14),
                    ),
                  ),
                ),

                // Speech Bubble Card matching exact reference colors & rounding
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF8F3),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    border: Border.all(
                      color: const Color(0xFFEFE6DC),
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: darkBrown.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Message Text (with rich formatting for 'Tokyo adventure')
                      _buildMessageText(
                        msg['message'] as String,
                        const Color(0xFF2E1C14),
                      ),

                      // Bottom Row: Reaction Pill + Timestamp
                      if (msg['reactionEmoji'] != null || msg['time'] != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Reaction Pill
                            if (msg['reactionEmoji'] != null)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    final current = int.tryParse(msg['reactionCount']?.toString() ?? '12') ?? 12;
                                    final reacted = msg['userReacted'] == true;
                                    msg['userReacted'] = !reacted;
                                    msg['reactionCount'] = (reacted ? current - 1 : current + 1).toString();
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3E9DF),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        msg['reactionEmoji'] as String,
                                        style: const TextStyle(fontSize: 12.5),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        msg['reactionCount'] as String,
                                        style: GoogleFonts.fredoka(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF382319),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              const SizedBox(),

                            const SizedBox(width: 14),

                            // Timestamp
                            if (msg['time'] != null)
                              Text(
                                msg['time'] as String,
                                style: GoogleFonts.fredoka(
                                  fontSize: 11.5,
                                  color: const Color(0xFFA69588),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                          ],
                        ),
                      ],
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

  /// Formats message text with bold emphasis on key phrases like 'Tokyo adventure'
  Widget _buildMessageText(String message, Color defaultColor) {
    if (message.contains('Tokyo adventure')) {
      final parts = message.split('Tokyo adventure');
      return RichText(
        text: TextSpan(
          style: GoogleFonts.fredoka(
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
            color: defaultColor,
            height: 1.35,
          ),
          children: [
            TextSpan(text: parts[0]),
            const TextSpan(
              text: 'Tokyo adventure',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            if (parts.length > 1) TextSpan(text: parts[1]),
          ],
        ),
      );
    }
    return Text(
      message,
      style: GoogleFonts.fredoka(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        color: defaultColor,
        height: 1.35,
      ),
    );
  }

  /// Illustrated Japanese clipboard chatbox with base_layer_chatbox as the base layer.
  /// Centralized, naturally blended, and sized with comfortable touch targets.
  Widget _buildBottomChatBar(
      Color brandOrange, Color darkBrown, Color textMuted) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth;
        // Aspect ratio of base_layer_chatbox.png: 1940 / 528 ≈ 3.674
        final barHeight = (barWidth / 3.674).clamp(94.0, 118.0);
        const pillHeight = 48.0;

        return SizedBox(
          width: barWidth,
          height: barHeight,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // 1. Transparent Base Layer Image underneath the chatbox
              Positioned.fill(
                child: Image.asset(
                  'assets/journey/base_layer_chatbox.png',
                  fit: BoxFit.fill,
                  errorBuilder: (ctx, err, st) {
                    return Image.asset(
                      'assets/journey/base_layer_chatbox.jpg',
                      fit: BoxFit.fill,
                    );
                  },
                ),
              ),

              // 2. Naturally Blended & Perfectly Centralized Pill Input Field
              Positioned(
                left: barWidth * 0.128, // Symmetrically centered between stamps
                right: barWidth * 0.128,
                top: (barHeight - pillHeight) * 0.5 + 0.5, // Centered vertically on parchment
                height: pillHeight,
                child: Container(
                  padding: const EdgeInsets.only(left: 16, right: 6),
                  decoration: BoxDecoration(
                    // Sampled pill body: warm ivory cream #FEF8F2
                    color: const Color(0xFFFEF8F2).withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFEADBCE).withValues(alpha: 0.70),
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF382315).withValues(alpha: 0.03),
                        blurRadius: 5,
                        offset: const Offset(0, 1.5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Text input field
                      Expanded(
                        child: TextField(
                          controller: _chatController,
                          style: GoogleFonts.fredoka(
                            fontSize: 14.5,
                            color: const Color(0xFF2E1C14),
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Say something...',
                            hintStyle: GoogleFonts.fredoka(
                              fontSize: 14.0,
                              color: const Color(0xFFA69385),
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),

                      // 1. Photo / Gallery Icon with exact circular effect & terracotta stroke
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Photo attachment coming soon!',
                                style: GoogleFonts.fredoka(color: Colors.white),
                              ),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            // Sampled circular button background: warm peachy cream #FCF0E4
                            color: Color(0xFFFCF0E4),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 20.5,
                              // Sampled icon stroke: warm terracotta brown #743414
                              color: Color(0xFF743414),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 6),

                      // 2. Mic / Voice Icon with exact circular effect & terracotta stroke
                      GestureDetector(
                        onTap: () {
                          if (_chatController.text.trim().isNotEmpty) {
                            _sendMessage();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Voice input coming soon!',
                                  style: GoogleFonts.fredoka(color: Colors.white),
                                ),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            // Sampled circular button background: warm peachy cream #FCF0E4
                            color: Color(0xFFFCF0E4),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              _chatController.text.trim().isNotEmpty
                                  ? Icons.arrow_upward_rounded
                                  : Icons.mic_none_rounded,
                              size: 21.0,
                              // Sampled icon stroke: warm terracotta brown #743414
                              color: const Color(0xFF743414),
                            ),
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
      },
    );
  }

  // ===========================================================================
  // TAB 1: TRIP (ITINERARY)
  // ===========================================================================
  Widget _buildTripTab(Color brandOrange, Color darkBrown, Color textMuted) {
    return const SizedBox();
  }

  // ===========================================================================
  // TAB 2: BOOKINGS
  // ===========================================================================
  Widget _buildBookingsTab(
      Color brandOrange, Color darkBrown, Color textMuted) {
    return const SizedBox();
  }

  // ===========================================================================
  // TAB 3: DIARY
  // ===========================================================================
  Widget _buildDiaryTab(Color brandOrange, Color darkBrown, Color textMuted) {
    return const SizedBox();
  }

  // ===========================================================================
  // TAB 4: FINANCE
  // ===========================================================================
  Widget _buildFinanceTab(Color brandOrange, Color darkBrown, Color textMuted) {
    return const SizedBox();
  }
}

/// Realistic 3D pushpin painted with shadow, tapered needle, sculpted neck,
/// rounded grip knob, and glossy highlight matching the reference image.
class RealisticPushPin extends StatelessWidget {
  final double size;
  const RealisticPushPin({super.key, this.size = 28.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RealisticPushPinPainter(),
      ),
    );
  }
}

class _RealisticPushPinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // Center of rotation
    canvas.translate(size.width * 0.5, size.height * 0.5);
    // Rotate ~45 degrees pointing down-left into the paper
    canvas.rotate(0.785);

    // 1. Soft oval cast shadow on paper
    final shadowPaint = Paint()
      ..color = const Color(0x381A0F0A)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
    final shadowPath = Path()
      ..addOval(Rect.fromCenter(
        center: const Offset(3.5, 3.5),
        width: 8.0,
        height: 14.0,
      ));
    canvas.drawPath(shadowPath, shadowPaint);

    // 2. Tapered metal needle
    final needlePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF90A4AE), Color(0xFF37474F)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(const Rect.fromLTWH(-1.2, 3.0, 2.4, 9.5));

    final needlePath = Path()
      ..moveTo(-1.1, 3.0)
      ..lineTo(1.1, 3.0)
      ..lineTo(0.2, 12.0)
      ..lineTo(-0.2, 12.0)
      ..close();
    canvas.drawPath(needlePath, needlePaint);

    // 3. Plastic collar / base rim
    final collarPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF4A342B), Color(0xFF1E130E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(const Rect.fromLTWH(-5.0, 0.0, 10.0, 3.5));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-5.0, 0.5, 10.0, 3.5),
        const Radius.circular(1.8),
      ),
      collarPaint,
    );

    // 4. Narrow neck / waist
    final neckPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF382319), Color(0xFF170E0A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(const Rect.fromLTWH(-3.0, -3.5, 6.0, 4.5));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-3.0, -3.5, 6.0, 4.5),
        const Radius.circular(1.2),
      ),
      neckPaint,
    );

    // 5. Main Rounded Head / Grip Knob
    final headPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.35, -0.4),
        radius: 0.85,
        colors: [
          Color(0xFF5D3F33), // specular warm highlight
          Color(0xFF2E1C14), // rich dark brown
          Color(0xFF120A07), // deep shadow
        ],
        stops: [0.0, 0.55, 1.0],
      ).createShader(const Rect.fromLTWH(-6.5, -12.5, 13.0, 10.0));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-6.5, -12.5, 13.0, 10.0),
        const Radius.circular(4.5),
      ),
      headPaint,
    );

    // 6. Glossy reflection highlight on knob
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.38)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.8);
    canvas.drawCircle(const Offset(-2.2, -8.5), 1.6, highlightPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
