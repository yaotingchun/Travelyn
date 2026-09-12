import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Interactive modal sheet for "Resolve Conflict" Simulation (Simulation 1).
/// Displays the AI Harmonized Itinerary proposal, traveler consensus status,
/// resolved schedule changes, and action buttons for user approval.
class TripConflictApprovalSheet extends StatelessWidget {
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final String destination;

  const TripConflictApprovalSheet({
    super.key,
    required this.onApprove,
    required this.onReject,
    this.destination = 'Tokyo, Japan',
  });

  /// Presents the interactive modal bottom sheet with haptic feedback.
  static Future<bool?> show(
    BuildContext context, {
    VoidCallback? onApprove,
    VoidCallback? onReject,
    String destination = 'Tokyo, Japan',
  }) async {
    HapticFeedback.mediumImpact();

    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: const Color(0xFF2E1C14).withValues(alpha: 0.50),
      builder: (ctx) => TripConflictApprovalSheet(
        onApprove: () {
          Navigator.of(ctx).pop(true);
        },
        onReject: () {
          Navigator.of(ctx).pop(false);
        },
        destination: destination,
      ),
    );

    if (result == true) {
      onApprove?.call();
    } else if (result == false) {
      onReject?.call();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxSheetHeight = screenHeight * 0.90;

    return Container(
      constraints: BoxConstraints(
        maxHeight: maxSheetHeight,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fixed Top Header & Close Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Close button
                  GestureDetector(
                    onTap: onReject,
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
            ),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Mascot Illustration
                    Center(
                      child: Image.asset(
                        'assets/journey/mascot_adjust_plan.png',
                        width: 130,
                        height: 105,
                        fit: BoxFit.contain,
                        errorBuilder: (ctx, err, st) => const Icon(
                          Icons.handshake_rounded,
                          size: 54,
                          color: Color(0xFFE65100),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Title
                    Text(
                      'Balanced Day 1 Itinerary',
                      style: GoogleFonts.fredoka(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2E1C14),
                        letterSpacing: -0.4,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 6),

                    // Subtitle
                    Text(
                      "I analyzed everyone's chat conversation and synthesized a schedule where nobody has to compromise!",
                      style: GoogleFonts.fredoka(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF7A6A60),
                        height: 1.35,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 18),

                    // 1. Travelers' Consensus Card
                    _buildConsensusSection(),

                    const SizedBox(height: 16),

                    // 2. Harmonized Itinerary Changes Breakdown
                    _buildItineraryChangesSection(),
                  ],
                ),
              ),
            ),

            // Fixed Bottom Action Buttons
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDF9),
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFFEDE3D7).withValues(alpha: 0.7),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Primary Approve Button
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: onApprove,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE65100), Color(0xFFF2742E)],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE65100).withValues(alpha: 0.30),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 19,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Approve & Update Itinerary',
                              style: GoogleFonts.fredoka(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Secondary Keep Original Button
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: onReject,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        alignment: Alignment.center,
                        child: Text(
                          'Keep Original Plan',
                          style: GoogleFonts.fredoka(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF7A6A60),
                          ),
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
    );
  }

  Widget _buildConsensusSection() {
    final members = [
      (
        name: 'Alex',
        avatar: 'assets/journey/member_avatar_1.jpg',
        desire: 'Thrifting & street food',
        status: 'Approved',
        isApproved: true,
      ),
      (
        name: 'Brenda',
        avatar: 'assets/journey/member_avatar_2.jpg',
        desire: 'Meiji Shrine & AFURI lunch',
        status: 'Approved',
        isApproved: true,
      ),
      (
        name: 'Charlie',
        avatar: 'assets/journey/member_avatar_3.jpg',
        desire: 'teamLab entry slot',
        status: 'Approved',
        isApproved: true,
      ),
      (
        name: 'You',
        avatar: 'assets/journey/member_avatar_4.jpg',
        desire: 'Your approval needed',
        status: 'Pending',
        isApproved: false,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDE3D7), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E1C14).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Group Consensus Status',
                style: GoogleFonts.fredoka(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2E1C14),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFDE68A), width: 0.8),
                ),
                child: Text(
                  '3 of 4 Approved',
                  style: GoogleFonts.fredoka(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF92400E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: members.map((m) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: m.isApproved
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFE65100),
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                m.avatar,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, st) => const Icon(
                                  Icons.person_rounded,
                                  size: 22,
                                  color: Color(0xFF6B5A50),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: m.isApproved
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFF59E0B),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                              child: Icon(
                                m.isApproved
                                    ? Icons.check_rounded
                                    : Icons.hourglass_top_rounded,
                                size: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        m.name,
                        style: GoogleFonts.fredoka(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2E1C14),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        m.isApproved ? 'Approved 👍' : 'Pending ⏳',
                        style: GoogleFonts.fredoka(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: m.isApproved
                              ? const Color(0xFF059669)
                              : const Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildItineraryChangesSection() {
    final changes = [
      (
        time: '09:25 AM',
        title: 'Meiji Shrine & Forest Walk',
        tag: 'Brenda’s Priority',
        tagColor: const Color(0xFF00B894),
        description: 'Full 55-min peaceful forest stroll kept without rushing',
        icon: Icons.park_rounded,
      ),
      (
        time: '10:35 AM',
        title: 'Harajuku & Cat Street Thrifting',
        tag: 'Alex’s Priority (+25 min)',
        tagColor: const Color(0xFFD97706),
        description: 'Added +25 min thrift shopping route + quick street crepes',
        icon: Icons.checkroom_rounded,
      ),
      (
        time: '12:15 PM',
        title: 'AFURI Harajuku (Yuzu Ramen)',
        tag: 'Brenda’s Priority',
        tagColor: const Color(0xFFE65100),
        description: 'Sit-down artisan lunch preserved right at opening wave',
        icon: Icons.ramen_dining_rounded,
      ),
      (
        time: '15:20 PM',
        title: 'teamLab Planets Tokyo',
        tag: 'Charlie’s Priority',
        tagColor: const Color(0xFF2563EB),
        description: 'Booked entry slot locked with relaxed 35-min transit buffer',
        icon: Icons.palette_rounded,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDE3D7), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E1C14).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.alt_route_rounded,
                size: 17,
                color: Color(0xFFE65100),
              ),
              const SizedBox(width: 7),
              Text(
                'Schedule Adjustments',
                style: GoogleFonts.fredoka(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2E1C14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: changes.length,
            separatorBuilder: (ctx, i) => const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1, color: Color(0xFFF1EBE3)),
            ),
            itemBuilder: (ctx, index) {
              final c = changes[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: c.tagColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        c.icon,
                        size: 16,
                        color: c.tagColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                c.title,
                                style: GoogleFonts.fredoka(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2E1C14),
                                ),
                              ),
                            ),
                            Text(
                              c.time,
                              style: GoogleFonts.fredoka(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF8A7A70),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: c.tagColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            c.tag,
                            style: GoogleFonts.fredoka(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: c.tagColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          c.description,
                          style: GoogleFonts.fredoka(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF6B5A50),
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
