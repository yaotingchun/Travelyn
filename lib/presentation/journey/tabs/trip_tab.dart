import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../../../services/mapbox_config.dart';
import '../../../services/mapbox_directions_service.dart';
import '../widgets/trip_next_stop_bottom_card.dart';
import '../widgets/trip_location_overview_sheet.dart';
import '../trip_arrival_screen.dart';
import '../trip_feedback_screen.dart';

/// Place stop model for the itinerary timeline
class ItineraryCardItem {
  final String id;
  final String time;
  final String name;
  final String location;
  final String walkTime;
  final String imageAsset;
  final double latitude;
  final double longitude;
  final int? visitDurationMinutes;
  final bool isDetour;
  final String? category;
  final String? tag;
  final String? specialtyDish;

  int get visitDuration => visitDurationMinutes ?? 60;

  const ItineraryCardItem({
    required this.id,
    required this.time,
    required this.name,
    required this.location,
    required this.walkTime,
    required this.imageAsset,
    required this.latitude,
    required this.longitude,
    this.visitDurationMinutes = 60,
    this.isDetour = false,
    this.category,
    this.tag,
    this.specialtyDish,
  });

  ItineraryCardItem copyWith({
    String? id,
    String? time,
    String? name,
    String? location,
    String? walkTime,
    String? imageAsset,
    double? latitude,
    double? longitude,
    int? visitDurationMinutes,
    bool? isDetour,
    String? category,
    String? tag,
    String? specialtyDish,
  }) {
    return ItineraryCardItem(
      id: id ?? this.id,
      time: time ?? this.time,
      name: name ?? this.name,
      location: location ?? this.location,
      walkTime: walkTime ?? this.walkTime,
      imageAsset: imageAsset ?? this.imageAsset,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      visitDurationMinutes: visitDurationMinutes ?? this.visitDurationMinutes ?? 60,
      isDetour: isDetour ?? this.isDetour,
      category: category ?? this.category,
      tag: tag ?? this.tag,
      specialtyDish: specialtyDish ?? this.specialtyDish,
    );
  }
}

/// Day itinerary group model
class DayItineraryGroup {
  final int dayNumber;
  final String dateLabel; // e.g. "08.09 SUN"
  final String fullDateHeader; // e.g. "Day 1 • 9 Sep (Wed)"
  final double centerLat;
  final double centerLng;
  final double zoom;
  final List<ItineraryCardItem> places;

  const DayItineraryGroup({
    required this.dayNumber,
    required this.dateLabel,
    required this.fullDateHeader,
    required this.centerLat,
    required this.centerLng,
    required this.zoom,
    required this.places,
  });
}

/// Tab 1: Trip Tab (Day-by-day Itinerary View)
///
/// Follows the user's design:
/// - Sits in the original layout directly under the top header & navbar
/// - On top: Real Mapbox map (originally complete view, collapsing smoothly to
///   compact top slice upon scrolling down)
/// - Top overlay controls: share (↗) and camera buttons (and back < if standalone)
/// - Directly below map: Day selection bar ("08.09 SUN", "09.09 MON", etc.)
/// - Itinerary timeline (Image 2): "Day 1 • 9 Sep (Wed)" with place cards
///   featuring thumbnail, time, title, district, walking estimate (🚶 15 min),
///   and reorder handle (≡).
class TripTab extends StatefulWidget {
  final String destination;
  final String? tripType;
  final DateTime? startDate;
  final DateTime? endDate;
  final Color brandOrange;
  final Color darkBrown;
  final Color textMuted;
  final VoidCallback? onBackTap;
  final String? mapboxAccessToken;
  final bool isTripStarted;
  final int tripStartVersion;
  final bool hasCompletedCheckin;
  final int initialStopIndex;
  final bool hasSurpriseDetourAdded;
  final bool hasCafeReplaced;
  final bool hasScheduleAdjusted;
  final bool hasConflictResolved;

  /// Global tracking for seamless check-in state across route transitions
  static bool hasCheckedInFirstStop = true;
  static int currentStopIndex = 0;

  const TripTab({
    super.key,
    this.destination = 'Tokyo, Japan',
    this.tripType = 'Group Trip',
    this.startDate,
    this.endDate,
    this.brandOrange = const Color(0xFFE65100),
    this.darkBrown = const Color(0xFF2E1C14),
    this.textMuted = const Color(0xFF6B5A50),
    this.onBackTap,
    this.mapboxAccessToken,
    this.isTripStarted = false,
    this.tripStartVersion = 0,
    this.hasCompletedCheckin = false,
    this.initialStopIndex = 0,
    this.hasSurpriseDetourAdded = false,
    this.hasCafeReplaced = false,
    this.hasScheduleAdjusted = false,
    this.hasConflictResolved = false,
  });

  static ItineraryCardItem? getFirstPlace({int dayIndex = 0}) {
    final groups = buildDefaultDayGroups();
    if (dayIndex >= 0 && dayIndex < groups.length) {
      final places = groups[dayIndex].places;
      if (places.isNotEmpty) return places.first;
    }
    return null;
  }

