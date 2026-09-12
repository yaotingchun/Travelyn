import 'package:flutter/material.dart';
import '../models/explorer_badge.dart';
import '../models/explorer_country.dart';
import '../models/user_profile.dart';

/// Centralized mock data repository for the redesigned "My Explorer Passport" experience.
class MockExplorerData {
  // Profile identity
  static const String explorerName = 'Diana';
  static const String username = '@explorer_yuki';
  static const String tagline = 'Collecting moments, not things ✨';
  static const String avatarAsset = 'assets/profile/avatar_shiba_explorer.jpg';
  static const String heroBannerAsset = 'assets/home/tokyo_pagoda_blossom.jpg';
  static const String compassAsset = 'assets/profile/compass_vintage.jpg';
  static const String stampAsset = 'assets/profile/stamp_lets_go.jpg';
  static const String worldMapAsset = 'assets/profile/vintage_world_map.jpg';
  static const String homeCity = 'Kuala Lumpur';

  // Explorer passport statistics
  static const int tripsCount = 18;
  static const int savedCount = 47;
  static const int countriesCount = 12;

  // Explorer rank & progression
  static const String explorerRank = 'Wanderer';
  static const int currentLevel = 3;
  static const int currentXp = 1200;
  static const int maxXp = 2000;
  static const String nextRank = 'Globetrotter';

  static UserProfile get defaultProfile => UserProfile(
        name: explorerName,
        username: username,
        email: 'explorer@travelyn.com',
        bio: tagline,
        avatarPath: avatarAsset,
        homeCity: homeCity,
        preferredLanguage: 'English',
        currency: 'MYR',
        travelIdentities: const [
          '✨ Explorer',
          '🍜 Foodie',
          '🏮 Local Lover',
        ],
        tripsCount: tripsCount,
        placesCount: 47,
        countriesCount: countriesCount,
        memoriesCount: 36,
      );

