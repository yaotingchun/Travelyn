import 'package:flutter/material.dart';

/// Segment navigation for bookings
enum BookingType {
  stays,
  flights,
  trains,
}

/// Status of a checklist item
enum BookingItemStatus {
  needed,
  booked,
  optional,
}

/// Hotel sorting options
enum HotelSortOption {
  recommended,
  price,
  rating,
  distance,
}

extension HotelSortOptionExt on HotelSortOption {
  String get label {
    switch (this) {
      case HotelSortOption.recommended:
        return 'Recommended';
      case HotelSortOption.price:
        return 'Price';
      case HotelSortOption.rating:
        return 'Rating';
      case HotelSortOption.distance:
        return 'Distance';
    }
  }
}

/// Flight sorting options
enum FlightSortOption {
  recommended,
  price,
  duration,
  departure,
}

extension FlightSortOptionExt on FlightSortOption {
  String get label {
    switch (this) {
      case FlightSortOption.recommended:
        return 'Recommended';
      case FlightSortOption.price:
        return 'Price';
      case FlightSortOption.duration:
        return 'Duration';
      case FlightSortOption.departure:
        return 'Departure';
    }
  }
}

/// Train sorting options
enum TrainSortOption {
  recommended,
  price,
  speed,
}

extension TrainSortOptionExt on TrainSortOption {
  String get label {
    switch (this) {
      case TrainSortOption.recommended:
        return 'Recommended';
      case TrainSortOption.price:
        return 'Lowest Fare';
      case TrainSortOption.speed:
        return 'Fastest Bullet Train';
    }
  }
}

/// Comparative role evaluated by Trippy AI
enum ComparativeRole {
  bestOverall,
  cheapestSuitable,
  closestToItinerary,
  highestRated,
  luxuryPick,
}

extension ComparativeRoleExt on ComparativeRole {
  String get stayBadgeLabel {
    switch (this) {
      case ComparativeRole.bestOverall:
        return 'Recommended for your trip';
      case ComparativeRole.cheapestSuitable:
        return 'Cheapest suitable';
      case ComparativeRole.closestToItinerary:
        return 'Closest to itinerary';
      case ComparativeRole.highestRated:
        return 'Highest rated';
      case ComparativeRole.luxuryPick:
        return 'Premium comfort';
    }
  }

  String get flightBadgeLabel {
    switch (this) {
      case ComparativeRole.bestOverall:
        return 'Recommended for your trip';
      case ComparativeRole.cheapestSuitable:
        return 'Lowest fare';
      case ComparativeRole.closestToItinerary:
        return 'Best arrival time';
      case ComparativeRole.highestRated:
        return 'Top airline rating';
      case ComparativeRole.luxuryPick:
        return 'Premium cabin';
    }
  }

  String get trainBadgeLabel {
    switch (this) {
      case ComparativeRole.bestOverall:
        return 'Recommended for itinerary';
      case ComparativeRole.cheapestSuitable:
        return 'Budget rail pass';
      case ComparativeRole.closestToItinerary:
        return 'Direct airport route';
      case ComparativeRole.highestRated:
        return 'Fastest bullet train';
      case ComparativeRole.luxuryPick:
        return 'Green car reserved';
    }
  }

  String get emoji {
    switch (this) {
      case ComparativeRole.bestOverall:
        return '';
      case ComparativeRole.cheapestSuitable:
        return '💰';
      case ComparativeRole.closestToItinerary:
        return '📍';
      case ComparativeRole.highestRated:
        return '⭐';
      case ComparativeRole.luxuryPick:
        return '✨';
    }
  }
}

/// Section category for checklist items
enum ChecklistCategory {
  beforeYouGo,
  enhanceYourTrip,
}

