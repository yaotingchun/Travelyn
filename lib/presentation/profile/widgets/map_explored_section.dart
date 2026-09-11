import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/explorer_country.dart';
import 'country_detail_sheet.dart';
import 'map_legend.dart';
import 'vintage_world_map.dart';

/// Section component containing the "✦ Map Explored" header, interactive vintage pirate treasure map,
/// and map state legend.
class MapExploredSection extends StatelessWidget {
  final List<ExplorerCountry> countries;
  final VoidCallback onViewAllCountriesTap;
  final ValueChanged<ExplorerCountry>? onCountryTap;

  const MapExploredSection({
    super.key,
    required this.countries,
    required this.onViewAllCountriesTap,
    this.onCountryTap,
  });

  @override
  Widget build(BuildContext context) {
    const darkBrown = Color(0xFF2E1C14);
    const brandOrange = Color(0xFFE87516);
    const textMuted = Color(0xFF7A6860);

    final exploredCount =
        countries.where((c) => c.status == CountryStatus.explored).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header Row: "✦ Map Explored" and "12 Countries >"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  const Text(
                    '✦',
                    style: TextStyle(
                      color: brandOrange,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Map Explored',
                    style: GoogleFonts.fredoka(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: darkBrown,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onViewAllCountriesTap,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$exploredCount Countries',
                        style: GoogleFonts.fredoka(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: textMuted,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: textMuted,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Vintage Pirate Treasure World Map Card
          VintageWorldMap(
            countries: countries,
            height: 220,
            onCountryTap: (country) {
              CountryDetailSheet.show(
                context,
                country: country,
                onViewJourneyTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Opening journeys for ${country.name}... ✈️',
                        style:
                            GoogleFonts.fredoka(fontWeight: FontWeight.w600),
                      ),
                      backgroundColor: brandOrange,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                onAddToWishlistTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Added ${country.name} to your travel wishlist! ✨',
                        style:
                            GoogleFonts.fredoka(fontWeight: FontWeight.w600),
                      ),
                      backgroundColor: const Color(0xFFD8A24A),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              );
              onCountryTap?.call(country);
            },
          ),
          const SizedBox(height: 10),

          // Map Legend (Explored / Wishlist / Someday)
          const MapLegend(),
        ],
      ),
    );
  }
}