  // All explorer countries (12 Explored, 4 Wishlist, plus Someday examples)
  // Coordinates are normalized (x: 0.0..1.0, y: 0.0..1.0) on a 2:1 world canvas
  static final List<ExplorerCountry> countries = [
    // --- Explored (12 Countries) ---
    const ExplorerCountry(
      code: 'MY',
      name: 'Malaysia',
      flag: '🇲🇾',
      status: CountryStatus.explored,
      visitCount: 8,
      placesVisited: 25,
      lastVisitedDate: 'Feb 2026',
      note: 'Home sweet home & endless street food gems',
      mapCoordinate: Offset(0.755, 0.575),
    ),
    const ExplorerCountry(
      code: 'JP',
      name: 'Japan',
      flag: '🇯🇵',
      status: CountryStatus.explored,
      visitCount: 3,
      placesVisited: 12,
      lastVisitedDate: 'Sep 2025',
      note: 'Tokyo ramen alleyways, Kyoto shrines & Mt. Fuji sunrise',
      mapCoordinate: Offset(0.855, 0.385),
    ),
    const ExplorerCountry(
      code: 'KR',
      name: 'South Korea',
      flag: '🇰🇷',
      status: CountryStatus.explored,
      visitCount: 2,
      placesVisited: 8,
      lastVisitedDate: 'Nov 2025',
      note: 'Hongdae street music, Bukchon Hanok & spicy tteokbokki',
      mapCoordinate: Offset(0.805, 0.395),
    ),
    const ExplorerCountry(
      code: 'SG',
      name: 'Singapore',
      flag: '🇸🇬',
      status: CountryStatus.explored,
      visitCount: 4,
      placesVisited: 10,
      lastVisitedDate: 'Jan 2026',
      note: 'Marina Bay lights, Gardens by the Bay & Maxwell Hawker',
      mapCoordinate: Offset(0.765, 0.605),
    ),
    const ExplorerCountry(
      code: 'TH',
      name: 'Thailand',
      flag: '🇹🇭',
      status: CountryStatus.explored,
      visitCount: 3,
      placesVisited: 11,
      lastVisitedDate: 'Dec 2025',
      note: 'Bangkok night markets, Chiang Mai temples & mango sticky rice',
      mapCoordinate: Offset(0.740, 0.510),
    ),
    const ExplorerCountry(
      code: 'ID',
      name: 'Indonesia',
      flag: '🇮🇩',
      status: CountryStatus.explored,
      visitCount: 2,
      placesVisited: 9,
      lastVisitedDate: 'Aug 2025',
      note: 'Bali rice terraces, Ubud art studios & sunset at Uluwatu',
      mapCoordinate: Offset(0.785, 0.640),
    ),
    const ExplorerCountry(
      code: 'CN',
      name: 'China',
      flag: '🇨🇳',
      status: CountryStatus.explored,
      visitCount: 2,
      placesVisited: 14,
      lastVisitedDate: 'Oct 2025',
      note: 'The Great Wall of Beijing, Shanghai Bund & Sichuan hotpot',
      mapCoordinate: Offset(0.725, 0.415),
    ),
    const ExplorerCountry(
      code: 'AU',
      name: 'Australia',
      flag: '🇦🇺',
      status: CountryStatus.explored,
      visitCount: 1,
      placesVisited: 7,
      lastVisitedDate: 'May 2025',
      note: 'Sydney Opera House, Bondi coastal walk & Melbourne coffee',
      mapCoordinate: Offset(0.815, 0.740),
    ),
    const ExplorerCountry(
      code: 'FR',
      name: 'France',
      flag: '🇫🇷',
      status: CountryStatus.explored,
      visitCount: 1,
      placesVisited: 6,
      lastVisitedDate: 'Jun 2024',
      note: 'Parisian cafe hopping, Louvre strolls & warm croissants',
      mapCoordinate: Offset(0.468, 0.355),
    ),
    const ExplorerCountry(
      code: 'IT',
      name: 'Italy',
      flag: '🇮🇹',
      status: CountryStatus.explored,
      visitCount: 1,
      placesVisited: 8,
      lastVisitedDate: 'Jul 2024',
      note: 'Venice gondolas, Colosseum history & authentic gelato',
      mapCoordinate: Offset(0.505, 0.375),
    ),
    const ExplorerCountry(
      code: 'GB',
      name: 'United Kingdom',
      flag: '🇬🇧',
      status: CountryStatus.explored,
      visitCount: 1,
      placesVisited: 5,
      lastVisitedDate: 'Aug 2024',
      note: 'Big Ben, London red buses & afternoon English tea',
      mapCoordinate: Offset(0.460, 0.280),
    ),
    const ExplorerCountry(
      code: 'US',
      name: 'United States',
      flag: '🇺🇸',
      status: CountryStatus.explored,
      visitCount: 1,
      placesVisited: 9,
      lastVisitedDate: 'Apr 2023',
      note: 'New York skyline, Central Park picnic & California coast',
      mapCoordinate: Offset(0.185, 0.390),
    ),

    // --- Wishlist (4 Countries) ---
    const ExplorerCountry(
      code: 'TR',
      name: 'Turkey',
      flag: '🇹🇷',
      status: CountryStatus.wishlist,
      note: 'Hot air balloons in Cappadocia & historic Hagia Sophia ✨',
      mapCoordinate: Offset(0.560, 0.395),
    ),
    const ExplorerCountry(
      code: 'NZ',
      name: 'New Zealand',
      flag: '🇳🇿',
      status: CountryStatus.wishlist,
      note: 'Hobbiton movie set, Queenstown fjords & stargazing ✨',
      mapCoordinate: Offset(0.915, 0.815),
    ),
    const ExplorerCountry(
      code: 'CH',
      name: 'Switzerland',
      flag: '🇨🇭',
      status: CountryStatus.wishlist,
      note: 'Scenic glacier train rides, snow peaks & Swiss chocolate ✨',
      mapCoordinate: Offset(0.495, 0.315),
    ),
    const ExplorerCountry(
      code: 'IS',
      name: 'Iceland',
      flag: '🇮🇸',
      status: CountryStatus.wishlist,
      note: 'Chasing northern lights, Blue Lagoon & black sand beaches ✨',
      mapCoordinate: Offset(0.400, 0.170),
    ),

    // --- Someday / Unexplored (Sample selections for interaction) ---
    const ExplorerCountry(
      code: 'BR',
      name: 'Brazil',
      flag: '🇧🇷',
      status: CountryStatus.someday,
      note: 'Christ the Redeemer & Amazon rainforest adventures',
      mapCoordinate: Offset(0.335, 0.670),
    ),
    const ExplorerCountry(
      code: 'CA',
      name: 'Canada',
      flag: '🇨🇦',
      status: CountryStatus.someday,
      note: 'Banff National Park, turquoise lakes & Rocky Mountains',
      mapCoordinate: Offset(0.220, 0.290),
    ),
    const ExplorerCountry(
      code: 'EG',
      name: 'Egypt',
      flag: '🇪🇬',
      status: CountryStatus.someday,
      note: 'Ancient Pyramids of Giza & Nile River cruising',
      mapCoordinate: Offset(0.560, 0.460),
    ),
    const ExplorerCountry(
      code: 'NO',
      name: 'Norway',
      flag: '🇳🇴',
      status: CountryStatus.someday,
      note: 'Deep dramatic fjords & Midnight Sun',
      mapCoordinate: Offset(0.505, 0.235),
    ),
    const ExplorerCountry(
      code: 'ES',
      name: 'Spain',
      flag: '🇪🇸',
      status: CountryStatus.someday,
      note: 'Sagrada Familia, tapas culture & flamenco nights',
      mapCoordinate: Offset(0.465, 0.390),
    ),
    const ExplorerCountry(
      code: 'DE',
      name: 'Germany',
      flag: '🇩🇪',
      status: CountryStatus.someday,
      note: 'Fairy-tale castles, Berlin culture & Oktoberfest',
      mapCoordinate: Offset(0.505, 0.325),
    ),
    const ExplorerCountry(
      code: 'MX',
      name: 'Mexico',
      flag: '🇲🇽',
      status: CountryStatus.someday,
      note: 'Chichen Itza Mayan ruins, cenotes & authentic tacos',
      mapCoordinate: Offset(0.205, 0.490),
    ),
    const ExplorerCountry(
      code: 'IN',
      name: 'India',
      flag: '🇮🇳',
      status: CountryStatus.someday,
      note: 'Taj Mahal at dawn, vibrant bazaars & aromatic spices',
      mapCoordinate: Offset(0.690, 0.485),
    ),
    const ExplorerCountry(
      code: 'ZA',
      name: 'South Africa',
      flag: '🇿🇦',
      status: CountryStatus.someday,
      note: 'Cape Town Table Mountain & Kruger safari',
      mapCoordinate: Offset(0.540, 0.760),
    ),
    const ExplorerCountry(
      code: 'AR',
      name: 'Argentina',
      flag: '🇦🇷',
      status: CountryStatus.someday,
      note: 'Buenos Aires tango & Patagonia glaciers',
      mapCoordinate: Offset(0.300, 0.790),
    ),
  ];

