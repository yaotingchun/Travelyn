import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'trip_simulation_events_sheet.dart';

/// Top Hero Section of the Trip Details Screen.
/// Displays the pagoda & cherry blossoms photo, back arrow (<), destination title,
/// dates, overlapping member avatars, '+' invite button, and simulation '?' button.
class TripHeroHeader extends StatelessWidget {
  final String destination;
  final DateTime? startDate;
  final DateTime? endDate;
  final double heroImageHeight;
  final VoidCallback onBackTap;
  final VoidCallback onInviteTap;
  final VoidCallback? onSimulateTap;
  final Color darkBrown;

  const TripHeroHeader({
    super.key,
    required this.destination,
    this.startDate,
    this.endDate,
    required this.heroImageHeight,
    required this.onBackTap,
    required this.onInviteTap,
    this.onSimulateTap,
    this.darkBrown = const Color(0xFF2E1C14),
  });

  String _formatDateRange() {
    if (startDate != null && endDate != null) {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final start = startDate!;
      final end = endDate!;
      return '${start.day} ${months[start.month - 1]} – ${end.day} ${months[end.month - 1]} ${end.year}';
    }
    return '12 Sep – 18 Sep 2025';
  }

  String _getDestinationWithFlag() {
    final dest = destination;
    if (dest.contains('🇯🇵') || dest.contains('Japan')) {
      if (!dest.contains('🇯🇵')) return '$dest 🇯🇵';
      return dest;
    }
    return '$dest ✈️';
  }

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

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: heroImageHeight + 30.0,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Natural cherry blossom & pagoda image with top sky aligned
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
                  // Naked Back Arrow (<)
                  GestureDetector(
                    onTap: onBackTap,
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
                                color: const Color(0xFFFFF7F0)
                                    .withValues(alpha: 0.75),
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
                                color: const Color(0xFFFFF7F0)
                                    .withValues(alpha: 0.70),
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
                              onTap: onInviteTap,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: darkBrown.withValues(alpha: 0.10),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: const Color(0xFFEDE3D7),
                                    width: 1.0,
                                  ),
                                ),
                                child: Center(
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

                  // Top Right: Question Mark Simulation Button (?)
                  GestureDetector(
                    onTap: onSimulateTap ?? () => TripSimulationEventsSheet.show(context),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 34,
                      height: 34,
                      margin: const EdgeInsets.only(top: 2.0, left: 6.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: darkBrown.withValues(alpha: 0.12),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFFEDE3D7),
                          width: 1.2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.question_mark_rounded,
                          size: 18,
                          color: darkBrown,
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
  }
}
