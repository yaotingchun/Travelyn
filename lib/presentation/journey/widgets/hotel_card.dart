import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../services/booking_models.dart';
import 'accommodation_booking_sheet.dart';

/// Realistic hotel card with itinerary-driven match scoring,
/// check-in/out scheduling, concrete measurable reasons, and dynamic comparative badges.
class HotelCard extends StatefulWidget {
  final HotelOption hotel;
  final int totalNights;
  final HotelSortOption activeSort;
  final bool isSelected;
  final VoidCallback onSelect;
  final void Function(String? platformName)? onSelectWithPlatform;
  final Color brandOrange;
  final Color darkBrown;
  final Color textMuted;

  const HotelCard({
    super.key,
    required this.hotel,
    required this.totalNights,
    required this.activeSort,
    required this.isSelected,
    required this.onSelect,
    this.onSelectWithPlatform,
    this.brandOrange = const Color(0xFFE65100),
    this.darkBrown = const Color(0xFF2E1C14),
    this.textMuted = const Color(0xFF6B5A50),
  });

  @override
  State<HotelCard> createState() => _HotelCardState();
}

class _HotelCardState extends State<HotelCard> {
  bool _isExpanded = false;

  void _openBookingSheet() {
    HapticFeedback.lightImpact();
    AccommodationBookingSheet.show(
      context: context,
      hotel: widget.hotel,
      totalNights: widget.totalNights,
      isSelected: widget.isSelected,
      onSelectStay: ({String? platformName}) {
        if (widget.onSelectWithPlatform != null) {
          widget.onSelectWithPlatform!(platformName);
        } else {
          widget.onSelect();
        }
      },
      brandOrange: widget.brandOrange,
      darkBrown: widget.darkBrown,
      textMuted: widget.textMuted,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hotel = widget.hotel;
    final totalPrice = hotel.calculateTotalPrice(widget.totalNights);
    final badgeLabel = hotel.getDynamicBadgeLabel(widget.activeSort);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: widget.isSelected
              ? widget.brandOrange
              : const Color(0xFFEDE3D7),
          width: widget.isSelected ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.isSelected
                ? widget.brandOrange.withValues(alpha: 0.12)
                : widget.darkBrown.withValues(alpha: 0.05),
            blurRadius: widget.isSelected ? 14 : 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Section: Comparative Badge + Trip Match Score
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? widget.brandOrange.withValues(alpha: 0.12)
                  : const Color(0xFFFFF3E6),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: const Border(
                bottom: BorderSide(
                  color: Color(0xFFFFE5CC),
                  width: 1.0,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    badgeLabel,
                    style: GoogleFonts.fredoka(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                      color: widget.brandOrange,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Trip Match Score Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: widget.brandOrange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${hotel.matchScore}% Match',
                    style: GoogleFonts.fredoka(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Main Body: Image + Hotel Details
          InkWell(
            onTap: _openBookingSheet,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hotel Thumbnail with review rating pill
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 96,
                    height: 106,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: hotel.imagePath != null
                              ? Image.asset(
                                  hotel.imagePath!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildImagePlaceholder(),
                                )
                              : _buildImagePlaceholder(),
                        ),
                        // Rating Pill on thumbnail
                        Positioned(
                          bottom: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: widget.darkBrown.withValues(alpha: 0.88),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 13,
                                  color: Color(0xFFFFB300),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '${hotel.rating} (${hotel.reviewsCount})',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
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

                const SizedBox(width: 14),

                // Hotel Details Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        hotel.name,
                        style: GoogleFonts.fredoka(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: widget.darkBrown,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 3),

                      // Neighborhood
                      Text(
                        '${hotel.neighborhood}, ${hotel.city}',
                        style: GoogleFonts.fredoka(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                          color: widget.textMuted,
                        ),
                      ),

                      const SizedBox(height: 5),

                      // Transit & Itinerary Proximity
                      Row(
                        children: [
                          Icon(
                            Icons.directions_walk_rounded,
                            size: 14,
                            color: widget.brandOrange,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              hotel.walkToStation,
                              style: GoogleFonts.fredoka(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: widget.darkBrown.withValues(alpha: 0.85),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Price & Total in RM
                      Row(
                        children: [
                          Text(
                            'RM${hotel.pricePerNightRm}',
                            style: GoogleFonts.fredoka(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: widget.brandOrange,
                            ),
                          ),
                          Text(
                            '/nt',
                            style: GoogleFonts.fredoka(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w400,
                              color: widget.textMuted,
                            ),
                          ),
                          const Spacer(),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3ECE3),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'RM$totalPrice (${widget.totalNights}n)',
                                style: GoogleFonts.fredoka(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: widget.darkBrown,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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

          // 3. Check-in / Check-out timing bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF7EFE6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.login_rounded, size: 14, color: widget.brandOrange),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Check-in',
                                style: GoogleFonts.fredoka(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: widget.textMuted,
                                ),
                              ),
                              Text(
                                hotel.checkInTime,
                                style: GoogleFonts.fredoka(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: widget.darkBrown,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 22,
                    color: const Color(0xFFDCCFC0),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.logout_rounded, size: 14, color: widget.brandOrange),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Check-out',
                                style: GoogleFonts.fredoka(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: widget.textMuted,
                                ),
                              ),
                              Text(
                                hotel.checkOutTime,
                                style: GoogleFonts.fredoka(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: widget.darkBrown,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 4. Booking Guarantees / Amenities Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _buildGuaranteeChip(
                  hotel.cancellationPolicy.contains('Free')
                      ? '✓ Free cancellation'
                      : 'Non-refundable',
                  isSuccess: hotel.cancellationPolicy.contains('Free'),
                ),
                _buildGuaranteeChip('✓ Breakfast included'),
                _buildGuaranteeChip('✓ Free Wi-Fi'),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 5. Expandable "Why this recommendation? ▾"
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5EA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFFE7D1),
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 16,
                    color: widget.brandOrange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Why? (Trip Match Breakdown)',
                    style: GoogleFonts.fredoka(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: widget.brandOrange,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: widget.brandOrange,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expanded Breakdown Section
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Match Score Breakdown Bars
                  ...hotel.matchBreakdown.entries.map((entry) {
                    final factor = entry.key;
                    final score = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 85,
                            child: Text(
                              factor,
                              style: GoogleFonts.fredoka(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: widget.textMuted,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: score / 100.0,
                                backgroundColor: const Color(0xFFEDE3D7),
                                color: widget.brandOrange,
                                minHeight: 6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 32,
                            child: Text(
                              '$score%',
                              style: GoogleFonts.fredoka(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: widget.darkBrown,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const Divider(color: Color(0xFFEDE3D7), height: 16),

                  // Measurable Itinerary Reasons
                  ...hotel.measurableReasons.map((reason) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 3),
                            child: Icon(
                              Icons.check_circle_rounded,
                              size: 14,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              reason,
                              style: GoogleFonts.fredoka(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                height: 1.35,
                                color: widget.darkBrown.withValues(alpha: 0.85),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),

          const SizedBox(height: 12),

          // 6. Action Button: Select / Selected
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                onPressed: _openBookingSheet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isSelected
                      ? const Color(0xFF2E7D32)
                      : widget.brandOrange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.isSelected
                          ? Icons.check_circle_rounded
                          : Icons.bookmark_add_rounded,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.isSelected
                          ? 'Selected Stay  ✓'
                          : 'Select This Stay',
                      style: GoogleFonts.fredoka(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuaranteeChip(String label, {bool isSuccess = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: isSuccess ? const Color(0xFFE8F5E9) : const Color(0xFFF3ECE3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: GoogleFonts.fredoka(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isSuccess ? const Color(0xFF2E7D32) : widget.darkBrown,
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFCC80), Color(0xFFFF8A65)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.apartment_rounded,
          color: Colors.white,
          size: 34,
        ),
      ),
    );
  }
}
