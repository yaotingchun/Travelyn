import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/realistic_push_pin.dart';

/// Model representing a journal scrapbook memory entry.
class _DiaryMemoryItem {
  final String title;
  final String time;
  final String location;
  final String imageAsset;
  final String note;
  final String stamp;
  final double tilt;
  final Color washiColor;

  const _DiaryMemoryItem({
    required this.title,
    required this.time,
    required this.location,
    required this.imageAsset,
    required this.note,
    required this.stamp,
    required this.tilt,
    required this.washiColor,
  });
}

/// Tab 3: Diary Tab (Travel Journal, Notes & Photo Memories)
///
/// Implements an emotional travel scrapbook diary showcasing:
/// - Nostalgic Tokyo scrapbook header & journey route summary
/// - Milestone stats (places visited, photos snapped, footsteps walked, joy rating)
/// - Daily memories album with vintage Polaroids, washi tape, and handwritten notes
/// - Interactive tap-to-inspect on every Polaroid memory
/// - Trippy's heartfelt handwritten farewell note with 3D pushpin
class DiaryTab extends StatelessWidget {
  final String destination;
  final String? tripType;
  final DateTime? startDate;
  final DateTime? endDate;
  final Color brandOrange;
  final Color darkBrown;
  final Color textMuted;

  const DiaryTab({
    super.key,
    this.destination = 'Tokyo, Japan',
    this.tripType = 'Group Trip',
    this.startDate,
    this.endDate,
    this.brandOrange = const Color(0xFFE65100),
    this.darkBrown = const Color(0xFF2E1C14),
    this.textMuted = const Color(0xFF6B5A50),
  });

  static const List<_DiaryMemoryItem> _memories = [
    _DiaryMemoryItem(
      title: 'Chatei Hatou (茶亭 羽當)',
      time: '08:30 AM • Day 1',
      location: 'Shibuya, Tokyo',
      imageAsset: 'assets/journey/food_french_toast_cafe.jpg',
      note:
          'Warm siphon coffee & fluffy chiffon toast to start our adventure. The aroma of roasted beans filled the quiet morning alley. ☕🍰',
      stamp: 'Morning Coffee 🥐',
      tilt: -0.015,
      washiColor: Color(0xFFE2C4A2),
    ),
    _DiaryMemoryItem(
      title: 'Meiji Shrine & Yoyogi Forest',
      time: '09:25 AM • Day 1',
      location: 'Yoyogi, Shibuya',
      imageAsset: 'assets/journey/place_meiji_shrine.jpg',
      note:
          'Walking among towering cedar trees felt sacred and peaceful. We made a silent wish at the main hall together and watched the morning sunlight filter through the forest. ⛩️🌲',
      stamp: 'Sacred Forest 🌿',
      tilt: 0.02,
      washiColor: Color(0xFFF3B4A2),
    ),
    _DiaryMemoryItem(
      title: 'Takeshita Street, Harajuku',
      time: '11:35 AM • Day 1',
      location: 'Harajuku, Tokyo',
      imageAsset: 'assets/journey/place_harajuku.jpg',
      note:
          'Marion sweet crepes overflowing with fresh strawberries & whipped cream! The vibrant boutiques and colorful crowds were bursting with energy. 🍓👗',
      stamp: 'Harajuku Vibe 🛍️',
      tilt: -0.02,
      washiColor: Color(0xFFD4BCE0),
    ),
    _DiaryMemoryItem(
      title: 'AFURI Harajuku (Yuzu Shio Ramen)',
      time: '12:15 PM • Day 1',
      location: 'Harajuku, Tokyo',
      imageAsset: 'assets/journey/food_yuzu_ramen.jpg',
      note:
          'The golden citrus broth was unmatched! Everyone agreed this was the best ramen stop of the entire trip. Smoky charcoal-grilled chashu that melted in our mouths. 🍜✨',
      stamp: 'Top Dish ⭐',
      tilt: 0.025,
      washiColor: Color(0xFFBCE0D4),
    ),
    _DiaryMemoryItem(
      title: 'Shibuya Scramble & Hachiko',
      time: '01:20 PM • Day 1',
      location: 'Shibuya Crossing',
      imageAsset: 'assets/journey/place_shibuya.jpg',
      note:
          'Stepped right into the neon heartbeat of Tokyo! We ran across the world’s busiest crosswalk together and patted the loyal Hachiko statue. 🌆🐕',
      stamp: 'Tokyo Icon 🎌',
      tilt: -0.018,
      washiColor: Color(0xFFF0A89C),
    ),
    _DiaryMemoryItem(
      title: 'teamLab Planets Tokyo',
      time: '03:10 PM • Day 1',
      location: 'Toyosu, Koto City',
      imageAsset: 'assets/journey/place_teamlab.jpg',
      note:
          'Wading barefoot through knee-deep water into an infinite crystal universe. It truly felt like stepping through the stars in a dream. 🔮🌌',
      stamp: 'Pure Magic ✨',
      tilt: 0.015,
      washiColor: Color(0xFFC7D9EC),
    ),
    _DiaryMemoryItem(
      title: 'Toyosu Banrai Waterfront Feast',
      time: '05:15 PM • Day 1',
      location: 'Toyosu Waterfront',
      imageAsset: 'assets/journey/food_toyosu_hawker.jpg',
      note:
          'Toasted with cold draft beer, grilled scallop skewers, and warm yakitori as the sunset painted Tokyo Bay in amber and gold. The perfect finale to Day 1! 🏮🍢🍻',
      stamp: 'Grand Finale 🏮',
      tilt: -0.022,
      washiColor: Color(0xFFE2B78D),
    ),
  ];