  static List<DayItineraryGroup> buildDefaultDayGroups({
    bool hasCafeReplaced = false,
    bool hasSurpriseDetourAdded = false,
    bool hasScheduleAdjusted = false,
    bool hasConflictResolved = false,
  }) {
    return [
      DayItineraryGroup(
        dayNumber: 1,
        dateLabel: '08.09 SUN',
        fullDateHeader: 'Day 1 • 9 Sep (Wed)',
        centerLat: 35.6660,
        centerLng: 139.7300,
        zoom: 12.8,
        places: [
          if (hasCafeReplaced)
            const ItineraryCardItem(
              id: 'chatei_hatou',
              time: '08:30',
              name: 'Chatei Hatou (茶亭 羽當)',
              location: 'Shibuya, Tokyo',
              walkTime: 'Starting Point',
              imageAsset: 'assets/journey/food_french_toast_cafe.jpg',
              latitude: 35.6598,
              longitude: 139.7035,
              visitDurationMinutes: 45,
              category: 'Breakfast',
              tag: '🔄 Backup Cafe',
              specialtyDish: 'Siphon coffee & matcha chiffon cake ☕🍰',
            )
          else
            const ItineraryCardItem(
              id: 'bread_espresso_arashiyama',
              time: '08:30',
              name: 'Bread, Espresso & Arashiyama Garden, Kyoto',
              location: 'Arashiyama / Kyoto',
              walkTime: 'Starting Point',
              imageAsset: 'assets/journey/food_french_toast_cafe.jpg',
              latitude: 35.6672,
              longitude: 139.7092,
              visitDurationMinutes: 45,
              category: 'Breakfast',
              tag: 'Bakery & Cafe',
              specialtyDish: 'Signature fluffy French toast & espresso ☕',
            ),
          ItineraryCardItem(
            id: 'meiji_shrine',
            time: '09:25',
            name: 'Meiji Shrine & Yoyogi Forest',
            location: 'Shibuya, Tokyo',
            walkTime: '12 min',
            imageAsset: 'assets/journey/place_meiji_shrine.jpg',
            latitude: 35.6764,
            longitude: 139.6993,
            visitDurationMinutes: hasScheduleAdjusted ? 85 : 60,
            category: 'Sightseeing',
            tag: 'Sacred Shrine',
          ),
          if (hasSurpriseDetourAdded)
            const ItineraryCardItem(
              id: 'ura_harajuku_local_market',
              time: '10:55',
              name: 'Ura-Harajuku Local Market',
              location: 'Cat Street, Harajuku',
              walkTime: '12 min (300m)',
              imageAsset: 'assets/journey/food_ameyoko_stalls.jpg',
              latitude: 35.6680,
              longitude: 139.7042,
              visitDurationMinutes: 30,
              isDetour: true,
              category: 'Local Food',
              tag: 'Hidden Gem',
              specialtyDish: 'Fresh taiyaki, yakitori & matcha snacks 🍡',
            ),
          ItineraryCardItem(
            id: 'harajuku_takeshita',
            time: '11:35',
            name: 'Harajuku Takeshita Street',
            location: 'Harajuku, Tokyo',
            walkTime: '10 min',
            imageAsset: 'assets/journey/place_harajuku.jpg',
            latitude: 35.6702,
            longitude: 139.7027,
            visitDurationMinutes: hasConflictResolved
                ? 70
                : (hasScheduleAdjusted ? 30 : 45),
            category: 'Shopping',
            tag: hasConflictResolved
                ? 'Extended Thrifting (+25m)'
                : 'Fashion & Crepes',
          ),
          ItineraryCardItem(
            id: 'afuri_harajuku',
            time: '12:15',
            name: 'AFURI Harajuku (Yuzu Shio Ramen)',
            location: 'Harajuku, Tokyo',
            walkTime: '8 min',
            imageAsset: 'assets/journey/food_yuzu_ramen.jpg',
            latitude: 35.6713,
            longitude: 139.7031,
            visitDurationMinutes: 50,
            category: 'Lunch',
            tag: hasConflictResolved
                ? 'Guaranteed Lunch (12:15)'
                : 'Ramen & Gyoza',
            specialtyDish: 'Yuzu Salt Ramen & charcoal-grilled chashu 🍜',
          ),
          const ItineraryCardItem(
            id: 'shibuya_scramble',
            time: '13:20',
            name: 'Shibuya Scramble & Hachiko',
            location: 'Shibuya, Tokyo',
            walkTime: '15 min',
            imageAsset: 'assets/journey/place_shibuya.jpg',
            latitude: 35.6595,
            longitude: 139.7005,
            visitDurationMinutes: 55,
            category: 'Landmark',
            tag: 'City Icon',
          ),
          ItineraryCardItem(
            id: 'teamlab_planets',
            time: hasConflictResolved ? '15:20' : '15:10',
            name: 'teamLab Planets Tokyo',
            location: 'Toyosu, Koto City',
            walkTime: '25 min transit',
            imageAsset: 'assets/journey/place_teamlab.jpg',
            latitude: 35.6491,
            longitude: 139.7898,
            visitDurationMinutes: 90,
            category: 'Art',
            tag: hasConflictResolved
                ? 'Guaranteed Entry Slot'
                : 'Digital Immersion',
          ),
          const ItineraryCardItem(
            id: 'toyosu_senkyaku_banrai',
            time: '17:15',
            name: 'Toyosu Senkyaku Banrai Food Stalls',
            location: 'Toyosu Waterfront, Tokyo',
            walkTime: '10 min',
            imageAsset: 'assets/journey/food_toyosu_hawker.jpg',
            latitude: 35.6458,
            longitude: 139.7842,
            visitDurationMinutes: 75,
            category: 'Dinner',
            tag: 'Hawker Stalls & Izakaya',
            specialtyDish: 'Grilled scallops, Edo skewers & craft draft beer 🍢',
          ),
        ],
      ),
      const DayItineraryGroup(
        dayNumber: 2,
        dateLabel: '09.09 MON',
        fullDateHeader: 'Day 2 • 10 Sep (Thu)',
        centerLat: 35.6980,
        centerLng: 139.7700,
        zoom: 13.0,
        places: [
          ItineraryCardItem(
            id: 'ameyoko_hawker_market',
            time: '08:30',
            name: 'Ameyoko Market Hawker Alley',
            location: 'Ueno, Taito City',
            walkTime: 'Starting Point',
            imageAsset: 'assets/journey/food_ameyoko_stalls.jpg',
            latitude: 35.7112,
            longitude: 139.7745,
            visitDurationMinutes: 45,
            category: 'Breakfast',
            tag: 'Hawker Stalls & Fruit',
            specialtyDish: 'Fresh melon sticks, warm taiyaki & takoyaki 🍓',
          ),
          ItineraryCardItem(
            id: 'ueno_park',
            time: '09:25',
            name: 'Ueno Park & Shinobazu Pond',
            location: 'Taito City, Tokyo',
            walkTime: '8 min',
            imageAsset: 'assets/journey/place_ueno_park.jpg',
            latitude: 35.7140,
            longitude: 139.7740,
            visitDurationMinutes: 60,
            category: 'Nature',
            tag: 'Historic Park',
          ),
          ItineraryCardItem(
            id: 'akihabara_town',
            time: '10:45',
            name: 'Akihabara Electric Town',
            location: 'Chiyoda City, Tokyo',
            walkTime: '18 min',
            imageAsset: 'assets/journey/place_harajuku.jpg',
            latitude: 35.6983,
            longitude: 139.7731,
            visitDurationMinutes: 60,
            category: 'Shopping',
            tag: 'Anime & Tech Hub',
          ),
          ItineraryCardItem(
            id: 'kyushu_jangara_ramen',
            time: '12:00',
            name: 'Kyushu Jangara Ramen (秋葉原)',
            location: 'Akihabara, Tokyo',
            walkTime: '6 min',
            imageAsset: 'assets/journey/food_tonkotsu_ramen.jpg',
            latitude: 35.6998,
            longitude: 139.7709,
            visitDurationMinutes: 50,
            category: 'Lunch',
            tag: 'Tonkotsu Ramen',
            specialtyDish: 'Rich tonkotsu broth with braised kakuni pork 🍜',
          ),
          ItineraryCardItem(
            id: 'ginza_district',
            time: '13:25',
            name: 'Ginza Chuo-dori Shopping Street',
            location: 'Chuo City, Tokyo',
            walkTime: '20 min transit',
            imageAsset: 'assets/journey/place_tokyo_tower.jpg',
            latitude: 35.6719,
            longitude: 139.7648,
            visitDurationMinutes: 75,
            category: 'Shopping',
            tag: 'Luxury & Dept Stores',
          ),
          ItineraryCardItem(
            id: 'yurakucho_sanchoku_yokocho',
            time: '17:30',
            name: 'Yurakucho Sanchoku Hawker Alley',
            location: 'Yurakucho, Ginza',
            walkTime: '8 min',
            imageAsset: 'assets/journey/food_yakitori_yokocho.jpg',
            latitude: 35.6738,
            longitude: 139.7608,
            visitDurationMinutes: 75,
            category: 'Dinner',
            tag: 'Hawker Alley & Izakaya',
            specialtyDish: 'Charcoal yakitori skewers & Michelin chicken ramen 🍢',
          ),
        ],
      ),
      const DayItineraryGroup(
        dayNumber: 3,
        dateLabel: '10.09 TUE',
        fullDateHeader: 'Day 3 • 11 Sep (Fri)',
        centerLat: 35.6700,
        centerLng: 139.7250,
        zoom: 12.9,
        places: [
          ItineraryCardItem(
            id: 'le_pain_shibakoen',
            time: '08:30',
            name: 'Le Pain Quotidien Shibakoen',
            location: 'Minato City, Tokyo',
            walkTime: 'Starting Point',
            imageAsset: 'assets/journey/food_bakery_croissant.jpg',
            latitude: 35.6565,
            longitude: 139.7490,
            visitDurationMinutes: 45,
            category: 'Breakfast',
            tag: 'Organic Bakery Cafe',
            specialtyDish: 'Fresh croissants & tartines under Tokyo Tower 🥐',
          ),
          ItineraryCardItem(
            id: 'tokyo_tower',
            time: '09:25',
            name: 'Tokyo Tower Observation Deck',
            location: 'Minato City, Tokyo',
            walkTime: '8 min',
            imageAsset: 'assets/journey/place_tokyo_tower.jpg',
            latitude: 35.6586,
            longitude: 139.7454,
            visitDurationMinutes: 60,
            category: 'Landmark',
            tag: 'Observation Deck',
          ),
          ItineraryCardItem(
            id: 'roppongi_hills',
            time: '10:45',
            name: 'Roppongi Hills Sky Deck',
            location: 'Minato City, Tokyo',
            walkTime: '18 min',
            imageAsset: 'assets/journey/place_shibuya.jpg',
            latitude: 35.6605,
            longitude: 139.7292,
            visitDurationMinutes: 60,
            category: 'Landmark',
            tag: 'Panoramic Sky Views',
          ),
          ItineraryCardItem(
            id: 'tonkatsu_butagumi_roppongi',
            time: '12:00',
            name: 'Tonkatsu Butagumi (豚組食堂)',
            location: 'Roppongi Hills, Tokyo',
            walkTime: '5 min',
            imageAsset: 'assets/journey/food_kurobuta_tonkatsu.jpg',
            latitude: 35.6602,
            longitude: 139.7298,
            visitDurationMinutes: 50,
            category: 'Lunch',
            tag: 'Kurobuta Tonkatsu',
            specialtyDish: 'Crispy golden Kurobuta pork cutlet set 🍱',
          ),
          ItineraryCardItem(
            id: 'shinjuku_gyoen',
            time: '13:25',
            name: 'Shinjuku Gyoen National Garden',
            location: 'Shinjuku City, Tokyo',
            walkTime: '22 min transit',
            imageAsset: 'assets/journey/place_meiji_shrine.jpg',
            latitude: 35.6852,
            longitude: 139.7101,
            visitDurationMinutes: 60,
            category: 'Nature',
            tag: 'Japanese Gardens',
          ),
          ItineraryCardItem(
            id: 'omoide_yokocho_shinjuku',
            time: '17:30',
            name: 'Omoide Yokocho (Memory Lane)',
            location: 'West Shinjuku, Tokyo',
            walkTime: '15 min',
            imageAsset: 'assets/journey/food_omoide_yokocho.jpg',
            latitude: 35.6932,
            longitude: 139.6998,
            visitDurationMinutes: 75,
            category: 'Dinner',
            tag: 'Yakitori Hawker Stalls',
            specialtyDish: 'Smoky alley yakitori, kushikatsu & highballs 🍢',
          ),
        ],
      ),
      const DayItineraryGroup(
        dayNumber: 4,
        dateLabel: '11.09 WED',
        fullDateHeader: 'Day 4 • 12 Sep (Sat)',
        centerLat: 35.6750,
        centerLng: 139.7900,
        zoom: 12.4,
        places: [
          ItineraryCardItem(
            id: 'tsukiji_market',
            time: '08:30',
            name: 'Tsukiji Outer Market Food Stalls',
            location: 'Chuo City, Tokyo',
            walkTime: 'Starting Point',
            imageAsset: 'assets/journey/food_tsukiji_sashimi.jpg',
            latitude: 35.6655,
            longitude: 139.7708,
            visitDurationMinutes: 60,
            category: 'Breakfast',
            tag: 'Fresh Seafood & Stalls',
            specialtyDish: 'Fresh tuna sashimi bowl & tamagoyaki skewers 🍣',
          ),
          ItineraryCardItem(
            id: 'odaiba_park',
            time: '10:00',
            name: 'Odaiba Seaside Park & Gundam',
            location: 'Minato City, Tokyo',
            walkTime: '25 min transit',
            imageAsset: 'assets/journey/place_teamlab.jpg',
            latitude: 35.6298,
            longitude: 139.7753,
            visitDurationMinutes: 60,
            category: 'Waterfront',
            tag: 'Seaside & Statue',
          ),
          ItineraryCardItem(
            id: 'odaiba_takoyaki_museum',
            time: '11:15',
            name: 'Odaiba Takoyaki Museum & Cafe',
            location: 'Decks Tokyo Beach, Odaiba',
            walkTime: '6 min',
            imageAsset: 'assets/journey/food_sizzling_takoyaki.jpg',
            latitude: 35.6288,
            longitude: 139.7760,
            visitDurationMinutes: 50,
            category: 'Lunch',
            tag: 'Takoyaki Hawker Stalls',
            specialtyDish: 'Osaka-style sizzling giant takoyaki & draft cider 🐙',
          ),
          ItineraryCardItem(
            id: 'sensoji_temple',
            time: '12:45',
            name: 'Senso-ji Temple & Nakamise-dori',
            location: 'Asakusa, Taito City',
            walkTime: '30 min transit',
            imageAsset: 'assets/journey/place_sensoji.jpg',
            latitude: 35.7148,
            longitude: 139.7967,
            visitDurationMinutes: 60,
            category: 'Culture',
            tag: 'Oldest Temple',
          ),
          ItineraryCardItem(
            id: 'tokyo_skytree',
            time: '14:15',
            name: 'Tokyo Skytree Town',
            location: 'Sumida City, Tokyo',
            walkTime: '18 min',
            imageAsset: 'assets/journey/place_tokyo_tower.jpg',
            latitude: 35.7100,
            longitude: 139.8107,
            visitDurationMinutes: 60,
            category: 'Landmark',
            tag: 'Tallest Tower',
          ),
          ItineraryCardItem(
            id: 'asakusa_hoppy_street',
            time: '17:30',
            name: 'Asakusa Hoppy Street Hawker Stalls',
            location: 'Asakusa, Tokyo',
            walkTime: '15 min',
            imageAsset: 'assets/journey/food_asakusa_hoppy.jpg',
            latitude: 35.7135,
            longitude: 139.7942,
            visitDurationMinutes: 75,
            category: 'Dinner',
            tag: 'Open-Air Hawker Alley',
            specialtyDish: 'Gyusuji beef tendon stew & crispy gyoza 🍲',
          ),
        ],
      ),
      const DayItineraryGroup(
        dayNumber: 5,
        dateLabel: '12.09 THU',
        fullDateHeader: 'Day 5 • 13 Sep (Sun)',
        centerLat: 35.6800,
        centerLng: 139.7100,
        zoom: 12.6,
        places: [
          ItineraryCardItem(
            id: 'fuglen_tokyo_cafe',
            time: '08:30',
            name: 'Fuglen Tokyo (Cafe & Bakery)',
            location: 'Tomigaya, Shibuya',
            walkTime: 'Starting Point',
            imageAsset: 'assets/journey/food_french_toast_cafe.jpg',
            latitude: 35.6648,
            longitude: 139.6925,
            visitDurationMinutes: 45,
            category: 'Breakfast',
            tag: 'Nordic Cafe & Waffles',
            specialtyDish: 'Single-origin pour-over & cardamom waffles ☕',
          ),
          ItineraryCardItem(
            id: 'nakano_broadway',
            time: '09:40',
            name: 'Nakano Broadway Vintage Arcade',
            location: 'Nakano City, Tokyo',
            walkTime: '22 min transit',
            imageAsset: 'assets/journey/place_harajuku.jpg',
            latitude: 35.7090,
            longitude: 139.6657,
            visitDurationMinutes: 60,
            category: 'Shopping',
            tag: 'Vintage Arcade',
          ),
          ItineraryCardItem(
            id: 'uobei_sushi_shibuya',
            time: '11:15',
            name: 'Uobei Shibuya (Express Sushi)',
            location: 'Dogenzaka, Shibuya',
            walkTime: '20 min transit',
            imageAsset: 'assets/journey/food_tsukiji_sashimi.jpg',
            latitude: 35.6598,
            longitude: 139.6975,
            visitDurationMinutes: 50,
            category: 'Lunch',
            tag: 'Conveyor Belt Sushi',
            specialtyDish: 'Fresh salmon nigiri, seared scallop & matcha 🍣',
          ),
          ItineraryCardItem(
            id: 'shibuya_sky',
            time: '12:35',
            name: 'Shibuya Sky Observatory',
            location: 'Shibuya, Tokyo',
            walkTime: '10 min',
            imageAsset: 'assets/journey/place_shibuya_sky.jpg',
            latitude: 35.6585,
            longitude: 139.7013,
            visitDurationMinutes: 60,
            category: 'Landmark',
            tag: '360 Rooftop Deck',
          ),
          ItineraryCardItem(
            id: 'tokyo_station',
            time: '14:15',
            name: 'Tokyo Station Marunouchi Brick',
            location: 'Chiyoda City, Tokyo',
            walkTime: '22 min transit',
            imageAsset: 'assets/journey/place_tokyo_station.jpg',
            latitude: 35.6812,
            longitude: 139.7671,
            visitDurationMinutes: 45,
            category: 'Architecture',
            tag: 'Historic Red Brick',
          ),
          ItineraryCardItem(
            id: 'tokyo_ramen_street',
            time: '17:30',
            name: 'Tokyo Ramen Street (Rokurinsha)',
            location: 'Tokyo Station B1F',
            walkTime: '5 min',
            imageAsset: 'assets/journey/food_yuzu_ramen.jpg',
            latitude: 35.6808,
            longitude: 139.7682,
            visitDurationMinutes: 60,
            category: 'Dinner',
            tag: 'Legendary Tsukemen',
            specialtyDish: 'Seafood-tonkotsu dipping noodles & chashu 🍜',
          ),
        ],
      ),
    ];
  }

