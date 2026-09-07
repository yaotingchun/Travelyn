import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../services/mapbox_config.dart';
import '../../../services/mapbox_directions_service.dart';

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

  const ItineraryCardItem({
    required this.id,
    required this.time,
    required this.name,
    required this.location,
    required this.walkTime,
    required this.imageAsset,
    required this.latitude,
    required this.longitude,
  });
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
  });

  @override
  State<TripTab> createState() => _TripTabState();
}

class _TripTabState extends State<TripTab> {
  int _selectedDayIndex = 0;
  late final List<DayItineraryGroup> _dayGroups;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _dayGroups = _buildDayGroups();
  }

  @override
  void dispose() {
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
    return [
      const DayItineraryGroup(
        dayNumber: 1,
        dateLabel: '08.09 SUN',
        fullDateHeader: 'Day 1 • 9 Sep (Wed)',
        centerLat: 35.6740,
        centerLng: 139.7028,
        zoom: 13.5,
        places: [
          ItineraryCardItem(
            id: 'meiji_shrine',
            time: '09:30',
            name: 'Meiji Shrine',
            location: 'Shibuya, Tokyo',
            walkTime: '15 min',
            imageAsset: 'assets/journey/place_meiji_shrine.jpg',
            latitude: 35.6764,
            longitude: 139.6993,
          ),
          ItineraryCardItem(
            id: 'harajuku_takeshita',
            time: '11:00',
            name: 'Harajuku Takeshita St.',
            location: 'Harajuku, Tokyo',
            walkTime: '20 min',
            imageAsset: 'assets/journey/place_harajuku.jpg',
            latitude: 35.6702,
            longitude: 139.7027,
          ),
          ItineraryCardItem(
            id: 'shibuya_scramble',
            time: '14:30',
            name: 'Shibuya Scramble',
            location: 'Shibuya, Tokyo',
            walkTime: '15 min',
            imageAsset: 'assets/journey/place_shibuya.jpg',
            latitude: 35.6595,
            longitude: 139.7005,
          ),
          ItineraryCardItem(
            id: 'teamlab_planets',
            time: '17:30',
            name: 'teamLab Planets',
            location: 'Koto City, Tokyo',
            walkTime: '25 min',
            imageAsset: 'assets/journey/place_teamlab.jpg',
            latitude: 35.6491,
            longitude: 139.7898,
          ),
        ],
      ),
      const DayItineraryGroup(
        dayNumber: 2,
        dateLabel: '09.09 MON',
        fullDateHeader: 'Day 2 • 10 Sep (Thu)',
        centerLat: 35.7140,
        centerLng: 139.7740,
        zoom: 13.2,
        places: [
          ItineraryCardItem(
            id: 'ueno_park',
            time: '09:00',
            name: 'Ueno Park & Zoo',
            location: 'Taito City, Tokyo',
            walkTime: '15 min',
            imageAsset: 'assets/journey/place_sensoji.jpg',
            latitude: 35.7140,
            longitude: 139.7740,
          ),
          ItineraryCardItem(
            id: 'akihabara_town',
            time: '11:30',
            name: 'Akihabara Electric Town',
            location: 'Chiyoda City, Tokyo',
            walkTime: '20 min',
            imageAsset: 'assets/journey/place_harajuku.jpg',
            latitude: 35.6983,
            longitude: 139.7731,
          ),
          ItineraryCardItem(
            id: 'ginza_district',
            time: '15:00',
            name: 'Ginza Shopping Street',
            location: 'Chuo City, Tokyo',
            walkTime: '10 min',
            imageAsset: 'assets/journey/place_tokyo_tower.jpg',
            latitude: 35.6719,
            longitude: 139.7648,
          ),
        ],
      ),
      const DayItineraryGroup(
        dayNumber: 3,
        dateLabel: '10.09 TUE',
        fullDateHeader: 'Day 3 • 11 Sep (Fri)',
        centerLat: 35.6586,
        centerLng: 139.7454,
        zoom: 13.0,
        places: [
          ItineraryCardItem(
            id: 'tokyo_tower',
            time: '09:30',
            name: 'Tokyo Tower Observation',
            location: 'Minato City, Tokyo',
            walkTime: '15 min',
            imageAsset: 'assets/journey/place_tokyo_tower.jpg',
            latitude: 35.6586,
            longitude: 139.7454,
          ),
          ItineraryCardItem(
            id: 'roppongi_hills',
            time: '12:30',
            name: 'Roppongi Hills Sky Deck',
            location: 'Minato City, Tokyo',
            walkTime: '20 min',
            imageAsset: 'assets/journey/place_shibuya.jpg',
            latitude: 35.6605,
            longitude: 139.7292,
          ),
          ItineraryCardItem(
            id: 'shinjuku_gyoen',
            time: '15:30',
            name: 'Shinjuku Gyoen National Garden',
            location: 'Shinjuku City, Tokyo',
            walkTime: '25 min',
            imageAsset: 'assets/journey/place_meiji_shrine.jpg',
            latitude: 35.6852,
            longitude: 139.7101,
          ),
        ],
      ),
      const DayItineraryGroup(
        dayNumber: 4,
        dateLabel: '11.09 WED',
        fullDateHeader: 'Day 4 • 12 Sep (Sat)',
        centerLat: 35.6500,
        centerLng: 139.8000,
        zoom: 12.8,
        places: [
          ItineraryCardItem(
            id: 'tsukiji_market',
            time: '08:30',
            name: 'Tsukiji Outer Market',
            location: 'Chuo City, Tokyo',
            walkTime: '10 min',
            imageAsset: 'assets/journey/place_sensoji.jpg',
            latitude: 35.6655,
            longitude: 139.7708,
          ),
          ItineraryCardItem(
            id: 'odaiba_park',
            time: '12:00',
            name: 'Odaiba Seaside Park',
            location: 'Minato City, Tokyo',
            walkTime: '30 min',
            imageAsset: 'assets/journey/place_teamlab.jpg',
            latitude: 35.6298,
            longitude: 139.7753,
          ),
          ItineraryCardItem(
            id: 'tokyo_skytree',
            time: '16:00',
            name: 'Tokyo Skytree Town',
            location: 'Sumida City, Tokyo',
            walkTime: '20 min',
            imageAsset: 'assets/journey/place_tokyo_tower.jpg',
            latitude: 35.7100,
            longitude: 139.8107,
          ),
        ],
      ),
      const DayItineraryGroup(
        dayNumber: 5,
        dateLabel: '12.09 THU',
        fullDateHeader: 'Day 5 • 13 Sep (Sun)',
        centerLat: 35.6700,
        centerLng: 139.7500,
        zoom: 13.0,
        places: [
          ItineraryCardItem(
            id: 'nakano_broadway',
            time: '10:00',
            name: 'Nakano Broadway',
            location: 'Nakano City, Tokyo',
            walkTime: '15 min',
            imageAsset: 'assets/journey/place_harajuku.jpg',
            latitude: 35.7090,
            longitude: 139.6657,
          ),
          ItineraryCardItem(
            id: 'shibuya_sky',
            time: '13:30',
            name: 'Shibuya Sky Observatory',
            location: 'Shibuya, Tokyo',
            walkTime: '20 min',
            imageAsset: 'assets/journey/place_shibuya.jpg',
            latitude: 35.6585,
            longitude: 139.7013,
          ),
          ItineraryCardItem(
            id: 'tokyo_station',
            time: '16:30',
            name: 'Tokyo Station Ichiban-gai',
            location: 'Chiyoda City, Tokyo',
            walkTime: '15 min',
            imageAsset: 'assets/journey/place_meiji_shrine.jpg',
            latitude: 35.6812,
            longitude: 139.7671,
          ),
        ],
      ),
    ];
  }

  void _onDaySelected(int index) {
    if (_selectedDayIndex == index) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selectedDayIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentGroup = _dayGroups[_selectedDayIndex];

    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        // UNIFIED COMBINED MAP & PLAN HEADER (Pinned so scrolling up shrinks map to a small slice, plan section sits on map with rounded top matching Image 2, while remaining the exact current width)
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

        // 3. UNIFIED DRAGGABLE BOTTOM SHEET: ITINERARY TIMELINE CONTENT (Same width as map)
        SliverToBoxAdapter(
          child: Container(
            color: const Color(0xFFFDF7F0),
            child: Container(
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 80),
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

                  // Cards List
                  ...List.generate(currentGroup.places.length, (index) {
                    final place = currentGroup.places[index];
                    final isLast = index == currentGroup.places.length - 1;
                    return _buildItineraryCard(
                      place,
                      isLast,
                      MapboxDirectionsService.getDayColor(currentGroup.dayNumber),
                    );
                  }),
                ],
              ),
            ),
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

  /// Itinerary Card item matching Image 2
  Widget _buildItineraryCard(ItineraryCardItem place, bool isLast, [Color? dayColor]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
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
          child: Row(
            children: [
              // Left: Place Thumbnail Image (74x74 rounded)
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

              const SizedBox(width: 14),

              // Middle: Time, Title, District & Walking info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      place.time,
                      style: GoogleFonts.fredoka(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFA09187),
                      ),
                    ),
                    const SizedBox(height: 2),

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
                    const SizedBox(height: 5),

                    Row(
                      children: [
                        Icon(
                          Icons.directions_walk_rounded,
                          size: 15,
                          color: dayColor ?? const Color(0xFFD97706),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          place.walkTime,
                          style: GoogleFonts.fredoka(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF7A6A60),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Right: Reorder / Drag handle icon (≡)
              const Padding(
                padding: EdgeInsets.only(right: 6.0),
                child: Icon(
                  Icons.menu_rounded,
                  size: 22,
                  color: Color(0xFFC5BDB7),
                ),
              ),
            ],
          ),
        ),

        // Vertical connector indicator between cards
        if (!isLast)
          Padding(
            padding: const EdgeInsets.only(left: 48.0),
            child: SizedBox(
              height: 18,
              child: CustomPaint(
                size: const Size(2, 18),
                painter: _DashedLinePainter(const Color(0xFFE2D6CB)),
              ),
            ),
          ),
      ],
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

        // Effective map display width and visible height
        final mapContentWidth = math.max(10.0, constraints.maxWidth - 28.0);
        final mapVisibleHeight = math.max(10.0, currentHeight - 78.0 - 6.0);

        // Real street-network route points turn-by-turn along roads
        final roadCoordinates =
            MapboxDirectionsService.getRealRouteForDay(currentGroup.dayNumber);

        final bounds = MapboxConfig.computeOptimalBounds(
          coordinates: coords,
          viewportWidth: mapContentWidth,
          viewportHeight: mapVisibleHeight,
          horizontalPadding: 45.0,
          verticalPadding: 32.0,
        );

        final mapboxUrl = MapboxConfig.buildMapboxStaticUrl(
          centerLat: bounds.centerLat,
          centerLng: bounds.centerLng,
          zoom: bounds.zoom,
          width: 800,
          height: 500,
          token: mapboxAccessToken,
        );

        final fallbackUrl = MapboxConfig.buildRealMapFallbackUrl(
          centerLat: bounds.centerLat,
          centerLng: bounds.centerLng,
          zoom: bounds.zoom,
          width: 800,
          height: 500,
        );

        // Project real road network points to screen viewport pixels
        final routePoints = <Offset>[];
        final pointsToProject =
            roadCoordinates.isNotEmpty ? roadCoordinates : coords;
        for (final ptCoord in pointsToProject) {
          final pt = MapboxConfig.latLngToViewportPoint(
            lat: ptCoord.lat,
            lng: ptCoord.lng,
            centerLat: bounds.centerLat,
            centerLng: bounds.centerLng,
            zoom: bounds.zoom,
            viewportWidth: mapContentWidth,
            viewportHeight: mapVisibleHeight,
          );
          routePoints.add(pt);
        }

        // Project place stops for circular numbered pins
        final pinPoints = <Offset>[];
        for (final place in places) {
          final pt = MapboxConfig.latLngToViewportPoint(
            lat: place.latitude,
            lng: place.longitude,
            centerLat: bounds.centerLat,
            centerLng: bounds.centerLng,
            zoom: bounds.zoom,
            viewportWidth: mapContentWidth,
            viewportHeight: mapVisibleHeight,
          );
          final clampedPt = Offset(
            pt.dx.clamp(16.0, mapContentWidth - 16.0),
            pt.dy.clamp(16.0, mapVisibleHeight - 16.0),
          );
          pinPoints.add(clampedPt);
        }

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
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Real Map Layer
                          Image.network(
                            mapboxUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, st) {
                              debugPrint(
                                  'Mapbox Static Image failed: $err | URL: $mapboxUrl');
                              return Image.network(
                                fallbackUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (c2, e2, s2) {
                                  return _buildRealMapPlaceholder(
                                      Size(mapContentWidth, mapVisibleHeight));
                                },
                              );
                            },
                          ),

                          // Real Road Network Route (Matching Image 2)
                          if (routePoints.length >= 2)
                            CustomPaint(
                              size: Size(mapContentWidth, mapVisibleHeight),
                              painter: _RealRoadRoutePainter(
                                routePoints: routePoints,
                                routeColor: dayColor,
                              ),
                            ),

                          // Circular Numbered Pins (1, 2, 3...) matching Image 2
                          ...List.generate(pinPoints.length, (index) {
                            final pt = pinPoints[index];
                            return Positioned(
                              left: pt.dx - 14.0,
                              top: pt.dy - 14.0,
                              child: _CircularNumberedPin(
                                number: index + 1,
                                color: dayColor,
                              ),
                            );
                          }),
                        ],
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

  /// Clean cartographic fallback placeholder if network is unavailable
  Widget _buildRealMapPlaceholder(Size size) {
    return Container(
      color: const Color(0xFFF4EFEA),
      child: CustomPaint(
        size: size,
        painter: _CartographicGridPainter(),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2D6CB)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.map_rounded,
                      size: 16,
                      color: Color(0xFFFF5B22),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Mapbox API',
                      style: GoogleFonts.fredoka(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B5A50),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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

/// Custom painter that draws a real street-network route with crisp white halo,
/// vibrant day-coded stroke, and subtle directional navigation chevrons (matching Image 2).
class _RealRoadRoutePainter extends CustomPainter {
  final List<Offset> routePoints;
  final Color routeColor;

  const _RealRoadRoutePainter({
    required this.routePoints,
    required this.routeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (routePoints.length < 2) return;

    final path = Path();
    path.moveTo(routePoints[0].dx, routePoints[0].dy);

    for (int i = 1; i < routePoints.length; i++) {
      path.lineTo(routePoints[i].dx, routePoints[i].dy);
    }

    // 1. Crisp white outer halo so route stands out over any street/satellite map
    final haloPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, haloPaint);

    // 2. Vibrant solid route stroke with day's theme color
    final routePaint = Paint()
      ..color = routeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, routePaint);

    // 3. Directional navigation chevrons along the route (matching Image 2)
    _drawDirectionalChevrons(canvas, path);
  }

  void _drawDirectionalChevrons(Canvas canvas, Path path) {
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final chevronPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    const spacing = 55.0;
    const chevronSize = 3.5;

    for (final metric in metrics) {
      if (metric.length < spacing) continue;

      double distance = spacing * 0.7;
      while (distance < metric.length - 15.0) {
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          final pos = tangent.position;
          final angle = tangent.angle;

          canvas.save();
          canvas.translate(pos.dx, pos.dy);
          canvas.rotate(angle);

          final chevronPath = Path()
            ..moveTo(-chevronSize, -chevronSize)
            ..lineTo(chevronSize * 0.4, 0)
            ..lineTo(-chevronSize, chevronSize);
          canvas.drawPath(chevronPath, chevronPaint);

          canvas.restore();
        }
        distance += spacing;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RealRoadRoutePainter oldDelegate) =>
      oldDelegate.routePoints != routePoints ||
      oldDelegate.routeColor != routeColor;
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

/// Subtle cartographic background lines for offline / fallback state
class _CartographicGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFFE5DDD3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Faint diagonal and cross grid imitating realistic street network
    for (double i = -size.height; i < size.width + size.height; i += 38.0) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height * 0.7, size.height),
        roadPaint,
      );
    }
    for (double j = -size.width; j < size.width + size.height; j += 46.0) {
      canvas.drawLine(
        Offset(j, size.height),
        Offset(j + size.height * 0.6, 0),
        roadPaint,
      );
    }
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
