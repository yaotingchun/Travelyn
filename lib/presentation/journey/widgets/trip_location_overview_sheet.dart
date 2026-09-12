import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../tabs/trip_tab.dart';

/// Location details model used to populate the overview sheet.
class LocationOverviewDetails {
  final String title;
  final double rating;
  final String reviewCount;
  final List<String> tags;
  final String description;
  final String openHours;
  final String entryFee;
  final String? proximity;
  final List<String> whyGo;

  const LocationOverviewDetails({
    required this.title,
    required this.rating,
    required this.reviewCount,
    required this.tags,
    required this.description,
    required this.openHours,
    required this.entryFee,
    this.proximity,
    required this.whyGo,
  });
}

/// Modal bottom sheet displaying a brief overview of any location in the plan.
/// Matches the reference design:
/// - Hero card displaying the location photo
/// - Floating circular close button 'X' at top-right
/// - Bottom information section overlapping with rounded top corners
/// - Location title & Star rating badge (e.g. ⭐ 4.6 (18k))
/// - Category & tag pill badges (e.g. Culture, Historic)
/// - Brief location description
/// - Quick info box (Open hours, Entry fee)
/// - "Why go?" highlights section with green checkmarks
class TripLocationOverviewSheet extends StatelessWidget {
  final ItineraryCardItem place;
  final LocationOverviewDetails details;

  const TripLocationOverviewSheet({
    super.key,
    required this.place,
    required this.details,
  });

