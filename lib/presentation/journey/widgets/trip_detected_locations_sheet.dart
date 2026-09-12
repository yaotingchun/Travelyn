import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../trip_places_input_screen.dart';

/// Modal bottom sheet displaying all locations detected from a member-shared link or reel.
class TripDetectedLocationsSheet extends StatelessWidget {
  final MemberSharedLink link;

  const TripDetectedLocationsSheet({
    super.key,
    required this.link,
  });

  /// Displays the detected locations bottom sheet with smooth transition.
  static Future<void> show(
    BuildContext context, {
    required MemberSharedLink link,
  }) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0xFF231815).withValues(alpha: 0.45),
      builder: (ctx) => TripDetectedLocationsSheet(link: link),
    );
  }

  static String? _getAssetForLocation(String locationName) {
    final lower = locationName.toLowerCase();
    if (lower.contains('zingaro') || lower.contains('cafe') || lower.contains('café')) {
      return 'assets/journey/food_french_toast_cafe.jpg';
    } else if (lower.contains('nakano') || lower.contains('broadway')) {
      return 'assets/journey/place_harajuku.jpg';
    } else if (lower.contains('station')) {
      return 'assets/journey/place_tokyo_station.jpg';
    } else if (lower.contains('shibuya sky')) {
      return 'assets/journey/place_shibuya_sky.jpg';
    } else if (lower.contains('roppongi') || lower.contains('tower')) {
      return 'assets/journey/place_tokyo_tower.jpg';
    } else if (lower.contains('miyashita') || lower.contains('shibuya')) {
      return 'assets/journey/place_shibuya.jpg';
    } else if (lower.contains('teamlab')) {
      return 'assets/journey/place_teamlab.jpg';
    } else if (lower.contains('tsukiji')) {
      return 'assets/journey/food_tsukiji_sashimi.jpg';
    } else if (lower.contains('omoide')) {
      return 'assets/journey/food_omoide_yokocho.jpg';
    } else if (lower.contains('ramen') || lower.contains('fuunji')) {
      return 'assets/journey/food_tonkotsu_ramen.jpg';
    } else if (lower.contains('matcha') || lower.contains('dessert') || lower.contains('teahouse')) {
      return 'assets/journey/food_matcha_dango.jpg';
    } else if (lower.contains('temple') || lower.contains('shrine') || lower.contains('senso') || lower.contains('kinkaku')) {
      return 'assets/journey/place_sensoji.jpg';
    } else if (lower.contains('market') || lower.contains('nishiki')) {
      return 'assets/journey/food_ameyoko_stalls.jpg';
    } else if (lower.contains('bamboo') || lower.contains('arashiyama') || lower.contains('scenic') || lower.contains('pagoda')) {
      return 'assets/journey/tokyo_pagoda_blossom.jpg';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const darkBrown = Color(0xFF231815);
    const textMuted = Color(0xFF8A786E);
    const sunsetOrange = Color(0xFFFF6422);
    final isUser = link.memberName == 'You';

    final platformLabel = link.platform == 'instagram'
        ? 'Instagram Reel'
        : link.platform == 'rednote'
            ? 'RedNote Post'
            : 'Google Maps';

    final platformColor = link.platform == 'instagram'
        ? const Color(0xFFE1306C)
        : link.platform == 'rednote'
            ? const Color(0xFFFF2442)
            : const Color(0xFF1A73E8);

    final locations = link.detectedLocations.isNotEmpty
        ? link.detectedLocations
        : [link.title];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFBF7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x33231815),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            // Grab handle
            Center(
              child: Container(
                width: 42,
                height: 4.5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6C8BC),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Row: Creator info + Close 'X' button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar with platform badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: darkBrown.withValues(alpha: 0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            link.avatarPath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.person,
                              color: Color(0xFF8A786E),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: platformColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Center(
                            child: Icon(
                              link.platform == 'instagram'
                                  ? Icons.camera_alt_rounded
                                  : link.platform == 'rednote'
                                      ? Icons.bookmark_rounded
                                      : Icons.location_on_rounded,
                              size: 11,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),

                  // Member name & source metadata
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              isUser ? 'Shared by You' : 'Shared by ${link.memberName}',
                              style: GoogleFonts.fredoka(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: darkBrown,
                              ),
                            ),
                            if (isUser) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color: sunsetOrange.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'You',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: sunsetOrange,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$platformLabel${link.timeAgo != null ? ' · ${link.timeAgo}' : ''}',
                          style: GoogleFonts.fredoka(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Close Button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2ECE4),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE4DAD0),
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: darkBrown,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Link Source Card / Title Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEFE8E0)),
                  boxShadow: [
                    BoxShadow(
                      color: darkBrown.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      link.title,
                      style: GoogleFonts.fredoka(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: darkBrown,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: sunsetOrange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            size: 13,
                            color: sunsetOrange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${locations.length} spots detected',
                            style: GoogleFonts.fredoka(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: sunsetOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Section Header: "Detected Locations"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Detected Locations',
                      style: GoogleFonts.fredoka(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        color: darkBrown,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2ECE4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${locations.length} spots',
                      style: GoogleFonts.fredoka(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Scrollable list of detected locations
            Flexible(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: locations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final spotName = locations[index];
                  final assetPath = _getAssetForLocation(spotName);

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFECE4D9)),
                      boxShadow: [
                        BoxShadow(
                          color: darkBrown.withValues(alpha: 0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Spot photo thumbnail or styled number pin
                        if (assetPath != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              assetPath,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildPinBadge(index + 1),
                            ),
                          )
                        else
                          _buildPinBadge(index + 1),

                        const SizedBox(width: 14),

                        // Spot Name and tags
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                spotName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.fredoka(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  color: darkBrown,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.place_rounded,
                                    size: 13,
                                    color: sunsetOrange,
                                  ),
                                  const SizedBox(width: 3),
                                  Flexible(
                                    child: Text(
                                      'Spot #${index + 1} from link',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.fredoka(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: textMuted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // "Included" badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 14,
                                color: Color(0xFF2E7D32),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Included',
                                style: GoogleFonts.fredoka(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2E7D32),
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

            // Bottom CTA Button: "Got it"
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sunsetOrange,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Got it',
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinBadge(int number) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0E6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFDEC9),
          width: 1.2,
        ),
      ),
      child: Center(
        child: Text(
          '$number',
          style: GoogleFonts.fredoka(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFFF6422),
          ),
        ),
      ),
    );
  }
}