/// AI-generated checklist item based on user itinerary
class BookingChecklistItem {
  final String id;
  final BookingType type;
  final String title;
  final String subtitle;
  final String routeOrCity;
  final String itineraryContext;
  final String dates;
  final BookingItemStatus status;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String priorityLabel;
  final Color priorityTextColor;
  final Color priorityBgColor;
  final ChecklistCategory category;
  final String? tip;
  final String aiRationale;
  final String? bookedOptionName;
  final int estimatedCostRm;

  const BookingChecklistItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.routeOrCity,
    required this.itineraryContext,
    required this.dates,
    this.status = BookingItemStatus.needed,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.priorityLabel,
    required this.priorityTextColor,
    required this.priorityBgColor,
    required this.category,
    this.tip,
    required this.aiRationale,
    this.bookedOptionName,
    required this.estimatedCostRm,
  });

  BookingChecklistItem copyWith({
    BookingItemStatus? status,
    String? bookedOptionName,
  }) {
    return BookingChecklistItem(
      id: id,
      type: type,
      title: title,
      subtitle: subtitle,
      routeOrCity: routeOrCity,
      itineraryContext: itineraryContext,
      dates: dates,
      status: status ?? this.status,
      icon: icon,
      iconColor: iconColor,
      iconBgColor: iconBgColor,
      priorityLabel: priorityLabel,
      priorityTextColor: priorityTextColor,
      priorityBgColor: priorityBgColor,
      category: category,
      tip: tip,
      aiRationale: aiRationale,
      bookedOptionName: bookedOptionName ?? this.bookedOptionName,
      estimatedCostRm: estimatedCostRm,
    );
  }
}

/// Split-stay recommendation for long journeys
class SplitStaySuggestion {
  final String primaryCity;
  final int primaryNights;
  final String secondaryCity;
  final int secondaryNights;
  final int additionalCostRm;
  final String travelTimeSaved;
  final String rationale;

  const SplitStaySuggestion({
    required this.primaryCity,
    required this.primaryNights,
    required this.secondaryCity,
    required this.secondaryNights,
    required this.additionalCostRm,
    required this.travelTimeSaved,
    required this.rationale,
  });
}

/// Model representing a hotel / stay option with measurable itinerary data
@immutable
class HotelOption {
  final String id;
  final String name;
  final String neighborhood;
  final String city;
  final String? imagePath;
  final double rating;
  final int reviewsCount;
  final int pricePerNightRm;
  final double distanceKm;
  final String walkToStation;
  final String walkToDay1Start;
  final int plannedLocationsWithin30Min;
  final int totalPlannedLocations;
  final String checkInTime;
  final String checkOutTime;
  final List<String> amenities;
  final String cancellationPolicy;
  final int matchScore;
  final Map<String, int> matchBreakdown;
  final ComparativeRole comparativeRole;
  final List<String> measurableReasons;

  const HotelOption({
    required this.id,
    required this.name,
    required this.neighborhood,
    required this.city,
    this.imagePath,
    required this.rating,
    required this.reviewsCount,
    required this.pricePerNightRm,
    required this.distanceKm,
    required this.walkToStation,
    required this.walkToDay1Start,
    required this.plannedLocationsWithin30Min,
    required this.totalPlannedLocations,
    this.checkInTime = '3:00 PM',
    this.checkOutTime = '11:00 AM',
    required this.amenities,
    required this.cancellationPolicy,
    required this.matchScore,
    required this.matchBreakdown,
    required this.comparativeRole,
    required this.measurableReasons,
  });

  int calculateTotalPrice(int nights) {
    return pricePerNightRm * (nights > 0 ? nights : 1);
  }

  String getDynamicBadgeLabel(HotelSortOption sortOption) {
    switch (sortOption) {
      case HotelSortOption.price:
        return '💰 BEST PRICE';
      case HotelSortOption.rating:
        return '⭐ HIGHEST RATED';
      case HotelSortOption.distance:
        return '📍 BEST LOCATION';
      case HotelSortOption.recommended:
        final prefix = comparativeRole.emoji.isEmpty ? '' : '${comparativeRole.emoji} ';
        return '$prefix${comparativeRole.stayBadgeLabel.toUpperCase()}';
    }
  }
}

