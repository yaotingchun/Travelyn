import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/explorer_country.dart';

/// Elegant bottom sheet modal showing exploration details, trip counts, or wishlist status for a country.
class CountryDetailSheet extends StatelessWidget {
  final ExplorerCountry country;
  final VoidCallback? onViewJourneyTap;
  final VoidCallback? onAddToWishlistTap;

  const CountryDetailSheet({
    super.key,
    required this.country,
    this.onViewJourneyTap,
    this.onAddToWishlistTap,
  });

  static Future<void> show(
    BuildContext context, {
    required ExplorerCountry country,
    VoidCallback? onViewJourneyTap,
    VoidCallback? onAddToWishlistTap,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CountryDetailSheet(
        country: country,
        onViewJourneyTap: onViewJourneyTap,
        onAddToWishlistTap: onAddToWishlistTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const darkBrown = Color(0xFF2E1C14);
    const textMuted = Color(0xFF7A6860);
    const brandOrange = Color(0xFFE87516);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFDF7F0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Grabber Pill
            Center(
              child: Container(
                width: 40,
                height: 4.5,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCC8B4),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Country Header (Flag, Name, Status Badge)
            Row(
              children: [
                // Flag Container
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF2E6),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE5D5C2),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2E1C14).withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      country.flag,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Name & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              country.name,
                              style: GoogleFonts.fredoka(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: darkBrown,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusBadge(country.status),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        country.isExplored
                            ? 'Passport Stamp Verified'
                            : (country.isWishlist
                                ? 'On your bucket list'
                                : 'Uncharted territory'),
                        style: GoogleFonts.nunito(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Explored Specific Stats Card
            if (country.isExplored) ...[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7EFE2),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFEADBCE),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('🧳', '${country.visitCount} Trips', 'Completed'),
                    Container(width: 1, height: 32, color: const Color(0xFFDCC8B4)),
                    _buildStatItem('📍', '${country.placesVisited} Places', 'Visited'),
                    Container(width: 1, height: 32, color: const Color(0xFFDCC8B4)),
                    _buildStatItem('🗓️', country.lastVisitedDate ?? '2025', 'Last Trip'),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Note / Memory preview
            if (country.note != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFEDE2D5),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💭', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        country.note!,
                        style: GoogleFonts.nunito(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4E342E),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Primary Action Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (country.isExplored) {
                    onViewJourneyTap?.call();
                  } else {
                    onAddToWishlistTap?.call();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: country.isExplored
                      ? brandOrange
                      : (country.isWishlist
                          ? const Color(0xFFD8A24A)
                          : const Color(0xFF5D4037)),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      country.isExplored
                          ? 'View Journey →'
                          : (country.isWishlist
                              ? 'Plan Trip with Trippy ✨'
                              : 'Add to Wishlist 🔖'),
                      style: GoogleFonts.fredoka(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
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

  Widget _buildStatusBadge(CountryStatus status) {
    Color bg;
    Color text;
    String label;

    switch (status) {
      case CountryStatus.explored:
        bg = const Color(0xFFFFE0B2);
        text = const Color(0xFFE65100);
        label = 'Explored';
        break;
      case CountryStatus.wishlist:
        bg = const Color(0xFFFFF8E1);
        text = const Color(0xFFF57F17);
        label = 'Wishlist ✨';
        break;
      case CountryStatus.someday:
        bg = const Color(0xFFEFEBE9);
        text = const Color(0xFF5D4037);
        label = 'Someday';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: GoogleFonts.fredoka(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }

  Widget _buildStatItem(String emoji, String title, String subtitle) {
    return Column(
      children: [
        Text(
          '$emoji $title',
          style: GoogleFonts.fredoka(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2E1C14),
          ),
        ),
        const SizedBox(height: 1),
        Text(
          subtitle,
          style: GoogleFonts.nunito(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF8D6E63),
          ),
        ),
      ],
    );
  }
}