  /// Presents the location overview sheet with smooth bottom-sheet animation.
  static Future<void> show(
    BuildContext context, {
    required ItineraryCardItem place,
  }) {
    HapticFeedback.lightImpact();
    final details = getDetailsForPlace(place);

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0xFF2E1C14).withValues(alpha: 0.45),
      builder: (ctx) => TripLocationOverviewSheet(
        place: place,
        details: details,
      ),
    );
  }

  /// Tailored metadata dictionary for Tokyo itinerary locations with sensible defaults.
  static LocationOverviewDetails getDetailsForPlace(ItineraryCardItem place) {
    final id = place.id.toLowerCase();
    final name = place.name.toLowerCase();

    if (id.contains('senso') || name.contains('senso')) {
      return const LocationOverviewDetails(
        title: 'Senso-ji Temple',
        rating: 4.6,
        reviewCount: '18k',
        tags: ['Culture', 'Historic'],
        description:
            "Tokyo's oldest temple, iconic for its giant red lantern and traditional streets.",
        openHours: 'Open 6AM – 5PM',
        entryFee: 'Free entry',
        proximity: '15 min\nfrom current location',
        whyGo: [
          'Iconic photo spot',
          'Traditional food street',
          'Feel the real Japanese atmosphere',
        ],
      );
    } else if (id.contains('meiji') || name.contains('meiji')) {
      return const LocationOverviewDetails(
        title: 'Meiji Shrine & Yoyogi Forest',
        rating: 4.7,
        reviewCount: '24k',
        tags: ['Culture', 'Nature', 'Historic'],
        description:
            'Tranquil Shinto shrine nestled in an expansive 170-acre evergreen forest in central Tokyo.',
        openHours: 'Open Sunrise – Sunset',
        entryFee: 'Free entry',
        proximity: '12 min\nfrom current location',
        whyGo: [
          'Towering ancient wooden Torii gates',
          'Peaceful forested strolling paths',
          'Write an ema prayer wish for good fortune',
        ],
      );
    } else if (id.contains('ura_harajuku') ||
        id.contains('ura') ||
        name.contains('ura-harajuku') ||
        name.contains('ura harajuku') ||
        name.contains('local market')) {
      return const LocationOverviewDetails(
        title: 'Ura-Harajuku Local Market',
        rating: 4.8,
        reviewCount: '9.2k',
        tags: ['Local Food', 'Hidden Gem'],
        description:
            "A bustling, charming maze of artisan food stalls, sizzling yakitori, fresh taiyaki, and matcha specialties tucked behind Harajuku.",
        openHours: 'Open 10AM – 8PM',
        entryFee: 'Free entry',
        proximity: '12 min (300m)\nfrom current location',
        whyGo: [
          'Authentic local street food away from crowds',
          'Fresh handcrafted matcha dango & taiyaki sweets',
          'Vibrant vintage alleys and cozy artisan stalls',
        ],
      );
    } else if (id.contains('nishi_sando') ||
        name.contains('nishi-sando') ||
        name.contains('nishi sando') ||
        name.contains('food alley')) {
      return const LocationOverviewDetails(
        title: 'Asakusa Nishi-sando Food Alley',
        rating: 4.7,
        reviewCount: '7.8k',
        tags: ['Traditional', 'Local Food', 'Street Snack'],
        description:
            "A nostalgic covered retro wooden arcade beside Senso-ji, renowned for piping-hot giant melonpan, dango, and artisanal cider.",
        openHours: 'Open 9AM – 6PM',
        entryFee: 'Free entry',
        proximity: '10 min (250m)\nfrom current location',
        whyGo: [
          'Famous freshly baked Kagetsudo jumbo melonpan',
          'Traditional wooden floor arcade with Edo vibes',
          'Sheltered cultural foodie stroll right by the temple',
        ],
      );
    } else if (id.contains('yanaka') || name.contains('yanaka')) {
      return const LocationOverviewDetails(
        title: 'Yanaka Ginza Market',
        rating: 4.8,
        reviewCount: '11k',
        tags: ['Local Food', 'Hidden Gem', 'Old Town'],
        description:
            "Preserved old Tokyo retro market street famed for crispy menchi-katsu, cat-themed pastries, and nostalgic Sunset Staircase views.",
        openHours: 'Open 10AM – 7PM',
        entryFee: 'Free entry',
        proximity: '12 min (300m)\nfrom current location',
        whyGo: [
          'Iconic Yuyake Dandan (Sunset Staircase) photo spot',
          'Crispy golden beef menchi-katsu street snacks',
          'Charming nostalgic Edo-Shitama atmosphere',
        ],
      );
    } else if (id.contains('harajuku') || id.contains('takeshita') || name.contains('takeshita')) {
      return const LocationOverviewDetails(
        title: 'Harajuku Takeshita Street',
        rating: 4.4,
        reviewCount: '19k',
        tags: ['Fashion', 'Shopping', 'Street Food'],
        description:
            'Vibrant pedestrian avenue celebrated for youth culture, colorful boutiques, and whimsical sweets.',
        openHours: 'Open 10AM – 8PM',
        entryFee: 'Free access',
        proximity: '10 min\nfrom current location',
        whyGo: [
          'Famous fluffy Japanese rainbow crepes',
          'Trendsetting Kawaii fashion boutiques',
          'Bustling energy and lively Tokyo vibes',
        ],
      );
    } else if (id.contains('afuri') || name.contains('afuri')) {
      return const LocationOverviewDetails(
        title: 'AFURI Harajuku',
        rating: 4.6,
        reviewCount: '12k',
        tags: ['Ramen', 'Lunch Spot', 'Citrus Dashi'],
        description:
            'Acclaimed ramen bar famed for light, refreshing broth infused with fresh Japanese yuzu citrus.',
        openHours: 'Open 11AM – 11PM',
        entryFee: '¥1,100 – ¥1,600',
        proximity: '8 min\nfrom current location',
        whyGo: [
          'Signature Yuzu Shio chicken-dashi ramen',
          'Charcoal-grilled melt-in-your-mouth chashu',
          'Crispy handmade bite-sized gyoza',
        ],
      );
    } else if (id.contains('shibuya_scramble') || name.contains('scramble')) {
      return const LocationOverviewDetails(
        title: 'Shibuya Scramble & Hachiko',
        rating: 4.7,
        reviewCount: '52k',
        tags: ['Landmark', 'City Icon', 'Must Visit'],
        description:
            'World-famous diagonal intersection where thousands cross simultaneously under dazzling neon screens.',
        openHours: 'Open 24 Hours',
        entryFee: 'Free access',
        proximity: '15 min\nfrom current location',
        whyGo: [
          "World's busiest and most iconic crossing",
          'Beloved bronze Hachiko loyal dog statue',
          'Electrifying neon cityscape and rooftop views',
        ],
      );
    } else if (id.contains('shibuya_sky') || name.contains('shibuya sky')) {
      return const LocationOverviewDetails(
        title: 'Shibuya Sky Observatory',
        rating: 4.9,
        reviewCount: '31k',
        tags: ['Landmark', 'Panoramic Deck', 'Views'],
        description:
            'Breathtaking 360-degree open-air rooftop deck soaring 229 meters above the Shibuya skyline.',
        openHours: 'Open 10AM – 10:30PM',
        entryFee: '¥2,200 entry',
        proximity: '10 min\nfrom current location',
        whyGo: [
          'Unobstructed 360° panorama of Tokyo and Mt. Fuji',
          'Sky Edge glass corner photo point',
          'Rooftop open turf lounge with sunset ambient beats',
        ],
      );
    } else if (id.contains('teamlab') || name.contains('teamlab')) {
      return const LocationOverviewDetails(
        title: 'teamLab Planets Tokyo',
        rating: 4.8,
        reviewCount: '45k',
        tags: ['Art', 'Digital Immersion', 'Sensory'],
        description:
            'Interactive museum where you walk barefoot through water and immerse in boundless digital artworks.',
        openHours: 'Open 9AM – 10PM',
        entryFee: '¥3,800 entry',
        proximity: '25 min\nfrom current location',
        whyGo: [
          'Walk barefoot through shimmering koi water',
          'Infinite crystal light mirror universe',
          'Floating live orchid garden with 13,000 blooms',
        ],
      );
    } else if (id.contains('bread') || id.contains('arashiyama') || name.contains('bread')) {
      return const LocationOverviewDetails(
        title: 'Bread, Espresso & Cafe',
        rating: 4.6,
        reviewCount: '8.5k',
        tags: ['Bakery', 'Breakfast', 'Artisan Coffee'],
        description:
            'Artisanal bakery acclaimed for its buttery honeycomb French toast and specialty espresso blends.',
        openHours: 'Open 8AM – 6PM',
        entryFee: '¥800 – ¥1,500',
        proximity: 'Starting Point\nof your day',
        whyGo: [
          'Signature skillet-baked fluffy French toast',
          'Warm flaky morning croissants & pastries',
          'Hand-crafted siphon iced espresso',
        ],
      );
    } else if (id.contains('chatei') || name.contains('chatei')) {
      return const LocationOverviewDetails(
        title: 'Chatei Hatou (茶亭 羽當)',
        rating: 4.7,
        reviewCount: '7.8k',
        tags: ['Kissaten', 'Specialty Coffee', 'Retro'],
        description:
            'Legendary vintage Tokyo kissaten celebrated for masterfully hand-poured siphon coffee and chiffon cake.',
        openHours: 'Open 10AM – 10PM',
        entryFee: '¥900 – ¥1,400',
        proximity: '5 min\nfrom current location',
        whyGo: [
          'Master hand-dripped aged dark roast',
          'Pillow-soft homemade matcha chiffon cake',
          'Charming retro wooden bar and rare ceramic cups',
        ],
      );
    } else if (id.contains('tokyo_tower') || name.contains('tokyo tower')) {
      return const LocationOverviewDetails(
        title: 'Tokyo Tower Observatory',
        rating: 4.6,
        reviewCount: '38k',
        tags: ['Landmark', 'Architecture', 'Historic'],
        description:
            'Iconic red-and-white communications and observation tower inspired by the Eiffel Tower.',
        openHours: 'Open 9AM – 10:30PM',
        entryFee: '¥1,200 deck',
        proximity: '8 min\nfrom current location',
        whyGo: [
          'Classic retro vantage over the Tokyo metropolis',
          'Glass floor observation lookdown windows',
          'Stunning warm evening illuminations',
        ],
      );
    } else if (id.contains('tsukiji') || name.contains('tsukiji')) {
      return const LocationOverviewDetails(
        title: 'Tsukiji Outer Market Food Stalls',
        rating: 4.7,
        reviewCount: '28k',
        tags: ['Seafood', 'Street Food', 'Market'],
        description:
            'Bustling waterfront food market packed with lively stalls serving ultra-fresh sashimi, sushi, and snacks.',
        openHours: 'Open 5AM – 2PM',
        entryFee: 'Free entry',
        proximity: 'Starting Point\nof your day',
        whyGo: [
          'Ultra-fresh bluefin tuna sashimi and chirashi bowls',
          'Piping hot rolled sweet tamagoyaki skewers',
          'Grilled giant buttered scallops and oysters',
        ],
      );
    } else if (id.contains('ueno') || name.contains('ueno')) {
      return const LocationOverviewDetails(
        title: 'Ueno Park & Shinobazu Pond',
        rating: 4.6,
        reviewCount: '22k',
        tags: ['Nature', 'Historic Park', 'Lakeside'],
        description:
            'Sprawling public park known for serene temples, picturesque lotus ponds, and seasonal blossoms.',
        openHours: 'Open 5AM – 11PM',
        entryFee: 'Free entry',
        proximity: '8 min\nfrom current location',
        whyGo: [
          'Peaceful Shinobazu Pond with lotus flowers',
          'Historic Bentendo Temple on the water',
          'Shaded walking avenues with park buskers',
        ],
      );
    } else if (id.contains('akihabara') || name.contains('akihabara')) {
      return const LocationOverviewDetails(
        title: 'Akihabara Electric Town',
        rating: 4.5,
        reviewCount: '26k',
        tags: ['Shopping', 'Anime & Tech', 'Subculture'],
        description:
            'Global hub for electronics, anime figurines, gaming arcades, and Japanese pop culture.',
        openHours: 'Open 10AM – 9PM',
        entryFee: 'Free access',
        proximity: '18 min\nfrom current location',
        whyGo: [
          'Multi-story retro arcade and crane game centers',
          'Vast selection of rare manga & collectible figures',
          'Dazzling neon billboards and themed specialty cafes',
        ],
      );
    } else if (id.contains('ginza') || name.contains('ginza')) {
      return const LocationOverviewDetails(
        title: 'Ginza Chuo-dori Shopping Street',
        rating: 4.6,
        reviewCount: '19k',
        tags: ['Shopping', 'Luxury', 'Architecture'],
        description:
            "Tokyo's premier high-end shopping district with glamorous department stores and flagship boutiques.",
        openHours: 'Open 10:30AM – 8PM',
        entryFee: 'Free access',
        proximity: '20 min\nfrom current location',
        whyGo: [
          'Pedestrian paradise on weekend afternoons',
          'Historic Ginza Wako clock tower facade',
          'World-class patisseries and depachika gourmet basements',
        ],
      );
    } else if (id.contains('roppongi') || name.contains('roppongi')) {
      return const LocationOverviewDetails(
        title: 'Roppongi Hills Sky Deck',
        rating: 4.6,
        reviewCount: '17k',
        tags: ['Landmark', 'Modern Art', 'Night Views'],
        description:
            'Integrated modern complex boasting premier panoramic sky decks and the renowned Mori Art Museum.',
        openHours: 'Open 10AM – 10PM',
        entryFee: '¥2,000 deck',
        proximity: '18 min\nfrom current location',
        whyGo: [
          'Stunning front-row view of the glowing Tokyo Tower',
          'Acclaimed contemporary exhibits at Mori Art Museum',
          'Iconic giant Maman spider outdoor sculpture',
        ],
      );
    } else if (id.contains('shinjuku_gyoen') || name.contains('gyoen')) {
      return const LocationOverviewDetails(
        title: 'Shinjuku Gyoen National Garden',
        rating: 4.7,
        reviewCount: '34k',
        tags: ['Nature', 'Imperial Garden', 'Peaceful'],
        description:
            'Expansive 144-acre oasis blending traditional Japanese landscape, English formal, and French gardens.',
        openHours: 'Open 9AM – 5:30PM',
        entryFee: '¥500 entry',
        proximity: '22 min\nfrom current location',
        whyGo: [
          'Immaculate classical Japanese ponds and bridges',
          'Quiet reflection away from bustling Shinjuku',
          'Historic Taiwan Pavilion overlooking the lake',
        ],
      );
    } else if (id.contains('omoide_yokocho') || name.contains('omoide')) {
      return const LocationOverviewDetails(
        title: 'Omoide Yokocho (Memory Lane)',
        rating: 4.5,
        reviewCount: '15k',
        tags: ['Nightlife', 'Yakitori', 'Izakaya'],
        description:
            'Nostalgic narrow alley packed with intimate yakitori taverns grilling over fragrant charcoal.',
        openHours: 'Open 5PM – Midnight',
        entryFee: 'Pay per order',
        proximity: '15 min\nfrom current location',
        whyGo: [
          'Smoky charcoal-grilled yakitori skewers',
          'Intimate 6-seat traditional izakaya counters',
          'Authentic vintage post-war Tokyo atmosphere',
        ],
      );
    } else if (id.contains('tokyo_station') || name.contains('tokyo station')) {
      return const LocationOverviewDetails(
        title: 'Tokyo Station Marunouchi',
        rating: 4.7,
        reviewCount: '36k',
        tags: ['Architecture', 'Historic Landmark', 'Railway'],
        description:
            'Splendid red-brick station palace built in 1914, blending European elegance with Japanese majesty.',
        openHours: 'Open 24 Hours',
        entryFee: 'Free access',
        proximity: '22 min\nfrom current location',
        whyGo: [
          'Gorgeous restored 1914 red-brick Renaissance facade',
          'Underground Tokyo Character Street & Ramen Street',
          'Spectacular Marunouchi square illuminated at dusk',
        ],
      );
    }

    // Default fallback based on place properties
    final tagList = <String>[];
    if (place.category != null) tagList.add(place.category!);
    if (place.tag != null && !place.tag!.startsWith('⏱️') && !place.tag!.startsWith('⚡')) {
      tagList.add(place.tag!.replaceAll(RegExp(r'^[^\w\s]+'), '').trim());
    }
    if (tagList.isEmpty) {
      tagList.addAll(['Sightseeing', 'Tokyo Spot']);
    }

    return LocationOverviewDetails(
      title: place.name,
      rating: 4.6,
      reviewCount: '14k',
      tags: tagList,
      description:
          'A featured highlight in your Tokyo journey offering authentic local sights and memorable cultural flavors.',
      openHours: 'Open ${place.time} – 6PM',
      entryFee: place.category == 'Lunch' || place.category == 'Dinner'
          ? 'Pay per order'
          : 'Free entry',
      proximity: place.walkTime.isNotEmpty
          ? '${place.walkTime}\nfrom current location'
          : '15 min\nfrom current location',
      whyGo: [
        'Curated landmark on your route',
        'Exceptional local ambiance and photography',
        if (place.specialtyDish != null)
          'Taste: ${place.specialtyDish!}'
        else
          'Immerse in Tokyo cultural highlights',
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;

    // Sheet height ~86% of screen height
    final sheetHeight = screenHeight * 0.86;
    final heroImageHeight = sheetHeight * 0.38;

    return Container(
      height: sheetHeight,
      decoration: const BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: Stack(
          children: [
            // 1. TOP HERO IMAGE
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: heroImageHeight + 20, // Extra overlap underneath sheet
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    place.imageAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, st) {
                      return Container(
                        color: const Color(0xFF3E2723),
                        child: const Center(
                          child: Icon(
                            Icons.landscape_rounded,
                            size: 64,
                            color: Color(0xFFD7CCC8),
                          ),
                        ),
                      );
                    },
                  ),
                  // Subtle top gradient scrim for close button visibility
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.35),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. FLOATING CLOSE BUTTON (Top Right)
            Positioned(
              top: 16,
              right: 18,
              child: SafeArea(
                top: false,
                child: Material(
                  color: Colors.white.withValues(alpha: 0.92),
                  shape: const CircleBorder(),
                  elevation: 4,
                  shadowColor: const Color(0xFF2E1C14).withValues(alpha: 0.25),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: Color(0xFF231815),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 3. BOTTOM INFORMATION SHEET (Rounded top corners overlapping hero photo)
            Positioned.fill(
              top: heroImageHeight - 16,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFDF9),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1F2E1C14),
                      blurRadius: 18,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Pull Handle Indicator
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 6),
                        width: 38,
                        height: 4.2,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDFD4C8),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),

                    // Scrollable Information Content
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(22, 10, 22, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title & Rating Row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    details.title,
                                    style: GoogleFonts.fredoka(
                                      fontSize: 23,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF231815),
                                      height: 1.15,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFF0E5D8),
                                      width: 1.0,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF2E1C14).withValues(alpha: 0.04),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        size: 19,
                                        color: Color(0xFFF59E0B),
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        details.rating.toStringAsFixed(1),
                                        style: GoogleFonts.fredoka(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF231815),
                                        ),
                                      ),
                                      const SizedBox(width: 3.5),
                                      Text(
                                        '(${details.reviewCount})',
                                        style: GoogleFonts.fredoka(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF9E8E82),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // Category / Tag Chips
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: details.tags.map((tag) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 5.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFEFE6),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFFFD8C2),
                                      width: 0.9,
                                    ),
                                  ),
                                  child: Text(
                                    tag,
                                    style: GoogleFonts.fredoka(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFE65100),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 14),

                            // Brief Description
                            Text(
                              details.description,
                              style: GoogleFonts.fredoka(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF5C4E46),
                                height: 1.42,
                              ),
                            ),

                            const SizedBox(height: 18),

                            // Quick Info Box (2 items in a rounded light card)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7EF),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFF3E7DC),
                                  width: 1.1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // 1. Open hours
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(7),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE65100).withValues(alpha: 0.10),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.access_time_rounded,
                                            size: 17,
                                            color: Color(0xFFE65100),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            details.openHours,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.fredoka(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF4A3E38),
                                              height: 1.2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Divider
                                  Container(
                                    width: 1,
                                    height: 28,
                                    color: const Color(0xFFEADFD3),
                                  ),

                                  // 2. Entry Fee
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(7),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE65100).withValues(alpha: 0.10),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.confirmation_number_outlined,
                                            size: 17,
                                            color: Color(0xFFE65100),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            details.entryFee,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.fredoka(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF4A3E38),
                                              height: 1.2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 22),

                            // "Why go?" Section
                            Text(
                              'Why go?',
                              style: GoogleFonts.fredoka(
                                fontSize: 17.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF231815),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Bullet Checklist with green checkmarks
                            ...details.whyGo.map((item) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 9.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 1.5),
                                      child: Icon(
                                        Icons.check_rounded,
                                        size: 19,
                                        color: Color(0xFF16A34A),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        item,
                                        style: GoogleFonts.fredoka(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF4A3E38),
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),

                            const SizedBox(height: 20),
                          ],
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
  }
}
