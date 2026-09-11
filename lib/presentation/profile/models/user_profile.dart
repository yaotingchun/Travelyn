/// Model representing the user's personal identity and lifetime travel stats.
class UserProfile {
  final String name;
  final String username;
  final String email;
  final String bio;
  final String avatarPath;
  final String homeCity;
  final String preferredLanguage;
  final String currency;
  final List<String> travelIdentities;
  final int tripsCount;
  final int placesCount;
  final int countriesCount;
  final int memoriesCount;

  const UserProfile({
    required this.name,
    required this.username,
    this.email = 'explorer@travelyn.com',
    required this.bio,
    this.avatarPath = 'assets/mascot/avatar.png',
    required this.homeCity,
    required this.preferredLanguage,
    required this.currency,
    required this.travelIdentities,
    required this.tripsCount,
    required this.placesCount,
    required this.countriesCount,
    required this.memoriesCount,
  });

  UserProfile copyWith({
    String? name,
    String? username,
    String? email,
    String? bio,
    String? avatarPath,
    String? homeCity,
    String? preferredLanguage,
    String? currency,
    List<String>? travelIdentities,
    int? tripsCount,
    int? placesCount,
    int? countriesCount,
    int? memoriesCount,
  }) {
    return UserProfile(
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      avatarPath: avatarPath ?? this.avatarPath,
      homeCity: homeCity ?? this.homeCity,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      currency: currency ?? this.currency,
      travelIdentities: travelIdentities ?? this.travelIdentities,
      tripsCount: tripsCount ?? this.tripsCount,
      placesCount: placesCount ?? this.placesCount,
      countriesCount: countriesCount ?? this.countriesCount,
      memoriesCount: memoriesCount ?? this.memoriesCount,
    );
  }
}