/// Model representing a flight option with concrete trade-offs
@immutable
class FlightOption {
  final String id;
  final String airline;
  final String airlineCode;
  final String flightNumber;
  final String departureAirport;
  final String departureCity;
  final String arrivalAirport;
  final String arrivalCity;
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final int durationMinutes;
  final int stops;
  final String stopsLabel;
  final String baggageAllowance;
  final int pricePerPersonRm;
  final String cabinClass;
  final int matchScore;
  final Map<String, int> matchBreakdown;
  final ComparativeRole comparativeRole;
  final String concreteTradeOff;
  final List<String> measurableReasons;

  const FlightOption({
    required this.id,
    required this.airline,
    required this.airlineCode,
    required this.flightNumber,
    required this.departureAirport,
    required this.departureCity,
    required this.arrivalAirport,
    required this.arrivalCity,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.durationMinutes,
    required this.stops,
    required this.stopsLabel,
    required this.baggageAllowance,
    required this.pricePerPersonRm,
    this.cabinClass = 'Economy',
    required this.matchScore,
    required this.matchBreakdown,
    required this.comparativeRole,
    required this.concreteTradeOff,
    required this.measurableReasons,
  });

  int calculateTotalPrice(int travellers) {
    return pricePerPersonRm * (travellers > 0 ? travellers : 1);
  }

  String getDynamicBadgeLabel(FlightSortOption sortOption) {
    switch (sortOption) {
      case FlightSortOption.price:
        return '💰 LOWEST FARE';
      case FlightSortOption.duration:
        return '⚡ FASTEST FLIGHT';
      case FlightSortOption.departure:
        return '🌅 EARLIEST DEPARTURE';
      case FlightSortOption.recommended:
        final prefix = comparativeRole.emoji.isEmpty ? '' : '${comparativeRole.emoji} ';
        return '$prefix${comparativeRole.flightBadgeLabel.toUpperCase()}';
    }
  }
}

/// Model representing a Bullet Train / Shinkansen / Intercity Rail option
@immutable
class TrainOption {
  final String id;
  final String trainName;
  final String trainOperator;
  final String route;
  final String departureStation;
  final String arrivalStation;
  final String duration;
  final int durationMinutes;
  final String speed;
  final String frequency;
  final int priceRm;
  final int matchScore;
  final Map<String, int> matchBreakdown;
  final ComparativeRole comparativeRole;
  final String concreteTradeOff;
  final List<String> measurableReasons;

  const TrainOption({
    required this.id,
    required this.trainName,
    required this.trainOperator,
    required this.route,
    required this.departureStation,
    required this.arrivalStation,
    required this.duration,
    required this.durationMinutes,
    required this.speed,
    required this.frequency,
    required this.priceRm,
    required this.matchScore,
    required this.matchBreakdown,
    required this.comparativeRole,
    required this.concreteTradeOff,
    required this.measurableReasons,
  });

  int calculateTotalPrice(int travellers) {
    return priceRm * (travellers > 0 ? travellers : 1);
  }

  String getDynamicBadgeLabel(TrainSortOption sortOption) {
    switch (sortOption) {
      case TrainSortOption.price:
        return '💰 LOWEST RAIL FARE';
      case TrainSortOption.speed:
        return '⚡ FASTEST BULLET TRAIN';
      case TrainSortOption.recommended:
        final prefix = comparativeRole.emoji.isEmpty ? '' : '${comparativeRole.emoji} ';
        return '$prefix${comparativeRole.trainBadgeLabel.toUpperCase()}';
    }
  }
}

/// Filter state for hotels
class HotelFilterState {
  final double maxPriceRm;
  final double minRating;
  final Set<String> selectedAmenities;
  final bool freeCancellationOnly;