  @override
  State<TripTab> createState() => _TripTabState();
}

class _TripTabState extends State<TripTab> with TickerProviderStateMixin {
  int _selectedDayIndex = 0;
  bool _isNextStopDismissed = false;
  late bool _hasCompletedCheckin;
  late int _currentStopIndex;
  late List<DayItineraryGroup> _dayGroups;
  final ScrollController _scrollController = ScrollController();

  // Swap Animation Controller & Tweens for Plan Swap (Simulation 4)
  late AnimationController _swapAnimationController;
  late Animation<double> _swapFlipAnimation;
  late Animation<double> _swapScaleAnimation;
  bool _hasAnimatedCafeSwap = false;
  bool _hasHapticTriggeredForSwap = false;
  String? _recentlyReorderedId;

  // Insert Animation Controller for Surprise Detour Plan (Simulation 3)
  late AnimationController _insertAnimationController;
  late Animation<double> _insertAnimation;
  bool _hasAnimatedInsert = false;

  // Schedule Swap Controller for Timeline Realignment (Simulation 5)
  late AnimationController _scheduleSwapController;
  bool _hasAnimatedScheduleSwap = false;
  final Set<int> _scheduleHapticsTriggered = {};

  final GlobalKey _scrollViewKey = GlobalKey();
  final Map<String, GlobalKey> _cardKeys = {};

  GlobalKey _getCardGlobalKey(String placeId) {
    return _cardKeys.putIfAbsent(placeId, () => GlobalKey());
  }

