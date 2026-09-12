import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../services/booking_models.dart';
import '../../../services/booking_service.dart';
import '../../../services/url_helper.dart';
import 'booking_confirmation_dialog.dart';

/// Modal bottom sheet for Accommodation Booking with multi-platform price comparison
/// (Klook, Trip.com, Agoda, Booking.com, Official Direct) matching the Attraction Ticket UX.
class AccommodationBookingSheet {
  static void show({
    required BuildContext context,
    required HotelOption hotel,
    required int totalNights,
    required bool isSelected,
    required void Function({String? platformName}) onSelectStay,
    Color brandOrange = const Color(0xFFE65100),
    Color darkBrown = const Color(0xFF2E1C14),
    Color textMuted = const Color(0xFF6B5A50),
  }) {
    final effectiveNights = totalNights > 0 ? totalNights : 1;
    final platformDeals = BookingService.getHotelPlatformDeals(
      hotel: hotel,
      totalNights: effectiveNights,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        bool currentSelected = isSelected;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.88,
              decoration: const BoxDecoration(
                color: Color(0xFFFDF7F0),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  // Drag handle
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 10),

                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Hero Image with Rating Pill, Match Badge & Close Button
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: hotel.imagePath != null
                                    ? Image.asset(
                                        hotel.imagePath!,
                                        height: 175,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => Container(
                                          height: 175,
                                          color: const Color(0xFFEFE6DC),
                                          child: const Icon(
                                            Icons.hotel_rounded,
                                            size: 44,
                                            color: Color(0xFFB0A398),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        height: 175,
                                        color: const Color(0xFFEFE6DC),
                                        child: const Icon(
                                          Icons.hotel_rounded,
                                          size: 44,
                                          color: Color(0xFFB0A398),
                                        ),
                                      ),
                              ),

                              // Rating Badge (Top Left)
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.68),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        color: Color(0xFFFFD54F),
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${hotel.rating} (${hotel.reviewsCount})',
                                        style: GoogleFonts.nunito(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Match Score Badge (Top Center-Left)
                              Positioned(
                                bottom: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: brandOrange,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    '${hotel.matchScore}% Trip Match',
                                    style: GoogleFonts.fredoka(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),

                              // Close Button (Top Right)
                              Positioned(
                                top: 12,
                                right: 12,
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(ctx),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.55),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.close_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // 2. Hotel Name & Neighborhood
                          Text(
                            hotel.name,
                            style: GoogleFonts.fredoka(
                              fontSize: 23,
                              fontWeight: FontWeight.w700,
                              color: darkBrown,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                Icons.place_rounded,
                                size: 15,
                                color: brandOrange,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${hotel.neighborhood}, ${hotel.city}',
                                  style: GoogleFonts.nunito(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: textMuted,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // 3. Stay Details Box (Schedule & Transit)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFEDE3D7)),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.login_rounded,
                                            size: 16,
                                            color: brandOrange,
                                          ),
                                          const SizedBox(width: 6),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Check-in',
                                                style: GoogleFonts.nunito(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: textMuted,
                                                ),
                                              ),
                                              Text(
                                                hotel.checkInTime,
                                                style: GoogleFonts.fredoka(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: darkBrown,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 26,
                                      color: const Color(0xFFEDE3D7),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                    ),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.logout_rounded,
                                            size: 16,
                                            color: brandOrange,
                                          ),
                                          const SizedBox(width: 6),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Check-out',
                                                style: GoogleFonts.nunito(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: textMuted,
                                                ),
                                              ),
                                              Text(
                                                hotel.checkOutTime,
                                                style: GoogleFonts.fredoka(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: darkBrown,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 26,
                                      color: const Color(0xFFEDE3D7),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                    ),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.night_shelter_rounded,
                                            size: 16,
                                            color: brandOrange,
                                          ),
                                          const SizedBox(width: 6),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Duration',
                                                style: GoogleFonts.nunito(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: textMuted,
                                                ),
                                              ),
                                              Text(
                                                '$effectiveNights ${effectiveNights == 1 ? "Night" : "Nights"}',
                                                style: GoogleFonts.fredoka(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: darkBrown,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Divider(
                                    height: 1,
                                    color: Color(0xFFF2EAE0),
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.directions_walk_rounded,
                                      size: 15,
                                      color: Color(0xFF2E7D32),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        hotel.walkToStation,
                                        style: GoogleFonts.nunito(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: darkBrown,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // 4. Trippy AI Insight Banner
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF6EE),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFFFDEC2),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '💡',
                                  style: TextStyle(fontSize: 15),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: GoogleFonts.nunito(
                                        fontSize: 12,
                                        color: const Color(0xFF6B4A3A),
                                        height: 1.35,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Trippy found: ',
                                          style: GoogleFonts.nunito(
                                            fontWeight: FontWeight.w800,
                                            color: brandOrange,
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                              'Klook offers the best verified rate at RM${hotel.pricePerNightRm}/nt (saving up to RM${(hotel.pricePerNightRm * 0.18 * effectiveNights).round()} for $effectiveNights nights) with instant confirmation and free cancellation!',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // 5. Section Header: Multi-platform Comparison
                          Row(
                            children: [
                              Text(
                                'Compare Booking Platforms',
                                style: GoogleFonts.fredoka(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: darkBrown,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Live rates',
                                  style: GoogleFonts.nunito(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF2E7D32),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Compare verified prices, room types & inclusions across major providers',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: textMuted,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // 6. List of Platform Cards
                          ...platformDeals.map(
                            (platform) => _buildPlatformCard(
                              context: context,
                              sheetContext: ctx,
                              hotel: hotel,
                              platform: platform,
                              totalNights: effectiveNights,
                              brandOrange: brandOrange,
                              darkBrown: darkBrown,
                              onSelectStay: onSelectStay,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 7. Bottom Action Button: Mark as Selected / Deselect
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF7F0),
                      boxShadow: [
                        BoxShadow(
                          color: darkBrown.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: currentSelected
                              ? const Color(0xFF2E7D32)
                              : brandOrange,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          setSheetState(() {
                            currentSelected = !currentSelected;
                          });
                          onSelectStay();
                          Navigator.pop(ctx);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              currentSelected
                                  ? Icons.check_circle_rounded
                                  : Icons.bookmark_add_rounded,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              currentSelected
                                  ? 'Stay Selected ✓ (Tap to Deselect)'
                                  : 'Select This Stay',
                              style: GoogleFonts.fredoka(
                                fontSize: 15,
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
          },
        );
      },
    );
  }

  /// Individual comparison platform card (e.g. Klook, Trip.com, Agoda, Booking.com)
  static Widget _buildPlatformCard({
    required BuildContext context,
    required BuildContext sheetContext,
    required HotelOption hotel,
    required PlatformTicketPrice platform,
    required int totalNights,
    required Color brandOrange,
    required Color darkBrown,
    required void Function({String? platformName}) onSelectStay,
  }) {
    final totalRm = platform.priceRm * totalNights;
    final totalOriginalRm = platform.originalPriceRm * totalNights;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: platform.isLowestPrice
              ? const Color(0xFFFF5722)
              : const Color(0xFFEDE3D7),
          width: platform.isLowestPrice ? 1.6 : 1.0,
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
        children: [
          // Header Row: Platform Name + Badges & Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Platform Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: platform.brandColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  platform.platformName,
                  style: GoogleFonts.fredoka(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: platform.brandColor,
                  ),
                ),
              ),

              if (platform.badge != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: platform.isLowestPrice
                        ? const Color(0xFFFFF0EB)
                        : const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    platform.badge!,
                    style: GoogleFonts.nunito(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: platform.isLowestPrice
                          ? const Color(0xFFD84315)
                          : const Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],

              const Spacer(),

              // Price Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'RM${platform.priceRm}',
                        style: GoogleFonts.fredoka(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: platform.isLowestPrice
                              ? const Color(0xFFE65100)
                              : darkBrown,
                        ),
                      ),
                      Text(
                        '/nt',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF8A766E),
                        ),
                      ),
                    ],
                  ),
                  if (platform.originalPriceRm > platform.priceRm) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'RM${platform.originalPriceRm}',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFB0A398),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${platform.discountPercentage}% OFF',
                          style: GoogleFonts.nunito(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFE65100),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),

          // Total Stay Cost Callout
          if (totalNights > 1) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'RM$totalRm total ($totalNights nights)',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF5A483E),
                  ),
                ),
              ],
            ),
          ],

          // Room Type Tag
          if (platform.roomType != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF7EFE6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.king_bed_outlined,
                    size: 13,
                    color: Color(0xFF8A766E),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      platform.roomType!,
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF5A483E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Inclusions / Perks
          ...platform.perks.map(
            (perk) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 13,
                    color: Color(0xFF2E7D32),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      perk,
                      style: GoogleFonts.nunito(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5A483E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Action Button to book on platform
          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: platform.brandColor,
                  width: 1.2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: platform.brandColor.withValues(alpha: 0.04),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                // Pop the bottom sheet first so the pop-out modal appears cleanly over the page
                Navigator.pop(sheetContext);

                // Open external booking site
                if (platform.bookingUrl.isNotEmpty) {
                  UrlHelper.launchExternalUrl(context, platform.bookingUrl);
                }

                // Show pop-out dialog asking if they already booked or haven't booked yet
                BookingConfirmationDialog.show(
                  context: context,
                  title: 'Did you complete your stay booking?',
                  itemName: hotel.name,
                  platformName: platform.platformName,
                  platformBrandColor: platform.brandColor,
                  headerIcon: Icons.hotel_rounded,
                  confirmText: 'Already booked',
                  notYetText: "Haven't booked yet",
                  brandOrange: brandOrange,
                  darkBrown: darkBrown,
                  onAlreadyBooked: () {
                    onSelectStay(platformName: platform.platformName);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Confirmed! ${hotel.name} booked via ${platform.platformName} is now your selected stay! 🎉',
                                style: GoogleFonts.fredoka(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: const Color(0xFF2E7D32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                  onNotYetBooked: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'No problem! You can select ${hotel.name} whenever your booking is confirmed.',
                                style: GoogleFonts.fredoka(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: darkBrown,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    platform.platformName == 'Official Hotel Direct'
                        ? 'Book Direct on Hotel Site'
                        : 'Book on ${platform.platformName}',
                    style: GoogleFonts.fredoka(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: platform.brandColor,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(
                    Icons.open_in_new_rounded,
                    size: 13,
                    color: platform.brandColor,
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
