import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/mock_explorer_data.dart';
import '../data/mock_profile_data.dart';
import '../models/explorer_country.dart';
import '../models/user_profile.dart';
import '../widgets/achievements_section.dart';
import '../widgets/explorer_level_card.dart';
import '../widgets/explorer_profile_header.dart';
import '../widgets/map_explored_section.dart';
import '../widgets/travel_dna_card.dart';
import '../widgets/trippy_insight_card.dart';
import 'achievements_page.dart';
import 'edit_profile_page.dart';
import 'explored_map_page.dart';
import 'notification_settings_page.dart';
import 'settings_page.dart';
import 'travel_insights_page.dart';
import 'travel_preferences_page.dart';

/// Redesigned "Me" tab delivering an immersive "My Explorer Passport" experience for Travelyn.
///
/// Hierarchy:
/// 1. Immersive Profile Header (Hero banner, overlapping avatar, notifications & settings)
/// 2. Explorer Statistics (Trips, Saved, Countries)
/// 3. Explorer Level / Journey Progress (Wanderer Level 3, animated XP bar, Globetrotter goal)
/// 4. Map Explored (Vintage pirate treasure map, highlighted explored & wishlist countries, legend)
/// 5. Travel DNA / Travel Preferences Section
/// 6. Travel Insights / Trippy Knows You AI Card
/// 7. My Achievements (Horizontally scrollable passport stamps & "View All →")
class MePage extends StatefulWidget {
  const MePage({super.key});

  @override
  State<MePage> createState() => _MePageState();
}

class _MePageState extends State<MePage> with SingleTickerProviderStateMixin {
  UserProfile _profile = MockExplorerData.defaultProfile;
  List<ExplorerCountry> _countries = List.from(MockExplorerData.countries);

  String _appLanguage = 'English';
  String _appCurrency = 'MYR (RM)';

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _profile = MockExplorerData.defaultProfile;
    _countries = List.from(MockExplorerData.countries);
    _appLanguage = _profile.preferredLanguage;
    _appCurrency = '${_profile.currency} (RM)';

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(
          profile: _profile,
          currentLanguage: _appLanguage,
          currentCurrency: _appCurrency,
          onProfileUpdated: (updated) {
            setState(() {
              _profile = updated;
            });
          },
          onLanguageUpdated: (lang) {
            setState(() {
              _appLanguage = lang;
            });
          },
          onCurrencyUpdated: (curr) {
            setState(() {
              _appCurrency = curr;
            });
          },
        ),
      ),
    );
  }

  void _navigateToNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationSettingsPage(),
      ),
    );
  }

  void _navigateToEditProfile() async {
    final updated = await Navigator.push<UserProfile>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          profile: _profile,
          onProfileSaved: (p) {
            setState(() {
              _profile = p;
            });
          },
        ),
      ),
    );

    if (updated != null) {
      setState(() {
        _profile = updated;
      });
    }
  }

  void _navigateToExploredMapPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ExploredMapPage(),
      ),
    );
  }

  void _navigateToTravelPreferences() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TravelPreferencesPage(),
      ),
    );
  }

  void _navigateToTravelInsights() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TravelInsightsPage(),
      ),
    );
  }

  void _navigateToAchievements() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AchievementsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F0),
      body: SafeArea(
        top: false,
        bottom: false,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SECTION 1 & 2: Immersive Profile Header with Integrated 3-Stat Row
                  ExplorerProfileHeader(
                    name: _profile.name,
                    tagline: _profile.bio,
                    avatarAsset: _profile.avatarPath,
                    heroBannerAsset: MockExplorerData.heroBannerAsset,
                    tripsCount: MockExplorerData.tripsCount,
                    savedCount: MockExplorerData.savedCount,
                    countriesCount: MockExplorerData.countriesCount,
                    onNotificationTap: _navigateToNotifications,
                    onSettingsTap: _navigateToSettings,
                    onEditProfileTap: _navigateToEditProfile,
                    onTripsTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '18 completed journeys in your passport! 🧳',
                            style: GoogleFonts.fredoka(fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: const Color(0xFFE87516),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    onSavedTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '47 bucket list spots saved for future trips! 🔖',
                            style: GoogleFonts.fredoka(fontWeight: FontWeight.w600),
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
                    onCountriesTap: _navigateToExploredMapPage,
                  ),
                  const SizedBox(height: 18),

                  // SECTION 3: Explorer Level & Progress Card
                  ExplorerLevelCard(
                    rank: MockExplorerData.explorerRank,
                    level: MockExplorerData.currentLevel,
                    currentXp: MockExplorerData.currentXp,
                    maxXp: MockExplorerData.maxXp,
                    nextRank: MockExplorerData.nextRank,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '800 XP remaining to unlock Globetrotter status! 🧭',
                            style: GoogleFonts.fredoka(fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: const Color(0xFFE87516),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  // SECTION 4: Map Explored (Vintage Pirate Treasure Map)
                  MapExploredSection(
                    countries: _countries,
                    onViewAllCountriesTap: _navigateToExploredMapPage,
                  ),
                  const SizedBox(height: 28),

                  // SECTION 5: Travel Preferences (Travel DNA Card)
                  TravelDnaCard(
                    dimensions: MockProfileData.dnaDimensions,
                    highlightTags: MockProfileData.dnaHighlightTags,
                    onEditPreferencesTap: _navigateToTravelPreferences,
                  ),
                  const SizedBox(height: 28),

                  // SECTION 6: Travel Insights (Trippy Knows You AI Card)
                  TrippyInsightCard(
                    quote: MockProfileData.trippyQuote,
                    onSeeInsightsTap: _navigateToTravelInsights,
                  ),
                  const SizedBox(height: 28),

                  // SECTION 7: My Achievements (Circular Stamps Carousel)
                  AchievementsSection(
                    badges: MockExplorerData.badges,
                    onViewAllTap: _navigateToAchievements,
                    onBadgeTap: (badge) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${badge.icon} ${badge.title} — ${badge.requirement} (${badge.isUnlocked ? "Unlocked ✨" : "${(badge.progress * 100).toInt()}% in progress"})',
                            style: GoogleFonts.fredoka(fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: const Color(0xFF5D4037),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                  ),

                  // Bottom padding ensuring no overlap with floating bottom nav bar
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
