/// Model representing a travel destination.
class Destination {
  final String city;
  final String country;
  final String flag;
  final String region;

  const Destination({
    required this.city,
    required this.country,
    required this.flag,
    required this.region,
  });

  String get displayName => '$city, $country';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Destination &&
          runtimeType == other.runtimeType &&
          city == other.city &&
          country == other.country;

  @override
  int get hashCode => city.hashCode ^ country.hashCode;
}

/// Destination service that acts as the backend source for city/destination search.
/// Provides instant substring and prefix matching across popular global destinations.
class DestinationService {
  static const List<Destination> allDestinations = [
    // Japan
    Destination(city: 'Tokyo', country: 'Japan', flag: '🇯🇵', region: 'Asia'),
    Destination(city: 'Kyoto', country: 'Japan', flag: '🇯🇵', region: 'Asia'),
    Destination(city: 'Osaka', country: 'Japan', flag: '🇯🇵', region: 'Asia'),
    Destination(city: 'Sapporo', country: 'Japan', flag: '🇯🇵', region: 'Asia'),
    Destination(city: 'Hiroshima', country: 'Japan', flag: '🇯🇵', region: 'Asia'),
    Destination(city: 'Nara', country: 'Japan', flag: '🇯🇵', region: 'Asia'),
    Destination(city: 'Fukuoka', country: 'Japan', flag: '🇯🇵', region: 'Asia'),
    Destination(city: 'Nagoya', country: 'Japan', flag: '🇯🇵', region: 'Asia'),
    Destination(city: 'Yokohama', country: 'Japan', flag: '🇯🇵', region: 'Asia'),
    Destination(city: 'Kobe', country: 'Japan', flag: '🇯🇵', region: 'Asia'),
    Destination(city: 'Hakone', country: 'Japan', flag: '🇯🇵', region: 'Asia'),
    Destination(city: 'Okinawa', country: 'Japan', flag: '🇯🇵', region: 'Asia'),
    Destination(city: 'Takayama', country: 'Japan', flag: '🇯🇵', region: 'Asia'),
    Destination(city: 'Kanazawa', country: 'Japan', flag: '🇯🇵', region: 'Asia'),

    // South Korea & East Asia
    Destination(city: 'Seoul', country: 'South Korea', flag: '🇰🇷', region: 'Asia'),
    Destination(city: 'Busan', country: 'South Korea', flag: '🇰🇷', region: 'Asia'),
    Destination(city: 'Jeju Island', country: 'South Korea', flag: '🇰🇷', region: 'Asia'),
    Destination(city: 'Taipei', country: 'Taiwan', flag: '🇹🇼', region: 'Asia'),
    Destination(city: 'Hong Kong', country: 'Hong Kong', flag: '🇭🇰', region: 'Asia'),
    Destination(city: 'Macau', country: 'Macau', flag: '🇲🇴', region: 'Asia'),
    Destination(city: 'Beijing', country: 'China', flag: '🇨🇳', region: 'Asia'),
    Destination(city: 'Shanghai', country: 'China', flag: '🇨🇳', region: 'Asia'),

    // Southeast Asia
    Destination(city: 'Bangkok', country: 'Thailand', flag: '🇹🇭', region: 'Asia'),
    Destination(city: 'Chiang Mai', country: 'Thailand', flag: '🇹🇭', region: 'Asia'),
    Destination(city: 'Phuket', country: 'Thailand', flag: '🇹🇭', region: 'Asia'),
    Destination(city: 'Singapore', country: 'Singapore', flag: '🇸🇬', region: 'Asia'),
    Destination(city: 'Kuala Lumpur', country: 'Malaysia', flag: '🇲🇾', region: 'Asia'),
    Destination(city: 'Penang', country: 'Malaysia', flag: '🇲🇾', region: 'Asia'),
    Destination(city: 'Bali', country: 'Indonesia', flag: '🇮🇩', region: 'Asia'),
    Destination(city: 'Jakarta', country: 'Indonesia', flag: '🇮🇩', region: 'Asia'),
    Destination(city: 'Hanoi', country: 'Vietnam', flag: '🇻🇳', region: 'Asia'),
    Destination(city: 'Da Nang', country: 'Vietnam', flag: '🇻🇳', region: 'Asia'),
    Destination(city: 'Ho Chi Minh City', country: 'Vietnam', flag: '🇻🇳', region: 'Asia'),
    Destination(city: 'Manila', country: 'Philippines', flag: '🇵🇭', region: 'Asia'),
    Destination(city: 'Boracay', country: 'Philippines', flag: '🇵🇭', region: 'Asia'),

    // Europe
    Destination(city: 'Paris', country: 'France', flag: '🇫🇷', region: 'Europe'),
    Destination(city: 'Nice', country: 'France', flag: '🇫🇷', region: 'Europe'),
    Destination(city: 'Lyon', country: 'France', flag: '🇫🇷', region: 'Europe'),
    Destination(city: 'London', country: 'United Kingdom', flag: '🇬🇧', region: 'Europe'),
    Destination(city: 'Edinburgh', country: 'United Kingdom', flag: '🇬🇧', region: 'Europe'),
    Destination(city: 'Rome', country: 'Italy', flag: '🇮🇹', region: 'Europe'),
    Destination(city: 'Florence', country: 'Italy', flag: '🇮🇹', region: 'Europe'),
    Destination(city: 'Venice', country: 'Italy', flag: '🇮🇹', region: 'Europe'),
    Destination(city: 'Milan', country: 'Italy', flag: '🇮🇹', region: 'Europe'),
    Destination(city: 'Barcelona', country: 'Spain', flag: '🇪🇸', region: 'Europe'),
    Destination(city: 'Madrid', country: 'Spain', flag: '🇪🇸', region: 'Europe'),
    Destination(city: 'Seville', country: 'Spain', flag: '🇪🇸', region: 'Europe'),
    Destination(city: 'Amsterdam', country: 'Netherlands', flag: '🇳🇱', region: 'Europe'),
    Destination(city: 'Berlin', country: 'Germany', flag: '🇩🇪', region: 'Europe'),
    Destination(city: 'Munich', country: 'Germany', flag: '🇩🇪', region: 'Europe'),
    Destination(city: 'Vienna', country: 'Austria', flag: '🇦🇹', region: 'Europe'),
    Destination(city: 'Salzburg', country: 'Austria', flag: '🇦🇹', region: 'Europe'),
    Destination(city: 'Prague', country: 'Czech Republic', flag: '🇨🇿', region: 'Europe'),
    Destination(city: 'Budapest', country: 'Hungary', flag: '🇭🇺', region: 'Europe'),
    Destination(city: 'Zurich', country: 'Switzerland', flag: '🇨🇭', region: 'Europe'),
    Destination(city: 'Lucerne', country: 'Switzerland', flag: '🇨🇭', region: 'Europe'),
    Destination(city: 'Geneva', country: 'Switzerland', flag: '🇨🇭', region: 'Europe'),
    Destination(city: 'Athens', country: 'Greece', flag: '🇬🇷', region: 'Europe'),
    Destination(city: 'Santorini', country: 'Greece', flag: '🇬🇷', region: 'Europe'),
    Destination(city: 'Lisbon', country: 'Portugal', flag: '🇵🇹', region: 'Europe'),
    Destination(city: 'Porto', country: 'Portugal', flag: '🇵🇹', region: 'Europe'),
    Destination(city: 'Dublin', country: 'Ireland', flag: '🇮🇪', region: 'Europe'),
    Destination(city: 'Reykjavik', country: 'Iceland', flag: '🇮🇸', region: 'Europe'),
    Destination(city: 'Copenhagen', country: 'Denmark', flag: '🇩🇰', region: 'Europe'),
    Destination(city: 'Stockholm', country: 'Sweden', flag: '🇸🇪', region: 'Europe'),
    Destination(city: 'Oslo', country: 'Norway', flag: '🇳🇴', region: 'Europe'),

    // Americas
    Destination(city: 'New York City', country: 'United States', flag: '🇺🇸', region: 'Americas'),
    Destination(city: 'Los Angeles', country: 'United States', flag: '🇺🇸', region: 'Americas'),
    Destination(city: 'San Francisco', country: 'United States', flag: '🇺🇸', region: 'Americas'),
    Destination(city: 'Chicago', country: 'United States', flag: '🇺🇸', region: 'Americas'),
    Destination(city: 'Honolulu', country: 'United States', flag: '🇺🇸', region: 'Americas'),
    Destination(city: 'Miami', country: 'United States', flag: '🇺🇸', region: 'Americas'),
    Destination(city: 'Las Vegas', country: 'United States', flag: '🇺🇸', region: 'Americas'),
    Destination(city: 'Seattle', country: 'United States', flag: '🇺🇸', region: 'Americas'),
    Destination(city: 'Vancouver', country: 'Canada', flag: '🇨🇦', region: 'Americas'),
    Destination(city: 'Toronto', country: 'Canada', flag: '🇨🇦', region: 'Americas'),
    Destination(city: 'Montreal', country: 'Canada', flag: '🇨🇦', region: 'Americas'),
    Destination(city: 'Mexico City', country: 'Mexico', flag: '🇲🇽', region: 'Americas'),
    Destination(city: 'Cancun', country: 'Mexico', flag: '🇲🇽', region: 'Americas'),
    Destination(city: 'Rio de Janeiro', country: 'Brazil', flag: '🇧🇷', region: 'Americas'),
    Destination(city: 'Buenos Aires', country: 'Argentina', flag: '🇦🇷', region: 'Americas'),
    Destination(city: 'Cusco', country: 'Peru', flag: '🇵🇪', region: 'Americas'),
    Destination(city: 'Lima', country: 'Peru', flag: '🇵🇪', region: 'Americas'),

    // Oceania
    Destination(city: 'Sydney', country: 'Australia', flag: '🇦🇺', region: 'Oceania'),
    Destination(city: 'Melbourne', country: 'Australia', flag: '🇦🇺', region: 'Oceania'),
    Destination(city: 'Brisbane', country: 'Australia', flag: '🇦🇺', region: 'Oceania'),
    Destination(city: 'Auckland', country: 'New Zealand', flag: '🇳🇿', region: 'Oceania'),
    Destination(city: 'Queenstown', country: 'New Zealand', flag: '🇳🇿', region: 'Oceania'),

    // Middle East & Africa
    Destination(city: 'Dubai', country: 'United Arab Emirates', flag: '🇦🇪', region: 'Middle East'),
    Destination(city: 'Abu Dhabi', country: 'United Arab Emirates', flag: '🇦🇪', region: 'Middle East'),
    Destination(city: 'Doha', country: 'Qatar', flag: '🇶🇦', region: 'Middle East'),
    Destination(city: 'Cairo', country: 'Egypt', flag: '🇪🇬', region: 'Africa'),
    Destination(city: 'Cape Town', country: 'South Africa', flag: '🇿🇦', region: 'Africa'),
    Destination(city: 'Marrakech', country: 'Morocco', flag: '🇲🇦', region: 'Africa'),
  ];

  /// Searches destinations by substring match on city or country.
  /// Ranks prefix matches on city first, followed by substring matches.
  static List<Destination> search(String query, {int limit = 6}) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return const [];

    final prefixMatches = <Destination>[];
    final substringMatches = <Destination>[];

    for (final dest in allDestinations) {
      final cityLower = dest.city.toLowerCase();
      final countryLower = dest.country.toLowerCase();

      if (cityLower.startsWith(cleanQuery)) {
        prefixMatches.add(dest);
      } else if (cityLower.contains(cleanQuery) || countryLower.contains(cleanQuery)) {
        substringMatches.add(dest);
      }
    }

    final combined = [...prefixMatches, ...substringMatches];
    if (combined.length > limit) {
      return combined.sublist(0, limit);
    }
    return combined;
  }
}