  void _scrollToPlace(String placeId, {int? fallbackIndex}) {
    if (!mounted) return;

    // Ensure we are viewing Day 1 where the adjustments are made
    if (_selectedDayIndex != 0) {
      setState(() {
        _selectedDayIndex = 0;
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 140), () {
        if (!mounted || !_scrollController.hasClients) return;

        final key = _cardKeys[placeId];
        final cardRenderBox = key?.currentContext?.findRenderObject() as RenderBox?;
        final scrollRenderBox = _scrollViewKey.currentContext?.findRenderObject() as RenderBox?;

        double targetOffset;
        if (cardRenderBox != null &&
            cardRenderBox.attached &&
            scrollRenderBox != null &&
            scrollRenderBox.attached) {
          final offsetInScrollView = cardRenderBox.localToGlobal(
            Offset.zero,
            ancestor: scrollRenderBox,
          );
          // Inside CustomScrollView, the pinned map header occupies y: 0 to 188.0.
          // Positioning at y: 205.0 places the top of the card 17px below the pinned header.
          const desiredY = 205.0;
          final delta = offsetInScrollView.dy - desiredY;
          targetOffset = (_scrollController.offset + delta).clamp(
            0.0,
            _scrollController.position.maxScrollExtent,
          );
        } else if (fallbackIndex != null) {
          if (fallbackIndex == 0) {
            targetOffset = 0.0;
          } else if (fallbackIndex == 1) {
            targetOffset = 280.0;
          } else if (fallbackIndex == 2) {
            targetOffset = 400.0;
          } else {
            targetOffset = 140.0 + (fallbackIndex * 120.0) - 20.0;
          }
          targetOffset = targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent);
        } else {
          return;
        }

        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      });
    });
  }

  static const ItineraryCardItem _originalBreadEspressoPlace = ItineraryCardItem(
    id: 'bread_espresso_arashiyama',
    time: '08:30',
    name: 'Bread, Espresso & Arashiyama Garden, Kyoto',
    location: 'Arashiyama / Kyoto',
    walkTime: 'Starting Point',
    imageAsset: 'assets/journey/food_french_toast_cafe.jpg',
    latitude: 35.6672,
    longitude: 139.7092,
    visitDurationMinutes: 45,
    category: 'Breakfast',
    tag: 'Bakery & Cafe',
    specialtyDish: 'Signature fluffy French toast & espresso ☕',
  );

  @override
  void initState() {
    super.initState();
    _hasCompletedCheckin = widget.hasCompletedCheckin || TripTab.hasCheckedInFirstStop;
    _currentStopIndex = widget.initialStopIndex != 0 ? widget.initialStopIndex : TripTab.currentStopIndex;
    _rebuildDayGroups();

    // Simulation 4: Cafe 3D Flip Swap Animation
    _swapAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    _swapFlipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _swapAnimationController,
        curve: const Interval(0.0, 0.78, curve: Curves.easeInOutCubic),
      ),
    );

    _swapScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.94).chain(CurveTween(curve: Curves.easeOut)),
        weight: 38,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.94, end: 1.04).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 42,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.04, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
    ]).animate(_swapAnimationController);

    _swapAnimationController.addListener(() {
      if (_swapFlipAnimation.value >= 0.5 && !_hasHapticTriggeredForSwap) {
        _hasHapticTriggeredForSwap = true;
        HapticFeedback.mediumImpact();
      }
      if (_swapFlipAnimation.value < 0.1) {
        _hasHapticTriggeredForSwap = false;
      }
    });

    _swapAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _hasAnimatedCafeSwap = true;
      }
    });

    if (widget.hasCafeReplaced && !_hasAnimatedCafeSwap) {
      _scrollToPlace('chatei_hatou', fallbackIndex: 0);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 380), () {
          if (mounted) {
            _triggerSwapAnimation();
          }
        });
      });
    }

    // Simulation 3: Surprise Detour Insert Animation
    _insertAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _insertAnimation = CurvedAnimation(
      parent: _insertAnimationController,
      curve: Curves.easeOutCubic,
    );

    _insertAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _hasAnimatedInsert = true;
      }
    });

    if (widget.hasSurpriseDetourAdded && !_hasAnimatedInsert) {
      _scrollToPlace('ura_harajuku_local_market', fallbackIndex: 2);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 380), () {
          if (mounted) {
            _triggerInsertAnimation();
          }
        });
      });
    }

    // Simulation 5: Schedule Swap Realignment Animation
    _scheduleSwapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1350),
    );

    _scheduleSwapController.addListener(() {
      for (int i = 0; i < 4; i++) {
        final start = i * 0.18;
        final mid = start + 0.225;
        if (_scheduleSwapController.value >= mid && !_scheduleHapticsTriggered.contains(i)) {
          _scheduleHapticsTriggered.add(i);
          HapticFeedback.lightImpact();
        }
      }
    });

    _scheduleSwapController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _hasAnimatedScheduleSwap = true;
      }
    });

    if (widget.hasScheduleAdjusted && !_hasAnimatedScheduleSwap) {
      _scrollToPlace('meiji_shrine', fallbackIndex: 1);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 380), () {
          if (mounted) {
            _triggerScheduleSwapAnimation();
          }
        });
      });
    }
  }

  void _triggerSwapAnimation() {
    if (!mounted) return;
    _hasHapticTriggeredForSwap = false;
    _swapAnimationController.reset();
    _swapAnimationController.forward();
  }

  void _triggerInsertAnimation() {
    if (!mounted) return;
    HapticFeedback.lightImpact();
    _insertAnimationController.reset();
    _insertAnimationController.forward();
  }

  void _triggerScheduleSwapAnimation() {
    if (!mounted) return;
    _scheduleHapticsTriggered.clear();
    _scheduleSwapController.reset();
    _scheduleSwapController.forward();
  }

  void _rebuildDayGroups() {
    _dayGroups = _buildDayGroups().map((group) {
      return DayItineraryGroup(
        dayNumber: group.dayNumber,
        dateLabel: group.dateLabel,
        fullDateHeader: group.fullDateHeader,
        centerLat: group.centerLat,
        centerLng: group.centerLng,
        zoom: group.zoom,
        places: _recalculateSchedule(group.places),
      );
    }).toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    MapboxConfig.precacheTokyoDays(context, token: widget.mapboxAccessToken);
  }

  @override
  void didUpdateWidget(covariant TripTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hasSurpriseDetourAdded != widget.hasSurpriseDetourAdded ||
        oldWidget.hasCafeReplaced != widget.hasCafeReplaced ||
        oldWidget.hasScheduleAdjusted != widget.hasScheduleAdjusted ||
        oldWidget.hasConflictResolved != widget.hasConflictResolved ||
        oldWidget.tripStartVersion != widget.tripStartVersion ||
        widget.hasSurpriseDetourAdded) {
      _rebuildDayGroups();
      if (!oldWidget.hasConflictResolved && widget.hasConflictResolved) {
        _scrollToPlace('harajuku_takeshita', fallbackIndex: 2);
      }
      if (widget.hasSurpriseDetourAdded) {
        final day1Places = _dayGroups.isNotEmpty ? _dayGroups[0].places : <ItineraryCardItem>[];
        final detourIdx = day1Places.indexWhere((p) => p.id == 'ura_harajuku_local_market' || p.isDetour);
        if (detourIdx != -1) {
          _currentStopIndex = detourIdx;
          TripTab.currentStopIndex = detourIdx;
          _hasCompletedCheckin = false;
          TripTab.hasCheckedInFirstStop = false;
          _isNextStopDismissed = false;
        }
      }
      if (!oldWidget.hasCafeReplaced && widget.hasCafeReplaced) {
        _hasAnimatedCafeSwap = false;
        _scrollToPlace('chatei_hatou', fallbackIndex: 0);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 380), () {
            if (mounted) {
              _triggerSwapAnimation();
            }
          });
        });
      }
      if (!oldWidget.hasSurpriseDetourAdded && widget.hasSurpriseDetourAdded) {
        _hasAnimatedInsert = false;
        _scrollToPlace('ura_harajuku_local_market', fallbackIndex: 2);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 380), () {
            if (mounted) {
              _triggerInsertAnimation();
            }
          });
        });
      }
      if (!oldWidget.hasScheduleAdjusted && widget.hasScheduleAdjusted) {
        _hasAnimatedScheduleSwap = false;
        _scrollToPlace('meiji_shrine', fallbackIndex: 1);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 380), () {
            if (mounted) {
              _triggerScheduleSwapAnimation();
            }
          });
        });
      }
    }
    if ((!oldWidget.isTripStarted && widget.isTripStarted) ||
        (widget.tripStartVersion != oldWidget.tripStartVersion)) {
      _isNextStopDismissed = false;
    }
    if (widget.hasCompletedCheckin != oldWidget.hasCompletedCheckin) {
      _hasCompletedCheckin = widget.hasCompletedCheckin;
      _isNextStopDismissed = false;
    }
    if (widget.initialStopIndex != oldWidget.initialStopIndex && !widget.hasSurpriseDetourAdded) {
      _currentStopIndex = widget.initialStopIndex;
      _isNextStopDismissed = false;
    }
    setState(() {});
  }

  Future<void> _moveToNextLocation() async {
    HapticFeedback.mediumImpact();
    final currentPlaces = _dayGroups[_selectedDayIndex].places;
    final currentPlace = _currentStopIndex < currentPlaces.length
        ? currentPlaces[_currentStopIndex]
        : null;

    final placeName = currentPlace?.name ?? 'Senso-ji Temple';
    final nextIndex = _currentStopIndex + 1;
    final nextPlace = nextIndex < currentPlaces.length
        ? currentPlaces[nextIndex]
        : null;

    final bool? result = await TripFeedbackScreen.show(
      context,
      placeName: placeName,
      nextPlaceName: nextPlace?.name,
      nextLocation: nextPlace?.location,
      nextImageAsset: nextPlace?.imageAsset,
      nextWalkTime: nextPlace?.walkTime,
      nextStopNumber: nextIndex + 1,
    );

    if (result != true || !mounted) return;

    if (nextPlace != null) {
      setState(() {
        _currentStopIndex = nextIndex;
        TripTab.currentStopIndex = nextIndex;
        _hasCompletedCheckin = false;
        TripTab.hasCheckedInFirstStop = false;
        _isNextStopDismissed = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'All stops completed for Day ${_selectedDayIndex + 1}! 🎉',
            style: GoogleFonts.fredoka(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2E1C14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _swapAnimationController.dispose();
    _insertAnimationController.dispose();
    _scheduleSwapController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onDragHandleUpdate(double deltaY) {
    if (!_scrollController.hasClients) return;
    final newOffset = (_scrollController.offset - deltaY)
        .clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.jumpTo(newOffset);
  }



  List<DayItineraryGroup> _buildDayGroups() {
    return TripTab.buildDefaultDayGroups(
      hasCafeReplaced: widget.hasCafeReplaced,
      hasSurpriseDetourAdded: widget.hasSurpriseDetourAdded,
      hasScheduleAdjusted: widget.hasScheduleAdjusted,
      hasConflictResolved: widget.hasConflictResolved,
    );
  }

  void _onDaySelected(int index) {
    if (_selectedDayIndex == index) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selectedDayIndex = index;
      _isNextStopDismissed = false;
    });
  }

  void _onReorderPlaces(int oldIndex, int newIndex) {
    HapticFeedback.mediumImpact();
    setState(() {
      final currentGroup = _dayGroups[_selectedDayIndex];
      final placesList = List<ItineraryCardItem>.from(currentGroup.places);

      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = placesList.removeAt(oldIndex);
      placesList.insert(newIndex, item);
      _recentlyReorderedId = item.id;

      // Dynamically recalculate walking times and arrival times based on GPS distance
      final updatedPlaces = _recalculateSchedule(placesList);

      _dayGroups[_selectedDayIndex] = DayItineraryGroup(
        dayNumber: currentGroup.dayNumber,
        dateLabel: currentGroup.dateLabel,
        fullDateHeader: currentGroup.fullDateHeader,
        centerLat: currentGroup.centerLat,
        centerLng: currentGroup.centerLng,
        zoom: currentGroup.zoom,
        places: updatedPlaces,
      );
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted && _recentlyReorderedId != null) {
        setState(() {
          _recentlyReorderedId = null;
        });
      }
    });
  }

  List<ItineraryCardItem> _recalculateSchedule(List<ItineraryCardItem> places) {
    if (places.isEmpty) return places;

    // Tour starts in the morning with breakfast at 08:30 AM
    int currentMinutes = 8 * 60 + 30;
    final result = <ItineraryCardItem>[];

    for (int i = 0; i < places.length; i++) {
      final place = places[i];

      if (i == 0) {
        final formattedTime = _formatMinutesToTime(currentMinutes);
        result.add(place.copyWith(
          time: formattedTime,
          walkTime: 'Starting Point',
        ));
        // Add visit duration spent at this place
        currentMinutes += place.visitDuration;
      } else {
        final prevPlace = places[i - 1];
        // Calculate realistic travel time & distance based on GPS distance between locations
        final travelInfo = _calculateTravelInfo(prevPlace, place);

        // Add travel time to arrive at this place
        currentMinutes += travelInfo.minutes;
        final formattedTime = _formatMinutesToTime(currentMinutes);

        result.add(place.copyWith(
          time: formattedTime,
          walkTime: travelInfo.label,
        ));

        // Add visit duration spent at this place
        currentMinutes += place.visitDuration;
      }
    }

    return result;
  }

  ({int minutes, String label, bool isTransit}) _calculateTravelInfo(
    ItineraryCardItem from,
    ItineraryCardItem to,
  ) {
    final distanceMeters = const ll.Distance().as(
      ll.LengthUnit.Meter,
      ll.LatLng(from.latitude, from.longitude),
      ll.LatLng(to.latitude, to.longitude),
    );

    // Formatted distance string (e.g. 750m, 1.8km, 5.2km)
    final distStr = distanceMeters < 1000
        ? '${distanceMeters.round()}m'
        : '${(distanceMeters / 1000.0).toStringAsFixed(1)}km';

    // Realistic walking and urban transit pace:
    // Short distance (< 1.2km): Walking pace (~75 meters/minute + pedestrian crossings)
    // Medium distance (1.2km - 3.0km): Walking pace / quick transit (~65 m/min)
    // Long distance (> 3.0km): Metro subway / train transit + station walking buffer
    if (distanceMeters <= 1200) {
      final mins = math.max(2, (distanceMeters / 75.0).round());
      return (minutes: mins, label: '$mins min walk ($distStr)', isTransit: false);
    } else if (distanceMeters <= 3000) {
      final mins = math.max(12, (distanceMeters / 65.0).round());
      return (minutes: mins, label: '$mins min walk ($distStr)', isTransit: false);
    } else {
      // Metro / Subway transit
      final mins = math.max(18, math.min(60, 10 + (distanceMeters / 300.0).round()));
      return (minutes: mins, label: '$mins min transit ($distStr)', isTransit: true);
    }
  }

  String _formatMinutesToTime(int totalMinutes) {
    final hours = (totalMinutes ~/ 60) % 24;
    final mins = totalMinutes % 60;
    final hStr = hours.toString().padLeft(2, '0');
    final mStr = mins.toString().padLeft(2, '0');
    return '$hStr:$mStr';
  }

  String _calculateTimeRange(ItineraryCardItem place) {
    try {
      final parts = place.time.split(':');
      if (parts.length == 2) {
        final startH = int.parse(parts[0]);
        final startM = int.parse(parts[1]);
        final startTotal = startH * 60 + startM;
        final endTotal = startTotal + place.visitDuration;
        return '${_formatMinutesToTime(startTotal)} - ${_formatMinutesToTime(endTotal)}';
      }
    } catch (_) {}
    return '${place.time} - 10:00';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hasSurpriseDetourAdded) {
      final hasDetourAt2 = _dayGroups.isNotEmpty &&
          _dayGroups[0].places.length > 2 &&
          _dayGroups[0].places[2].id == 'ura_harajuku_local_market';
      if (!hasDetourAt2) {
        _rebuildDayGroups();
      }
    }

    final currentGroup = _dayGroups[_selectedDayIndex];
    final currentPlaces = currentGroup.places;
    final maxIdx = currentPlaces.isNotEmpty ? currentPlaces.length - 1 : 0;
    int activeIndex = _currentStopIndex.clamp(0, maxIdx);

    if (widget.hasSurpriseDetourAdded && !_hasCompletedCheckin) {
      final detourIdx = currentPlaces.indexWhere((p) => p.id == 'ura_harajuku_local_market' || p.isDetour);
      if (detourIdx != -1) {
        activeIndex = detourIdx;
      }
    }

    final activePlace = currentPlaces.isNotEmpty ? currentPlaces[activeIndex] : null;
    final nextPlace = (activeIndex + 1 < currentPlaces.length) ? currentPlaces[activeIndex + 1] : null;

    return Stack(
      children: [
        CustomScrollView(
          key: _scrollViewKey,
          controller: _scrollController,
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            // UNIFIED COMBINED MAP & PLAN HEADER
            SliverPersistentHeader(
              pinned: true,
              delegate: _CombinedMapPlanHeaderDelegate(
                minHeight: 188.0,
                maxHeight: 328.0,
                mapboxAccessToken: widget.mapboxAccessToken,
                currentGroup: currentGroup,
                dayGroups: _dayGroups,
                selectedIndex: _selectedDayIndex,
                onDaySelected: _onDaySelected,
                onDragUpdate: _onDragHandleUpdate,
                onBackTap: widget.onBackTap,
              ),
            ),

            // 3. UNIFIED DRAGGABLE BOTTOM SHEET: ITINERARY TIMELINE CONTENT
            SliverToBoxAdapter(
              child: Container(
                color: const Color(0xFFFDF7F0),
                child: Container(
                  margin: EdgeInsets.fromLTRB(14, 0, 14, widget.isTripStarted ? 110 : 80),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(22.0)),
                    border: Border(
                      left: BorderSide(color: Color(0xFFEDE3D7), width: 1.2),
                      right: BorderSide(color: Color(0xFFEDE3D7), width: 1.2),
                      bottom: BorderSide(color: Color(0xFFEDE3D7), width: 1.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x0C2E1C14),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Day Subheader: "Day 1 • 9 Sep (Wed)"
                      _buildDaySubheader(currentGroup),

                      const SizedBox(height: 14),

                      // Swappable / Reorderable Cards List
                      ReorderableListView.builder(
                        buildDefaultDragHandles: false,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: currentGroup.places.length,
                        onReorder: _onReorderPlaces,
                        proxyDecorator: (Widget child, int index, Animation<double> animation) {
                          return AnimatedBuilder(
                            animation: animation,
                            builder: (BuildContext context, Widget? _) {
                              final double animValue = Curves.easeInOut.transform(animation.value);
                              final double elevation = animValue * 8.0;
                              return Material(
                                elevation: elevation,
                                color: Colors.transparent,
                                shadowColor: const Color(0xFF2E1C14).withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(20),
                                child: child,
                              );
                            },
                          );
                        },
                        itemBuilder: (context, index) {
                          final place = currentGroup.places[index];
                          final isLast = index == currentGroup.places.length - 1;
                          return _buildItineraryCard(
                            key: ValueKey('place_${place.id}'),
                            place: place,
                            index: index,
                            isLast: isLast,
                            currentGroup: currentGroup,
                            dayColor: MapboxDirectionsService.getDayColor(currentGroup.dayNumber),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // Floating Stop bottom card: active when trip is started (Current Stop or Next Stop)
        if (widget.isTripStarted && !_isNextStopDismissed && activePlace != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 4,
            child: TripNextStopBottomCard(
              key: ValueKey('stop_${activePlace.id}_${_hasCompletedCheckin}_${_currentStopIndex}_${widget.tripStartVersion}'),
              place: activePlace,
              isCurrentStop: _hasCompletedCheckin,
              nextStopLabel: _hasCompletedCheckin ? 'Current Stop' : 'Next Stop',
              timeRange: _calculateTimeRange(activePlace),
              nextLocationName: nextPlace?.name,
              onMoveToNextLocation: _moveToNextLocation,
              onTap: () {
                TripArrivalScreen.show(
                  context,
                  placeName: activePlace.name,
                  location: activePlace.location,
                  imageAsset: activePlace.imageAsset,
                  destination: widget.destination,
                  tripType: widget.tripType,
                  startDate: widget.startDate,
                  endDate: widget.endDate,
                );
              },
              onDismissed: () {
                setState(() {
                  _isNextStopDismissed = true;
                });
              },
            ),
          ),
      ],
    );
  }

  /// Day Subheader: "Day 1 • 9 Sep (Wed)"
  Widget _buildDaySubheader(DayItineraryGroup currentGroup) {
    final dayColor = MapboxDirectionsService.getDayColor(currentGroup.dayNumber);
    return Row(
      children: [
        Text(
          'Day ${currentGroup.dayNumber}',
          style: GoogleFonts.fredoka(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF231815),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: dayColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          currentGroup.fullDateHeader.split('•').last.trim(),
          style: GoogleFonts.fredoka(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF4A3E38),
          ),
        ),
      ],
    );
  }

  String _getOriginalScheduleTime(String placeId, bool hasDetour) {
    switch (placeId) {
      case 'meiji_shrine':
        return '09:25';
      case 'harajuku_takeshita':
        return hasDetour ? '11:35' : '10:45';
      case 'afuri_harajuku':
        return '12:15';
      case 'shibuya_scramble':
        return '13:20';
      default:
        return '';
    }
  }

  String _getAdjustedScheduleTime(String placeId) {
    switch (placeId) {
      case 'meiji_shrine':
        return '09:25 – 10:50';
      case 'harajuku_takeshita':
        return '11:00 – 11:45';
      case 'afuri_harajuku':
        return '12:00 – 12:45';
      case 'shibuya_scramble':
        return '13:00';
      default:
        return '';
    }
  }

  /// Swappable Itinerary Card Item with Stop Number, Dynamic Times, 3D Swap Flip Animation, and Drag Handle
  Widget _buildItineraryCard({
    required Key key,
    required ItineraryCardItem place,
    required int index,
    required bool isLast,
    required DayItineraryGroup currentGroup,
    Color? dayColor,
  }) {
    String? customTimeDisplay;

    if (widget.hasScheduleAdjusted && currentGroup.dayNumber == 1) {
      final adj = _getAdjustedScheduleTime(place.id);
      if (adj.isNotEmpty) {
        customTimeDisplay = adj;
      }
    }

    final bool isSwappedCafeCard =
        currentGroup.dayNumber == 1 && index == 0 && widget.hasCafeReplaced;
    final bool isRecentlyReordered = _recentlyReorderedId == place.id;

    // Simulation 5: Schedule Swap card detection for Day 1
    const affectedScheduleIds = [
      'meiji_shrine',
      'harajuku_takeshita',
      'afuri_harajuku',
      'shibuya_scramble',
    ];
    final int scheduleIdx = (currentGroup.dayNumber == 1 && widget.hasScheduleAdjusted)
        ? affectedScheduleIds.indexOf(place.id)
        : -1;
    final bool isScheduleSwappedCard = scheduleIdx != -1;

    Widget cardBody;

    if (isSwappedCafeCard) {
      cardBody = AnimatedBuilder(
        animation: _swapAnimationController,
        builder: (context, child) {
          final bool isAnimating = _swapAnimationController.isAnimating;
          final bool isFirstHalf = _swapFlipAnimation.value < 0.5;

          // Before 50% flip: show original place ("Bread, Espresso & Arashiyama Garden").
          // After 50% flip or when finished: show swapped place ("Chatei Hatou").
          final ItineraryCardItem activePlace = (isAnimating && isFirstHalf)
              ? _originalBreadEspressoPlace
              : place;

          final double flipAngle = isAnimating
              ? (isFirstHalf
                  ? _swapFlipAnimation.value * math.pi
                  : (1.0 - _swapFlipAnimation.value) * math.pi)
              : 0.0;

          final double scale = isAnimating ? _swapScaleAnimation.value : 1.0;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateY(flipAngle),
            child: Transform.scale(
              scale: scale,
              child: _buildCardContent(
                place: activePlace,
                index: index,
                currentGroup: currentGroup,
                dayColor: dayColor,
                customTimeDisplay: customTimeDisplay,
              ),
            ),
          );
        },
      );
    } else if (isScheduleSwappedCard) {
      cardBody = AnimatedBuilder(
        animation: _scheduleSwapController,
        builder: (context, child) {
          final bool isAnimating = _scheduleSwapController.isAnimating;
          final double startInterval = scheduleIdx * 0.18;
          final double endInterval = (startInterval + 0.45).clamp(0.0, 1.0);

          final double localProgress = isAnimating
              ? ((_scheduleSwapController.value - startInterval) / (endInterval - startInterval)).clamp(0.0, 1.0)
              : (_hasAnimatedScheduleSwap ? 1.0 : 0.0);

          final double curvedVal = Curves.easeInOutCubic.transform(localProgress);
          final bool isFirstHalf = curvedVal < 0.5;

          final String originalTime = _getOriginalScheduleTime(place.id, widget.hasSurpriseDetourAdded);
          final String adjustedTime = _getAdjustedScheduleTime(place.id);

          // Before midpoint: original time. After midpoint or when finished: adjusted time.
          final String activeTime = isFirstHalf ? originalTime : adjustedTime;

          final double flipAngle = (isAnimating && localProgress > 0.0 && localProgress < 1.0)
              ? (isFirstHalf
                  ? curvedVal * math.pi
                  : (1.0 - curvedVal) * math.pi)
              : 0.0;

          final double scale = (isAnimating && localProgress > 0.0 && localProgress < 1.0)
              ? (isFirstHalf
                  ? 1.0 - (curvedVal * 0.07)
                  : 0.96 + ((curvedVal - 0.5) * 2 * 0.05))
              : 1.0;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateY(flipAngle),
            child: Transform.scale(
              scale: scale,
              child: _buildCardContent(
                place: place,
                index: index,
                currentGroup: currentGroup,
                dayColor: dayColor,
                customTimeDisplay: activeTime,
              ),
            ),
          );
        },
      );
    } else {
      cardBody = AnimatedScale(
        scale: isRecentlyReordered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        child: _buildCardContent(
          place: place,
          index: index,
          currentGroup: currentGroup,
          dayColor: dayColor,
          customTimeDisplay: customTimeDisplay,
        ),
      );
    }

    // Simulation 3: Smooth and clean insert animation for Surprise Detour Card
    final bool isDetourPlace =
        currentGroup.dayNumber == 1 &&
        (place.id == 'ura_harajuku_local_market' || place.isDetour);

    final Widget cardContainer = Container(
      margin: const EdgeInsets.only(bottom: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KeyedSubtree(
            key: _getCardGlobalKey(place.id),
            child: cardBody,
          ),

          // Vertical connector indicator between cards
          if (!isLast)
            Padding(
              padding: const EdgeInsets.only(left: 48.0, top: 2.0, bottom: 2.0),
              child: SizedBox(
                height: 16,
                child: CustomPaint(
                  size: const Size(2, 16),
                  painter: _DashedLinePainter(const Color(0xFFE2D6CB)),
                ),
              ),
            ),
        ],
      ),
    );

    if (isDetourPlace) {
      return AnimatedBuilder(
        key: key,
        animation: _insertAnimationController,
        builder: (context, child) {
          final bool isAnimating = _insertAnimationController.isAnimating;
          if (!isAnimating && _hasAnimatedInsert) {
            return cardContainer;
          }

          final double animValue = _insertAnimation.value;
          return ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: animValue,
              child: Opacity(
                opacity: ((animValue - 0.15) / 0.85).clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0.0, -24.0 * (1.0 - animValue)),
                  child: cardContainer,
                ),
              ),
            ),
          );
        },
      );
    }

    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          cardBody,

          // Vertical connector indicator between cards
          if (!isLast)
            Padding(
              padding: const EdgeInsets.only(left: 48.0, top: 2.0, bottom: 2.0),
              child: SizedBox(
                height: 16,
                child: CustomPaint(
                  size: const Size(2, 16),
                  painter: _DashedLinePainter(const Color(0xFFE2D6CB)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardContent({
    required ItineraryCardItem place,
    required int index,
    required DayItineraryGroup currentGroup,
    Color? dayColor,
    String? customTimeDisplay,
  }) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFF0EAE1),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E1C14).withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            TripLocationOverviewSheet.show(context, place: place);
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Left: Stop Number Badge + Place Thumbnail Image (74x74 rounded)
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        width: 74,
                        height: 74,
                        child: Image.asset(
                          place.imageAsset,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, st) {
                            return Container(
                              color: const Color(0xFFF4EDE4),
                              child: const Center(
                                child: Icon(
                                  Icons.landscape_rounded,
                                  color: Color(0xFFC5BDB7),
                                  size: 28,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Stop Number Badge
                    Positioned(
                      top: -4,
                      left: -4,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: dayColor ?? const Color(0xFFE65100),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.0),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2E1C14).withValues(alpha: 0.18),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: GoogleFonts.fredoka(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 14),

                // Middle: Time Chip, Title, District & Walking info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F2EB),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Colors.transparent,
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              customTimeDisplay ?? place.time,
                              style: GoogleFonts.fredoka(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF4A3E38),
                              ),
                            ),
                          ),
                          if (place.category != null) ...[
                            const SizedBox(width: 6),
                            Flexible(
                              child: _buildCategoryBadge(place),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),

                      Text(
                        place.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.fredoka(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF231815),
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 3),

                      Text(
                        place.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.fredoka(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF8A786E),
                        ),
                      ),
                      if (place.specialtyDish != null) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(
                              Icons.restaurant_rounded,
                              size: 11.5,
                              color: Color(0xFF8C7A70),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                place.specialtyDish!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.fredoka(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF7A6A60),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 5),

                      Row(
                        children: [
                          Icon(
                            index == 0
                                ? Icons.flag_rounded
                                : (place.walkTime.contains('transit')
                                    ? Icons.directions_transit_rounded
                                    : Icons.directions_walk_rounded),
                            size: 15,
                            color: dayColor ?? const Color(0xFFD97706),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              index == 0
                                  ? 'Starting Point'
                                  : place.walkTime,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.fredoka(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF7A6A60),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Right: Reorder / Drag handle listener
                ReorderableDragStartListener(
                  index: index,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF6F0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.drag_indicator_rounded,
                      size: 20,
                      color: Color(0xFF9E8E82),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(ItineraryCardItem place) {
    final cat = place.category;
    if (cat == null) return const SizedBox.shrink();

    Color bgColor;
    Color borderColor;
    Color textColor;
    IconData icon;
    String label = cat;

    switch (cat.toLowerCase()) {
      case 'breakfast':
        bgColor = const Color(0xFFFFF7ED);
        borderColor = const Color(0xFFFFEDD5);
        textColor = const Color(0xFFEA580C);
        icon = Icons.bakery_dining_rounded;
        break;
      case 'lunch':
        bgColor = const Color(0xFFFEF2F2);
        borderColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        icon = Icons.ramen_dining_rounded;
        break;
      case 'dinner':
        bgColor = const Color(0xFFFAF5FF);
        borderColor = const Color(0xFFF3E8FF);
        textColor = const Color(0xFF7E22CE);
        icon = Icons.dinner_dining_rounded;
        break;
      case 'cafe':
      case 'dessert':
        bgColor = const Color(0xFFFFFBEB);
        borderColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFB45309);
        icon = Icons.local_cafe_rounded;
        break;
      case 'local food':
      case 'hawker stall':
      case 'street food':
        bgColor = const Color(0xFFECFDF5);
        borderColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF047857);
        icon = Icons.storefront_rounded;
        break;
      case 'shopping':
        bgColor = const Color(0xFFFDF4FF);
        borderColor = const Color(0xFFFAE8FF);
        textColor = const Color(0xFFC026D3);
        icon = Icons.shopping_bag_rounded;
        break;
      default:
        bgColor = const Color(0xFFF0FDF4);
        borderColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF15803D);
        icon = Icons.place_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10.5, color: textColor),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.fredoka(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Unified Combined Map & Plan Header Delegate
/// Combines the real Mapbox map and the plan section top into a single continuous component:
/// - Pinned so scrolling up smoothly shrinks the map to a small slice (minHeight 188.0, 110 map + 78 bar) without disappearing
/// - The plan section top overlaps the map with a beautiful rounded top (radius 24.0) matching Image 2
/// - The map extends underneath the top of the plan section, so in the rounded corners the map shows through (matching Image 2)
/// - The entire component retains the exact current width (margin: horizontal 14.0)
class _CombinedMapPlanHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final String? mapboxAccessToken;
  final DayItineraryGroup currentGroup;
  final List<DayItineraryGroup> dayGroups;
  final int selectedIndex;
  final ValueChanged<int> onDaySelected;
  final ValueChanged<double>? onDragUpdate;
  final VoidCallback? onBackTap;

  _CombinedMapPlanHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    this.mapboxAccessToken,
    required this.currentGroup,
    required this.dayGroups,
    required this.selectedIndex,
    required this.onDaySelected,
    this.onDragUpdate,
    this.onBackTap,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final currentHeight =
            (maxHeight - shrinkOffset).clamp(minHeight, maxHeight);
        final places = currentGroup.places;
        final coords = places
            .map((p) => (lat: p.latitude, lng: p.longitude))
            .toList();

        // Distinct color code for this day
        final dayColor =
            MapboxDirectionsService.getDayColor(currentGroup.dayNumber);

        // Effective map display width, full uncollapsed height, and visible clipped height
        final mapContentWidth = math.max(10.0, constraints.maxWidth - 28.0);
        final fullMapHeight = maxHeight - 78.0 - 6.0;
        final mapVisibleHeight = math.max(10.0, currentHeight - 78.0 - 6.0);

        // Real street-network route points turn-by-turn along roads
        final roadCoordinates =
            MapboxDirectionsService.getRealRouteForDay(currentGroup.dayNumber);

        // Compute stable optimal bounds fixed for the entire day group
        final bounds = MapboxConfig.computeOptimalBounds(
          coordinates: coords,
          viewportWidth: mapContentWidth,
          viewportHeight: fullMapHeight,
          horizontalPadding: 45.0,
          verticalPadding: 32.0,
        );

        return Container(
          color: const Color(0xFFFDF7F0),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                // 1. MAP SECTION (Top part, connects seamlessly under the plan section)
                Positioned(
                  top: 6.0,
                  left: 0,
                  right: 0,
                  // Extends 22px lower so it renders behind the rounded top corners of the plan section
                  height: mapVisibleHeight + 22.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(22)),
                      border: const Border(
                        top: BorderSide(color: Color(0xFFEDE3D7), width: 1.2),
                        left: BorderSide(color: Color(0xFFEDE3D7), width: 1.2),
                        right:
                            BorderSide(color: Color(0xFFEDE3D7), width: 1.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF2E1C14).withValues(alpha: 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(21)),
                      child: _DynamicInfiniteMapView(
                        key: ValueKey('infinite_map_${currentGroup.dayNumber}'),
                        centerLat: bounds.centerLat,
                        centerLng: bounds.centerLng,
                        zoom: bounds.zoom,
                        places: places,
                        roadCoordinates: roadCoordinates,
                        dayColor: dayColor,
                        dayNumber: currentGroup.dayNumber,
                        mapboxAccessToken: mapboxAccessToken,
                      ),
                    ),
                  ),
                ),

                // 2. PLAN SECTION TOP (Rounded top overlapping the map, matching Image 2)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 78.0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24.0)),
                      border: Border(
                        top: BorderSide(color: Color(0xFFEDE3D7), width: 1.2),
                        left: BorderSide(color: Color(0xFFEDE3D7), width: 1.2),
                        right:
                            BorderSide(color: Color(0xFFEDE3D7), width: 1.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x0E2E1C14),
                          blurRadius: 10,
                          offset: Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Drag Handle Pill Indicator (Image 2)
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onVerticalDragUpdate: (details) {
                            if (onDragUpdate != null) {
                              onDragUpdate!(details.delta.dy);
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding:
                                const EdgeInsets.only(top: 10.0, bottom: 8.0),
                            color: Colors.transparent,
                            child: Center(
                              child: Container(
                                width: 38,
                                height: 4.5,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD4CDC5),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Day Selection Bar with Day-Coded Colors
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 14.0),
                            child: Row(
                              children:
                                  List.generate(dayGroups.length, (index) {
                                final group = dayGroups[index];
                                final isSelected = selectedIndex == index;
                                final tabDayColor =
                                    MapboxDirectionsService.getDayColor(
                                        group.dayNumber);

                                return GestureDetector(
                                  key: ValueKey('day_tab_$index'),
                                  onTap: () => onDaySelected(index),
                                  behavior: HitTestBehavior.opaque,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Subtle color code indicator dot
                                            Container(
                                              width: 6.5,
                                              height: 6.5,
                                              margin: const EdgeInsets.only(
                                                  right: 5.0),
                                              decoration: BoxDecoration(
                                                color: tabDayColor,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            Text(
                                              group.dateLabel,
                                              style: GoogleFonts.fredoka(
                                                fontSize: 14.5,
                                                fontWeight: isSelected
                                                    ? FontWeight.w700
                                                    : FontWeight.w500,
                                                color: isSelected
                                                    ? const Color(0xFF1E1714)
                                                    : const Color(0xFF8E847E),
                                                letterSpacing: -0.2,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        // Dynamic Day-Coded Indicator Bar
                                        AnimatedContainer(
                                          duration: const Duration(
                                              milliseconds: 200),
                                          curve: Curves.easeOutCubic,
                                          height: 3.0,
                                          width: isSelected ? 24.0 : 0.0,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? tabDayColor
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(2.0),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  bool shouldRebuild(covariant _CombinedMapPlanHeaderDelegate oldDelegate) {
    return oldDelegate.mapboxAccessToken != mapboxAccessToken ||
        oldDelegate.currentGroup != currentGroup ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.dayGroups != dayGroups ||
        oldDelegate.minHeight != minHeight ||
        oldDelegate.maxHeight != maxHeight;
  }
}

/// Pannable & Zoomable interactive Map layer with smooth re-center gesture
/// Full Dynamic Infinite Interactive Map (powered by FlutterMap / OpenStreetMap tiles)
/// Provides seamless infinite panning in all directions, pinch-to-zoom, live tiles,
/// turn-by-turn road route overlay, numbered place markers, and quick re-center controls.
class _DynamicInfiniteMapView extends StatefulWidget {
  final double centerLat;
  final double centerLng;
  final double zoom;
  final List<ItineraryCardItem> places;
  final List<({double lat, double lng})> roadCoordinates;
  final Color dayColor;
  final int dayNumber;
  final String? mapboxAccessToken;

  const _DynamicInfiniteMapView({
    super.key,
    required this.centerLat,
    required this.centerLng,
    required this.zoom,
    required this.places,
    this.roadCoordinates = const [],
    required this.dayColor,
    required this.dayNumber,
    this.mapboxAccessToken,
  });

  @override
  State<_DynamicInfiniteMapView> createState() =>
      _DynamicInfiniteMapViewState();
}

class _DynamicInfiniteMapViewState extends State<_DynamicInfiniteMapView> {
  late final MapController _mapController;
  List<ll.LatLng> _realRoutePoints = [];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadRealRoute();
  }

  @override
  void didUpdateWidget(covariant _DynamicInfiniteMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final placesChanged = !_arePlacesEqual(oldWidget.places, widget.places);
    final dayChanged = oldWidget.dayNumber != widget.dayNumber;

    if (dayChanged) {
      _mapController.move(
        ll.LatLng(widget.centerLat, widget.centerLng),
        widget.zoom,
      );
    }
    if (dayChanged || placesChanged) {
      _loadRealRoute();
    }
  }

  bool _arePlacesEqual(List<ItineraryCardItem> a, List<ItineraryCardItem> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  void _loadRealRoute() {
    final waypoints = widget.places
        .map((p) => (lat: p.latitude, lng: p.longitude))
        .toList();

    // 1. Instantly use cached or precomputed real road route synchronously
    final syncRoute = MapboxDirectionsService.getSyncRouteForCoordinates(
      waypoints: waypoints,
      dayNumber: widget.dayNumber,
    );
    if (syncRoute.isNotEmpty) {
      _realRoutePoints = syncRoute.map((c) => ll.LatLng(c.lat, c.lng)).toList();
    } else if (widget.roadCoordinates.isNotEmpty) {
      _realRoutePoints = widget.roadCoordinates.map((c) => ll.LatLng(c.lat, c.lng)).toList();
    } else {
      _realRoutePoints = widget.places.map((p) => ll.LatLng(p.latitude, p.longitude)).toList();
    }

    // 2. Asynchronously query real street turn-by-turn road route (OSRM / Mapbox)
    MapboxDirectionsService.fetchRealRouteForCoordinates(
      waypoints: waypoints,
      token: widget.mapboxAccessToken,
      dayNumber: widget.dayNumber,
    ).then((coords) {
      if (mounted && coords.isNotEmpty) {
        setState(() {
          _realRoutePoints = coords.map((c) => ll.LatLng(c.lat, c.lng)).toList();
        });
      }
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _recenter() {
    HapticFeedback.selectionClick();
    _mapController.move(
      ll.LatLng(widget.centerLat, widget.centerLng),
      widget.zoom,
    );
  }

  @override
  Widget build(BuildContext context) {
    final routePoints = _realRoutePoints.isNotEmpty
        ? _realRoutePoints
        : widget.places.map((p) => ll.LatLng(p.latitude, p.longitude)).toList();

    return Stack(
      children: [
        // 1. Instant offline canvas background while dynamic tiles stream in
        const Positioned.fill(
          child: CustomPaint(
            painter: _OfflineVectorMapPainter(),
          ),
        ),

        // 2. Full dynamic infinite slippy map
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: ll.LatLng(widget.centerLat, widget.centerLng),
            initialZoom: widget.zoom,
            minZoom: 3.0,
            maxZoom: 18.5,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            // Standard Street Tile Layer
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.travelyn.travelyn',
              maxZoom: 19,
            ),

            // Road Network Route with white halo & vibrant day color
            if (routePoints.length >= 2)
              PolylineLayer(
                polylines: [
                  // Outer white halo
                  Polyline(
                    points: routePoints,
                    strokeWidth: 6.4,
                    color: Colors.white.withValues(alpha: 0.95),
                    strokeCap: StrokeCap.round,
                    strokeJoin: StrokeJoin.round,
                  ),
                  // Vibrant theme color stroke
                  Polyline(
                    points: routePoints,
                    strokeWidth: 4.2,
                    color: widget.dayColor,
                    strokeCap: StrokeCap.round,
                    strokeJoin: StrokeJoin.round,
                  ),
                ],
              ),

            // Numbered Circular Place Markers (1, 2, 3...)
            MarkerLayer(
              markers: List.generate(widget.places.length, (index) {
                final place = widget.places[index];
                return Marker(
                  point: ll.LatLng(place.latitude, place.longitude),
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () {
                      TripLocationOverviewSheet.show(context, place: place);
                    },
                    child: _CircularNumberedPin(
                      number: index + 1,
                      color: widget.dayColor,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),

        // 3. Floating Re-Center Control
        Positioned(
          top: 10,
          right: 10,
          child: GestureDetector(
            onTap: _recenter,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E1C14).withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                    color: const Color(0xFFEDE3D7), width: 1.0),
              ),
              child: Icon(
                Icons.my_location_rounded,
                size: 17,
                color: widget.dayColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Clean circular numbered pin matching Image 2
class _CircularNumberedPin extends StatelessWidget {
  final int number;
  final Color color;

  const _CircularNumberedPin({
    required this.number,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x35000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$number',
          style: GoogleFonts.fredoka(
            color: Colors.white,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

/// Full-fledged offline vector cartographic map painter for Tokyo
/// Renders authentic geography: Tokyo Bay, Sumida River, lush parks (Ueno, Shinjuku, Yoyogi),
/// major expressways & avenues, urban district blocks, and cartographic labels.
class _OfflineVectorMapPainter extends CustomPainter {
  const _OfflineVectorMapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Landmass Background
    final landPaint = Paint()..color = const Color(0xFFF9F5EE);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), landPaint);

    // 2. Tokyo Bay & Coastal Water Body (Bottom-Right)
    final waterPaint = Paint()..color = const Color(0xFFD2E8F4);
    final waterPath = Path()
      ..moveTo(w * 0.45, h)
      ..quadraticBezierTo(w * 0.60, h * 0.78, w * 0.75, h * 0.65)
      ..quadraticBezierTo(w * 0.88, h * 0.58, w, h * 0.52)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(waterPath, waterPaint);

    // Subtle water coastline border
    final waterBorderPaint = Paint()
      ..color = const Color(0xFFB4D8EC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(waterPath, waterBorderPaint);

    // 3. Sumida River & Waterways
    final riverPaint = Paint()
      ..color = const Color(0xFFD2E8F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final riverPath = Path()
      ..moveTo(w * 0.82, 0)
      ..quadraticBezierTo(w * 0.76, h * 0.22, w * 0.78, h * 0.38)
      ..quadraticBezierTo(w * 0.72, h * 0.52, w * 0.68, h * 0.72)
      ..lineTo(w * 0.64, h * 0.85);
    canvas.drawPath(riverPath, riverPaint);

    // Kanda River Tributary
    final canalPaint = Paint()
      ..color = const Color(0xFFD2E8F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;
    final canalPath = Path()
      ..moveTo(w * 0.25, h * 0.20)
      ..quadraticBezierTo(w * 0.48, h * 0.32, w * 0.76, h * 0.35);
    canvas.drawPath(canalPath, canalPaint);

    // 4. Parks & Nature Reserves (Lush Greenery)
    final parkPaint = Paint()..color = const Color(0xFFE2EED8);
    final parkBorderPaint = Paint()
      ..color = const Color(0xFFCFE2C3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    void drawPark(RRect rrect) {
      canvas.drawRRect(rrect, parkPaint);
      canvas.drawRRect(rrect, parkBorderPaint);
    }

    // Yoyogi Park & Meiji Jingu (West)
    drawPark(RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.08, h * 0.38, w * 0.16, h * 0.20),
      const Radius.circular(10),
    ));

    // Shinjuku Gyoen (North-West)
    drawPark(RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.18, h * 0.18, w * 0.15, h * 0.14),
      const Radius.circular(8),
    ));

    // Imperial Palace Gardens (Center)
    drawPark(RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.46, h * 0.32, w * 0.18, h * 0.22),
      const Radius.circular(12),
    ));

    // Ueno Park (North-East)
    drawPark(RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.66, h * 0.08, w * 0.14, h * 0.16),
      const Radius.circular(8),
    ));

    // Hamarikyu Gardens (South-East Waterfront)
    drawPark(RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.54, h * 0.66, w * 0.11, h * 0.11),
      const Radius.circular(6),
    ));

    // 5. Urban Street Grid Network (Secondary streets)
    final minorStreetPaint = Paint()
      ..color = const Color(0xFFEDE5D9)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (double x = 20.0; x < w; x += 32.0) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), minorStreetPaint);
    }
    for (double y = 20.0; y < h; y += 32.0) {
      canvas.drawLine(Offset(0, y), Offset(w, y), minorStreetPaint);
    }

    // 6. Major Arterial Avenues & Expressways (Primary roads)
    final mainRoadBg = Paint()
      ..color = const Color(0xFFE2D6C6)
      ..strokeWidth = 5.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final mainRoadFill = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..strokeWidth = 3.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    void drawAvenue(Path path) {
      canvas.drawPath(path, mainRoadBg);
      canvas.drawPath(path, mainRoadFill);
    }

    // Yamanote / Chuo corridor horizontal
    final av1 = Path()
      ..moveTo(0, h * 0.32)
      ..quadraticBezierTo(w * 0.35, h * 0.30, w * 0.65, h * 0.38)
      ..lineTo(w, h * 0.40);
    drawAvenue(av1);

    // Meiji-dori diagonal
    final av2 = Path()
      ..moveTo(w * 0.12, 0)
      ..quadraticBezierTo(w * 0.20, h * 0.45, w * 0.35, h)
      ..lineTo(w * 0.40, h);
    drawAvenue(av2);

    // Ginza / Tokyo Station avenue
    final av3 = Path()
      ..moveTo(w * 0.40, 0)
      ..quadraticBezierTo(w * 0.52, h * 0.48, w * 0.58, h);
    drawAvenue(av3);

    // Showa-dori / Asakusa avenue
    final av4 = Path()
      ..moveTo(w * 0.70, 0)
      ..quadraticBezierTo(w * 0.66, h * 0.40, w * 0.72, h * 0.70);
    drawAvenue(av4);

    // Coastal Bay Expressway
    final av5 = Path()
      ..moveTo(w * 0.35, h * 0.88)
      ..quadraticBezierTo(w * 0.58, h * 0.74, w, h * 0.60);
    drawAvenue(av5);

    // 7. Cartographic District Labels
    void drawLabel(String text, Offset pos, {Color color = const Color(0xFF9E8E82), double fontSize = 9.5, bool bold = false}) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            color: color,
            letterSpacing: 0.8,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, pos);
    }

    drawLabel('SHINJUKU', Offset(w * 0.16, h * 0.12), bold: true);
    drawLabel('SHIBUYA', Offset(w * 0.12, h * 0.62), bold: true);
    drawLabel('ASAKUSA', Offset(w * 0.74, h * 0.06), bold: true);
    drawLabel('GINZA', Offset(w * 0.58, h * 0.48), bold: true);
    drawLabel('MINATO', Offset(w * 0.36, h * 0.72), bold: true);
    drawLabel('TOKYO BAY', Offset(w * 0.72, h * 0.82), color: const Color(0xFF6DA5C4), fontSize: 10.5, bold: true);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


/// Custom painter for dashed connecting line between timeline cards
class _DashedLinePainter extends CustomPainter {
  final Color color;
  const _DashedLinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    const dashHeight = 4.0;
    const dashSpace = 3.0;
    double startY = 0.0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, math.min(startY + dashHeight, size.height)),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
