import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/mock_explorer_data.dart';
import '../models/explorer_country.dart';
import '../widgets/country_detail_sheet.dart';
import '../widgets/map_legend.dart';
import '../widgets/vintage_world_map.dart';

/// Dedicated full-screen explorer world map and country directory screen.
class ExploredMapPage extends StatefulWidget {
  const ExploredMapPage({super.key});

  @override
  State<ExploredMapPage> createState() => _ExploredMapPageState();
}

class _ExploredMapPageState extends State<ExploredMapPage> {
  int _selectedFilterIndex = 0; // 0: All, 1: Explored, 2: Wishlist
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ExplorerCountry> get _filteredCountries {
    final list = MockExplorerData.countries.where((c) {
      if (_selectedFilterIndex == 1 && !c.isExplored) return false;
      if (_selectedFilterIndex == 2 && !c.isWishlist) return false;
      if (_searchQuery.isNotEmpty) {
        return c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.code.toLowerCase().contains(_searchQuery.toLowerCase());
      }
      return true;
    }).toList();

    return list;
  }

  @override
  Widget build(BuildContext context) {
    const darkBrown = Color(0xFF2E1C14);
    const textMuted = Color(0xFF7A6860);
    const brandOrange = Color(0xFFE87516);

    final exploredCount = MockExplorerData.exploredCountries.length;
    final wishlistCount = MockExplorerData.wishlistCountries.length;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF7F0),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: darkBrown, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'My Explored World',
          style: GoogleFonts.fredoka(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: darkBrown,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF2E6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFEAD8C4),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    const Text('🗺️', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$exploredCount Countries Explored Across the Globe',
                            style: GoogleFonts.fredoka(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: brandOrange,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tap on any country or marker to view trip highlights and travel memories.',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: darkBrown,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Interactive Vintage Map Container
              VintageWorldMap(
                countries: MockExplorerData.countries,
                height: 250,
                onCountryTap: (country) {
                  CountryDetailSheet.show(
                    context,
                    country: country,
                  );
                },
              ),
              const SizedBox(height: 10),
              const MapLegend(),
              const SizedBox(height: 20),

              // Filter Tabs (All / Explored / Wishlist)
              Row(
                children: [
                  _buildFilterTab(0, 'All (${MockExplorerData.countries.length})'),
                  const SizedBox(width: 8),
                  _buildFilterTab(1, 'Explored ($exploredCount)'),
                  const SizedBox(width: 8),
                  _buildFilterTab(2, 'Wishlist ($wishlistCount)'),
                ],
              ),
              const SizedBox(height: 16),

              // Search Bar
              TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim();
                  });
                },
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: darkBrown,
                ),
                decoration: InputDecoration(
                  hintText: 'Search countries...',
                  hintStyle: GoogleFonts.nunito(
                    color: textMuted.withValues(alpha: 0.6),
                  ),
                  prefixIcon: const Icon(Icons.search_rounded,
                      size: 20, color: Color(0xFF8D6E63)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                        color: Color(0xFFEDE4DA), width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                        color: Color(0xFFE87516), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Countries List Cards
              ..._filteredCountries.map((country) => _buildCountryCard(country)),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTab(int index, String label) {
    final isSelected = _selectedFilterIndex == index;
    const brandOrange = Color(0xFFE87516);
    const darkBrown = Color(0xFF2E1C14);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilterIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFAF4EA) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? brandOrange : const Color(0xFFEADBCE),
              width: isSelected ? 1.4 : 1.0,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.fredoka(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? brandOrange : (darkBrown.withValues(alpha: 0.7)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountryCard(ExplorerCountry country) {
    const darkBrown = Color(0xFF2E1C14);
    const textMuted = Color(0xFF7A6860);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: country.isExplored
              ? const Color(0xFFFFD54F).withValues(alpha: 0.6)
              : const Color(0xFFEDE4DA),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E1C14).withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => CountryDetailSheet.show(context, country: country),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Flag
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF3E8),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE8DAC9),
                      width: 1.0,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      country.flag,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name & Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            country.name,
                            style: GoogleFonts.fredoka(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: darkBrown,
                            ),
                          ),
                          _buildCardBadge(country.status),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        country.isExplored
                            ? '${country.visitCount} Trips • ${country.placesVisited} Places • ${country.lastVisitedDate}'
                            : (country.note ?? 'Explore next adventure'),
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: Color(0xFFBCAAA4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardBadge(CountryStatus status) {
    if (status == CountryStatus.explored) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE0B2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Explored',
          style: GoogleFonts.fredoka(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFE65100),
          ),
        ),
      );
    } else if (status == CountryStatus.wishlist) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Wishlist',
          style: GoogleFonts.fredoka(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFF57F17),
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F3EF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Someday',
          style: GoogleFonts.fredoka(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF8D6E63),
          ),
        ),
      );
    }
  }
}
