import 'package:flutter/material.dart';

import 'booking_models.dart';

/// Mock booking data provider powered by Travelyn's itinerary intelligence.
/// Generates an AI Booking Checklist from itinerary requirements and provides
/// curated recommendations for Stays, Flights, and Shinkansen Bullet Trains.
class BookingService {
  /// Extract clean city name from a destination string (e.g. "Kobe, Japan" -> "Kobe")
  static String extractCity(String destination) {
    if (destination.trim().isEmpty) return 'Kobe';
    final parts = destination.split(',');
    return parts.first.trim();
  }

  /// Calculate the number of nights between two dates, defaulting to 3
  static int calculateNights(DateTime? start, DateTime? end) {
    if (start != null && end != null) {
      final days = end.difference(start).inDays;
      return days > 0 ? days : 1;
    }
    return 3;
  }

  /// Infer travellers count based on tripType
  static int getTravellerCount(String? tripType) {
    final type = (tripType ?? '').toLowerCase();
    if (type.contains('solo')) return 1;
    if (type.contains('couple') || type.contains('duo')) return 2;
    if (type.contains('family')) return 3;
    return 4; // Default group trip
  }

  /// Format date range as friendly string (e.g. "4–7 Sep 2026")
  static String formatDateRange(DateTime? start, DateTime? end) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    if (start != null && end != null) {
      if (start.month == end.month && start.year == end.year) {
        return '${start.day}–${end.day} ${months[start.month - 1]} ${start.year}';
      }
      return '${start.day} ${months[start.month - 1]} – ${end.day} ${months[end.month - 1]} ${end.year}';
    }
    return '4–7 Sep 2026';
  }

  /// Destination airport code inference
  static String getAirportCode(String city) {
    final lower = city.toLowerCase();
    if (lower.contains('tokyo')) return 'NRT';
    if (lower.contains('osaka') || lower.contains('kyoto') || lower.contains('kobe')) return 'KIX';
    if (lower.contains('seoul')) return 'ICN';
    if (lower.contains('taipei')) return 'TPE';
    if (lower.contains('bangkok')) return 'BKK';
    if (lower.contains('singapore')) return 'SIN';
    if (lower.contains('paris')) return 'CDG';
    if (lower.contains('london')) return 'LHR';
    if (lower.contains('new york')) return 'JFK';
    if (lower.contains('bali')) return 'DPS';
    return city.length >= 3 ? city.substring(0, 3).toUpperCase() : 'DEST';
  }

  /// Generates the AI Booking Checklist derived from the trip's itinerary
  static List<BookingChecklistItem> generateAiChecklist({
    required String destination,
    DateTime? startDate,
    DateTime? endDate,
    String? tripType,
  }) {
    final city = extractCity(destination);
    final nights = calculateNights(startDate, endDate);
    final dateRangeStr = formatDateRange(startDate, endDate);
    final arrCode = getAirportCode(city);

    return [
      // 1. Flights (Before you go)
      BookingChecklistItem(
        id: 'chk_flight',
        type: BookingType.flights,
        title: 'Flights',
        subtitle: 'Roundtrip flights to $city',
        routeOrCity: 'KUL ⇄ $arrCode',
        itineraryContext: 'Day 1 Arrival & Day ${nights + 1} Departure',
        dates: dateRangeStr,
        icon: Icons.flight_takeoff_rounded,
        iconColor: const Color(0xFFE65100),
        iconBgColor: const Color(0xFFFFF0E8),
        priorityLabel: 'High priority',
        priorityTextColor: const Color(0xFFE65100),
        priorityBgColor: const Color(0xFFFFF0E8),
        category: ChecklistCategory.beforeYouGo,
        aiRationale:
            'Daytime arrival recommended so you reach $city before evening transit frequency decreases.',
        estimatedCostRm: 680,
      ),

      // 2. Accommodation (Before you go)
      BookingChecklistItem(
        id: 'chk_hotel',
        type: BookingType.stays,
        title: 'Accommodation',
        subtitle: 'Hotels near your itinerary',
        routeOrCity: 'Downtown $city (Sannomiya)',
        itineraryContext: '$dateRangeStr · $nights nights',
        dates: dateRangeStr,
        icon: Icons.hotel_rounded,
        iconColor: const Color(0xFF7E57C2),
        iconBgColor: const Color(0xFFF3EEFA),
        priorityLabel: 'High priority',
        priorityTextColor: const Color(0xFFE65100),
        priorityBgColor: const Color(0xFFFFF0E8),
        category: ChecklistCategory.beforeYouGo,
        aiRationale:
            'Staying near Sannomiya Station saves ~45 min daily commute for your itinerary stops.',
        estimatedCostRm: 138 * nights,
      ),

      // 3. Transportation in City (Before you go)
      BookingChecklistItem(
        id: 'chk_train',
        type: BookingType.trains,
        title: 'Transportation in $city',
        subtitle: 'Trains, transfers & passes',
        routeOrCity: 'Shin-Kobe ⇄ Kyoto / Osaka',
        itineraryContext: 'Day 3 Day-trip to Kyoto · 28 mins high-speed',
        dates: dateRangeStr,
        icon: Icons.train_rounded,
        iconColor: const Color(0xFF2E7D32),
        iconBgColor: const Color(0xFFEAF6EE),
        priorityLabel: 'Medium priority',
        priorityTextColor: const Color(0xFFD97706),
        priorityBgColor: const Color(0xFFFEF7E6),
        category: ChecklistCategory.beforeYouGo,
        aiRationale:
            'Bullet train saves 1h 45m travel time compared to local rapid trains, maximizing your temple visit.',
        estimatedCostRm: 145,
      ),

      // 4. Activities & Attractions (Enhance your trip)
      BookingChecklistItem(
        id: 'chk_activities',
        type: BookingType.stays,
        title: 'Activities & Attractions',
        subtitle: 'Top sights & experiences',
        routeOrCity: '$city Cultural Sights',
        itineraryContext: 'Nunobiki Ropeway, Kitano Ijinkan, Kobe Port Tower',
        dates: dateRangeStr,
        icon: Icons.camera_alt_rounded,
        iconColor: const Color(0xFFF59E0B),
        iconBgColor: const Color(0xFFFFF6E5),
        priorityLabel: 'Optional',
        priorityTextColor: const Color(0xFF2E7D32),
        priorityBgColor: const Color(0xFFE8F5E9),
        category: ChecklistCategory.enhanceYourTrip,
        tip: 'Some attractions require advance booking.',
        aiRationale:
            'Pre-booking Nunobiki Herb Garden ropeway & Kobe beef dinner avoids 45-min peak lines.',
        estimatedCostRm: 120,
      ),

      // 5. Travel Insurance (Enhance your trip)
      BookingChecklistItem(
        id: 'chk_insurance',
        type: BookingType.flights,
        title: 'Travel Insurance',
        subtitle: 'Medical & delay coverage',
        routeOrCity: 'Overseas Comprehensive Cover',
        itineraryContext: 'Medical, baggage delay, and trip interruption',
        dates: dateRangeStr,
        icon: Icons.verified_user_rounded,
        iconColor: const Color(0xFF1976D2),
        iconBgColor: const Color(0xFFEBF3FC),
        priorityLabel: 'Recommended',
        priorityTextColor: const Color(0xFF1976D2),
        priorityBgColor: const Color(0xFFEDF4FD),
        category: ChecklistCategory.enhanceYourTrip,
        aiRationale:
            'Comprehensive protection covers emergency clinic visits and luggage protection on high-speed trains.',
        estimatedCostRm: 48,
      ),
    ];
  }

  /// Provides split-stay intelligence for multi-day itineraries (e.g. >= 7 nights)
  static SplitStaySuggestion? getSplitStaySuggestion({
    required String destination,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final nights = calculateNights(startDate, endDate);
    if (nights < 7) return null;

    final city = extractCity(destination);
    final isKansai = city.toLowerCase().contains('kobe') ||
        city.toLowerCase().contains('osaka') ||
        city.toLowerCase().contains('kyoto');

    if (isKansai) {
      return SplitStaySuggestion(
        primaryCity: city,
        primaryNights: 5,
        secondaryCity: 'Kyoto',
        secondaryNights: nights - 5,
        additionalCostRm: 180,
        travelTimeSaved: '6h 40m',
        rationale:
            'Staying in $city for all $nights nights is cheaper, but you\'ll spend ~2h 10m commuting on your Kyoto and Osaka days.\n\nTrippy recommends splitting your stay:\n• $city · 5 nights\n• Kyoto · ${nights - 5} nights',
      );
    }

    return null;
  }

  /// Returns curated hotel options evaluated against user itinerary
  static List<HotelOption> getHotels({
    required String destination,
    DateTime? startDate,
    DateTime? endDate,
    String? tripType,
  }) {
    final city = extractCity(destination);
    final nights = calculateNights(startDate, endDate);
    final lower = city.toLowerCase();

    // 1. KYOTO (Real authentic hotels)
    if (lower.contains('kyoto')) {
      return [
        HotelOption(
          id: 'hotel_kyoto_1',
          name: 'The Thousand Kyoto',
          neighborhood: 'Kyoto Station Plaza, Shimogyo Ward',
          city: 'Kyoto',
          imagePath: 'assets/journey/hotel.jpeg',
          rating: 4.8,
          reviewsCount: 1840,
          pricePerNightRm: 210,
          distanceKm: 0.2,
          walkToStation: '2 min to JR Kyoto Station & Shinkansen',
          walkToDay1Start: '5 min walk to Higashi Hongan-ji & Day 1 Start',
          plannedLocationsWithin30Min: 5,
          totalPlannedLocations: 6,
          checkInTime: '3:00 PM',
          checkOutTime: '12:00 PM',
          amenities: ['Free cancellation', 'Onsen spa', 'Free Wi-Fi', 'Garden terrace'],
          cancellationPolicy: 'Free cancellation up to 48h before arrival',
          matchScore: 95,
          matchBreakdown: const {
            'Location': 96,
            'Price': 88,
            'Rating': 95,
            'Itinerary': 98,
            'Preferences': 92,
          },
          comparativeRole: ComparativeRole.bestOverall,
          measurableReasons: [
            '2 min walk to JR Kyoto Station (direct Shinkansen & Haruka Express)',
            '5 of 6 planned Kyoto destinations accessible with zero transfers',
            'Serene contemporary zen architecture with award-winning spa bathhouse',
            'RM${210 * nights} total — comfortably fits your group budget',
            '4.8 rating from 1,840+ verified guest reviews',
          ],
        ),
        HotelOption(
          id: 'hotel_kyoto_2',
          name: 'Cross Hotel Kyoto',
          neighborhood: 'Kawaramachi Sanjo, Nakagyo Ward',
          city: 'Kyoto',
          imagePath: 'assets/journey/hotel.jpeg',
          rating: 4.7,
          reviewsCount: 2150,
          pricePerNightRm: 175,
          distanceKm: 0.3,
          walkToStation: '3 min to Sanjo Keihan & Hankyu Station',
          walkToDay1Start: '4 min walk to Pontocho Alley & Gion',
          plannedLocationsWithin30Min: 6,
          totalPlannedLocations: 6,
          checkInTime: '3:00 PM',
          checkOutTime: '11:00 AM',
          amenities: ['Free cancellation', 'Buffet breakfast', 'Free Wi-Fi', 'English concierge'],
          cancellationPolicy: 'Free cancellation up to 24h before',
          matchScore: 92,
          matchBreakdown: const {
            'Location': 98,
            'Price': 86,
            'Rating': 92,
            'Itinerary': 96,
            'Preferences': 88,
          },
          comparativeRole: ComparativeRole.closestToItinerary,
          measurableReasons: [
            'Prime nightlife & dining: 4 min walk to Pontocho Alley and Gion',
            'Direct access to Keihan Line for quick transit to Fushimi Inari',
            'Surrounded by over 80 authentic izakayas, ramen shops & tea houses',
            'Spacious guest rooms with separate deep-soaking Japanese bathtubs',
          ],
        ),
        HotelOption(
          id: 'hotel_kyoto_3',
          name: 'Sotetsu Fresa Inn Kyoto-Kiyomizu Gojo',
          neighborhood: 'Karasuma Gojo, Shimogyo Ward',
          city: 'Kyoto',
          imagePath: 'assets/journey/hotel.jpeg',
          rating: 4.5,
          reviewsCount: 1420,
          pricePerNightRm: 118,
          distanceKm: 0.4,
          walkToStation: '4 min to Subway Gojo Station (Karasuma Line)',
          walkToDay1Start: '12 min walk to Kiyomizu-dera approach',
          plannedLocationsWithin30Min: 4,
          totalPlannedLocations: 6,
          checkInTime: '3:00 PM',
          checkOutTime: '11:00 AM',
          amenities: ['Free cancellation', 'Free Wi-Fi', 'Luggage storage', 'Self check-in'],
          cancellationPolicy: 'Free cancellation up to 24h before arrival',
          matchScore: 88,
          matchBreakdown: const {
            'Location': 84,
            'Price': 98,
            'Rating': 85,
            'Itinerary': 86,
            'Preferences': 84,
          },
          comparativeRole: ComparativeRole.cheapestSuitable,
          measurableReasons: [
            'Best value in central Kyoto: RM${118 * nights} total (saves RM${92 * nights})',
            'Direct Kyoto City Bus #206 stop right outside heading straight to Gion',
            'Complimentary organic tea and skincare amenity station in lobby',
            'Immaculately clean private modern rooms with Simmons pocket-coil beds',
          ],
        ),
        HotelOption(
          id: 'hotel_kyoto_4',
          name: 'Hotel Granvia Kyoto',
          neighborhood: 'Inside JR Kyoto Station, Shimogyo Ward',
          city: 'Kyoto',
          imagePath: 'assets/journey/hotel.jpeg',
          rating: 4.8,
          reviewsCount: 3280,
          pricePerNightRm: 285,
          distanceKm: 0.0,
          walkToStation: '0 min (Direct JR Kyoto Station building)',
          walkToDay1Start: '1 min walk to Central Bus Terminal & JR Lines',
          plannedLocationsWithin30Min: 6,
          totalPlannedLocations: 6,
          checkInTime: '3:00 PM',
          checkOutTime: '12:00 PM',
          amenities: ['Free cancellation', 'Station direct link', 'Indoor pool', 'Michelin dining'],
          cancellationPolicy: 'Free cancellation up to 3 days before',
          matchScore: 94,
          matchBreakdown: const {
            'Location': 100,
            'Price': 78,
            'Rating': 97,
            'Itinerary': 99,
            'Preferences': 93,
          },
          comparativeRole: ComparativeRole.highestRated,
          measurableReasons: [
            'Completely indoor access to Shinkansen, airport express, and all city bus hubs',
            'Zero walking in rain or handling heavy luggage through street transfers',
            'Panoramic upper-floor rooms overlooking Kyoto Tower and surrounding hills',
            'Top-rated 4.8 score from over 3,280 international travelers',
          ],
        ),
        HotelOption(
          id: 'hotel_kyoto_5',
          name: 'Ace Hotel Kyoto',
          neighborhood: 'ShinPuhKan, Karasuma Oike',
          city: 'Kyoto',
          imagePath: 'assets/journey/hotel.jpeg',
          rating: 4.9,
          reviewsCount: 1760,
          pricePerNightRm: 360,
          distanceKm: 0.1,
          walkToStation: '1 min to Karasuma Oike Station (Direct link)',
          walkToDay1Start: '8 min walk to Nijo Castle & Imperial Palace',
          plannedLocationsWithin30Min: 5,
          totalPlannedLocations: 6,
          checkInTime: '3:00 PM',
          checkOutTime: '12:00 PM',
          amenities: ['Free cancellation', 'Kengo Kuma design', 'Stumptown Coffee', 'Rooftop bar'],
          cancellationPolicy: 'Free cancellation up to 48h before arrival',
          matchScore: 90,
          matchBreakdown: const {
            'Location': 90,
            'Price': 70,
            'Rating': 99,
            'Itinerary': 91,
            'Preferences': 95,
          },
          comparativeRole: ComparativeRole.luxuryPick,
          measurableReasons: [
            'Architectural masterpiece by Kengo Kuma inside historic ShinPuhKan complex',
            'Subway interchange connects seamlessly to Kyoto Station and Arashiyama',
            'Features bespoke artwork, turntable sound systems, and artisan ceramic wares',
            'Acclaimed rooftop Mexican taco bar & Italian trattoria on site',
          ],
        ),
      ];
    }

    // 2. TOKYO (Real authentic hotels)
    if (lower.contains('tokyo')) {
      return [
        HotelOption(
          id: 'hotel_tokyo_1',
          name: 'Hotel Gracery Shinjuku',
          neighborhood: 'Kabukicho, Shinjuku',
          city: 'Tokyo',
          imagePath: 'assets/journey/hotel.jpeg',
          rating: 4.7,
          reviewsCount: 4210,
          pricePerNightRm: 185,
          distanceKm: 0.4,
          walkToStation: '5 min to JR Shinjuku Station (East Exit)',
          walkToDay1Start: '6 min walk to Shinjuku Gyoen National Garden',
          plannedLocationsWithin30Min: 6,
          totalPlannedLocations: 6,
          checkInTime: '2:00 PM',
          checkOutTime: '11:00 AM',
          amenities: ['Free cancellation', 'Free Wi-Fi', 'Godzilla Terrace', 'Direct airport limo'],
          cancellationPolicy: 'Free cancellation up to 48h before',
          matchScore: 95,
          matchBreakdown: const {
            'Location': 98,
            'Price': 89,
            'Rating': 94,
            'Itinerary': 98,
            'Preferences': 92,
          },
          comparativeRole: ComparativeRole.bestOverall,
          measurableReasons: [
            '5 min walk to Shinjuku Station — world’s most connected transit hub',
            'Direct Haneda/Narita airport limousine bus stops right at entrance',
            'Surrounded by Shinjuku shopping malls, Omoide Yokocho & Golden Gai',
            'Iconic Godzilla head observation deck with guest lounge access',
          ],
        ),
        HotelOption(
          id: 'hotel_tokyo_2',
          name: 'Candeo Hotels Tokyo Shimbashi',
          neighborhood: 'Shimbashi / Ginza, Minato Ward',
          city: 'Tokyo',
          imagePath: 'assets/journey/hotel.jpeg',
          rating: 4.8,
          reviewsCount: 2380,
          pricePerNightRm: 195,
          distanceKm: 0.3,
          walkToStation: '4 min to JR Shimbashi Station',
          walkToDay1Start: '10 min walk to Ginza Shopping Boulevard',
          plannedLocationsWithin30Min: 5,
          totalPlannedLocations: 6,
          checkInTime: '3:00 PM',
          checkOutTime: '11:00 AM',
          amenities: ['Free cancellation', 'Rooftop Sky Spa onsen', 'Sauna', 'Free Wi-Fi'],
          cancellationPolicy: 'Free cancellation up to 24h before',
          matchScore: 93,
          matchBreakdown: const {
            'Location': 95,
            'Price': 87,
            'Rating': 96,
            'Itinerary': 95,
            'Preferences': 93,
          },
          comparativeRole: ComparativeRole.closestToItinerary,
          measurableReasons: [
            'Open-air Sky Spa on the top floor with open sky views of Tokyo Tower',
            '4 min walk to Yamanote line for quick direct transit to Shibuya & Akihabara',
            'Steps from Ginza luxury boutiques and Michelin-starred dining',
          ],
        ),
        HotelOption(
          id: 'hotel_tokyo_3',
          name: 'APA Hotel & Resort Ryogoku Eki Tower',
          neighborhood: 'Ryogoku, Sumida Ward',
          city: 'Tokyo',
          imagePath: 'assets/journey/hotel.jpeg',
          rating: 4.5,
          reviewsCount: 3120,
          pricePerNightRm: 120,
          distanceKm: 0.3,
          walkToStation: '3 min to JR Ryogoku Station',
          walkToDay1Start: '4 min walk to Edo-Tokyo & Sumo Stadium',
          plannedLocationsWithin30Min: 4,
          totalPlannedLocations: 6,
          checkInTime: '3:00 PM',
          checkOutTime: '10:00 AM',
          amenities: ['Free cancellation', 'Large public bath', 'Rooftop pool', 'Free Wi-Fi'],
          cancellationPolicy: 'Free cancellation up to 24h before',
          matchScore: 86,
          matchBreakdown: const {
            'Location': 82,
            'Price': 99,
            'Rating': 84,
            'Itinerary': 84,
            'Preferences': 82,
          },
          comparativeRole: ComparativeRole.cheapestSuitable,
          measurableReasons: [
            'Superb value: RM${120 * nights} total — saves RM${65 * nights} vs central stays',
            'Includes expansive indoor & outdoor public onsen baths and rooftop pool',
            '3 min walk to JR Chuo-Sobu Line with direct 12-min ride to Akihabara',
          ],
        ),
        HotelOption(
          id: 'hotel_tokyo_4',
          name: 'The Gate Hotel Tokyo by Hulic',
          neighborhood: 'Yurakucho / Ginza, Chiyoda Ward',
          city: 'Tokyo',
          imagePath: 'assets/journey/hotel.jpeg',
          rating: 4.8,
          reviewsCount: 2650,
          pricePerNightRm: 270,
          distanceKm: 0.1,
          walkToStation: '1 min to Subway Ginza & Yurakucho Station',
          walkToDay1Start: '3 min walk to Imperial Palace Gardens',
          plannedLocationsWithin30Min: 6,
          totalPlannedLocations: 6,
          checkInTime: '2:00 PM',
          checkOutTime: '11:00 AM',
          amenities: ['Free cancellation', 'Rooftop lounge', 'French bistro', 'Free Wi-Fi'],
          cancellationPolicy: 'Free cancellation up to 48h before',
          matchScore: 94,
          matchBreakdown: const {
            'Location': 99,
            'Price': 78,
            'Rating': 98,
            'Itinerary': 97,
            'Preferences': 93,
          },
          comparativeRole: ComparativeRole.highestRated,
          measurableReasons: [
            'Sweeping 13th-floor open-air terrace overlooking Sukiyabashi crossing',
            'Ranked top 1% hotel in Tokyo for guest satisfaction and hospitality',
            'Unrivaled access to 5 major metro and JR lines across Ginza and Tokyo Station',
          ],
        ),
        HotelOption(
          id: 'hotel_tokyo_5',
          name: 'Park Hotel Tokyo',
          neighborhood: 'Shiodome Media Tower, Minato Ward',
          city: 'Tokyo',
          imagePath: 'assets/journey/hotel.jpeg',
          rating: 4.8,
          reviewsCount: 1980,
          pricePerNightRm: 340,
          distanceKm: 0.2,
          walkToStation: '2 min to Shiodome Station (Direct link)',
          walkToDay1Start: '10 min walk to Hamarikyu Gardens',
          plannedLocationsWithin30Min: 5,
          totalPlannedLocations: 6,
          checkInTime: '3:00 PM',
          checkOutTime: '12:00 PM',
          amenities: ['Free cancellation', 'Artist rooms', 'Tokyo Tower view', 'Art gallery'],
          cancellationPolicy: 'Free cancellation up to 3 days before',
          matchScore: 89,
          matchBreakdown: const {
            'Location': 91,
            'Price': 72,
            'Rating': 98,
            'Itinerary': 90,
            'Preferences': 94,
          },
          comparativeRole: ComparativeRole.luxuryPick,
          measurableReasons: [
            'Museum-style hotel on floors 25–34 with direct postcard views of Tokyo Tower',
            'Custom hand-painted Artist Rooms created by renowned contemporary Japanese artists',
            'Covered pedestrian walkway directly to Yurikamome monorail for Odaiba',
          ],
        ),
      ];
    }

    // 3. OSAKA (Real authentic hotels)
    if (lower.contains('osaka')) {
      return [
        HotelOption(
          id: 'hotel_osaka_1',
          name: 'Swissôtel Nankai Osaka',
          neighborhood: 'Namba, Chuo Ward',
          city: 'Osaka',
          imagePath: 'assets/journey/hotel.jpeg',
          rating: 4.8,
          reviewsCount: 3890,
          pricePerNightRm: 220,
          distanceKm: 0.0,
          walkToStation: '0 min (Direct above Nankai Namba Station)',
          walkToDay1Start: '5 min walk to Dotonbori Glico Sign',
          plannedLocationsWithin30Min: 6,
          totalPlannedLocations: 6,
          checkInTime: '3:00 PM',
          checkOutTime: '11:00 AM',
          amenities: ['Free cancellation', 'Airport train direct', 'Spa & pool', 'Panoramic dining'],
          cancellationPolicy: 'Free cancellation up to 48h before',
          matchScore: 96,
          matchBreakdown: const {
            'Location': 100,
            'Price': 85,
            'Rating': 96,
            'Itinerary': 99,
            'Preferences': 93,
          },
          comparativeRole: ComparativeRole.bestOverall,
          measurableReasons: [
            'Direct elevator to Nankai Rapi:t airport express train (34 mins to KIX)',
            '5 min walk to Dotonbori street food, Kuromon Market & Shinsaibashi arcade',
            'Zero transfers needed for Universal Studios Japan and Osaka Castle transit',
            '4.8 rating from 3,890 verified reviews',
          ],
        ),
        HotelOption(
          id: 'hotel_osaka_2',
          name: 'Cross Hotel Osaka',
          neighborhood: 'Dotonbori / Shinsaibashi, Chuo Ward',
          city: 'Osaka',
          imagePath: 'assets/journey/hotel.jpeg',
          rating: 4.7,
          reviewsCount: 2940,
          pricePerNightRm: 165,
          distanceKm: 0.2,
          walkToStation: '3 min to Namba Subway Station',
          walkToDay1Start: '1 min walk to Dotonbori Canal',
          plannedLocationsWithin30Min: 5,
          totalPlannedLocations: 6,
          checkInTime: '3:00 PM',
          checkOutTime: '11:00 AM',
          amenities: ['Free cancellation', 'Buffet breakfast', 'Free Wi-Fi', 'Design bath'],
          cancellationPolicy: 'Free cancellation up to 24h before',
          matchScore: 92,
          matchBreakdown: const {
            'Location': 99,
            'Price': 88,
            'Rating': 91,
            'Itinerary': 96,
            'Preferences': 89,
          },
          comparativeRole: ComparativeRole.closestToItinerary,
          measurableReasons: [
            'Unbeatable food location: 1 min walk from Dotonbori Canal and street food stalls',
            'Modern boutique interior with luxury bathroom amenities',
            'Direct access to Midosuji Line connecting Namba, Shinsaibashi & Umeda',
          ],
        ),
        HotelOption(
          id: 'hotel_osaka_3',
          name: 'Dormy Inn Premium Namba Natural Hot Spring',
          neighborhood: 'Nihonbashi / Dotonbori, Chuo Ward',
          city: 'Osaka',
          imagePath: 'assets/journey/hotel.jpeg',
          rating: 4.6,
          reviewsCount: 2450,
          pricePerNightRm: 125,
          distanceKm: 0.4,
          walkToStation: '5 min to Subway Nihonbashi Station',
          walkToDay1Start: '4 min walk to Kuromon Fresh Food Market',
          plannedLocationsWithin30Min: 4,
          totalPlannedLocations: 6,
          checkInTime: '3:00 PM',
          checkOutTime: '11:00 AM',
          amenities: ['Free cancellation', 'Natural hot spring onsen', 'Free evening ramen', 'Sauna'],
          cancellationPolicy: 'Free cancellation up to 24h before',
          matchScore: 89,
          matchBreakdown: const {
            'Location': 88,
            'Price': 98,
            'Rating': 89,
            'Itinerary': 88,
            'Preferences': 87,
          },
          comparativeRole: ComparativeRole.cheapestSuitable,
          measurableReasons: [
            'Authentic natural indoor/outdoor onsen mineral baths and sauna included',
            'Complimentary hot Yonaki Soba ramen served fresh nightly to guests',
            'RM${125 * nights} total — supreme value in central Osaka',
          ],
        ),
        HotelOption(
          id: 'hotel_osaka_4',
          name: 'Hotel Monterey Grasmere Osaka',
          neighborhood: 'JR Namba Station, Naniwa Ward',
          city: 'Osaka',
          imagePath: 'assets/journey/hotel.jpeg',
          rating: 4.7,
          reviewsCount: 3100,
          pricePerNightRm: 180,
          distanceKm: 0.1,
          walkToStation: '1 min to JR Namba & OCAT Airport Terminal',
          walkToDay1Start: '8 min walk to Dotonbori street',
          plannedLocationsWithin30Min: 5,
          totalPlannedLocations: 6,
          checkInTime: '3:00 PM',
          checkOutTime: '11:00 AM',
          amenities: ['Free cancellation', 'OCAT direct link', '22nd floor sky lobby', 'British chapel'],
          cancellationPolicy: 'Free cancellation up to 48h before',
          matchScore: 93,
          matchBreakdown: const {
            'Location': 96,
            'Price': 87,
            'Rating': 95,
            'Itinerary': 94,
            'Preferences': 91,
          },
          comparativeRole: ComparativeRole.highestRated,
          measurableReasons: [
            'Elevator connects straight to OCAT bus terminal and 24-hour Life Supermarket',
            'Sky lobby on the 22nd floor with panoramic sunset views over Osaka bay',
            'Classic European manor decor with spacious soundproofed bedrooms',
          ],
        ),
        HotelOption(
          id: 'hotel_osaka_5',
          name: 'W Osaka',
          neighborhood: 'Midosuji Boulevard, Shinsaibashi',
          city: 'Osaka',
          imagePath: 'assets/journey/hotel.jpeg',
          rating: 4.9,
          reviewsCount: 1650,
          pricePerNightRm: 380,
          distanceKm: 0.3,
          walkToStation: '3 min to Shinsaibashi Station',
          walkToDay1Start: '4 min walk to America-mura & luxury fashion street',
          plannedLocationsWithin30Min: 5,
          totalPlannedLocations: 6,
          checkInTime: '3:00 PM',
          checkOutTime: '12:00 PM',
          amenities: ['Free cancellation', 'Tadao Ando design', 'WET indoor pool', 'Living Room bar'],
          cancellationPolicy: 'Free cancellation up to 3 days before',
          matchScore: 88,
          matchBreakdown: const {
            'Location': 92,
            'Price': 68,
            'Rating': 99,
            'Itinerary': 90,
            'Preferences': 95,
          },
          comparativeRole: ComparativeRole.luxuryPick,
          measurableReasons: [
            'Iconic black monolith tower designed by world-renowned architect Tadao Ando',
            'Vibrant signature cocktail lounge, indoor heated pool and DJ booth',
            'Centrally located on Osaka’s premier tree-lined avenue Midosuji',
          ],
        ),
      ];
    }

    // 4. KOBE (Real authentic hotels)
    if (lower.contains('kobe')) {
      return [
        HotelOption(
          id: 'hotel_kobe_1',
          name: 'Hotel Okura Kobe',
          neighborhood: 'Meriken Park / Waterfront, Chuo Ward',
          city: 'Kobe',
          imagePath: 'assets/journey/hotel.jpeg',
          rating: 4.8,
          reviewsCount: 2180,
          pricePerNightRm: 175,
          distanceKm: 0.5,
          walkToStation: '5 min to Subway Minato Motomachi',
          walkToDay1Start: '6 min walk to Kobe Port Tower & Harborland',
          plannedLocationsWithin30Min: 5,
          totalPlannedLocations: 6,
          checkInTime: '3:00 PM',
          checkOutTime: '12:00 PM',
          amenities: ['Free cancellation', 'Port views', 'Free station shuttle', 'Indoor pool'],
          cancellationPolicy: 'Free cancellation up to 48h before arrival',
          matchScore: 95,
          matchBreakdown: const {
            'Location': 94,
            'Price': 88,
            'Rating': 96,
            'Itinerary': 97,
            'Preferences': 94,
          },
          comparativeRole: ComparativeRole.bestOverall,
          measurableReasons: [
            'Unrivaled waterfront vistas of Kobe Port Tower and sparkling harbor cruise lights',
            'Complimentary shuttle bus running every 15 minutes straight to Sannomiya Station',
            'Legendary Japanese hospitality with spacious 37m² renovated rooms',
            'RM${175 * nights} total — exceptional luxury-to-price ratio',
          ],
        ),
        HotelOption(
          id: 'hotel_kobe_2',
          name: 'Kobe Sannomiya Tokyu REI Hotel',
          neighborhood: 'Sannomiya Station Plaza, Chuo Ward',
          city: 'Kobe',
          imagePath: 'assets/journey/hotel.jpeg',
          rating: 4.5,
          reviewsCount: 1640,
          pricePerNightRm: 110,
          distanceKm: 0.2,
          walkToStation: '2 min to JR & Hanshin Sannomiya Station',
          walkToDay1Start: '8 min walk to Ikuta Shrine & Kitano',
          plannedLocationsWithin30Min: 4,
          totalPlannedLocations: 6,
          checkInTime: '3:00 PM',
          checkOutTime: '10:00 AM',
          amenities: ['Free cancellation', 'Station adjacent', 'Free Wi-Fi', 'Complimentary coffee'],
          cancellationPolicy: 'Free cancellation up to 24h before',
          matchScore: 89,
          matchBreakdown: const {
            'Location': 98,
            'Price': 99,
            'Rating': 85,
            'Itinerary': 92,
            'Preferences': 84,
          },
          comparativeRole: ComparativeRole.cheapestSuitable,
          measurableReasons: [
            'Best budget stay: RM${110 * nights} total — saves RM${65 * nights} on your trip',
            '2 min walk to JR Sannomiya for 21-min rapid trains to Osaka and Kyoto',
            'Clean air-conditioned rooms with high-pressure massage showers',
          ],
        ),
        HotelOption(
          id: 'hotel_kobe_3',
          name: 'Daiwa Roynet Hotel Kobe Sannomiya Premier',
          neighborhood: 'Sannomiya Center, Chuo Ward',
          city: 'Kobe',
          imagePath: 'assets/journey/hotel.jpeg',
          rating: 4.7,
          reviewsCount: 1920,
          pricePerNightRm: 145,
          distanceKm: 0.3,
          walkToStation: '4 min to Sannomiya Station (Direct subway link)',
          walkToDay1Start: '4 min walk to Ikuta Shrine & Sannomiya Arcade',
          plannedLocationsWithin30Min: 5,
          totalPlannedLocations: 6,
          checkInTime: '2:00 PM',
          checkOutTime: '11:00 AM',
          amenities: ['Free cancellation', 'Separate bath/toilet', 'Breakfast included', 'Free Wi-Fi'],
          cancellationPolicy: 'Free cancellation up to 24h before',
          matchScore: 92,
          matchBreakdown: const {
            'Location': 99,
            'Price': 89,
            'Rating': 91,
            'Itinerary': 96,
            'Preferences': 88,
          },
          comparativeRole: ComparativeRole.closestToItinerary,
          measurableReasons: [
            'Zero transfers needed for 5 of 6 planned trip locations',
            'Covered arcade walk from station — stay dry even during rainfall',
            'Premium floor rooms equipped with facial steamers and massage chairs',
          ],
        ),
        HotelOption(
          id: 'hotel_kobe_4',
          name: 'Kobe Meriken Park Oriental Hotel',
          neighborhood: 'Harborland / Waterfront, Chuo Ward',
          city: 'Kobe',
          imagePath: 'assets/journey/hotel.jpeg',
          rating: 4.8,
          reviewsCount: 2890,
          pricePerNightRm: 195,
          distanceKm: 0.8,
          walkToStation: '8 min to Minato Motomachi Station',
          walkToDay1Start: '2 min walk to Harborland Mosaic shopping',
          plannedLocationsWithin30Min: 4,
          totalPlannedLocations: 6,
          checkInTime: '3:00 PM',
          checkOutTime: '11:00 AM',
          amenities: ['Free cancellation', 'Private ocean balcony', 'Spa', 'Free shuttle'],
          cancellationPolicy: 'Free cancellation up to 48h before',
          matchScore: 93,
          matchBreakdown: const {
            'Location': 90,
            'Price': 82,
            'Rating': 98,
            'Itinerary': 92,
            'Preferences': 94,
          },
          comparativeRole: ComparativeRole.highestRated,
          measurableReasons: [
            'Surrounded on 3 sides by the ocean with private balconies in every single room',
            'Direct access to Kobe cruise departure terminal and Mosaic Ferris wheel',
            'Top-rated 4.8 score with acclaimed seafood breakfast buffet',
          ],
        ),
        HotelOption(
          id: 'hotel_kobe_5',
          name: 'Oriental Hotel Kobe',
          neighborhood: 'Former Foreign Settlement (Kyukyoryuchi)',
          city: 'Kobe',
          imagePath: 'assets/journey/hotel.jpeg',
          rating: 4.9,
          reviewsCount: 2310,
          pricePerNightRm: 240,
          distanceKm: 0.6,
          walkToStation: '6 min to Motomachi Station',
          walkToDay1Start: '10 min walk to Kitano Ijinkan foreign residences',
          plannedLocationsWithin30Min: 5,
          totalPlannedLocations: 6,
          checkInTime: '3:00 PM',
          checkOutTime: '12:00 PM',
          amenities: ['Free cancellation', 'Michelin dining', 'Fitness center', 'Concierge'],
          cancellationPolicy: 'Free cancellation up to 3 days before',
          matchScore: 89,
          matchBreakdown: const {
            'Location': 88,
            'Price': 70,
            'Rating': 99,
            'Itinerary': 89,
            'Preferences': 93,
          },
          comparativeRole: ComparativeRole.luxuryPick,
          measurableReasons: [
            'Historic boutique luxury hotel founded in 1870 in Kobe’s European heritage district',
            'Generous 38m² rooms provide plenty of luggage and lounge space',
            'Acclaimed rooftop bar and Italian steakhouse on site with city skyline views',
          ],
        ),
      ];
    }

    // 5. SEOUL (Real authentic hotels)
    if (lower.contains('seoul')) {
      return [
        HotelOption(
          id: 'hotel_seoul_1',
          name: 'L7 Myeongdong by LOTTE',
          neighborhood: 'Myeongdong, Jung-gu',
          city: 'Seoul',
          imagePath: 'assets/journey/hotel.jpeg',
          rating: 4.8,
          reviewsCount: 2650,
          pricePerNightRm: 180,
          distanceKm: 0.1,
          walkToStation: '1 min to Myeongdong Subway Station (Line 4)',
          walkToDay1Start: '2 min walk to Myeongdong Night Market',
          plannedLocationsWithin30Min: 6,
          totalPlannedLocations: 6,
          checkInTime: '3:00 PM',
          checkOutTime: '12:00 PM',
          amenities: ['Free cancellation', 'Rooftop foot spa', 'Free Wi-Fi', 'N Seoul Tower view'],
          cancellationPolicy: 'Free cancellation up to 24h before',
          matchScore: 96,
          matchBreakdown: const {
            'Location': 100,
            'Price': 88,
            'Rating': 95,
            'Itinerary': 99,
            'Preferences': 94,
          },
          comparativeRole: ComparativeRole.bestOverall,
          measurableReasons: [
            '1 min to Myeongdong Station exit 9 — prime retail and Korean cosmetics hub',
            'Rooftop outdoor foot spa with direct illuminated views of N Seoul Tower',
            'Airport limousine bus #6015 stops directly outside the hotel door',
          ],
        ),
        HotelOption(
          id: 'hotel_seoul_2',
          name: 'Nine Tree Premier Hotel Myeongdong II',
          neighborhood: 'Euljiro / Myeongdong, Jung-gu',
          city: 'Seoul',
          imagePath: 'assets/journey/hotel.jpeg',
          rating: 4.7,
          reviewsCount: 2890,
          pricePerNightRm: 155,
          distanceKm: 0.3,
          walkToStation: '4 min to Euljiro 3-ga Station (Lines 2 & 3)',
          walkToDay1Start: '5 min walk to Cheonggyecheon Stream',
          plannedLocationsWithin30Min: 5,
          totalPlannedLocations: 6,
          checkInTime: '3:00 PM',
          checkOutTime: '12:00 PM',
          amenities: ['Free cancellation', 'Pillow menu', 'Rooftop garden', 'Free Wi-Fi'],
          cancellationPolicy: 'Free cancellation up to 48h before',
          matchScore: 92,
          matchBreakdown: const {
            'Location': 96,
            'Price': 92,
            'Rating': 92,
            'Itinerary': 95,
            'Preferences': 89,
          },
          comparativeRole: ComparativeRole.closestToItinerary,
          measurableReasons: [
            'Interchange station (Lines 2 & 3) gives 1-train direct ride to Gangnam & Hongdae',
            'Complimentary customizable 9-type pillow comfort menu for deep sleep',
            'Quiet restful street just 5 mins from bustling Myeongdong main street',
          ],
        ),
        HotelOption(
          id: 'hotel_seoul_3',
          name: 'Stanford Hotel Myeongdong',
          neighborhood: 'Central Myeongdong, Jung-gu',
          city: 'Seoul',
          imagePath: 'assets/journey/hotel.jpeg',
          rating: 4.5,
          reviewsCount: 1720,
          pricePerNightRm: 115,
          distanceKm: 0.2,
          walkToStation: '3 min to Euljiro 1-ga Station',
          walkToDay1Start: '3 min walk to Lotte Department Store Main',
          plannedLocationsWithin30Min: 4,
          totalPlannedLocations: 6,
          checkInTime: '3:00 PM',
          checkOutTime: '11:00 AM',
          amenities: ['Free cancellation', 'Free Wi-Fi', 'Luggage scales', 'Cafe'],
          cancellationPolicy: 'Free cancellation up to 24h before',
          matchScore: 88,
          matchBreakdown: const {
            'Location': 92,
            'Price': 99,
            'Rating': 84,
            'Itinerary': 88,
            'Preferences': 84,
          },
          comparativeRole: ComparativeRole.cheapestSuitable,
          measurableReasons: [
            'Best price in Myeongdong: RM${115 * nights} total — saves RM${65 * nights}',
            'Opposite Lotte Department Store and tax-free shopping mall',
            'Modern soundproofed rooms with eco-friendly amenities',
          ],
        ),
        HotelOption(
          id: 'hotel_seoul_4',
          name: 'The Shilla Seoul',
          neighborhood: 'Jangchung-dong, Jung-gu',
          city: 'Seoul',
          imagePath: 'assets/journey/hotel.jpeg',
          rating: 4.9,
          reviewsCount: 3450,
          pricePerNightRm: 320,
          distanceKm: 0.8,
          walkToStation: '5 min to Dongguk Univ Station (Line 3)',
          walkToDay1Start: '10 min transit to Dongdaemun & Namsan',
          plannedLocationsWithin30Min: 5,
          totalPlannedLocations: 6,
          checkInTime: '3:00 PM',
          checkOutTime: '11:00 AM',
          amenities: ['Free cancellation', 'Urban Island pool', 'Michelin dining', 'Shilla Spa'],
          cancellationPolicy: 'Free cancellation up to 3 days before',
          matchScore: 93,
          matchBreakdown: const {
            'Location': 88,
            'Price': 75,
            'Rating': 99,
            'Itinerary': 92,
            'Preferences': 95,
          },
          comparativeRole: ComparativeRole.highestRated,
          measurableReasons: [
            'Korea’s premier flagship luxury hotel frequented by heads of state',
            'Home to 3-Michelin-starred La Yeon traditional Korean dining',
            'Heated outdoor Urban Island cabana pools with Namsan forest backdrop',
          ],
        ),
        HotelOption(
          id: 'hotel_seoul_5',
          name: 'Josun Palace, a Luxury Collection Hotel, Seoul Gangnam',
          neighborhood: 'Teheran-ro, Gangnam-gu',
          city: 'Seoul',
          imagePath: 'assets/journey/hotel.jpeg',
          rating: 4.9,
          reviewsCount: 1540,
          pricePerNightRm: 390,
          distanceKm: 0.3,
          walkToStation: '4 min to Yeoksam Station (Line 2)',
          walkToDay1Start: '8 min transit to COEX Mall & K-Star Road',
          plannedLocationsWithin30Min: 5,
          totalPlannedLocations: 6,
          checkInTime: '3:00 PM',
          checkOutTime: '12:00 PM',
          amenities: ['Free cancellation', 'Sky heated pool', 'Grand Masters lounge', 'Butler service'],
          cancellationPolicy: 'Free cancellation up to 3 days before',
          matchScore: 89,
          matchBreakdown: const {
            'Location': 90,
            'Price': 65,
            'Rating': 99,
            'Itinerary': 89,
            'Preferences': 94,
          },
          comparativeRole: ComparativeRole.luxuryPick,
          measurableReasons: [
            'Breathtaking art deco architecture perched on the upper floors of Centerfield Tower',
            'Panoramic indoor heated sky pool overlooking the dazzling Gangnam skyline',
            'Full Grand Masters Club privileges including bespoke high tea and evening cocktails',
          ],
        ),
      ];
    }

    // 6. BANGKOK (Real authentic hotels)
    if (lower.contains('bangkok')) {
      return [
        HotelOption(
          id: 'hotel_bkk_1',
          name: 'Grande Centre Point Terminal 21',
          neighborhood: 'Sukhumvit / Asok, Watthana',
          city: 'Bangkok',
          imagePath: 'assets/journey/hotel.jpeg',
          rating: 4.8,
          reviewsCount: 4120,
          pricePerNightRm: 160,
          distanceKm: 0.0,
          walkToStation: '0 min (Direct skybridge to BTS Asok & MRT Sukhumvit)',
          walkToDay1Start: '1 min to Terminal 21 Mall & food street',
          plannedLocationsWithin30Min: 6,
          totalPlannedLocations: 6,
          checkInTime: '2:00 PM',
          checkOutTime: '12:00 PM',
          amenities: ['Free cancellation', 'Infinity pool', 'BTS direct link', 'Free Wi-Fi'],
          cancellationPolicy: 'Free cancellation up to 24h before',
          matchScore: 96,
          matchBreakdown: const {
            'Location': 100,
            'Price': 90,
            'Rating': 95,
            'Itinerary': 99,
            'Preferences': 93,
          },
          comparativeRole: ComparativeRole.bestOverall,
          measurableReasons: [
            'Direct dual interchange connecting BTS Skytrain (Asok) and MRT Subway (Sukhumvit)',
            'Avoid Bangkok traffic jams completely with direct elevated skybridge access',
            'Large infinity pool and tennis court overlooking Sukhumvit cityscape',
          ],
        ),
        HotelOption(
          id: 'hotel_bkk_2',
          name: 'Eastin Grand Hotel Phayathai',
          neighborhood: 'Phayathai, Ratchathewi',
          city: 'Bangkok',
          imagePath: 'assets/journey/hotel.jpeg',
          rating: 4.8,
          reviewsCount: 3200,
          pricePerNightRm: 175,
          distanceKm: 0.1,
          walkToStation: '1 min (Direct covered link to Phayathai Airport Rail Link)',
          walkToDay1Start: '2 stops to Siam Paragon & CentralWorld',
          plannedLocationsWithin30Min: 6,
          totalPlannedLocations: 6,
          checkInTime: '3:00 PM',
          checkOutTime: '12:00 PM',
          amenities: ['Free cancellation', '2 infinity pools', 'Airport link direct', 'Executive lounge'],
          cancellationPolicy: 'Free cancellation up to 48h before',
          matchScore: 94,
          matchBreakdown: const {
            'Location': 98,
            'Price': 88,
            'Rating': 97,
            'Itinerary': 96,
            'Preferences': 92,
          },
          comparativeRole: ComparativeRole.closestToItinerary,
          measurableReasons: [
            'Covered skywalk directly into Airport Rail Link (25 mins straight to Suvarnabhumi)',
            'Two spectacular infinity pools on the 22nd and 37th floors',
            'Only 2 BTS stops to Siam shopping paradise (Siam Paragon & CentralWorld)',
          ],
        ),
        HotelOption(
          id: 'hotel_bkk_3',
          name: 'Amara Bangkok',
          neighborhood: 'Surawong / Silom, Bang Rak',
          city: 'Bangkok',
          imagePath: 'assets/journey/hotel.jpeg',
          rating: 4.5,
          reviewsCount: 2150,
          pricePerNightRm: 110,
          distanceKm: 0.4,
          walkToStation: '6 min to BTS Chong Nonsi / Sala Daeng',
          walkToDay1Start: '5 min walk to Patpong Night Market',
          plannedLocationsWithin30Min: 4,
          totalPlannedLocations: 6,
          checkInTime: '3:00 PM',
          checkOutTime: '12:00 PM',
          amenities: ['Free cancellation', 'Rooftop sky pool', 'Tuk-tuk shuttle', 'Free Wi-Fi'],
          cancellationPolicy: 'Free cancellation up to 24h before',
          matchScore: 89,
          matchBreakdown: const {
            'Location': 88,
            'Price': 99,
            'Rating': 86,
            'Itinerary': 88,
            'Preferences': 85,
          },
          comparativeRole: ComparativeRole.cheapestSuitable,
          measurableReasons: [
            'Outstanding value: RM${110 * nights} total — saves RM${50 * nights}',
            'Famous 26th-floor rooftop infinity pool with unblocked city views',
            'Complimentary air-conditioned tuk-tuk shuttle to BTS Skytrain stations',
          ],
        ),
        HotelOption(
          id: 'hotel_bkk_4',
          name: 'Sindhorn Kempinski Hotel Bangkok',
          neighborhood: 'Langsuan / Lumphini, Pathum Wan',
          city: 'Bangkok',
          imagePath: 'assets/journey/hotel.jpeg',
          rating: 4.9,
          reviewsCount: 1890,
          pricePerNightRm: 320,
          distanceKm: 0.6,
          walkToStation: '8 min to BTS Chit Lom',
          walkToDay1Start: '5 min walk to Lumphini Park greenery',
          plannedLocationsWithin30Min: 5,
          totalPlannedLocations: 6,
          checkInTime: '3:00 PM',
          checkOutTime: '12:00 PM',
          amenities: ['Free cancellation', 'Cantilevered pool', 'Sindhorn Wellness spa', 'Garden oasis'],
          cancellationPolicy: 'Free cancellation up to 3 days before',
          matchScore: 92,
          matchBreakdown: const {
            'Location': 90,
            'Price': 74,
            'Rating': 99,
            'Itinerary': 92,
            'Preferences': 95,
          },
          comparativeRole: ComparativeRole.highestRated,
          measurableReasons: [
            'Iconic luxury garden sanctuary adjoining green Lumphini Park',
            'Spectacular 19-meter cantilevered infinity pool projecting out from the 9th floor',
            'Voted best wellness hotel in Asia with comprehensive hydrothermal facilities',
          ],
        ),
        HotelOption(
          id: 'hotel_bkk_5',
          name: 'The Peninsula Bangkok',
          neighborhood: 'Chao Phraya Riverfront, Khlong San',
          city: 'Bangkok',
          imagePath: 'assets/journey/hotel.jpeg',
          rating: 4.9,
          reviewsCount: 2980,
          pricePerNightRm: 360,
          distanceKm: 0.1,
          walkToStation: 'Private river shuttle to BTS Saphan Taksin',
          walkToDay1Start: '5 min river boat to ICONSIAM luxury mega-mall',
          plannedLocationsWithin30Min: 5,
          totalPlannedLocations: 6,
          checkInTime: '3:00 PM',
          checkOutTime: '12:00 PM',
          amenities: ['Free cancellation', 'River shuttle boat', '3-tiered river pool', 'Spa'],
          cancellationPolicy: 'Free cancellation up to 3 days before',
          matchScore: 88,
          matchBreakdown: const {
            'Location': 88,
            'Price': 68,
            'Rating': 99,
            'Itinerary': 89,
            'Preferences': 93,
          },
          comparativeRole: ComparativeRole.luxuryPick,
          measurableReasons: [
            'All rooms feature panoramic riverfront floor-to-ceiling vistas of Chao Phraya',
            'Complimentary private heritage ferry shuttle across the river to Skytrain & ICONSIAM',
            'Three-tiered 88-meter riverside swimming pool with shaded Thai cabanas',
          ],
        ),
      ];
    }

    // 7. GENERIC FALLBACK (For any other destination — guarantees 5 diverse real-standard hotels!)
    return [
      HotelOption(
        id: 'hotel_gen_1',
        name: 'Central Station Grand Hotel, $city',
        neighborhood: 'Downtown & Central Transit, $city',
        city: city,
        imagePath: 'assets/journey/hotel.jpeg',
        rating: 4.8,
        reviewsCount: 1840,
        pricePerNightRm: 145,
        distanceKm: 0.2,
        walkToStation: '2 min to Central Transit Hub',
        walkToDay1Start: '6 min walk to Day 1 starting point in $city',
        plannedLocationsWithin30Min: 5,
        totalPlannedLocations: 6,
        checkInTime: '3:00 PM',
        checkOutTime: '11:00 AM',
        amenities: ['Free cancellation', 'Breakfast included', 'Free Wi-Fi', 'Central station direct'],
        cancellationPolicy: 'Free cancellation up to 48h before',
        matchScore: 95,
        matchBreakdown: const {
          'Location': 96,
          'Price': 88,
          'Rating': 94,
          'Itinerary': 98,
          'Preferences': 91,
        },
        comparativeRole: ComparativeRole.bestOverall,
        measurableReasons: [
          '2 min walk to central transit line with direct connections to all planned sights',
          'RM${145 * nights} total — comfortably fits your group stay budget',
          '5 of 6 planned itinerary locations are reachable within 30 min transit',
          '4.8 rating from 1,840+ verified traveler reviews',
        ],
      ),
      HotelOption(
        id: 'hotel_gen_2',
        name: 'Old Town Heritage Boutique Hotel, $city',
        neighborhood: 'Historic Old Town & Cultural Quarter, $city',
        city: city,
        imagePath: 'assets/journey/hotel.jpeg',
        rating: 4.7,
        reviewsCount: 1320,
        pricePerNightRm: 155,
        distanceKm: 0.3,
        walkToStation: '4 min to Old Town Metro',
        walkToDay1Start: '3 min walk to Historic Center & Evening Dining',
        plannedLocationsWithin30Min: 5,
        totalPlannedLocations: 6,
        checkInTime: '2:00 PM',
        checkOutTime: '11:00 AM',
        amenities: ['Free cancellation', 'Artisan breakfast', 'Free Wi-Fi', 'Courtyard terrace'],
        cancellationPolicy: 'Free cancellation up to 24h before',
        matchScore: 92,
        matchBreakdown: const {
          'Location': 98,
          'Price': 84,
          'Rating': 91,
          'Itinerary': 96,
          'Preferences': 89,
        },
        comparativeRole: ComparativeRole.closestToItinerary,
        measurableReasons: [
          'Walking distance to central landmarks, museums, and night dining streets',
          'Zero subway transfers needed for 5 of 6 planned itinerary stops',
          'Authentic local architecture with modern renovated soundproofed bedrooms',
        ],
      ),
      HotelOption(
        id: 'hotel_gen_3',
        name: 'Express City Plaza Inn, $city',
        neighborhood: 'Commercial Plaza, $city',
        city: city,
        imagePath: 'assets/journey/hotel.jpeg',
        rating: 4.4,
        reviewsCount: 980,
        pricePerNightRm: 98,
        distanceKm: 0.6,
        walkToStation: '5 min to Subway Station',
        walkToDay1Start: '12 min transit to Day 1 starting point',
        plannedLocationsWithin30Min: 4,
        totalPlannedLocations: 6,
        checkInTime: '3:00 PM',
        checkOutTime: '10:00 AM',
        amenities: ['Free cancellation', 'Free Wi-Fi', 'Luggage storage', '24h reception'],
        cancellationPolicy: 'Free cancellation up to 24h before',
        matchScore: 86,
        matchBreakdown: const {
          'Location': 80,
          'Price': 99,
          'Rating': 82,
          'Itinerary': 84,
          'Preferences': 82,
        },
        comparativeRole: ComparativeRole.cheapestSuitable,
        measurableReasons: [
          'Best budget pick: RM${98 * nights} total — saves RM${47 * nights} compared to central hotels',
          'Clean, air-conditioned rooms with high-speed Wi-Fi and power shower',
          'Within 10 min transit to shopping arcades and convenience stores',
        ],
      ),
      HotelOption(
        id: 'hotel_gen_4',
        name: 'The Metropolitan Park Hotel, $city',
        neighborhood: 'City Park Boulevard, $city',
        city: city,
        imagePath: 'assets/journey/hotel.jpeg',
        rating: 4.9,
        reviewsCount: 2410,
        pricePerNightRm: 195,
        distanceKm: 0.4,
        walkToStation: '4 min to Boulevard Subway',
        walkToDay1Start: '8 min walk to City Gardens & Museum Plaza',
        plannedLocationsWithin30Min: 5,
        totalPlannedLocations: 6,
        checkInTime: '3:00 PM',
        checkOutTime: '12:00 PM',
        amenities: ['Free cancellation', 'Park views', 'Spa & wellness', 'Breakfast buffet'],
        cancellationPolicy: 'Free cancellation up to 48h before',
        matchScore: 94,
        matchBreakdown: const {
          'Location': 92,
          'Price': 80,
          'Rating': 99,
          'Itinerary': 94,
          'Preferences': 93,
        },
        comparativeRole: ComparativeRole.highestRated,
        measurableReasons: [
          'Top guest satisfaction rating (4.9 / 5.0) in $city from over 2,400 reviews',
          'Lush park views with on-site sauna and relaxing wellness facilities',
          'Comprehensive hot and cold breakfast buffet included with booking',
        ],
      ),
      HotelOption(
        id: 'hotel_gen_5',
        name: 'The Royal $city Palace & Suites',
        neighborhood: 'Diplomatic & Financial District, $city',
        city: city,
        imagePath: 'assets/journey/hotel.jpeg',
        rating: 4.9,
        reviewsCount: 1650,
        pricePerNightRm: 260,
        distanceKm: 0.5,
        walkToStation: '5 min to Grand Avenue Station',
        walkToDay1Start: '10 min transit to central attractions',
        plannedLocationsWithin30Min: 4,
        totalPlannedLocations: 6,
        checkInTime: '3:00 PM',
        checkOutTime: '12:00 PM',
        amenities: ['Free cancellation', 'Fine dining', 'Concierge service', 'Executive lounge'],
        cancellationPolicy: 'Free cancellation up to 3 days before',
        matchScore: 88,
        matchBreakdown: const {
          'Location': 88,
          'Price': 70,
          'Rating': 99,
          'Itinerary': 88,
          'Preferences': 92,
        },
        comparativeRole: ComparativeRole.luxuryPick,
        measurableReasons: [
          'Prestigious 5-star flagship hotel with personalized 24/7 concierge',
          'Spacious executive suites featuring panoramic skyline views',
          'Award-winning on-site fine dining restaurant and rooftop cocktail bar',
        ],
      ),
    ];
  }

  /// Returns curated flight options evaluated with concrete itinerary trade-offs
  static List<FlightOption> getFlights({
    required String destination,
    DateTime? startDate,
    DateTime? endDate,
    String? tripType,
  }) {
    final city = extractCity(destination);
    final arrCode = getAirportCode(city);

    return [
      FlightOption(
        id: 'flight_1',
        airline: 'AirAsia X',
        airlineCode: 'D7',
        flightNumber: 'D7 534',
        departureAirport: 'KUL',
        departureCity: 'Kuala Lumpur',
        arrivalAirport: arrCode,
        arrivalCity: city,
        departureTime: '10:20 AM',
        arrivalTime: '06:00 PM',
        duration: '6h 40m',
        durationMinutes: 400,
        stops: 0,
        stopsLabel: 'Direct',
        baggageAllowance: '20kg checked bag included',
        pricePerPersonRm: 680,
        cabinClass: 'Economy',
        matchScore: 92,
        matchBreakdown: const {
          'Schedule': 95,
          'Price': 92,
          'Comfort': 85,
          'Baggage': 88,
        },
        comparativeRole: ComparativeRole.bestOverall,
        concreteTradeOff:
            'RM50 more than the cheapest flight, but arrives 2h earlier and gives you enough time for your Day 1 itinerary.',
        measurableReasons: [
          'Arrives at 6:00 PM — plenty of time to clear customs and reach your hotel before 8:00 PM dinner',
          'Direct daytime nonstop flight avoids overnight sleep disruption',
          'RM680 / person is 28% below seasonal average fares for $arrCode',
          '20kg baggage allowance per passenger included',
        ],
      ),
      FlightOption(
        id: 'flight_2',
        airline: 'Batik Air',
        airlineCode: 'OD',
        flightNumber: 'OD 612',
        departureAirport: 'KUL',
        departureCity: 'Kuala Lumpur',
        arrivalAirport: arrCode,
        arrivalCity: city,
        departureTime: '02:15 PM',
        arrivalTime: '09:40 PM',
        duration: '6h 25m',
        durationMinutes: 385,
        stops: 0,
        stopsLabel: 'Direct',
        baggageAllowance: '20kg checked bag included',
        pricePerPersonRm: 630,
        cabinClass: 'Economy',
        matchScore: 82,
        matchBreakdown: const {
          'Schedule': 72,
          'Price': 98,
          'Comfort': 80,
          'Baggage': 85,
        },
        comparativeRole: ComparativeRole.cheapestSuitable,
        concreteTradeOff:
            'Lowest fare available (RM630), but lands late at 9:40 PM — Day 1 evening activities will be missed.',
        measurableReasons: [
          'Saves RM200 total for your group on airfare',
          'Direct flight with 20kg baggage included',
          'Late arrival means you will need late night transit or airport bus',
        ],
      ),
      FlightOption(
        id: 'flight_3',
        airline: 'Malaysia Airlines',
        airlineCode: 'MH',
        flightNumber: 'MH 052',
        departureAirport: 'KUL',
        departureCity: 'Kuala Lumpur',
        arrivalAirport: arrCode,
        arrivalCity: city,
        departureTime: '10:30 PM',
        arrivalTime: '06:10 AM +1',
        duration: '6h 40m',
        durationMinutes: 400,
        stops: 0,
        stopsLabel: 'Direct (Overnight)',
        baggageAllowance: '30kg checked bag included',
        pricePerPersonRm: 950,
        cabinClass: 'Economy',
        matchScore: 89,
        matchBreakdown: const {
          'Schedule': 88,
          'Price': 82,
          'Comfort': 92,
          'Baggage': 98,
        },
        comparativeRole: ComparativeRole.closestToItinerary,
        concreteTradeOff:
            'Full-service national carrier with generous 30kg baggage and morning landing to maximize Day 1.',
        measurableReasons: [
          'Lands at 6:10 AM giving you the entire day to start your itinerary',
          '30kg baggage allowance per person — ideal for shopping',
          'Hot meals, entertainment, and seat selection included',
        ],
      ),
      FlightOption(
        id: 'flight_4',
        airline: 'Singapore Airlines',
        airlineCode: 'SQ',
        flightNumber: 'SQ 618',
        departureAirport: 'KUL',
        departureCity: 'Kuala Lumpur',
        arrivalAirport: arrCode,
        arrivalCity: city,
        departureTime: '08:30 AM',
        arrivalTime: '05:45 PM',
        duration: '8h 15m',
        durationMinutes: 495,
        stops: 1,
        stopsLabel: '1 Stop (SIN 1h 15m)',
        baggageAllowance: '25kg checked bag included',
        pricePerPersonRm: 1180,
        cabinClass: 'Economy',
        matchScore: 88,
        matchBreakdown: const {
          'Schedule': 90,
          'Price': 74,
          'Comfort': 99,
          'Baggage': 92,
        },
        comparativeRole: ComparativeRole.highestRated,
        concreteTradeOff:
            'World-class 5-star airline experience with swift 75-minute connection at Changi.',
        measurableReasons: [
          'Rated #1 airline globally for passenger service and in-flight dining',
          'Reliable daytime schedule arriving at 5:45 PM',
          'Seamless luggage transfer directly to $arrCode',
        ],
      ),
    ];
  }

  /// Returns curated bullet train / Shinkansen & intercity rail options
  static List<TrainOption> getTrains({
    required String destination,
    DateTime? startDate,
    DateTime? endDate,
    String? tripType,
  }) {
    final city = extractCity(destination);

    return [
      // 1. Shinkansen Bullet Train Nozomi
      TrainOption(
        id: 'train_1',
        trainName: 'Tokaido-Sanyo Shinkansen (Nozomi)',
        trainOperator: 'JR West / JR Central',
        route: 'Shin-Kobe ⇄ Kyoto Station',
        departureStation: 'Shin-Kobe Station',
        arrivalStation: 'Kyoto Station',
        duration: '28 mins',
        durationMinutes: 28,
        speed: 'Bullet Train · 300 km/h',
        frequency: 'Departs every 10–15 mins',
        priceRm: 145,
        matchScore: 96,
        matchBreakdown: const {
          'Speed': 99,
          'Convenience': 95,
          'Price': 88,
          'Itinerary Fit': 98,
        },
        comparativeRole: ComparativeRole.bestOverall,
        concreteTradeOff:
            'Fastest way to visit Kyoto for Day 3 — saves 1h 45m travel time compared to local JR lines.',
        measurableReasons: [
          '28 mins nonstop from Shin-Kobe to Kyoto Station (saves 1h 45m return commute)',
          'Top speed of 300 km/h with scenic Mount Rokko departure',
          'High frequency (trains every 10–15 mins) allows flexible return whenever your dinner finishes',
          'Reserved reclining seat with power outlet and quiet car options',
        ],
      ),

      // 2. Kansai Rail Pass
      TrainOption(
        id: 'train_2',
        trainName: 'JR Kansai Area Rail Pass (1-Day)',
        trainOperator: 'JR West',
        route: 'Kobe ⇄ Osaka ⇄ Kyoto (All JR Rapid Lines)',
        departureStation: 'Sannomiya / Kobe Station',
        arrivalStation: 'Kyoto / Osaka Stations',
        duration: '52 mins',
        durationMinutes: 52,
        speed: 'Special Rapid · 130 km/h',
        frequency: 'Departs every 15 mins',
        priceRm: 85,
        matchScore: 88,
        matchBreakdown: const {
          'Speed': 78,
          'Convenience': 86,
          'Price': 98,
          'Itinerary Fit': 85,
        },
        comparativeRole: ComparativeRole.cheapestSuitable,
        concreteTradeOff:
            'Saves RM60 per person and includes Kyoto local buses, but takes 52 mins vs 28 mins on the Shinkansen.',
        measurableReasons: [
          'Unlimited rides on JR Special Rapid, Rapid, and local trains for full day',
          'Complimentary Kyoto city subway and Keihan Kyoto bus pass voucher included',
          'Departs directly from Sannomiya Station (no need to go to Shin-Kobe)',
        ],
      ),

      // 3. Shinkansen Hikari / Kodama
      TrainOption(
        id: 'train_3',
        trainName: 'Sanyo Shinkansen (Hikari / Sakura)',
        trainOperator: 'JR West',
        route: 'Shin-Kobe ⇄ Shin-Osaka / Kyoto',
        departureStation: 'Shin-Kobe Station',
        arrivalStation: 'Kyoto Station',
        duration: '34 mins',
        durationMinutes: 34,
        speed: 'Bullet Train · 285 km/h',
        frequency: 'Departs every 30 mins',
        priceRm: 130,
        matchScore: 91,
        matchBreakdown: const {
          'Speed': 94,
          'Convenience': 88,
          'Price': 92,
          'Itinerary Fit': 90,
        },
        comparativeRole: ComparativeRole.highestRated,
        concreteTradeOff:
            'Slightly cheaper bullet train ticket with wider 2x2 reserved seats.',
        measurableReasons: [
          'Wider, plush 2x2 seating on Sakura N700 series train sets',
          'Only 6 minutes slower than Nozomi service',
          'Eligible for discount e-ticket mobile booking',
        ],
      ),

      // 4. Airport Express Limousine Bus
      TrainOption(
        id: 'train_4',
        trainName: 'Kansai Airport Limousine Bus',
        trainOperator: 'Hankyu Bus / Hanshin Bus',
        route: 'KIX Airport ⇄ Sannomiya Hub',
        departureStation: 'KIX Terminal 1 (Stop 4)',
        arrivalStation: 'Sannomiya Bus Terminal',
        duration: '65 mins',
        durationMinutes: 65,
        speed: 'Highway Express Bus',
        frequency: 'Departs every 20 mins',
        priceRm: 65,
        matchScore: 90,
        matchBreakdown: const {
          'Speed': 82,
          'Convenience': 98,
          'Price': 95,
          'Itinerary Fit': 92,
        },
        comparativeRole: ComparativeRole.closestToItinerary,
        concreteTradeOff:
            'Zero luggage lifting or station stairs — direct express highway coach straight to Sannomiya.',
        measurableReasons: [
          'Board right outside customs at KIX Terminal 1 & 2',
          'Luggage stored underneath bus by attendants (2 pieces included)',
          'Arrives directly in front of central Sannomiya hotel district',
        ],
      ),
    ];
  }

  /// Filter and sort hotel list based on user selections
  static List<HotelOption> filterAndSortHotels({
    required List<HotelOption> hotels,
    required HotelSortOption sortOption,
    required HotelFilterState filter,
  }) {
    var filtered = hotels.where((hotel) {
      if (hotel.pricePerNightRm > filter.maxPriceRm) return false;
      if (hotel.rating < filter.minRating) return false;
      if (filter.freeCancellationOnly &&
          !hotel.cancellationPolicy.toLowerCase().contains('free')) {
        return false;
      }
      if (filter.selectedAmenities.isNotEmpty) {
        final matchesAll = filter.selectedAmenities.every(
          (amenity) => hotel.amenities.any(
            (a) => a.toLowerCase().contains(amenity.toLowerCase()),
          ),
        );
        if (!matchesAll) return false;
      }
      return true;
    }).toList();

    switch (sortOption) {
      case HotelSortOption.recommended:
        filtered.sort((a, b) => b.matchScore.compareTo(a.matchScore));
        break;
      case HotelSortOption.price:
        filtered.sort((a, b) => a.pricePerNightRm.compareTo(b.pricePerNightRm));
        break;
      case HotelSortOption.rating:
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case HotelSortOption.distance:
        filtered.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
        break;
    }

    return filtered;
  }

  /// Filter and sort flight list based on user selections
  static List<FlightOption> filterAndSortFlights({
    required List<FlightOption> flights,
    required FlightSortOption sortOption,
    required FlightFilterState filter,
  }) {
    var filtered = flights.where((flight) {
      if (flight.pricePerPersonRm > filter.maxPriceRm) return false;
      if (filter.directOnly && flight.stops > 0) return false;
      if (filter.selectedAirlines.isNotEmpty &&
          !filter.selectedAirlines.contains(flight.airline)) {
        return false;
      }
      return true;
    }).toList();

    switch (sortOption) {
      case FlightSortOption.recommended:
        filtered.sort((a, b) => b.matchScore.compareTo(a.matchScore));
        break;
      case FlightSortOption.price:
        filtered.sort((a, b) => a.pricePerPersonRm.compareTo(b.pricePerPersonRm));
        break;
      case FlightSortOption.duration:
        filtered.sort((a, b) => a.durationMinutes.compareTo(b.durationMinutes));
        break;
      case FlightSortOption.departure:
        filtered.sort((a, b) => a.departureTime.compareTo(b.departureTime));
        break;
    }

    return filtered;
  }

  /// Filter and sort train list based on user selections
  static List<TrainOption> filterAndSortTrains({
    required List<TrainOption> trains,
    required TrainSortOption sortOption,
  }) {
    var list = List<TrainOption>.from(trains);

    switch (sortOption) {
      case TrainSortOption.recommended:
        list.sort((a, b) => b.matchScore.compareTo(a.matchScore));
        break;
      case TrainSortOption.price:
        list.sort((a, b) => a.priceRm.compareTo(b.priceRm));
        break;
      case TrainSortOption.speed:
        list.sort((a, b) => a.durationMinutes.compareTo(b.durationMinutes));
        break;
    }

    return list;
  }

  /// Get comprehensive attraction ticket details with multi-platform price comparison
  /// (e.g. Klook, Trip.com, KKday, and Official Box Office)
  static AttractionTicketDetail getAttractionTicketDetails({
    required String attractionType, // 'aquarium', 'zoo', 'museum'
    required String city,
  }) {
    final cleanType = attractionType.toLowerCase();

    if (cleanType.contains('zoo')) {
      return AttractionTicketDetail(
        id: 'attraction_zoo',
        title: 'Zoo',
        subtitle: 'Historic park with wildlife exhibits',
        city: city,
        imageAsset: 'assets/journey/zoo.jpeg',
        rating: 4.6,
        reviewCount: 1920,
        openingHours: '9:30 AM – 5:00 PM (Closed Mondays)',
        address: 'Ueno Park, $city',
        smartInsight:
            'Trippy found: Klook offers instant electronic barcode tickets saving 20% compared to on-site ticket vending queues!',
        platforms: const [
          PlatformTicketPrice(
            platformName: 'Klook',
            priceRm: 16,
            originalPriceRm: 20,
            badge: '🏆 Lowest Price',
            isLowestPrice: true,
            perks: [
              'Skip-the-line E-barcode entry',
              'Valid for 90 days from purchase',
              'Instant confirmation',
              'Free cancellation (24h before)',
            ],
            bookingUrl: 'https://www.klook.com',
            brandColor: Color(0xFFFF5722),
          ),
          PlatformTicketPrice(
            platformName: 'Trip.com',
            priceRm: 18,
            originalPriceRm: 20,
            badge: '⭐ Easy Booking',
            perks: [
              'Instant E-ticket delivery',
              'Earn Trip Coins cash rebate',
              '24/7 customer support',
            ],
            bookingUrl: 'https://www.trip.com',
            brandColor: Color(0xFF287DFA),
          ),
          PlatformTicketPrice(
            platformName: 'KKday',
            priceRm: 19,
            originalPriceRm: 20,
            perks: [
              'Direct QR admission',
              'Includes bilingual park map',
              'Flexible rescheduling',
            ],
            bookingUrl: 'https://www.kkday.com',
            brandColor: Color(0xFF00BCD4),
          ),
          PlatformTicketPrice(
            platformName: 'Official Box Office',
            priceRm: 20,
            originalPriceRm: 20,
            badge: 'On-site counter',
            perks: [
              'Standard ticket from vending machine',
              'Cash or IC transit card required',
              'Peak queue lines during weekends',
            ],
            bookingUrl: '',
            brandColor: Color(0xFF6B5A50),
          ),
        ],
      );
    } else if (cleanType.contains('museum')) {
      return AttractionTicketDetail(
        id: 'attraction_museum',
        title: 'Museum',
        subtitle: '$city National Museum & Cultural Treasures',
        city: city,
        imageAsset: 'assets/journey/musuem.jpeg',
        rating: 4.7,
        reviewCount: 3150,
        openingHours: '9:30 AM – 5:00 PM (Closed Mondays)',
        address: 'National Museum Complex, $city',
        smartInsight:
            'Trippy found: Klook provides fast-track priority entry at RM28 with a complimentary digital English audio guide!',
        platforms: const [
          PlatformTicketPrice(
            platformName: 'Klook',
            priceRm: 28,
            originalPriceRm: 34,
            badge: '🏆 Lowest Price',
            isLowestPrice: true,
            perks: [
              'Fast-track priority entry',
              'Free digital English audio guide app',
              'Instant confirmation',
              'Mobile voucher acceptance',
            ],
            bookingUrl: 'https://www.klook.com',
            brandColor: Color(0xFFFF5722),
          ),
          PlatformTicketPrice(
            platformName: 'Trip.com',
            priceRm: 30,
            originalPriceRm: 34,
            badge: '⭐ Official Partner',
            perks: [
              'Official partner direct e-ticket',
              'Free cancellation up to entry',
              'Multi-museum pass combo available',
            ],
            bookingUrl: 'https://www.trip.com',
            brandColor: Color(0xFF287DFA),
          ),
          PlatformTicketPrice(
            platformName: 'KKday',
            priceRm: 32,
            originalPriceRm: 34,
            perks: [
              'Instant confirmation voucher',
              'Special temporary exhibition add-on option',
              'English customer support',
            ],
            bookingUrl: 'https://www.kkday.com',
            brandColor: Color(0xFF00BCD4),
          ),
          PlatformTicketPrice(
            platformName: 'Official Box Office',
            priceRm: 34,
            originalPriceRm: 34,
            badge: 'On-site counter',
            perks: [
              'Physical ticket purchase at entrance',
              'ID check required at counter',
              'No refund once issued',
            ],
            bookingUrl: '',
            brandColor: Color(0xFF6B5A50),
          ),
        ],
      );
    } else {
      // Default / Aquarium
      return AttractionTicketDetail(
        id: 'attraction_aquarium',
        title: 'Aquarium',
        subtitle: 'Explore marine life & ocean wonders',
        city: city,
        imageAsset: 'assets/journey/aquarium.jpeg',
        rating: 4.8,
        reviewCount: 2340,
        openingHours: '9:00 AM – 8:00 PM (Daily)',
        address: 'Harbor City Promenade, $city',
        smartInsight:
            'Trippy found: Klook currently offers an exclusive 13% discount (RM68 vs RM78 at the counter) with direct QR turnstile entry!',
        platforms: const [
          PlatformTicketPrice(
            platformName: 'Klook',
            priceRm: 68,
            originalPriceRm: 78,
            badge: '🏆 Lowest Price',
            isLowestPrice: true,
            perks: [
              'Direct QR code turnstile entry',
              'Instant confirmation',
              'Free cancellation (24h before visit)',
              'Exclusive in-app 13% discount',
            ],
            bookingUrl: 'https://www.klook.com',
            brandColor: Color(0xFFFF5722),
          ),
          PlatformTicketPrice(
            platformName: 'Trip.com',
            priceRm: 72,
            originalPriceRm: 78,
            badge: '⭐ Popular Choice',
            perks: [
              'Instant mobile E-voucher',
              'Earn Trip Coins rewards',
              'Customer support via app call',
            ],
            bookingUrl: 'https://www.trip.com',
            brandColor: Color(0xFF287DFA),
          ),
          PlatformTicketPrice(
            platformName: 'KKday',
            priceRm: 75,
            originalPriceRm: 78,
            perks: [
              'Direct turnstile barcode scan',
              'Combo ticket option with ropeway',
              'Easy 1-click date change',
            ],
            bookingUrl: 'https://www.kkday.com',
            brandColor: Color(0xFF00BCD4),
          ),
          PlatformTicketPrice(
            platformName: 'Official Box Office',
            priceRm: 78,
            originalPriceRm: 78,
            badge: 'On-site counter',
            perks: [
              'Standard admission ticket',
              'Physical queuing required (avg 25 mins)',
              'Cash or credit card on-site',
            ],
            bookingUrl: '',
            brandColor: Color(0xFF6B5A50),
          ),
        ],
      );
    }
  }

  /// Get live platform comparison deals for any hotel stay
  /// (e.g. Klook, Trip.com, Agoda, Booking.com, Official Direct)
  static List<PlatformTicketPrice> getHotelPlatformDeals({
    required HotelOption hotel,
    required int totalNights,
  }) {
    final basePrice = hotel.pricePerNightRm;
    final klookPrice = basePrice;
    final klookOriginal = (basePrice * 1.18).round();

    final tripPrice = (basePrice * 1.04).round();
    final tripOriginal = (basePrice * 1.15).round();

    final agodaPrice = (basePrice * 1.02).round();
    final agodaOriginal = (basePrice * 1.16).round();

    final bookingPrice = (basePrice * 1.07).round();
    final bookingOriginal = (basePrice * 1.14).round();

    final directPrice = (basePrice * 1.12).round();

    return [
      PlatformTicketPrice(
        platformName: 'Klook',
        priceRm: klookPrice,
        originalPriceRm: klookOriginal,
        badge: '🏆 Lowest Price',
        isLowestPrice: true,
        roomType: 'Standard King / Twin • City View',
        perks: const [
          'Instant booking confirmation & mobile voucher',
          'Free cancellation (up to 24h before check-in)',
          'Earn Klook travel credits rewards',
          'Best rate guarantee with instant sync',
        ],
        bookingUrl: 'https://www.klook.com/zh-CN/hotels/?spm=Home.TopSearchBar_MainNode_LIST&clickId=2c2ca18b39',
        brandColor: const Color(0xFFFF5722),
      ),
      PlatformTicketPrice(
        platformName: 'Trip.com',
        priceRm: tripPrice,
        originalPriceRm: tripOriginal,
        badge: '⭐ Member Special',
        roomType: 'Deluxe Queen Room • High Floor',
        perks: const [
          'Includes daily buffet breakfast for 2',
          'Trip Coins cash rebate rewards',
          '24/7 customer support via app chat/call',
          'Free room upgrade upon availability',
        ],
        bookingUrl: 'https://www.trip.com',
        brandColor: const Color(0xFF287DFA),
      ),
      PlatformTicketPrice(
        platformName: 'Agoda',
        priceRm: agodaPrice,
        originalPriceRm: agodaOriginal,
        badge: '🔥 Agoda VIP Price',
        roomType: 'Superior Double / Twin Room',
        perks: const [
          'Agoda VIP tier discount applied',
          'Pay at hotel or pay now option',
          'Free high-speed Wi-Fi in room',
          'Easy 1-click cancellation',
        ],
        bookingUrl: 'https://www.agoda.com',
        brandColor: const Color(0xFF5856D6),
      ),
      PlatformTicketPrice(
        platformName: 'Booking.com',
        priceRm: bookingPrice,
        originalPriceRm: bookingOriginal,
        badge: '👍 Flexible Policy',
        roomType: 'Comfort King Room • Quiet Side',
        perks: const [
          'Genius Level 2 discount included',
          'No prepayment needed at booking',
          'Free cancellation anytime up to 48h before',
          'Loyalty stay points credited',
        ],
        bookingUrl: 'https://www.booking.com',
        brandColor: const Color(0xFF003580),
      ),
      PlatformTicketPrice(
        platformName: 'Official Hotel Direct',
        priceRm: directPrice,
        originalPriceRm: directPrice,
        badge: 'Direct Member',
        roomType: '${hotel.name} Signature Room',
        perks: const [
          'Direct hotel member privilege',
          'Complimentary late check-out till 1:00 PM',
          'Priority room allocation on high floor',
          'Welcome beverage at guest lounge',
        ],
        bookingUrl: 'https://www.google.com/search?q=${Uri.encodeComponent(hotel.name)}',
        brandColor: const Color(0xFF5D4037),
      ),
    ];
  }
}