  const HotelFilterState({
    this.maxPriceRm = 800,
    this.minRating = 0.0,
    this.selectedAmenities = const {},
    this.freeCancellationOnly = false,
  });

  HotelFilterState copyWith({
    double? maxPriceRm,
    double? minRating,
    Set<String>? selectedAmenities,
    bool? freeCancellationOnly,
  }) {
    return HotelFilterState(
      maxPriceRm: maxPriceRm ?? this.maxPriceRm,
      minRating: minRating ?? this.minRating,
      selectedAmenities: selectedAmenities ?? this.selectedAmenities,
      freeCancellationOnly: freeCancellationOnly ?? this.freeCancellationOnly,
    );
  }

  bool get hasActiveFilters =>
      maxPriceRm < 800 ||
      minRating > 0.0 ||
      selectedAmenities.isNotEmpty ||
      freeCancellationOnly;

  int get activeFilterCount {
    int count = 0;
    if (maxPriceRm < 800) count++;
    if (minRating > 0.0) count++;
    if (selectedAmenities.isNotEmpty) count += selectedAmenities.length;
    if (freeCancellationOnly) count++;
    return count;
  }
}

/// Filter state for flights
class FlightFilterState {
  final double maxPriceRm;
  final bool directOnly;
  final Set<String> selectedAirlines;

  const FlightFilterState({
    this.maxPriceRm = 2000,
    this.directOnly = false,
    this.selectedAirlines = const {},
  });

  FlightFilterState copyWith({
    double? maxPriceRm,
    bool? directOnly,
    Set<String>? selectedAirlines,
  }) {
    return FlightFilterState(
      maxPriceRm: maxPriceRm ?? this.maxPriceRm,
      directOnly: directOnly ?? this.directOnly,
      selectedAirlines: selectedAirlines ?? this.selectedAirlines,
    );
  }

  bool get hasActiveFilters =>
      maxPriceRm < 2000 || directOnly || selectedAirlines.isNotEmpty;

  int get activeFilterCount {
    int count = 0;
    if (maxPriceRm < 2000) count++;
    if (directOnly) count++;
    if (selectedAirlines.isNotEmpty) count += selectedAirlines.length;
    return count;
  }
}

/// Model representing a ticket price offered by a specific platform (e.g. Klook, Trip.com, KKday)
class PlatformTicketPrice {
  final String platformName;
  final int priceRm;
  final int originalPriceRm;
  final String? badge;
  final bool isLowestPrice;
  final List<String> perks;
  final String bookingUrl;
  final Color brandColor;
  final String? roomType;

  const PlatformTicketPrice({
    required this.platformName,
    required this.priceRm,
    required this.originalPriceRm,
    this.badge,
    this.isLowestPrice = false,
    required this.perks,
    required this.bookingUrl,
    required this.brandColor,
    this.roomType,
  });

  int get discountPercentage {
    if (originalPriceRm <= priceRm) return 0;
    return (((originalPriceRm - priceRm) / originalPriceRm) * 100).round();
  }
}

/// Detailed attraction model including multi-platform price comparison
class AttractionTicketDetail {
  final String id;
  final String title;
  final String subtitle;
  final String city;
  final String imageAsset;
  final double rating;
  final int reviewCount;
  final String openingHours;
  final String address;
  final String smartInsight;
  final List<PlatformTicketPrice> platforms;

  const AttractionTicketDetail({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.city,
    required this.imageAsset,
    required this.rating,
    required this.reviewCount,
    required this.openingHours,
    required this.address,
    required this.smartInsight,
    required this.platforms,
  });

  PlatformTicketPrice get bestPricePlatform {
    if (platforms.isEmpty) {
      return PlatformTicketPrice(
        platformName: 'Standard',
        priceRm: 50,
        originalPriceRm: 50,
        perks: const [],
        bookingUrl: '',
        brandColor: const Color(0xFFE65100),
      );
    }
    return platforms.reduce((curr, next) => curr.priceRm < next.priceRm ? curr : next);
  }
}