  void _showMemoryDetail(BuildContext context, _DiaryMemoryItem item) {
    HapticFeedback.selectionClick();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 28),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFEDE3D7), width: 1.4),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E1C14).withValues(alpha: 0.22),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4CDC5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title & Stamp
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: GoogleFonts.fredoka(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              color: darkBrown,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.time} • ${item.location}',
                            style: GoogleFonts.fredoka(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF3EB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFFE5D7C6), width: 1),
                      ),
                      child: Text(
                        item.stamp,
                        style: GoogleFonts.fredoka(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: brandOrange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Photo
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Image.asset(
                      item.imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        color: const Color(0xFFEAE0D4),
                        child: const Icon(Icons.image,
                            size: 40, color: Colors.white70),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Note card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF4ED),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE8DCCF), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_stories_rounded,
                              size: 16, color: Color(0xFFE65100)),
                          const SizedBox(width: 6),
                          Text(
                            'Journal Note',
                            style: GoogleFonts.fredoka(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: brandOrange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.note,
                        style: GoogleFonts.fredoka(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF3E2C22),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkBrown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Close Memory 🌸',
                      style: GoogleFonts.fredoka(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title: Polaroid Memories
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('📸', style: TextStyle(fontSize: 19)),
                  const SizedBox(width: 8),
                  Text(
                    'Tokyo Memories & Polaroids',
                    style: GoogleFonts.fredoka(
                      fontSize: 18.5,
                      fontWeight: FontWeight.w700,
                      color: darkBrown,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: brandOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_memories.length} Highlights',
                  style: GoogleFonts.fredoka(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: brandOrange,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 5. Polaroid Memory Cards Stream
          ..._memories.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildPolaroidCard(context, item),
            );
          }),

          const SizedBox(height: 10),

          // 6. Trippy's Pinned Handwritten Letter
          _buildTrippyLetterCard(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPolaroidCard(BuildContext context, _DiaryMemoryItem item) {
    return Transform.rotate(
      angle: item.tilt,
      child: GestureDetector(
        onTap: () => _showMemoryDetail(context, item),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEDE3D7), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: darkBrown.withValues(alpha: 0.10),
                blurRadius: 14,
                offset: const Offset(1, 5),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Washi tape in top-right
              Positioned(
                top: -8,
                right: 18,
                child: Transform.rotate(
                  angle: 0.22,
                  child: Container(
                    width: 55,
                    height: 18,
                    decoration: BoxDecoration(
                      color: item.washiColor.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: AspectRatio(
                        aspectRatio: 16 / 10,
                        child: Image.asset(
                          item.imageAsset,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            color: const Color(0xFFEAE0D4),
                            child: const Icon(Icons.photo,
                                size: 36, color: Colors.white70),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Title & Stamp row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.fredoka(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: darkBrown,
                                ),
                              ),
                              Text(
                                item.time,
                                style: GoogleFonts.fredoka(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF3EB),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: const Color(0xFFE5D7C6), width: 0.8),
                          ),
                          child: Text(
                            item.stamp,
                            style: GoogleFonts.fredoka(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: brandOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Handwritten note caption
                    Text(
                      item.note,
                      style: GoogleFonts.fredoka(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF4A382D),
                        height: 1.35,
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

  Widget _buildTrippyLetterCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEBE0D2), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: darkBrown.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(
            top: -10,
            right: 16,
            child: RealisticPushPin(size: 24),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🦊', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Text(
                      'Trippy\'s Farewell Note',
                      style: GoogleFonts.fredoka(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: darkBrown,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '"Every single step in Tokyo was filled with warmth, smiles, and wonder. Keep this scrapbook close — the world has many more roads waiting for us! 🌸✨"',
                  style: GoogleFonts.fredoka(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFF5A4438),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '~ Trippy & the Explorers 🌸🐾',
                      style: GoogleFonts.fredoka(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: brandOrange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
