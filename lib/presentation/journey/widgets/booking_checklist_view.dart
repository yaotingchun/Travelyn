import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../services/booking_models.dart';
import '../../../services/booking_service.dart';
import '../../../services/url_helper.dart';

/// Default view for the Bookings tab inside Journey screen.
/// Accurately matches the user's reference mockup:
/// - Hero Header with pagoda backdrop, Bookings title & subtitle
/// - 5 Travelers card with overlapping member avatars
/// - Accommodation section with hotel photo & "Not yet booked" status
/// - Flights section with flight photo & "Not yet booked" status
/// - Attraction Tickets section (Aquarium, Zoo, Museum)
/// - Bottom "Let's lock in these plans!" banner
class BookingChecklistView extends StatefulWidget {
  final List<BookingChecklistItem> checklistItems;
  final String destination;
  final String dateRangeStr;
  final int travellerCount;
  final String tripType;
  final ValueChanged<BookingType> onItemTapped;
  final ValueChanged<String> onToggleItem;
  final VoidCallback? onBackTap;
  final Color brandOrange;
  final Color darkBrown;
  final Color textMuted;

  const BookingChecklistView({
    super.key,
    required this.checklistItems,
    required this.destination,
    required this.dateRangeStr,
    required this.travellerCount,
    required this.tripType,
    required this.onItemTapped,
    required this.onToggleItem,
    this.onBackTap,
    this.brandOrange = const Color(0xFFE65100),
    this.darkBrown = const Color(0xFF2E1C14),
    this.textMuted = const Color(0xFF8A766E),
  });

  @override
  State<BookingChecklistView> createState() => _BookingChecklistViewState();
}

class _BookingChecklistViewState extends State<BookingChecklistView> {
  // Booking status toggles for each item
  bool _isHotelBooked = false;
  bool _isFlightBooked = false;
  bool _isAquariumBooked = false;
  bool _isZooBooked = false;
  bool _isMuseumBooked = false;

  String get _cleanCity {
    if (widget.destination.isEmpty) return 'Tokyo';
    return widget.destination.split(',').first.trim();
  }

  String get _hotelAreaSubtitle {
    final lower = _cleanCity.toLowerCase();
    if (lower.contains('kyoto')) return 'Kyoto Station & Gion Area, Kyoto';
    if (lower.contains('tokyo')) return 'Shinjuku & Ginza Area, Tokyo';
    if (lower.contains('osaka')) return 'Namba & Dotonbori Area, Osaka';
    if (lower.contains('kobe')) return 'Sannomiya & Harbor Area, Kobe';
    if (lower.contains('seoul')) return 'Myeongdong & Hongdae Area, Seoul';
    if (lower.contains('bangkok')) return 'Sukhumvit & Asok Area, Bangkok';
    if (lower.contains('london')) return 'West End & Central Area, London';
    if (lower.contains('paris')) return 'Central & Seine Area, Paris';
    return 'Central & Downtown Area, $_cleanCity';
  }