  // Achievements for the circular passport badge row and achievements page
  static const List<ExplorerBadge> badges = [
    ExplorerBadge(
      id: 'badge_early_bird',
      title: 'Early Bird',
      requirement: '5 trips completed',
      icon: '🌅',
      imageAsset: 'assets/profile/badge_early_bird.jpg',
      isUnlocked: true,
      unlockedDate: 'Oct 2025',
      accentColor: Color(0xFFFFA000),
      progress: 1.0,
    ),
    ExplorerBadge(
      id: 'badge_city_explorer',
      title: 'City Explorer',
      requirement: '10 cities explored',
      icon: '🏙',
      imageAsset: 'assets/profile/badge_city_explorer.jpg',
      isUnlocked: true,
      unlockedDate: 'Dec 2025',
      accentColor: Color(0xFF0288D1),
      progress: 1.0,
    ),
    ExplorerBadge(
      id: 'badge_foodie',
      title: 'Foodie',
      requirement: '15 local culinary spots',
      icon: '🍜',
      imageAsset: 'assets/profile/badge_foodie.jpg',
      isUnlocked: true,
      unlockedDate: 'Jan 2026',
      accentColor: Color(0xFFE65100),
      progress: 1.0,
    ),
    ExplorerBadge(
      id: 'badge_peak_seeker',
      title: 'Peak Seeker',
      requirement: '3 mountain hikes',
      icon: '🏔',
      imageAsset: 'assets/profile/badge_peak_seeker.jpg',
      isUnlocked: true,
      unlockedDate: 'Feb 2026',
      accentColor: Color(0xFF2E7D32),
      progress: 1.0,
    ),
    ExplorerBadge(
      id: 'badge_culture_lover',
      title: 'Culture Lover',
      requirement: '5 cultural experiences',
      icon: '🏮',
      imageAsset: 'assets/profile/badge_culture_lover.jpg',
      isUnlocked: true,
      unlockedDate: 'Mar 2026',
      accentColor: Color(0xFFC2185B),
      progress: 1.0,
    ),
    ExplorerBadge(
      id: 'badge_memory_maker',
      title: 'Memory Maker',
      requirement: '20+ photo journal moments',
      icon: '📸',
      imageAsset: null,
      isUnlocked: false,
      progress: 0.85,
      accentColor: Color(0xFF7B1FA2),
    ),
    ExplorerBadge(
      id: 'badge_group_explorer',
      title: 'Group Explorer',
      requirement: '3 collaborative group trips',
      icon: '👥',
      imageAsset: null,
      isUnlocked: false,
      progress: 0.60,
      accentColor: Color(0xFF1976D2),
    ),
  ];

  static List<ExplorerCountry> get exploredCountries =>
      countries.where((c) => c.status == CountryStatus.explored).toList();

  static List<ExplorerCountry> get wishlistCountries =>
      countries.where((c) => c.status == CountryStatus.wishlist).toList();

  static List<ExplorerCountry> get somedayCountries =>
      countries.where((c) => c.status == CountryStatus.someday).toList();
}