  void _showAttractionSheet({
    required String attractionType, // 'aquarium', 'zoo', 'museum'
    required bool isBooked,
    required ValueChanged<bool> onToggleBooked,
  }) {
    final detail = BookingService.getAttractionTicketDetails(
      attractionType: attractionType,
      city: _cleanCity,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
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

                  // Scrollable comparison content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hero Image with tags & close button
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  detail.imageAsset,
                                  height: 175,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Container(
                                    height: 175,
                                    color: const Color(0xFFEFE6DC),
                                    child: const Icon(Icons.image_outlined, size: 40),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.65),
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
                                        '${detail.rating} (${detail.reviewCount})',
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

                          // Title & Subtitle
                          Text(
                            detail.title,
                            style: GoogleFonts.fredoka(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: widget.darkBrown,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            detail.subtitle,
                            style: GoogleFonts.nunito(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: widget.textMuted,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Hours & Location Info Row
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFEDE3D7)),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.access_time_rounded,
                                  size: 16,
                                  color: Color(0xFFE65100),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    detail.openingHours,
                                    style: GoogleFonts.nunito(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: widget.darkBrown,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Real Address & Transit Row
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFEDE3D7)),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  size: 16,
                                  color: Color(0xFFE65100),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    detail.address,
                                    style: GoogleFonts.nunito(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: widget.darkBrown,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if (detail.smartInsight.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7F0),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFFFDEC9)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.lightbulb_rounded,
                                    size: 16,
                                    color: Color(0xFFE65100),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      detail.smartInsight,
                                      style: GoogleFonts.nunito(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF8A3B00),
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 18),

                          // Section Header: Multi-platform Comparison
                          Row(
                            children: [
                              Text(
                                'Compare Ticket Platforms',
                                style: GoogleFonts.fredoka(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: widget.darkBrown,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
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
                            'Compare verified prices and inclusions across major providers',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: widget.textMuted,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // List of Platform Cards
                          ...detail.platforms.map(
                            (platform) => _buildPlatformCard(ctx, platform, () {
                              setSheetState(() {
                                isBooked = true;
                              });
                              onToggleBooked(true);
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Action Button: Mark as Booked toggle
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF7F0),
                      boxShadow: [
                        BoxShadow(
                          color: widget.darkBrown.withValues(alpha: 0.05),
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
                          backgroundColor: isBooked
                              ? const Color(0xFF2E7D32)
                              : widget.brandOrange,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          setSheetState(() {
                            isBooked = !isBooked;
                          });
                          onToggleBooked(isBooked);
                          Navigator.pop(ctx);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isBooked
                                  ? Icons.check_circle_rounded
                                  : Icons.bookmark_add_rounded,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isBooked
                                  ? 'Ticket Booked (Tap to Undo)'
                                  : 'Mark Ticket as Booked',
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

  /// Individual comparison platform card (e.g. Klook, Trip.com, KKday)
  Widget _buildPlatformCard(
    BuildContext ctx,
    PlatformTicketPrice platform,
    VoidCallback onBookedSimulated,
  ) {
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
            color: widget.darkBrown.withValues(alpha: 0.04),
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
                  Text(
                    'RM${platform.priceRm}',
                    style: GoogleFonts.fredoka(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: platform.isLowestPrice
                          ? const Color(0xFFE65100)
                          : widget.darkBrown,
                    ),
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
                onBookedSimulated();
                Navigator.pop(ctx);
                if (platform.bookingUrl.isNotEmpty) {
                  UrlHelper.launchExternalUrl(context, platform.bookingUrl);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Redirecting to ${platform.platformName}... Ticket will sync to Travelyn!',
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: const Color(0xFF2E1C14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    platform.platformName == 'Official Box Office'
                        ? 'View Counter Details'
                        : 'Book on ${platform.platformName}',
                    style: GoogleFonts.fredoka(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: platform.brandColor,
                    ),
                  ),
                  const SizedBox(width: 4),
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

  @override
  Widget build(BuildContext context) {
    final city = _cleanCity;
    final totalTravelers = widget.travellerCount <= 1 ? 5 : widget.travellerCount;

    // Sync with external booking checklist state if available
    final hotelItem = widget.checklistItems.cast<BookingChecklistItem?>().firstWhere(
      (item) => item?.type == BookingType.stays,
      orElse: () => null,
    );
    final flightItem = widget.checklistItems.cast<BookingChecklistItem?>().firstWhere(
      (item) => item?.type == BookingType.flights,
      orElse: () => null,
    );

    final isHotelActuallyBooked = _isHotelBooked || (hotelItem?.status == BookingItemStatus.booked);
    final isFlightActuallyBooked = _isFlightBooked || (flightItem?.status == BookingItemStatus.booked);

    final hotelTitle = (isHotelActuallyBooked && hotelItem?.bookedOptionName != null)
        ? hotelItem!.bookedOptionName!
        : 'Hotel in $city';
    final hotelSubtitle = (isHotelActuallyBooked && hotelItem?.bookedOptionName != null)
        ? 'Shinjuku & Ginza Area • Booking Confirmed 🏨'
        : _hotelAreaSubtitle;

    final flightTitle = (isFlightActuallyBooked && flightItem?.bookedOptionName != null)
        ? flightItem!.bookedOptionName!
        : 'Kuala Lumpur ↔ $city';
    final flightSubtitle = isFlightActuallyBooked
        ? 'Round trip • $totalTravelers Travelers • Confirmed ✈️'
        : 'Round trip • $totalTravelers Travelers';

    final activeDateRange = widget.dateRangeStr.isNotEmpty
        ? widget.dateRangeStr
        : '11–14 Sep 2026';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. ACCOMMODATION SECTION
          _buildSectionTitle(
            iconAsset: 'assets/journey/accomodation_icon.png',
            title: 'Accommodation',
          ),
          const SizedBox(height: 10),
          _buildBookingCard(
            imageAsset: 'assets/journey/hotel.jpeg',
            title: hotelTitle,
            subtitle: hotelSubtitle,
            dateOrContext: activeDateRange,
            isBooked: isHotelActuallyBooked,
            isDateRow: true,
            onCardTap: () {
              HapticFeedback.lightImpact();
              widget.onItemTapped(BookingType.stays);
            },
            onToggleBooked: () {
              HapticFeedback.selectionClick();
              setState(() => _isHotelBooked = !_isHotelBooked);
            },
          ),

          const SizedBox(height: 22),

          // 2. FLIGHTS SECTION
          _buildSectionTitle(
            iconAsset: 'assets/journey/flight_icon.png',
            title: 'Flights',
          ),
          const SizedBox(height: 10),
          _buildBookingCard(
            imageAsset: 'assets/journey/flight.jpeg',
            title: flightTitle,
            subtitle: flightSubtitle,
            dateOrContext: activeDateRange,
            isBooked: isFlightActuallyBooked,
            isDateRow: true,
            onCardTap: () {
              HapticFeedback.lightImpact();
              widget.onItemTapped(BookingType.flights);
            },
            onToggleBooked: () {
              HapticFeedback.selectionClick();
              setState(() => _isFlightBooked = !_isFlightBooked);
            },
          ),

          const SizedBox(height: 22),

          // 3. ATTRACTION TICKETS SECTION
          _buildSectionTitle(
            iconAsset: 'assets/journey/ticket_icon.png',
            title: 'Attraction Tickets',
          ),
          const SizedBox(height: 10),

          // Card 1: Aquarium (Maxell Aqua Park Shinagawa)
          _buildBookingCard(
            imageAsset: 'assets/journey/aquarium.jpeg',
            title: 'Aquarium',
            subtitle: 'Maxell Aqua Park Shinagawa',
            dateOrContext: city,
            isBooked: _isAquariumBooked,
            isDateRow: false,
            onCardTap: () {
              _showAttractionSheet(
                attractionType: 'aquarium',
                isBooked: _isAquariumBooked,
                onToggleBooked: (val) =>
                    setState(() => _isAquariumBooked = val),
              );
            },
            onToggleBooked: () {
              HapticFeedback.selectionClick();
              setState(() => _isAquariumBooked = !_isAquariumBooked);
            },
          ),
          const SizedBox(height: 12),

          // Card 2: Zoo (Ueno Zoo)
          _buildBookingCard(
            imageAsset: 'assets/journey/zoo.jpeg',
            title: 'Zoo',
            subtitle: 'Ueno Zoo',
            dateOrContext: city,
            isBooked: _isZooBooked,
            isDateRow: false,
            onCardTap: () {
              _showAttractionSheet(
                attractionType: 'zoo',
                isBooked: _isZooBooked,
                onToggleBooked: (val) =>
                    setState(() => _isZooBooked = val),
              );
            },
            onToggleBooked: () {
              HapticFeedback.selectionClick();
              setState(() => _isZooBooked = !_isZooBooked);
            },
          ),
          const SizedBox(height: 12),

          // Card 3: Museum (Tokyo National Museum)
          _buildBookingCard(
            imageAsset: 'assets/journey/musuem.jpeg',
            title: 'Museum',
            subtitle: 'Tokyo National Museum',
            dateOrContext: city,
            isBooked: _isMuseumBooked,
            isDateRow: false,
            onCardTap: () {
              _showAttractionSheet(
                attractionType: 'museum',
                isBooked: _isMuseumBooked,
                onToggleBooked: (val) =>
                    setState(() => _isMuseumBooked = val),
              );
            },
            onToggleBooked: () {
              HapticFeedback.selectionClick();
              setState(() => _isMuseumBooked = !_isMuseumBooked);
            },
          ),

          const SizedBox(height: 22),

                // 6. BOTTOM BANNER CARD ("Let's lock in these plans!")
                Container(
                  margin: const EdgeInsets.only(bottom: 120),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: widget.darkBrown.withValues(alpha: 0.07),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.asset(
                      'assets/journey/banner.jpeg',
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, st) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF6ED),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/mascot/avatar.png',
                                width: 54,
                                height: 54,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Let's lock in these plans!",
                                      style: GoogleFonts.fredoka(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w700,
                                        color: widget.darkBrown,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "The earlier we book, the more we can enjoy!",
                                      style: GoogleFonts.nunito(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: widget.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        }



  /// Section title with custom icon, bold title, and whimsical dashed orange trail
  Widget _buildSectionTitle({
    required String iconAsset,
    required String title,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          iconAsset,
          width: 24,
          height: 24,
          errorBuilder: (c, e, s) => const SizedBox(width: 24),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.fredoka(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: widget.darkBrown,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(width: 6),
        CustomPaint(
          size: const Size(36, 14),
          painter: _DashedLoopPainter(color: const Color(0xFFE67E51)),
        ),
      ],
    );
  }

  /// Individual item card with thumbnail photo, titles, metadata, and status pill
  Widget _buildBookingCard({
    required String imageAsset,
    required String title,
    required String subtitle,
    required String dateOrContext,
    required bool isBooked,
    required bool isDateRow,
    required VoidCallback onCardTap,
    required VoidCallback onToggleBooked,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isBooked ? const Color(0xFFA5D6A7) : const Color(0xFFEDE3D7),
          width: isBooked ? 1.4 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.darkBrown.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onCardTap,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Thumbnail photo on the left
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 108,
                    height: 80,
                    child: Image.asset(
                      imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        color: const Color(0xFFEDE5DC),
                        child: const Icon(
                          Icons.image_outlined,
                          color: Color(0xFF8A766E),
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Details column in middle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        title,
                        style: GoogleFonts.fredoka(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: widget.darkBrown,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 2),

                      // Subtitle
                      Text(
                        subtitle,
                        style: GoogleFonts.nunito(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                          color: widget.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // Bottom Metadata + Status Pill Row
                      Row(
                        children: [
                          Icon(
                            isDateRow
                                ? Icons.calendar_today_outlined
                                : Icons.location_on_outlined,
                            size: 13,
                            color: const Color(0xFF8A766E),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              dateOrContext,
                              style: GoogleFonts.nunito(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF8A766E),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),

                          // Interactive Status Pill
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: onToggleBooked,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: isBooked
                                    ? const Color(0xFFE8F5E9)
                                    : const Color(0xFFFFF1E8),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isBooked
                                      ? const Color(0xFFA5D6A7)
                                      : const Color(0xFFFFCCBC),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isBooked) ...[
                                    const Icon(
                                      Icons.check_rounded,
                                      size: 11,
                                      color: Color(0xFF2E7D32),
                                    ),
                                    const SizedBox(width: 3),
                                  ],
                                  Text(
                                    isBooked ? 'Booked' : 'Not yet booked',
                                    style: GoogleFonts.nunito(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isBooked
                                          ? const Color(0xFF2E7D32)
                                          : const Color(0xFFE65100),
                                    ),
                                  ),
                                ],
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
      ),
    );
  }
}

/// Custom painter for the cute whimsical dashed orange trail with loop
class _DashedLoopPainter extends CustomPainter {
  final Color color;

  _DashedLoopPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.cubicTo(
      size.width * 0.35,
      size.height * 0.1,
      size.width * 0.7,
      size.height * 0.2,
      size.width * 0.82,
      size.height * 0.6,
    );
    path.cubicTo(
      size.width * 0.92,
      size.height * 0.95,
      size.width * 1.05,
      size.height * 0.5,
      size.width * 0.88,
      size.height * 0.35,
    );
    path.cubicTo(
      size.width * 0.78,
      size.height * 0.3,
      size.width * 0.78,
      size.height * 0.75,
      size.width * 0.95,
      size.height * 0.85,
    );

    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final length = draw ? 3.5 : 2.5;
        if (draw) {
          dashPath.addPath(
            metric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
